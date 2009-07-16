require "lucie/io"
require "lucie/log"
require "popen3/shell"


class Debootstrap
  include Lucie::IO


  attr_accessor :arch
  attr_accessor :exclude
  attr_accessor :http_proxy
  attr_accessor :include
  attr_accessor :package_repository
  attr_accessor :suite
  attr_accessor :target

  attr_accessor :dry_run # :nodoc:
  attr_accessor :messenger # :nodoc:
  attr_accessor :verbose # :nodoc:


  def self.VERSION dpkg_l = "dpkg -l"
    Popen3::Shell.open do | shell |
      version = nil
      shell.on_stdout do | line |
        version = $1 if /^ii\s+debootstrap\s+(\S+)/=~ line
      end
      shell.exec dpkg_l
      version
    end
  end


  def self.setup &block
    self.new &block
  end


  ##############################################################################
  private
  ##############################################################################


  def initialize # :nodoc:
    yield self
    Lucie::Log.verbose = @verbose
    run
  end


  def command
    "/usr/sbin/debootstrap #{ options } #{ suite } #{ target } #{ package_repository }"
  end


  # Popen3 #####################################################################


  def run
    check_mandatory_options
    Popen3::Shell.open do | shell |
      set_handlers_for shell
      exec_debootstrap shell
    end
  end


  def set_handlers_for shell
    shell.on_stdout do | line |
      do_stdout line
    end
    shell.on_stderr do | line |
      do_stderr line
    end
    shell.on_failure do
      raise RuntimeError, @last_error
    end
  end


  def do_stdout line
    if /\AE: /=~ line
      error line
      @last_error = line
    else
      debug line
    end
  end


  def do_stderr line
    raise RuntimeError, line if /\Aln: \S+ File exists/=~ line
    error line
    @last_error = line
  end


  def exec_debootstrap shell
    debug command_debug
    shell.exec command, { "LC_ALL" => "C", "http_proxy" => @http_proxy } unless @dry_run
  end


  def command_debug
    if @http_proxy
      "#{ command } (http_proxy = #{ @http_proxy })"
    else
      command
    end
  end


  # options ####################################################################


  def options
    all_options.join " "
  end


  def all_options
    [ arch_option, verbose_option, exclude_option, include_option ].compact
  end


  def check_mandatory_options
    mandatory_options.each_pair do | key, value |
      raise "#{ key } option is a mandatory" if value.nil?
    end
  end


  def mandatory_options
    { :suite => @suite, :target => @target, :package_repository => @package_repository }
  end


  def arch_option
    @arch ? "--arch #{ @arch }" : nil
  end


  def verbose_option
    @verbose ? "--verbose" : nil
  end


  def exclude_option
    @exclude ? "--exclude=#{ @exclude.join( ',' ) }" : nil
  end


  def include_option
    @include ? "--include=#{ @include.join( ',' ) }" : nil
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
