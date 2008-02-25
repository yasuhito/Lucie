class BuildsController < ApplicationController
  layout 'default'
  
  def show
    render :text => 'Installer not specified', :status => 404 and return unless params[:installer]
    @installer = Installers.find(params[:installer])
    render :text => "Installer #{params[:installer].inspect} not found", :status => 404 and return unless @installer

    @build = (params[:build] ? @installer.find_build(params[:build]) : @installer.last_build)
    render :action => (@build ? 'show' : 'no_builds_yet') 
  end
  
  def artifact
    render :text => 'Installer not specified', :status => 404 and return unless params[:installer]
    render :text => 'Build not specified', :status => 404 and return unless params[:build]
    render :text => 'Path not specified', :status => 404 and return unless params[:path]

    @installer = Installers.find(params[:installer])
    render :text => "Installer #{params[:installer].inspect} not found", :status => 404 and return unless @installer
    @build = @installer.find_build(params[:build])
    render :text => "Build #{params[:build].inspect} not found", :status => 404 and return unless @build

    path = File.join(@build.artifacts_directory, params[:path])

    if File.directory? path
      if File.exists?(path + '/index.html')
        redirect_to :path => File.join(params[:path], 'index.html')
      else
        # TODO: generate an index from directory contents
        render :text => "this should be an index of #{params[:path]}"
      end
    elsif File.exists? path
      send_file(path, :type => get_mime_type(path), :disposition => 'inline', :stream => false)
    else
      render_not_found
    end
  end
  
  private
  
  def get_mime_type(name)
    case name.downcase
    when /\.html$/
      'text/html'
    when /\.js$/
      'text/javascript'
    when /\.css$/
      'text/css'
    when /\.gif$/
      'image/gif'
    when /(\.jpg|\.jpeg)$/
      'image/jpeg'
    when /\.png$/
      'image/png'
    else
      'text/plain'
    end
  end

end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
