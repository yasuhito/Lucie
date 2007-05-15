#
# $Id: installer_test.rb 35 2007-05-14 07:37:03Z yasuhito $
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 35 $
# License:: GPL2


class InstallersController < ApplicationController
  layout 'default'

  
  def index
    @installers = Installers.load_all
    
    respond_to do |format|
      format.html
      format.js { render :action => 'index_js' }
      format.rss { render :action => 'index_rss', :layout => false }
      format.cctray { render :action => 'index_cctray', :layout => false }
    end
  end


  def show
    render :text => 'Installer not specified', :status => 404 and return unless params[:id]

    @installer = Installers.find(params[:id])
    render :text => "Installer #{params[:id].inspect} not found", :status => 404 and return unless @installer

    respond_to do |format|
      format.html { redirect_to :controller => "builds", :action => "show", :installer => @installer }
      format.rss { render :action => 'show_rss', :layout => false }
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
