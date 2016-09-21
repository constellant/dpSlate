# create a custom renderer for dpSlate Markdown

require "middleman-core/renderers/redcarpet"

class DpSlateRenderer < Middleman::Renderers::MiddlemanRedcarpetHTML

  def initialize
    $headCount = 0
    super
  end    
  
  def header(text, header_level)
    $headCount = $headCount + 1
    "<h%s id=\"%s-%d\">%s</h%s>" % [header_level, text.parameterize, $headCount, text, header_level]
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

# Define a helper to create a formated date string

helpers do
    def datestring()
    Time.now.strftime('%B %d, %Y')
    end
end

