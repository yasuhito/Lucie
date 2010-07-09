# -*- coding: utf-8 -*-
Given /^中身が "([^"]*)" の一時ファイルが存在$/ do | content | #"
  @tempfile = tempfile( content )
end


When /^その一時ファイルを encrypt コマンド \(オプションは "([^"]*)"\) で暗号化した$/ do | options | #"
  @output ||= Hash.new
  @error ||= Hash.new
  @output[ :encrypt ] = Tempfile.new( "encout" ).path
  @error[ :encrypt ] = Tempfile.new( "encerr" ).path
  @rc = system( "./script/encrypt #{ options } #{ @tempfile.path } 1> #{ @output[ :encrypt ] } 2> #{ @error[ :encrypt ] }" )
end


When /^その出力を decrypt コマンド \(オプションは "([^"]*)" \) で復号した$/ do | options | #"
  @output[ :decrypt ] = Tempfile.new( "decrypt" ).path
  @rc = system( "./script/decrypt #{ options } #{ @output[ :encrypt ] } > #{ @output[ :decrypt ] }" )
end


When /^encrypt \-\-help コマンドを実行$/ do
  tmp = Tempfile.new( "encrypt" ).path
  system "./script/encrypt --help > #{ tmp }"
  @messenger = StringIO.new( IO.read tmp )
end


When /^encrypt \-h コマンドを実行$/ do
  tmp = Tempfile.new( "encrypt" ).path
  system "./script/encrypt -h > #{ tmp }"
  @messenger = StringIO.new( IO.read tmp )
end


When /^decrypt \-\-help コマンドを実行$/ do
  tmp = Tempfile.new( "decrypt" ).path
  system "./script/decrypt --help > #{ tmp }"
  @messenger = StringIO.new( IO.read tmp )
end


When /^decrypt \-h コマンドを実行$/ do
  tmp = Tempfile.new( "decrypt" ).path
  system "./script/decrypt -h > #{ tmp }"
  @messenger = StringIO.new( IO.read tmp )
end


When /^encrypt コマンドに引数を付けずに実行$/ do
  tmp = Tempfile.new( "encrypt" ).path
  system "./script/encrypt > #{ tmp }"
  @messenger = StringIO.new( IO.read tmp )
end


When /^decrypt コマンドに引数を付けずに実行$/ do
  tmp = Tempfile.new( "decrypt" ).path
  system "./script/decrypt > #{ tmp }"
  @messenger = StringIO.new( IO.read tmp )
end


Then /^encrypt コマンドは成功する$/ do
  @rc.should be_true
end


Then /^decrypt コマンドは成功する$/ do
  @rc.should be_true
end


Then /^encrypt コマンドの標準出力は無し$/ do
  IO.read( @output[ :encrypt ] ).should == ""
end


Then /^encrypt コマンドの標準エラー出力は "([^"]*)" にマッチ$/ do | regexp | #"
  IO.read( @error[ :encrypt ] ).should match( Regexp.new regexp )
end


Then /^出力 "([^"]*)" を得る$/ do | expected | #"
  IO.read( @output[ :decrypt ] ).should == expected
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
