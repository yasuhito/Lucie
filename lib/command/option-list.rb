require 'stringio'


module OptionList
  @@usage = ""
  @@option_list = []


  def self.clear_options
    @@option_list = []
  end


  def self.register_usage str
    @@usage = str
  end


  def self.register_options long, short, arg, desc
    @@option_list.push [ long, short, arg, desc ]
  end


  def self.push_separator
    @@option_list.push :separator
  end


  def self.options
    ( @@option_list - [ :separator ] ).collect do | long, short, arg, |
      [ long, short, arg ? GetoptLong::REQUIRED_ARGUMENT : GetoptLong::NO_ARGUMENT ]
    end
  end


  def self.option_desc_tab
    ( @@option_list - [ :separator ] ).collect do | long, short, arg, desc |
      if arg
        long.size + arg.size
      else
        long.size
      end
    end.sort.reverse[ 0 ] + 10
  end


  def self.usage
    out = StringIO.new( "" )
    out.puts "usage: " + @@usage
    out.puts

    out.puts "Options:"
    @@option_list.each do | each |
      if each == :separator
        out.puts
        next
      else
        long, short, arg, desc = each
        out.print( if arg
                     sprintf "  %-#{ option_desc_tab }s", "#{ short }, #{ long } #{ arg }"
                   else
                     sprintf "  %-#{ option_desc_tab }s", "#{ short }, #{ long } "
                   end )
        desc = desc.split( "\n" )
        out.puts desc.shift
        desc.each do | each |
          puts( ' ' * ( option_desc_tab + 2 ) + each )
        end
      end
    end
    out.string
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
