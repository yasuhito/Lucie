class Installer
  @@plugin_names = []


  def self.install node
    install = Install.new( node, :new )
    install.run
    return install
  end


  def self.plugin(plugin_name)
    @@plugin_names << plugin_name unless RAILS_ENV == 'test' or @@plugin_names.include? plugin_name
  end


  def self.read dir, load_config = true
    @installer_in_the_works = Installer.new( File.basename( dir ) )
    begin
      if load_config
        @installer_in_the_works.load_config
      end
      return @installer_in_the_works
    ensure
      @installer_in_the_works = nil
    end
  end


  attr_accessor :scheduler
  attr_accessor :source_control
  attr_reader :build_command
  attr_reader :config_file_content
  attr_reader :config_tracker
  attr_reader :error_message
  attr_reader :name
  attr_reader :path
  attr_reader :plugins
  attr_reader :rake_task
  attr_reader :settings


  def self.configure &block
    raise 'No installer is currently being created' unless @installer_in_the_works
    block.call @installer_in_the_works
  end


  def initialize name, source_control = Subversion.new
    @name = name
    @source_control = source_control
    @path = File.join( Configuration.installers_directory, @name )
    @scheduler = PollingScheduler.new( self )
    @plugins = []
    @plugins_by_name = {}
    @config_tracker = InstallerConfigTracker.new( self.path )
    @settings = ''
    @config_file_content = ''
    @error_message = ''
    instantiate_plugins
  end


  def last_complete_build_status
    if BuilderStatus.new( self ).fatal?
      return 'failed'
    end
    last_complete_build ? last_complete_build.status : 'never_built'
  end


  def builder_state_and_activity
    BuilderStatus.new( self ).status
  end


  def builder_error_message
    BuilderStatus.new( self ).error_message
  end



  def last_five_builds
    last_builds 5
  end


  def local_checkout
    @local_checkout or File.join(@path, 'work')
  end


  def find_build(label)
    # this could be optimized a lot
    builds.find { |build| build.label.to_s == label }
  end


  def previous_build(current_build)
    all_builds = builds
    index = get_build_index(all_builds, current_build.label)

    if index > 0
      return all_builds[index-1]
    else
      return nil
    end
  end


  def config_valid?
    @settings == @config_file_content
  end


  def builds
    unless path
      raise "Installer #{ name.inspect } has no path"
    end

    the_builds = Dir[ "#{ path }/build-*/build_status.*" ].collect do | each |
      build_directory = File.basename( File.dirname( each ) )
      build_label = build_directory[ 6..-1 ]
      Build.new self, build_label
    end
    order_by_label the_builds
  end


  def load_and_remember file
    return unless File.file?(file)
    @settings << File.read(file) << "\n"
    @config_file_content = @settings
    load file
  end


  def load_config
    begin
      retried_after_update = false
      begin
        load_and_remember config_tracker.central_config_file
      # TODO shouldn't it be "rescue Exception => e"?
      rescue
        if retried_after_update
          raise
        else
          @source_control.update self
          retried_after_update = true
          retry
        end
      end
      load_and_remember config_tracker.local_config_file
    rescue Exception => e
      @error_message = "Could not load installer configuration: #{ e.message } in #{ e.backtrace.first }"
      Lucie::Log.event( @error_message, :fatal ) rescue nil
      @settings = ''
    end
    self
  end


  def build_if_necessary
    notify :polling_source_control
    begin
      revisions = new_revisions
      if revisions.empty?
        notify :no_new_revisions_detected
        return nil
      else
        remove_build_requested_flag_file if build_requested?
        notify(:new_revisions_detected, revisions)
        return build(revisions)
      end
    rescue => e
      notify(:build_loop_failed, e) rescue nil
      @build_loop_failed = true
      raise
    ensure
      notify(:sleeping) unless @build_loop_failed rescue nil
    end
  end


  def path= value
    @config_tracker = InstallerConfigTracker.new( value )
    @path = value
  end


  def new_revisions
    builds.empty? ? [ @source_control.latest_revision( self ) ] : @source_control.revisions_since( self, builds.last.label.to_i )
  end


  def build_command=(value)
    raise 'Cannot set build_command when rake_task is already defined' if value and @rake_task
    @build_command = value
  end


  def rake_task=(value)
    raise 'Cannot set rake_task when build_command is already defined' if value and @build_command
    @rake_task = value
  end


  def notify event, *event_parameters
    errors = []
    results = @plugins.collect do | plugin |
      begin
        if plugin.respond_to?( event )
          plugin.send( event, *event_parameters )
        end
      rescue => plugin_error
        Lucie::Log.error(plugin_error)
        if (event_parameters.first and event_parameters.first.respond_to? :artifacts_directory)
          plugin_errors_log = File.join(event_parameters.first.artifacts_directory, 'plugin_errors.log')
          begin
            File.open(plugin_errors_log, 'a') do |f|
              f << "#{plugin_error.message} at #{plugin_error.backtrace.first}"
            end
          rescue => e
            Lucie::Log.error(e)
          end
        end
        errors << "#{plugin.class}: #{plugin_error.message}"
      end
    end

    if errors.empty?
      return results.compact
    else
      if errors.size == 1
        error_message = "Error in plugin #{errors.first}"
      else
        error_message = "Errors in plugins:\n" + errors.map { |e| "  #{e}" }.join("\n")
      end
      raise error_message
    end
  end


  def build_if_requested
    if build_requested?
      remove_build_requested_flag_file
      build
    end
  end


  def build_requested?
    return File.file?( build_requested_flag_file )
  end


  def build_requested_flag_file
    return File.join( path, 'build_requested' )
  end


  def build(revisions = nil)
    notify(:build_initiated)
    if revisions.nil?
      revisions = new_revisions
      revisions = [@source_control.latest_revision(self)] if revisions.empty?
    end
    previous_build = last_build
    last_revision = revisions.last

    build = Build.new(self, create_build_label(last_revision.number))
    log_changeset(build.artifacts_directory, revisions)
    @source_control.update(self, last_revision)

    if config_tracker.config_modified?
      build.abort
      notify :configuration_modified
      throw :reload_installer
    end

    notify(:build_started, build)
    build.run
    notify(:build_finished, build)

    if previous_build
      if build.failed? and previous_build.successful?
        notify(:build_broken, build, previous_build)
      elsif build.successful? and previous_build.failed?
        notify(:build_fixed, build, previous_build)
      end
    end

    build
  end


  def config_modified?
    if config_tracker.config_modified?
      notify :configuration_modified
      return true
    else
      return false
    end
  end


  def last_build
    builds.last
  end


  def last_complete_build
    builds.reverse.each do | each |
      unless each.incomplete?
        return each
      end
    end
    return nil
  end


  def log_changeset(artifacts_directory, revisions)
    File.open(File.join(artifacts_directory, 'changeset.log'), 'w') do |f|
      revisions.each { |rev| f << rev.to_s << "\n" }
    end
  end


  def instantiate_plugins
    @@plugin_names.each do |plugin_name|
      plugin_instance = plugin_name.to_s.camelize.constantize.new(self)
      self.add_plugin(plugin_instance)
    end
  end


  def add_plugin(plugin, plugin_name = plugin.class)
    @plugins << plugin
    plugin_name = plugin_name.to_s.underscore.to_sym
    if self.respond_to?(plugin_name)
      raise "Cannot register an plugin with name #{plugin_name.inspect} " +
            "because another plugin, or a method with the same name already exists"
    end
    @plugins_by_name[plugin_name] = plugin
    plugin
  end


  def create_build_requested_flag_file
    FileUtils.touch(build_requested_flag_file)
  end


  def request_build
    if builder_state_and_activity == 'builder_down'
      BuilderStarter.begin_builder(name)
      10.times do
        sleep 1.second
        break if builder_state_and_activity != 'builder_down'
      end
    end
    unless build_requested?
      notify :build_requested
      create_build_requested_flag_file
    end
  end


  def next_build current_build
    all_builds = builds
    index = get_build_index( all_builds, current_build.label )

    if index == ( all_builds.size - 1 )
      return nil
    else
      return all_builds[ index + 1 ]
    end
  end


  def last_builds n
    builds.reverse[ 0..( n - 1 ) ]
  end


  def to_param
    self.name
  end


  def == another
    return( another.is_a?( Installer ) and another.name == self.name )
  end


  # access plugins by their names
  def method_missing method_name, *args, &block
    @plugins_by_name.key?( method_name ) ? @plugins_by_name[ method_name ] : super
  end


  private


  def create_build_label(revision_number)
    revision_number = revision_number.to_s
    build_labels = builds.map { |b| b.label.to_s }
    related_builds_pattern = Regexp.new("^#{Regexp.escape(revision_number)}(\\.\\d+)?$")
    related_builds = build_labels.select { |label| label =~ related_builds_pattern }

    case related_builds
    when [] then revision_number
    when [revision_number] then "#{revision_number}.1"
    else
      rebuild_numbers = related_builds.map { |label| label.split('.')[1] }.compact
      last_rebuild_number = rebuild_numbers.sort_by { |x| x.to_i }.last
      "#{revision_number}.#{last_rebuild_number.next}"
    end
  end


  # sorts a array of builds in order of revision number and rebuild number
  def order_by_label builds
    builds.sort_by do | each |
      number_and_rebuild = each.label.split( '.' )
      number_and_rebuild.map do | x |
        x.to_i
      end
    end
  end


  def get_build_index all_builds, build_label
    result = 0;
    all_builds.each_with_index do | each, index |
      if each.label.to_s == build_label
        result = index
      end
    end
    result
  end
end


# TODO make me pretty, move me to another file, invoke me from environment.rb
# TODO check what happens if loading a plugin raises an error (e.g, SyntaxError in plugin/init.rb)

plugin_loader = Object.new


def plugin_loader.load_plugin(plugin_path)
  plugin_file = File.basename(plugin_path).sub(/\.rb$/, '')
  plugin_is_directory = (plugin_file == 'init')
  plugin_name = plugin_is_directory ? File.basename(File.dirname(plugin_path)) : plugin_file

  Lucie::Log.debug("Loading plugin #{plugin_name}")
  if RAILS_ENV == 'development'
    load plugin_path
  else
    if plugin_is_directory
      require "#{plugin_name}/init"
    else
      require plugin_name
    end
  end
end


def plugin_loader.load_all
  plugins = Dir[File.join(RAILS_ROOT, 'builder_plugins', 'installed', '*')]

  plugins.each do |plugin|
    if File.file?(plugin)
      if plugin[-3..-1] == '.rb'
        load_plugin(File.basename(plugin))
      else
        # a file without .rb extension, ignore
      end
    elsif File.directory?(plugin)
      # ignore Subversion directory (although it should be considered hidden by Dir[], but just in case)
      next if plugin[-4..-1] == '.svn'
      init_path = File.join(plugin, 'init.rb')
      if File.file?(init_path)
        load_plugin(init_path)
      else
        log.error("No init.rb found in plugin directory #{plugin}")
      end
    else
      # a path is neither file nor directory. whatever else it may be, let's ignore it.
      # TODO: find out what happens with symlinks on a Linux here? how about broken symlinks?
    end
  end


  def remove_build_requested_flag_file
    FileUtils.rm_f(Dir[build_requested_flag_file])
  end
end


plugin_loader.load_all


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
