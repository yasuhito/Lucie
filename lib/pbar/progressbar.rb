# = Ruby/ProgressBar - a text progress bar library
# = Ruby/ProgressBar - テキストのプログレスバーライブラリ
#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require 'pbar/progress'


# The ProgressBar is typically used to display the progress of a long
# running operation. It provides a visual clue that processing is
# underway. The ProgressBar can be used in two different modes:
# percentage mode and activity mode.
#
# ProgressBar は、実行時間の長いオペレーションの進行状況を表示するのに
# よく用いられます。プロセスが進行中である視覚的な手がかりを与えます。
# ProgressBar は 2 つの異なるモードで使用できます。パーセンテージモー
# ドとアクティビティモードです。
#
# When an application can determine how much work needs to take place
# (e.g. read a fixed number of bytes from a file) and can monitor its
# progress, it can use the ProgressBar in percentage mode and the user
# sees a growing bar indicating the percentage of the work that has
# been completed. In this mode, the application is required to call
# ProgressBar#fraction= periodically to update the progress bar.
#
# アプリケーションがどれほどの仕事を必要としているかが決定でき (たとえ
# ば、決まったバイト数をあるファイルから読みこむ場合など)、その進行状
# 況をモニタできる場合、パーセンテージモードを使用することによって、ユー
# ザは仕事の完了度合のパーセンテージを、バーの伸び具合で知ることができ
# ます。このモードでは、アプリケーションはプログレスバーを更新するため
# に、周期的に ProgressBar#fraction= を呼ぶ必要があります。
#
# When an application has no accurate way of knowing the amount of
# work to do, it can use the ProgressBar in activity mode, which shows
# activity by a block moving back and forth within the progress
# area. In this mode, the application is required to call
# ProgressBar#pulse perodically to update the progress bar.
#
# アプリケーションが正確な総仕事量を決定できない場合、ProgressBar をア
# クティビティモードで使用できます。このモードでは、アクティビティをプ
# ログレスエリアの中で行き来するブロックで表示します。このモードでは、
# アプリケーションはプログレスバーを更新するために、周期的に 
# ProgressBar#pulse を呼ぶ必要があります。
#
# There is quite a bit of flexibility provided to control the
# appearance of the ProgressBar. Methods are provided to control the
# orientation of the bar, optional text can be displayed along with
# the bar, and the step size used in activity mode can be set.
#
# ProgressBar の外観をコントロールするための柔軟性がほんのちょっとだけ
# 用意されています。バーの方向をコントロールするメソッドや、必要によっ
# てバーとともにテキストを表示する機能、アクティビティモードでのステッ
# プサイズの設定があります。
# 
class ProgressBar < Progress
  LEFT_TO_RIGHT = 0
  RIGHT_TO_LEFT = 1


  # Creates a new ProgressBar.
  #
  # _Returns_ : a ProgressBar.
  #
  # 新たな ProgressBar オブジェクトを作ります。
  #
  # 返り値 : ProgressBar オブジェクト。
  #
  def initialize
    super
    @fraction = 0.0
    @pulse_step = 0.01
    @text = ''
    @orientation = LEFT_TO_RIGHT
    @start_time = Time.now
    @out = STDERR
    @bar_length = 80
  end


  # Indicates that some progress is made, but you don't know how
  # much. Causes the progress bar to enter "activity mode," where a
  # block bounces back and forth. Each call to ProgressBar#pulse
  # causes the block to move by a little bit (the amount of movement
  # per pulse is determined by ProgressBar#pulse_step=).
  #
  # * _Returns_ : self
  #
  # このメソッドでは、なんらかの進捗があったが、どの程度かはわからない、
  # ということを表すのに用います。このメソッドは、プログレスバーを "ア
  # クティビティモード" に設定します。このモードでは、ブロックが行った
  # り来たりするようになります。ProgressBar#pulse を呼ぶたびに、ブロッ
  # クはほんのちょっと移動します (pulse 呼出し毎の移動量は 
  # ProgressBar#pulse_step= によって決定されます)。
  # 
  # * 返り値 : self
  #
  def pulse
    @activity_mode = true
    @fraction += @pulse_step
    show
    self
  end


  # Retrieves the pulse step set with ProgressBar#pulse_step=.
  #
  # * _Returns_ : a fraction from 0.0 to 1.0
  #
  # ProgressBar#pulse_step= によって設定された pulse のステップサイズ
  # を取得します。
  #
  # * 返り値 : 0.0 から 1.0 の間の数
  #
  def pulse_step
    @pulse_step
  end

  
  # Sets the fraction of total progress bar length to move the
  # bouncing block for each call to ProgressBar#pulse.
  #
  # * _fraction_ : fraction between 0.0 and 1.0
  # * _Returns_ : fraction
  #
  # ProgressBar#pulse の呼出し毎のブロックの移動量を、プログレスバー全
  # 体の長さへの比で指定します。
  #
  # * _fraction_ : 0.0 から 1.0 の間の数
  # * 返り値 : fraction
  #
  def pulse_step=( fraction )
    @pulse_step = fraction
  end


  # Same as pulse_step=.
  #
  # * _fraction_ : fraction between 0.0 and 1.0
  # * _Returns_ : self
  #
  # pulse_step= と同じです。
  #
  # * _fraction_ : 0.0 から 1.0 の間の数
  # * 返り値 : self
  #
  def set_pulse_step( fraction )
    @pulse_step = fraction
    self
  end


  # Returns the current text to appear beside the progress bar.
  #
  # * _Returns_ : text
  #
  # 現在プログレスバーの脇に表示されているテキストを返します。
  #
  # * 返り値 : text
  #
  def text
    @text
  end


  # Causes the given text to appear beside the progress bar.
  #
  # * _text_ : a String
  # * _Returns_ : text
  #
  # text をプログレスバーの脇に表示します。
  #
  # * _text_ : String オブジェクト
  # * 返り値 : text
  #
  def text=( text )
    @text = text
  end


  # Same as text=.
  #
  # * _text_ : a String
  # * _Returns_ : self
  #
  # text= と同じ。
  #
  # * _text_ : String オブジェクト。
  # * 返り値 : self
  #
  def set_text( text )
    @text = text
    self
  end


  # Returns the current fraction of the task that's been completed.
  #
  # * _Returns_ : a fraction from 0.0 to 1.0
  #
  # 現在完了している仕事の割合を返します。
  #
  # * 返り値 : 0.0 から 1.0 の間の数
  #
  def fraction
    @fraction
  end


  # Causes the progress bar to "fill in" the given fraction of the
  # bar. The fraction should be between 0.0 and 1.0, inclusive.
  #
  # * _fraction_ : fraction of the task that's been completed
  # * _Returns_ : fraction
  #
  # プログレスバーを与えられた割合の長さにします。fraction は 0.0 以上 
  # 1.0 以下です。
  #
  # * _fraction_ : タスクの完了度合。
  # * 返り値 : fraction
  #
  def fraction=( fraction )
    @fraction = fraction
    show
    @fraction
  end


  # Same as fraction=.
  #
  # * _fraction_ : fraction of the task that's been completed
  # * _Returns_ : self
  #
  # fraction= と同じです。
  #
  # * _fraction_ : タスクの完了度合。
  # * 返り値 : self
  #
  def set_fraction( fraction )
    @fraction = fraction
    show
    self
  end


  # Retrieves the current progress bar orientation.
  #
  # * _Returns_ : orientation of the progress bar
  # 
  # 現在のプログレスバーの伸びる方向を返します。
  #
  # * 返り値 : プログレスバーの伸びる方向。
  # 
  def orientation
    @orientation
  end


  # Causes the progress bar to switch to a different orientation
  # (left-to-right or right-to-left).
  #
  # * _orientation_ : orientation of the progress bar.
  # * _Returns_ : orientation
  #
  # プログレスバーの伸びる方向を変更します。
  # (左から右 もしくは 右から左).
  #
  # * _orientation_ : プログレスバーの伸びる方向。
  # * 返り値 : orientation
  #
  def orientation=( orientation )
    @orientation = orientation
  end


  # Same as orientation=.
  #
  # * _orientation_ : orientation of the progress bar.
  # * _Returns_ : orientation
  #
  # orientation= と同じです。
  #
  # * _orientation_ : プログレスバーの伸びる方向。
  # * 返り値 : orientation
  #
  def set_orientation( orientation )
    @orientation = orientation
  end


  # Returns a String containing a human-readable representation of
  # ProgressBar.
  # 
  # ProgressBar の状態を人間に読める形式の String で返します。
  #
  def inspect
    "(ProgressBar: #{percentage}%)"
  end


  private


  def percentage
    return ( @fraction * 100 ).to_i
  end


  def bar_mark
    '='
  end
  
  
  def bar_activity
    sbar_len = 8
    len = @bar_length * percentage / 100
    
    if toward_left?
      sprintf('[%s%s%s]',
              blank_char * (@bar_length - (len % @bar_length)),
              '<' + bar_mark * sbar_len + '>', 
              blank_char * [(len % @bar_length - sbar_len), 0].max)
    else
      sprintf('[%s%s%s]',
              blank_char * [(len % @bar_length - sbar_len), 0].max, 
              '<' + bar_mark * sbar_len + '>', 
              blank_char * (@bar_length - (len % @bar_length)))
    end
  end


  def toward_left?
    return( ( @fraction.to_i % 2 ) == 1 )
  end


  def bar
    len = @bar_length * percentage / 100
    if @orientation == LEFT_TO_RIGHT
      sprintf('[%s%s]', bar_mark * (len) + '>', blank_char * (@bar_length - len))
    elsif @orientation == RIGHT_TO_LEFT
      sprintf('[%s%s]', blank_char * (@bar_length - len), '<' + bar_mark * (len))
    end
  end


  def eta
    elapsed = Time.now - @start_time
    sprintf('ETA:  %s', format_time(elapsed))
  end


  def format_time(t)
    t = t.to_i
    sec = t % 60
    min  = (t / 60) % 60
    hour = t / 3600
    sprintf('%02d:%02d:%02d', hour, min, sec);
  end


  # set @bar_length properly and output a line on @out.
  def show
    textarea_length = width/4
    if @show_text
      if @text.length < textarea_length
        text_truncated = ' ' * (textarea_length - @text.length) + @text
      else
        text_truncated = @text[0...(width/4-2)] + '..'
      end
      if @activity_mode
        line = sprintf('%s: ---%% %s %s', text_truncated, bar_activity, eta)
      else
        line = sprintf('%s: %3d%% %s %s', text_truncated, percentage, bar, eta)
      end
    else
      if @activity_mode
        line = sprintf(' ' * (textarea_length+7) + "%s %s", bar_activity, eta)
      else
        line = sprintf("%#{textarea_length+5}d%% %s %s", percentage, bar, eta)
      end
    end
    
    if justfit_width?(line.length, width)
      @out.print(line + eol)
    elsif line.length >= width
      @bar_length = [@bar_length - (line.length - width + 1), 0].max
      if @bar_length == 0 then @out.print(line + eol) else show end
    elsif line.length < width - 1
      @bar_length += width - line.length + 1
      show
    end
  end


  #++
  # FIXME: I don't know how portable ioctrl is.
  #--
  def width
    begin
      tiocgwinsz = 0x5413
      data = [0, 0, 0, 0].pack('SSSS')
      if @out.ioctl(tiocgwinsz, data) >= 0 
        rows, cols, xpixels, ypixels = data.unpack('SSSS')
        if cols >= 0 then cols else default_width end
      else
        default_width
      end
    rescue Exception
      default_width
    end
  end


  def default_width
    80
  end


  def justfit_width?( line_length, width )
    line_length == (width - eol.length)
  end


  def eol
    "\r"
  end


  def blank_char
    ' '
  end
end


### Local variables:
### mode: Ruby
### coding: euc-jp-unix
### indent-tabs-mode: nil
### End:
