# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def format_time(time, format = :iso)
    TimeFormatter.send(format, time)
  end


  def format_seconds(total_seconds, format = :general)
    DurationFormatter.new(total_seconds).send(format)
  end


  def setting_row(label, value, help = '&nbsp;')
    <<-EOL
    <tr>
      <td class='label'>#{label} :</td>
      <td>#{value}</td>
      <td class='help'>#{help}</td>
    </tr>
    EOL
  end


  def link_to_install install
    text = install_label( install )
    if install.failed?
      text += " <span class='error'>FAILED</span>"
    end
    return text
  end


  def link_to_build(installer, build)
    text = build_label(build)
    text += " <span class='error'>FAILED</span>" if build.failed?
    build_link(text, installer, build)
  end


  def text_to_install install, with_elapsed_time = true
    text = install_label( install )
    if install.failed?
      text += " <span class='error'>FAILED</span>"
    elsif install.incomplete?
      text += ' incomplete'
    else
      elapsed_time_text = install_elapsed_time( install )
      if (with_elapsed_time and !elapsed_time_text.empty?)
        text += " took #{elapsed_time_text}"
      end
    end
    return text
  end


  def text_to_build(build, with_elapsed_time = true)
    text = build_label(build)
    if build.failed?
      text += ' FAILED'
    elsif build.incomplete?
      text += ' incomplete'
    else
      elapsed_time_text = build_elapsed_time(build)
      text += " took #{elapsed_time_text}" if (with_elapsed_time and !elapsed_time_text.empty?)
    end
    return text
  end

  def link_to_build_with_elapsed_time(installer, build)
    build_link(text_to_build(build), installer, build)
  end

  def display_builder_state(state)
    case state
    when 'building', 'builder_down', 'build_requested', 'svn_error'
      "<div class=\"builder_status_#{state}\">#{state.gsub('_', ' ')}</div>"
    when 'sleeping', 'checking_for_modifications'
      ''
    else
      "<div class=\"builder_status_unknown\">#{h state}<br/>unknown state</div>"
    end
  end

  def format_changeset_log(log)
    h(log.strip)
  end


  def install_elapsed_time install, format = :general
    begin
      "<span>#{ format_seconds( install.elapsed_time, format ) }</span>"
    rescue
      '' # The install time is not present.
    end
  end


  def build_elapsed_time build, format = :general
    begin
      "<span>#{ format_seconds( build.elapsed_time, format ) }</span>"
    rescue
      '' # The build time is not present.
    end
  end


  def build_link(text, installer, build)
    link_to text, build_url(:installer => installer.name, :build => build.label), :class => build.status
  end


  private


  def build_label(build)
    "#{build.label} (#{format_time(build.time, :human)})"
  end


  def install_label install
    "#{ install.label } (#{ format_time( install.time, :human ) })"
  end
end
