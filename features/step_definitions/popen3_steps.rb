# -*- coding: utf-8 -*-
When /^サブプロセス "([^\"]*)" を実行$/ do | cmd |
  @stdout = []
  @stderr = []
  @on_success = nil
  @on_failure = nil
  @child_status = nil
  Popen3::Shell.open do | shell |
    shell.on_stdout do | line |
      @stdout << line
    end
    shell.on_stderr do | line |
      @stderr << line
    end

    shell.on_success do
      @on_success = true
    end
    shell.on_failure do
      @on_failure = true
    end
    shell.on_exit do
      @child_status = shell.child_status
    end
    shell.exec cmd
  end
end


Then /^終了コード "([^\"]*)" が返る$/ do | status |
  @child_status.exitstatus.should == status.to_i
end


Then /^標準出力に "([^\"]*)" を得る$/ do | string |
  @stdout.should == string.split( "\n" )
end


Then /^標準エラー出力に "([^\"]*)" を得る$/ do | string |
  @stderr.should == string.split( "\n" )
end


Then /^成功時の後処理が呼ばれる$/ do
  @on_success.should be_true
end


Then /^失敗時の後処理が呼ばれる$/ do
  @on_failure.should be_true
end
