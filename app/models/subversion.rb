require 'popen3/shell'


class Subversion
  attr_accessor :url
  attr_accessor :username
  attr_accessor :password


  def initialize options = {}
    @url = options.delete( :url )
    @username = options.delete( :username )
    @password = options.delete( :password )
    @interactive = options.delete( :interactive )

    if options.length > 0
      raise "don't know how to handle '#{ options.keys.first }'"
    end
  end


  def checkout target_directory, revision = nil
    @url or raise 'URL not specified'

    options = "#{ @url } #{ target_directory }"
    if username
      options << " --username #{ @username }"
    end
    if password
      options << " --password #{ @password }"
    end
    if revision
      options << " --revision #{ revision_number( revision ) }"
    end

    sh_exec svn( :co, options )
  end


  def latest_revision installer
    last_locally_known_revision = info( installer ).last_changed_revision
    svn_output = execute_in_local_copy( installer, svn( :log, "--revision HEAD:#{ last_locally_known_revision } --verbose --xml" ) )
    SubversionLogParser.new.parse_log( svn_output ).first
  end


  def revisions_since installer, revision_number
    svn_output = execute_in_local_copy( installer, svn( :log, "--revision HEAD:#{ revision_number } --verbose --xml" ) )
    new_revisions = SubversionLogParser.new.parse_log( svn_output ).reverse
    new_revisions.delete_if { | r | r.number == revision_number }
    new_revisions
  end


  def update installer, revision = nil
    revision_number = revision ? revision_number( revision ) : 'HEAD'
    svn_output = execute_in_local_copy( installer, svn( :update, "--revision #{ revision_number }" ) )
    SubversionLogParser.new.parse_update svn_output
  end


  ################################################################################
  private
  ################################################################################


  def revision_number revision
    revision.respond_to?( :number ) ? revision.number : revision.to_i
  end


  def info installer
    svn_output = execute_in_local_copy( installer, svn( :info, '--xml' ) )
    SubversionLogParser.new.parse_info svn_output
  end


  def svn operation, options = nil
    command = 'svn'
    unless @interactive
      command << ' --non-interactive'
    end
    command << ' ' << operation.to_s
    if options
      command << ' ' << options
    end
    command
  end


  def execute_in_local_copy installer, command
    result = []
    error = []

    Dir.chdir( installer.local_checkout ) do
      Popen3::Shell.open do | shell |
        shell.on_stderr do | line |
          error << line
        end
        shell.on_stdout do | line |
          result << line
        end
        shell.exec command
      end
    end

    unless error.empty?
      raise BuilderError.new( error.join( "\n" ), 'svn_error' )
    end

    result
  end


  Info = Struct.new :revision, :last_changed_revision, :last_changed_author
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
