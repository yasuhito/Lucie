class Puppet
  def self.setup local_checkout_dir
    manifest_dir = File.join( local_checkout_dir, 'puppet/manifests' )
    files_dir = File.join( local_checkout_dir, 'puppet/files' )

    unless File.exists?( '/usr/sbin/puppetmasterd' )
      puts 'FAILED: puppetmaster package is not installed. Please install first.'
      puts ' % sudo aptitude install puppetmaster'
      exit 1
    end

    File.open( '/etc/puppet/puppetmasterd.conf', 'w' ) do | file |
      file.puts( <<-EOF )
[puppetmasterd]
manifestdir=#{ manifest_dir }

logdir=/var/log/puppet
vardir=/var/lib/puppet
rundir=/var/run

[ca]
autosign=true
EOF
    end

    # [XXX] Allow Lucie clients only.
    File.open( '/etc/puppet/fileserver.conf', 'w' ) do | file |
      file.puts( <<-EOF )
[files]
  path #{ files_dir }
  allow *
EOF
    end

    system( '/etc/init.d/puppetmaster restart' )
  end
end
