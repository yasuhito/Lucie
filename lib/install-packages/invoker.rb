module InstallPackages
  class Invoker
    attr_reader :commands


    def initialize
      @commands = []
    end


    def start options
      @commands.each do | each |
        each.execute options
      end
    end


    def add_command aCommand
      if aCommand.respond_to?( :execute )
        @commands << aCommand
      else
        raise "Invalid command added: #{ aCommand }"
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
