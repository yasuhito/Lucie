# -*- coding: utf-8 -*-
Given /^中身が "([^"]*)" の一時ファイルが存在$/ do | content | #"
  @tempfile = tempfile( content )
end


When /^その一時ファイルを encrypt コマンド \(オプションは "([^"]*)"\) で暗号化した$/ do | options | #"
  @encout = File.join( Dir.tmpdir, "encout" )
  @encerr = File.join( Dir.tmpdir, "encerr" )
  @rc = system( "./script/encrypt #{ options } #{ @tempfile.path } 1> #{ @encout } 2> #{ @encerr }" )
end


When /^その出力を decrypt コマンド \(オプションは "([^"]*)" \) で復号した$/ do | options | #"
  @decout = File.join( Dir.tmpdir, "decout" )
  @decerr = File.join( Dir.tmpdir, "deccerr" )
  @rc = system( "./script/decrypt #{ options } #{ @encout } 1> #{ @decout } 2> #{ @decerr }" )
end


When /^encrypt \-\-help コマンドを実行$/ do
  tmp = File.join( Dir.tmpdir, "encout" )
  system "./script/encrypt --help > #{ tmp }"
  @messenger = StringIO.new( IO.read tmp )
end


When /^encrypt \-h コマンドを実行$/ do
  tmp = File.join( Dir.tmpdir, "encout" )
  system "./script/encrypt -h > #{ tmp }"
  @messenger = StringIO.new( IO.read tmp )
end


When /^decrypt \-\-help コマンドを実行$/ do
  tmp = File.join( Dir.tmpdir, "decout" )
  system "./script/decrypt --help > #{ tmp }"
  @messenger = StringIO.new( IO.read tmp )
end


When /^decrypt \-h コマンドを実行$/ do
  tmp = File.join( Dir.tmpdir, "decout" )
  system "./script/decrypt -h > #{ tmp }"
  @messenger = StringIO.new( IO.read tmp )
end


When /^encrypt コマンドに引数を付けずに実行$/ do
  tmp = File.join( Dir.tmpdir, "encout" )
  system "./script/encrypt > #{ tmp }"
  @messenger = StringIO.new( IO.read tmp )
end


When /^decrypt コマンドに引数を付けずに実行$/ do
  tmp = File.join( Dir.tmpdir, "decout" )
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
  IO.read( @encout ).should == ""
end


Then /^decrypt コマンドの標準出力は無し$/ do
  IO.read( @decout ).should == ""
end


Then /^encrypt コマンドの標準エラー出力は "([^"]*)" にマッチ$/ do | regexp | #"
  IO.read( @encerr ).should match( Regexp.new regexp )
end


Then /^decrypt コマンドの標準エラー出力は "([^"]*)" にマッチ$/ do | regexp | #"
  IO.read( @decerr ).should match( Regexp.new regexp )
end


Then /^出力 "([^"]*)" を得る$/ do | expected | #"
  IO.read( @decout ).should == expected
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
