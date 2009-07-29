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
    @messenger.print "Checking #{ @scm } ... "
    if @dpkg.installed?( @scm )
      @messenger.puts "INSTALLED"
    else
      @messenger.puts "NOT INSTALLED"
      raise "#{ @scm } is not installed"
    end
  end
end
