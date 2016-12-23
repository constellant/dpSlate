# create a custom renderer for dpSlate Markdown

require "middleman-core/renderers/redcarpet"

$headCount =0  # create a sequential counter use in rendering headers to ensure each has a unique ID cross the site

class DpSlateRenderer < Middleman::Renderers::MiddlemanRedcarpetHTML
    
  def header(text, header_level)
    $headCount = $headCount + 1
    "<h%s id=\"%s-%d\">%s</h%s>" % [header_level, text.parameterize, $headCount, text, header_level]
  end
  
  def image(link, title, alt_text)
    title.nil? ? titleParm = "" : titleParm = "title='#{title}'"
    alt_text.nil? ? alt_textParm = "" : alt_textParm = "alt='#{alt_text}'"
    "<img class='lazy' #{titleParm} #{alt_textParm} data-original='#{link}' />"
  end
    
  #
  # Override paragraph to support custom alerts.
  #
  # @param [String] text
  # @return [String]
  #
  def paragraph(text)
    add_alerts("#{text.strip}\n")
  end
    
  #
  # Add alert text to the given markdown.
  #
  # @param [String] text
  # @return [String]
  #
  def add_alerts(text)
    map = {
      "=&gt;" => "success",
      "-&gt;" => "notice",
      "~&gt;" => "warning",
      "!&gt;" => "danger",
    }

    regexp = map.map { |k, _| Regexp.escape(k) }.join("|")

    if md = text.match(/^(#{regexp})/)
      key = md.captures[0]
      klass = map[key]
      text.gsub!(/#{Regexp.escape(key)}\s+?/, "")

      return <<-EOH.gsub(/^ {8}/, "")
        <aside class="#{klass}">#{text}</aside>
      EOH
    else
      return "<p>" + text + "</p>"
    end
  end
    
end

# set the folders up for dpEngine

set :source, 'source'
set :build_dir, 'site'
set :layouts_dir, 'layouts'
set :partials_dir, 'includes'
set :images_dir, 'dpSlateStatic/images'

# set the folders for Static files

set :data_dir, 'dpSlateStatic/data'
set :css_dir, 'dpSlateStatic/css'
set :js_dir, 'dpSlateStatic/js'
set :fonts_dir, 'dpSlateStatic/fonts'

# Markdown
set :markdown_engine, :redcarpet
set :markdown,
    fenced_code_blocks: true,
    smartypants: true,
    disable_indented_code_blocks: true,
    prettify: true,
    tables: true,
    footnotes: true,
    with_toc_data: true,
    no_intra_emphasis: true,
    strikethrough: true,
    renderer: DpSlateRenderer

# Activate the syntax highlighter
activate :syntax

# Github pages require relative links but dpEngine does not
#activate :relative_assets
#set :relative_links, true


# Build configuraton
configure :build do
  # dpEngine configuration call with '$ DP=true bundle exec middleman build'    
  if ENV['DP']
    set :build_dir, '../site'
    set :layouts_dir, 'layouts/gsp/'
    template_extensions :md => :gsp, :erb => :gsp
    set :http_prefix, "/site/"    
  end
  activate :minify_css
  activate :minify_javascript
  # activate :relative_assets
  # activate :asset_hash
  # activate :gzip
  activate :autoprefixer do |config|
    config.browsers = ['last 2 version', 'Firefox ESR']
    config.cascade  = false
    config.inline   = true
  end
end
