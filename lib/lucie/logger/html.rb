require "configuration"
require "installer"
require "lucie/io"
require "lucie/utils"
require "lucie/version"
require "nodes"


module Lucie
  module Logger
    class HTML
      include Lucie::IO
      include Lucie::Utils


      REFRESH_INTERVAL = 10


      def self.log_file
        File.join Configuration.log_directory, "install.html"
      end


      def initialize debug_options
        @debug_options = debug_options
      end


      #
      # install_options holds site-wide installation settings.
      # e.g. debian version to be installed, LDB repository uri, and
      # so on.
      #
      def start install_options
        @install_options = install_options
        @status = {}
        @current_step = Hash.new( -1 )
        info "HTML log file: #{ HTML.log_file }"
        make_log_directory
        update_html
      end


      def update_status node, status
        @status[ node ] = status
      end


      def next_step node
        @current_step[ node ] += 1
      end


      def update_html
        write_file HTML.log_file, <<-EOF, @debug_options
<html>
  <head>
    <meta http-equiv="Refresh" content="#{ REFRESH_INTERVAL }">
    <title>Lucie html log</title>
  #{ css }
  </head>

  <body>
#{ install_options_html }
#{ node_list_html }
#{ footer_html }
  </body>
</html>
EOF
      end


      ##########################################################################
      private
      ##########################################################################


      def make_log_directory
        unless FileTest.directory?( Configuration.log_directory )
          mkdir_p Configuration.log_directory, @debug_options
        end
      end

      
      def nodes_sorted_by_name
        @status.keys.sort_by do | each |
          each.name
        end
      end


      # HTML snippets ##########################################################


      def install_options_html
        return <<-HTML
    <div class="header">

    <div class="config">
      <span class="config_item">
        <b>Debian Release:</b> <a href="http://www.debian.org/releases/#{ @install_options[ :suite ] }/">#{ @install_options[ :suite ] }</a>
      </span>
      #{ @install_options[ :ldb_repository ] ? "<span class=\"config_item\"><b>LDB Repository:</b> #{ @install_options[ :ldb_repository ] }</span>" : "" }
      <span class="config_item">
        <b>Package Repository:</b> <a href="#{ ::Installer::DEFAULT_PACKAGE_REPOSITORY }">#{ ::Installer::DEFAULT_PACKAGE_REPOSITORY }</a>
      </span>
      #{ @install_options[ :http_proxy ] ? %{<span class="config_item"><b>HTTP Proxy:</b> <a href="#{ @install_options[ :http_proxy ] }">#{ @install_options[ :http_proxy ] }</a></span>} : "" }
    </div>

    <div class="hstatus">
      <span class="hstatus_item">
        <b>Incomplete Nodes:</b> #{ incomplete_nodes.join( ", " ) }
      </span>
      <span class="hstatus_item">
        <b>Success Nodes:</b> #{ success_nodes.join( ", " ) }
      </span>
      <span class="hstatus_item">
        <b>Failure Nodes:</b> #{ failure_nodes.join( ", " ) }
      </span>
    </div>

    </div>
HTML
      end


      def incomplete_nodes
        Nodes.load_all.select do | each |
          each.status and each.status.incomplete?
        end.collect do | each |
          each.name
        end.sort
      end


      def success_nodes
        Nodes.load_all.select do | each |
          each.status and each.status.succeeded?
        end.collect do | each |
          each.name
        end.sort
      end


      def failure_nodes
        Nodes.load_all.select do | each |
          each.status and each.status.failed?
        end.collect do | each |
          each.name
        end.sort
      end


      def spinner_html node
        status = %{<span class="status">#{ @status[ node ] }</span>}
        case @status[ node ]
        when /\Afailed/
          %{<img src="./images/spinner_error.gif"/> #{ status }}
        when /\Aok\Z/
          status
        else
          %{<img src="./images/spinner.gif"/> #{ status }}
        end
      end


      def node_status_html node
        return <<-HTML
      <div class="#{ status_div_class_of( node ) }">
	<table>
          <tr><td>
            <span class="node_name"><a href="#{ Lucie::Logger::Installer.latest_log_relative( node ) }">#{ node.name }</a></span> #{ spinner_html( node ) }
          </tr></td>
          <tr><td>
            <ul class="step10">
#{ steps_html( node ) }              
	    </ul>
	</td></tr></table>
      </div>
HTML
      end


      def status_div_class_of node
        case @status[ node ]
        when /\Afailed/
          "fail"
        when /manual reboot/
          "manual_reboot"
        when /\Aok\Z/
          "success"
        else
          "incomplete"
        end
      end


      def node_list_html
        list = nodes_sorted_by_name.collect do | each |
          node_status_html each
        end
        return <<-HTML
    <div class="node_list">
#{ list.join( "\n" ) }
    </div>
HTML
      end


      #
      # [TODO] make hyperlinks from each step to raw log
      #
      def steps_html node
        html = ""
        ::Installer::STEPS.each_with_index do | each, index |
          li_attr = []
          li_attr << %{class="past"} if index < @current_step[ node ]
          li_attr << %{class="active"} if index == @current_step[ node ]
          li_attr << %{id="lastStep"} if index == 9
          html += %{<li #{ li_attr.join( " " ) }><span><a href="">#{ index + 1 }</a></span><a href="#">#{ each }</a></li>\n}
        end
        html
      end


      def footer_html
        return <<-HTML
    <div class="footer">
      <a href="http://lucie.is.titech.ac.jp/">Lucie Version #{ Lucie::VERSION::STRING }</a>
    </div>
HTML
      end


      def css
        <<-CSS
    <style type='text/css'>
* {
  margin:0px;
  padding:0px;
  color:#333333;
  font-family: verdana,arial,helvetica;
  font-size:10px;
}


/******************************************************************************/
/* Header                                                                     */
/******************************************************************************/

.header {
  background-position: top;
  background-repeat: repeat-x;
  background-image: url(images/top_gradient.png);
  clear: both;
}

.header a {
  color: #507ec0;
  text-decoration: none;
}

.hstatus { 
  color: #507ec0;
  padding: 0.5em 0 0.5em 1.5em;
}

.hstatus .hstatus_item {
  color: #666;
  display: block;
  font-size: 0.8em;
  text-align: left;
  padding: 0 0.2em 0 0.35em;
}

.config {
  color: #507ec0;
  padding: 0.5em 1.5em 0.5em 0.5em;
  float: right;
}

.config .config_item {
  color: #666;
  display: block;
  font-size: 0.8em;
  text-align: right;
  padding: 0 0.35em 0.2em 0;
}

/******************************************************************************/
/* Footer                                                                     */
/******************************************************************************/

.footer {
  font-size: 0.7em;
  color: #999;
  text-align: right;
  padding: 2em 1em 0 0;
  clear: both;
}

.footer a {
  color: #507ec0;
  text-decoration: none;
}

/******************************************************************************/
/* Node List                                                                  */
/******************************************************************************/

.node_list table {
  margin: 0 0 0 1.5em;
}

.node_name a {
  padding: 0;
  margin: 0 15px 0 0;
  font-size: 3em;
  font-weight: normal;
  color: #507ec0;
  text-decoration: none;
}

.status {
  font-size: 1.5em;
  font-weight: bold;
}

.success {
  background-position: bottom;
  background-repeat: repeat-x;
  background-image: url(./images/green_gradient.png);
}

.fail {
  background-position: bottom;
  background-repeat: repeat-x;
  background-image: url(./images/red_gradient.png);
}

.incomplete {
  background-position: bottom;
  background-repeat: repeat-x;
  background-image: url(./images/gray_gradient.png);
}

.manual_reboot {
  background-position: bottom;
  background-repeat: repeat-x;
  background-image: url(./images/yellow_gradient.png);
}

/* Easy CSS Progress Bar 1.0 - by Koller Juergen [www.kollermedia.at] */
ul {width:800px; list-style:none; margin:10px; clear:both; float:left;}
ul a {text-decoration:none; color:#a9a9a9;}
ul li {float:left; width:25%; background:url(./images/arrow.gif) repeat-x right 6px; text-align:left;}
ul.step10 li {width:10%;} ul.step10 li a {margin-right:25%;} ul.step10 li span a {display:block; width:19px; height:19px; margin:0px;}  /*only needed if you want to use 10 Steps*/
ul li span {display:block; margin:auto; margin-right:50%; text-align:center; border:1px solid #a9a9a9; width:19px; height:19px; line-height:19px; background-color:#ffffff;}
ul li span a {display:block; width:19px; height:19px; margin:0px;}
ul li span a.active, ul li.active span a, ul li.past span a:hover, ul li.past:hover span a {background-color:#333333; color:#ffffff; }
ul li a {display:block; margin-right:11%; text-align:center;}
ul li.past {background-position:right -106px;}
ul li.active {background-position:right -48px;}
ul li#lastStep {background-position:right -214px;}
ul li#lastStep.active {background-position:right -160px;}
ul li.active a:hover, ul li.past a:hover, ul li.past a, ul li.active a {color:#333333;}
ul li.active span a:hover {color:#ffffff;}
ul li.past:hover {cursor:hand; cursor:pointer;}
ul li.past span, ul li.active span {border:1px solid #333333;}
    </style>
CSS
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
