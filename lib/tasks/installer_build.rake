module Lucie
  def self.invoke_rake_task task_name
    puts "Invoking Rake task #{ task_name.inspect }"
    Rake::Task[ task_name ].invoke
  end
end


namespace :installer do
  task 'build' do
    ENV['RAILS_ENV'] = 'builder'

    if Rake.application.lookup( 'installer:nfsroot' )
      Lucie::invoke_rake_task 'installer:nfsroot'

      # update pxelinux.cfg/* files
      nodes = Nodes.load_enabled( ENV[ 'INSTALLER_NAME' ] ).list.collect do | each |
        each.name
      end
      Tftp.setup nodes, ENV[ 'INSTALLER_NAME' ]
      PuppetController.restart
    else
      raise "'installer:nfsroot' task not found. Lucie doesn't know what to build."
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
