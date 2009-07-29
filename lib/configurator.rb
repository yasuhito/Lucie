require "dpkg"


class Configurator
  attr_writer :dpkg
  attr_reader :scm


  def initialize scm = nil, messenger = $stdout
    @scm = scm
    @dpkg = Dpkg.new
    @messenger = messenger
  end


  def scm_installed?
    return unless @scm
    if @dpkg.installed?( @scm )
      @messenger.puts "Checking #{ @scm } ... INSTALLED"
    else
      @messenger.puts "Checking #{ @scm } ... NOT INSTALLED"
      raise "#{ @scm } is not installed"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
