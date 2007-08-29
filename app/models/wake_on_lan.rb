# based on ftp://ftp.math.kobe-u.ac.jp/pub/knot/wakeonlan.rb


class WakeOnLan
  def wake mac_addr, broadcast='', ip_addr=''
    begin
      socket = UDPSocket.open()
      socket.setsockopt( Socket::SOL_SOCKET, Socket::SO_BROADCAST, 1 )

      wol_magic=( 0xff.chr ) * 6 + ( mac_addr.split( /:/ ).pack( 'H*H*H*H*H*H*') ) * 16
      # Set broadcast. Assume that standard IP-class.
      if broadcast == ''
        ips=ip_addr.split( /\./ )
        c = ips[ 0 ].to_i

        # class A:1--127
        if c<=127
          ips[1]='255'
        end

        # class B:128--191
        if c<=191
          ips[2]='255'
        end

        # class C:192--223
        if c<=223
          ips[3]='255'
        end

        # class D:224--239 multicast
        broadcast = ips.join( '.' )
      end

      3.times do
        socket.send wol_magic, 0, broadcast, 'discard'
      end
    ensure
      socket.close
    end
  end
end
