# -*- coding: utf-8 -*-
When /^サブプロセス "([^\"]*)" を実行$/ do | command |
  @stdout = []
  @stderr = []
  @on_success_called = false
  @on_failure_called = false
  @child_status = nil

  Popen3::Shell.open do | shell |
    shell.on_stdout do | line |
      @stdout << line
    end
    shell.on_stderr do | line |
      @stderr << line
    end

    shell.on_success do
      @on_success_called = true
    end
    shell.on_failure do
      @on_failure_called = true
    end
    shell.on_exit do
      @child_status = shell.child_status
    end

    shell.exec command
  end
end


Then /^終了コード "([^\"]*)" が返る$/ do | status |
  @child_status.should_not be_nil
  @child_status.exitstatus.to_s.should == status
end


Then /^次の標準出力を得る:$/ do | string |
  @stdout.join( "\n" ).should == string
end


Then /^標準出力には何も得ない$/ do
  @stdout.should be_empty
end


Then /^次の標準エラー出力を得る:$/ do | string |
  @stderr.join( "\n" ).should == string
end


Then /^標準エラー出力には何も得ない$/ do
  @stderr.should be_empty
end


Then /^成功時の後処理が呼ばれる$/ do
  @on_success_called.should be_true
end


Then /^成功時の後処理は呼ばれない$/ do
  @on_success_called.should be_false
end


Then /^失敗時の後処理が呼ばれる$/ do
  @on_failure_called.should be_true
end


Then /^失敗時の後処理は呼ばれない$/ do
  @on_failure_called.should be_false
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
