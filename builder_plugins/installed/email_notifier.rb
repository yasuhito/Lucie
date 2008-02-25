# Lucie can send email notices whenever build is broken or fixed. To
# make it happen, you need to tell it how to send email, and who to
# send it to. Do the following:
# 
# 1. Configure SMTP server connection. Copy
#    [lucie]/config/lucie_config.rb_example to
#    [lucie]/config/lucie_config.rb, read it and edit according to your
#    situation.
# 
# 2. Tell the builder, whom do you want to receive build notices:
# <pre><code>Installer.configure do | installer |
#   ...
#   installer.email_notifier.emails = [ 'john@doe.com', 'jane@doe.com' ]
#   ...
# end</code></pre>
#
# You can also specify who to send the email from, either for the
# entire site by setting Configuration.email_from in
# [lucie]/config/site_config.rb, or on a per installer basis, by
# placing the following line in lucie_config.rb:
# <pre><code>Installer.configure do | installer |
#   ...
#   installer.email_notifier.from = "lucie@doe.com"
#   ...
# end</code></pre>


class EmailNotifier
  attr_accessor :emails
  attr_writer :from
  

  def initialize installer = nil
    @emails = []
  end


  def from
    @from || Configuration.email_from
  end


  def build_finished build
    return if @emails.empty? or not build.failed?
    email :deliver_build_report, build, "#{ build.installer.name } build #{ build.label } failed", "The build failed."
  end


  def build_fixed build, previous_build
    return if @emails.empty?
    email :deliver_build_report, build, "#{ build.installer.name } build #{ build.label } fixed", "The build has been fixed."
  end
  

  private
  

  def email template, build, *args
    BuildMailer.send template, build, @emails, from, *args
    Lucie::Log.event( "Sent e-mail to #{ @emails.size == 1 ? "1 person" : "#{ @emails.size } people"}", :debug )
  rescue => e
    settings = ActionMailer::Base.smtp_settings.map { | k, v | "  #{ k.inspect } = #{ v.inspect }" }.join( "\n" )
    Lucie::Log.event( "Error sending e-mail - current server settings are :\n#{ settings }", :error )
    raise
  end
end


Installer.plugin :email_notifier


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
