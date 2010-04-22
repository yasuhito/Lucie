# -*- coding: utf-8 -*-
Given /^TFTP のルートパスは "([^\"]*)"$/ do | path |
  Configuration.tftp_root = path
end


Given /^ファイル "([^\"]*)" が存在$/ do | path |
  FileUtils.mkdir_p File.dirname( path )
  FileUtils.touch path
end


When /^node reset コマンドを実行した$/ do
  argv = []
  @messenger = StringIO.new
  app = Command::NodeReset::App.new( argv, :messenger => @messenger, :dry_run => true, :verbose => true )
  app.main
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
