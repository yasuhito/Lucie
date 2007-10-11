require 'popen3/shell'


class Debootstrap
  class DebootstrapOption # :nodoc:
    attr_accessor :env
    attr_accessor :arch
    attr_accessor :exclude
    attr_accessor :include
    attr_accessor :mirror
    attr_accessor :suite
    attr_accessor :target


    def commandline
      arch = @arch ? "--arch=#{ @arch }" : "--arch=i386"
      exclude = @exclude ? "--exclude=#{ @exclude.join( ',' ) }" : nil
      include = @include ? "--include=#{ @include.join( ',' ) }" : nil
      return [ '/usr/sbin/debootstrap', arch, include, exclude, @suite, @target, @mirror ].compact
    end


    def check_mandatory_options
      mandatory_options.each do | each |
        option_value = instance_variable_get( ( '@' + each.to_s ).to_sym )
        if option_value.nil?
          raise "#{ each } option is a mandatory"
        end
      end
    end


    def mandatory_options
      return [ :arch, :suite, :target, :mirror ]
    end
  end


  def self.VERSION
    version = nil
    Popen3::Shell.open do | shell |
      shell.on_stdout do | line |
        if /^ii\s+debootstrap\s+(\S+)/=~ line
          version = $1
        end
      end
      shell.exec( { 'LC_ALL' => 'C' }, 'dpkg', '-l' )
    end

    unless version
      raise 'Cannot determine debootstrap version.'
    end
    return version
  end


  def self.start &block
    self.new &block
  end


  def initialize
    @option = DebootstrapOption.new
    yield self
    @option.check_mandatory_options
    exec_shell
  end


  def child_status
    return @shell.child_status
  end


  def method_missing message, *arg
    @option.__send__ message, *arg
  end


  private


  def exec_shell
    error_message = []

    @shell = Popen3::Shell.open do | shell |
      Thread.new do
        loop do
          shell.puts
        end
      end

      shell.on_stdout do | line |
        Lucie::Log.debug line
      end

      shell.on_stderr do | line |
        case line
        when /\Aln: \S+ File exists/
          raise RuntimeError, line
        end
        Lucie::Log.error line
        error_message.push line
      end

      shell.on_failure do
        raise RuntimeError, error_message.last
      end

      shell.exec @option.env, *@option.commandline
    end
  end
end
