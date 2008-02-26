require 'open3'


def extract_options help_message
  options = []
  help_message.split( "\n" ).each do | each |
    if /(\-\w), (\-\-[\w\-]+)/=~ each
      options.push [ $1, $2 ]
    end
  end
  options
end


def output_with command
  Open3.popen3( command ) do | stdin, stdout, stderr |
    return [ stdout.read, stderr.read ]
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
