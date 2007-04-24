#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


# A Progress is the abstract base class used to derive a ProgressBar
# which provides a visual text-based representation of the progress of
# a long running operation.
#
# Progress は、ProgressBar へ派生するアブストラクトベースクラスです。
# ProgressBar は、長時間にわたる操作の進行状況を、視覚的にテキスト表示
# します。
#
class Progress
  VERSION = '0.6.3'.freeze


  # Returns a new Progress object.
  #
  # 新しい Progress object を返します。
  # 
  def initialize
    @activity_mode = false
    @show_text = false
  end


  # Return a value indicating wheter activity mode is enabled.
  #
  # * _Returns_ : true if activity mode is enabled.
  #
  # アクティビティモードが有効かどうかを返します。
  #
  # * 返り値 : アクティビティモードが有効であれば true。
  # 
  def activity_mode?
    @activity_mode
  end


  # Sets a value indicating whether activity mode is enabled.
  #
  # * _enable_ : true if activity mode is enabled.
  # * _Returns_ : enable
  #
  # アクティビティモードが有効か無効かをセットします。
  #
  # * _enable_ : アクティビティモードを有効にするのであれば true。
  # * 返り値 : enable 
  #
  def activity_mode=( enable )
    raise TypeError unless is_bool?( enable )
    @activity_mode = enable
  end


  # Same as activity_mode=.
  #
  # * _enable_ : true if activity mode is enabled.
  # * _Returns_ : self
  #
  # activity_mode= と同じです。
  #
  # * _enable_ : アクティビティモードを有効にするのであれば true。
  # * 返り値 : self
  #
  def set_activity_mode( enable )
    raise TypeError unless is_bool?( enable )
    @activity_mode = enable
    self
  end


  # Return a value indicating wheter the progress is shown as text.
  #
  # * _Returns_ : true if the progress is shown as text.
  #
  # 進行状況をテキストで表示するかどうかを返します。
  #
  # * 返り値 : 進行状況をテキストで表示するのであれば true。
  #
  def show_text?
    @show_text
  end


  # Sets a value indicating whether the progress is shown as text.
  #
  # * _shown_ : true if the progress is shown as text.
  # * _Returns_ : shown
  #
  # 進行状況をテキストで表示するかどうかをセットします。
  #
  # * _shown_ : 進行状況をテキストで表示するのであれば true。
  # * 返り値 : shown
  #
  def show_text=( shown )
    raise TypeError unless is_bool?( shown )
    @show_text = shown
  end


  # Same as show_text=.
  #
  # * _shown_ : true if the progress is shown as text.
  # * _Returns_ : shown
  #
  # show_text= と同じ。
  #
  # * _shown_ : 進行状況をテキストで表示するのであれば true。
  # * 返り値 : shown
  #
  def set_show_text( shown )
    raise TypeError unless is_bool?( shown )
    @show_text = shown
  end


  private


  def is_bool?( bool )
    bool.is_a?( TrueClass ) or bool.is_a?( FalseClass )
  end
end


### Local variables:
### mode: Ruby
### coding: euc-jp-unix
### indent-tabs-mode: nil
### End:
