class Service
  @@prerequisites = {}


  def self.check_prerequisites options
    missings = []
    ObjectSpace.each_object( Class ) do | klass |
      next if klass.superclass != self
      missings += check_prerequisite( klass, options, options[ :messenger ] || $stderr )
    end
    unless missings.empty?
      raise "#{ missings.sort.join( ', ' ) } not installed. Try 'aptitude install #{ missings.sort.join( ' ' ) }'"
    end
  end


  def self.check_prerequisite service, options, messenger
    missings = []
    return missings unless @@prerequisites[ service ]
    @@prerequisites[ service ].each do | each |
      messenger.print "Checking #{ each } ... "
      if FileTest.exist?( "/var/lib/dpkg/info/#{ each }.md5sums" )
        messenger.puts "INSTALLED"
      else
        missings << each unless options[ :dry_run ]
        messenger.puts "NOT INSTALLED"
      end
    end
    missings
  end


  def self.prerequisite package
    module_eval do | service |
      @@prerequisites[ service ] ||= []
      @@prerequisites[ service ] << package
    end
  end


  def self.config path
    module_eval %-
      @@config = path
    -
  end


  def initialize options, messenger
    @options = options
    @messenger = messenger
  end


  ##############################################################################
  private
  ##############################################################################


  def restart
    instance_eval do | obj |
      prerequisites = obj.class.__send__( :class_variable_get, :@@prerequisites )[ obj.class ]
      prerequisites.each do | each |
        script = "/etc/init.d/#{ each }"
        if @options[ :dry_run ] || FileTest.exists?( script )
          run "sudo #{ script } restart", @options, @messenger
        end
      end
    end
  end


  def backup
    instance_eval do | obj |
      config = obj.class.__send__( :class_variable_get, :@@config )
      if @options[ :dry_run ] || FileTest.exists?( config )
        run "sudo mv -f #{ config } #{ config }.old", @options, @messenger
      end
    end
  end
end


require "service/approx"
require "service/debootstrap"
require "service/dhcp"
require "service/installer"
require "service/nfs"
require "service/tftp"


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
