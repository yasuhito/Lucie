module InstallsHelper
  def format_install_log log
    h log
  end


  def display_install_time
    elapsed_time_text = install_elapsed_time( @install, :precise )
    install_time_text = format_time( @install.time, :verbose )
    elapsed_time_text.empty? ? "finished at #{install_time_text}" : "finished at #{install_time_text} taking #{elapsed_time_text}"
  end
end
