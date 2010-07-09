# -*- coding: utf-8 -*-
Given /^中身が "([^"]*)" の一時ファイルが存在$/ do | content | #"
  @tempfile = tempfile( content )
end


When /^その一時ファイルを encrypt コマンド \(パスワード = "([^"]*)"\) で暗号化した$/ do | password | #"
  @output ||= Hash.new
  @output[ :encrypt ] = Tempfile.new( "encrypt" ).path
  @rc = system( "./script/encrypt --password #{ password } #{ @tempfile.path } > #{ @output[ :encrypt ] }" )
end


When /^その出力を decrypt コマンドで復号 \(パスワード = "([^"]*)" \) した$/ do | password | #"
  @output[ :decrypt ] = Tempfile.new( "decrypt" ).path
  @rc = system( "./script/decrypt --password #{ password } #{ @output[ :encrypt ] } > #{ @output[ :decrypt ] }" )
end


When /^encrypt \-\-help コマンドを実行$/ do
  @output = Tempfile.new( "encrypt" ).path
  system "./script/encrypt --help > #{ @output }"
  @messenger = StringIO.new( IO.read @output )
end


Then /^encrypt コマンドは成功する$/ do
  @rc.should be_true
end


Then /^decrypt コマンドは成功する$/ do
  @rc.should be_true
end


Then /^出力 "([^"]*)" を得る$/ do | expected | #"
  IO.read( @output[ :decrypt ] ).should == expected
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
