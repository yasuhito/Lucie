require 'install-packages/aptget'
require 'install-packages/aptitude'
require 'install-packages/command/aptitude'
require 'install-packages/command/aptitude-r'
require 'install-packages/command/clean'
require 'install-packages/command/install'
require 'install-packages/command/remove'
require 'install-packages/invoker'
require 'install-packages/kernel'
require 'singleton'


module InstallPackages
  class App
    include Singleton


    attr_accessor :invoker


    def self.load_aptget aptget_class
      @@aptget = aptget_class
    end


    def self.load_aptitude aptitude
      @@aptitude = aptitude
    end


    def self.load_command command
      @@command = command
    end


    def self.reset
      @@aptget = InstallPackages::AptGet
      @@aptitude = InstallPackages::Aptitude
      @@command = {
        :aptget_install => InstallPackages::InstallCommand,
        :aptget_remove => InstallPackages::RemoveCommand,
        :aptget_clean => InstallPackages::CleanCommand,
        :aptitude => InstallPackages::AptitudeCommand,
        :aptitude_r => InstallPackages::AptitudeRCommand
      }
    end


    reset


    def add_command directive, packages = nil
      receiver = receiver_command_table[ directive ][ :receiver ].new( packages )
      command = receiver_command_table[ directive ][ :command ].new( receiver )

      @invoker ||= InstallPackages::Invoker.new
      @invoker.add_command command
    end


    def main option
      @option = option
      begin
        if( @option.version or @option.help )
          exit 0
        end
      end
      config_file.each do | each |
        do_install each
      end
    end


    private


    def receiver_command_table
      return receiver_command_table = {
        :aptget_install => { :receiver => @@aptget, :command => @@command[ :aptget_install ] },
        :aptget_remove => { :receiver => @@aptget, :command => @@command[ :aptget_remove ] },
        :aptget_clean => { :receiver => @@aptget, :command => @@command[ :aptget_clean ] },
        :aptitude => { :receiver => @@aptitude, :command => @@command[ :aptitude ] },
        :aptitude_r => { :receiver => @@aptitude, :command => @@command[ :aptitude_r ] }
      }
    end


    def config_file
      if @option.config_file
        return [ @option.config_file ]
      else
        # [XXX] デフォルトの設定ファイルをロードさせる
        # return Dir.glob( '/etc/lucie/package/*' )
      end
    end


    def do_install configFile
      load configFile
      @invoker.start @option
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
