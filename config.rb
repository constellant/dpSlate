require "./lib/DpSlateRender"   # pull in the dpSlate Markdown with extensions to redcarpet markdown
require "./lib/DpSlateHelpers"  # get the dpSlate Helpers
helpers DpSlateHelpers

# set the folders up for dpEngine

set :source, 'source'
set :build_dir, 'site'
set :layouts_dir, 'layouts/html/'
set :partials_dir, 'includes'
set :images_dir, 'static/images'

# set the folders for Static files

set :data_dir, 'static/data'
set :css_dir, 'static/css'
set :js_dir, 'static/js'
set :fonts_dir, 'static/fonts'

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
activate :vcs_time

# Github pages require relative links but dpEngine does not
#activate :relative_assets
#set :relative_links, true


# Build configuraton
configure :build do
  # dpEngine configuration call with '$ DP=true bundle exec middleman build'    
  if ENV['DP']
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
