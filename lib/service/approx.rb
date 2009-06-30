require "lucie/io"
require "lucie/utils"


class Service
  class Approx < Service
    include Lucie::IO


    config "/etc/approx/approx.conf"
    prerequisite "approx"


    def setup
      info "Setting up approx ..."
      Lucie::Utils.write_file @@config, <<-CONFIG, @options.merge( :sudo => true ), @messenger
debian          http://cdn.debian.or.jp/debian
security        http://security.debian.org/debian-security
volatile        http://volatile.debian.org/debian-volatile
CONFIG
      Lucie::Utils.run "sudo /etc/init.d/approx restart", @options, @messenger
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
