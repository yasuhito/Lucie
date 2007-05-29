module InstallersHelper

  def rss_title(installer, build)
    installer.name + (build ? " build #{build.label} #{build.status}" :
                            " has never been built")
  end

  def rss_description(installer, build)
    build ? build.changeset : ''
  end

  def rss_pub_date(build)
    format_time(build ? build.time : Time.at(0), :rss)
  end

  def rss_link(installer, build)
    build ? build_url(:only_path => false, :installer => installer, :build => build) :
            installer_without_builds_url(:only_path => false, :installer => installer)            
  end

  def show_revisions_in_build(revisions)
    return '' if revisions.empty?    
    if revisions.length == 1
      revision = revisions[0]
      text = "<div><span class='build_committed_by'>#{revision.committed_by}</span>" + ' committed the checkin</div>'
      # TODO: <br/> - should probably use css instead.
      text += '<br/>'
      text +="<div>Comments:<br/>#{format_changeset_log(revision.message)}</div>" unless revision.message.empty?
      text
    else
      committers = revisions.collect { |rev| rev.committed_by }.uniq
      text = "<div><span class='build_committed_by'>#{committers.join(', ')}</span>" + ' committed the checkin</div>'
    end
  end

  def revisions_in_build(build)    
    changeset = build.changeset
    ChangesetLogParser.new.parse_log changeset.split("\n")
  end

  # Re-map our installer statuses to match the installer statuses recognized
  # by CCTray.Net
  def map_to_cctray_installer_status(installer_status)
    case installer_status.to_s
    when 'success', 'building' then 'Success'
    when 'never_built' then 'Unknown'
    when 'failed' then 'Failure'
    else 'Unknown'
    end
  end

  # Re-map our build activities to match the build activities recognized
  # by CCTray.Net
  def map_to_cctray_activity(builder_state)
    case builder_state.to_s
    when 'checking_for_modifications' then 'CheckingModifications'  
    when 'building' then 'Building'
    when 'sleeping', 'builder_down' then 'Sleeping'
    else 'Unknown'
    end
  end

end
