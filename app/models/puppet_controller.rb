require 'facter'
require 'popen3/shell'


class PuppetController
  def self.setup local_checkout_dir
    self.new.setup local_checkout_dir
  end


  def self.restart
    self.new.restart_puppet
  end


  attr_reader :manifest_dir
  attr_reader :template_dir
  attr_reader :files_dir
  attr_reader :facts_dir


  def setup local_checkout_dir
    @manifest_dir = File.join( local_checkout_dir, 'puppet/manifests' )
    @template_dir = File.join( local_checkout_dir, 'puppet/templates' )
    @files_dir = File.join( local_checkout_dir, 'puppet/files' )
    @facts_dir = File.join( local_checkout_dir, 'puppet/facts' )

    check_puppet_installed
    write_config
    restart_puppet
  end


  def check_puppet_installed
    unless File.exists?( '/usr/sbin/puppetmasterd' )
      raise 'puppetmaster package is not installed. Please install first.'
    end
  end


  def write_config
    File.open( '/etc/puppet/puppetmasterd.conf', 'w' ) do | file |
      file.puts( <<-EOF )
[puppetmasterd]
manifestdir=#{ manifest_dir }

logdir=/var/log/puppet
vardir=/var/lib/puppet
rundir=/var/run


[parser]
templatedir=#{ template_dir }


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

[facts]
  path #{ facts_dir }
EOF
    end
  end


  def restart_puppet
    Nodes.load_all.list.each do | each |
      sh_exec "puppetca --clean #{ each.name }.#{ Facter.value( 'domain' ) }"
    end
    sh_exec '/etc/init.d/puppetmaster restart'
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
