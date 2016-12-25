require "middleman-core/renderers/redcarpet"

$headCount =0  # create a sequential counter use in rendering headers to ensure each has a unique ID cross the site

class DpSlateRenderer < Middleman::Renderers::MiddlemanRedcarpetHTML
  
  #
  #  Override the Header tag to insert a unique identifer across all documents
  #    
  # @param [String] text - the text of the header
  # @param [Integer] header_level - the level of the header (1 to 6)
  # Global Variable [Integer] $headCount - the count of the total number of headers being used in the build
  # @return [String] - return HTML for the h tag with a unique ID based upon the level and header count
  #
  def header(text, header_level)
    $headCount = $headCount + 1
    "<h%s id=\"%s-%d\">%s</h%s>" % [header_level, text.parameterize, $headCount, text, header_level]
  end
  
  #
  #  Overide the image tag to use lazyload.js and improve load performance by only loading images when needed
  #     
  # @param [String] link - the link (href) of the image
  # @param [String] title - the title of the image
  # @param [String] alt_text - the alternative text used for the image
  # @return [String] - return HTML for the image tage set up for Lazyload
  #
  def image(link, title, alt_text)
    title.nil? ? titleParm = "" : titleParm = "title='#{title}'"
    alt_text.nil? ? alt_textParm = "" : alt_textParm = "alt='#{alt_text}'"
    "<img class='lazy' #{titleParm} #{alt_textParm} data-original='#{link}' />"
  end
    
  #
  # Override paragraph to support custom alerts by calling the add_alerts method
  #
  # @param [String] text - the text of the next markdown paragraph
  # @return [String] - the text of the next markdown paragraph with the alert now as HTML
  #
  def paragraph(text)
    add_alerts("#{text.strip}\n")
  end
    
  #
  # Add alert text to the given markdown.
  #
  # @param [String] text - the text of all markdown paragraphs
  # @return [String] - the text of the markdown paragraph with the alert transformed into HTML
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
      
  #
  # add the include markdown {{filename}}
  #
  # @param [String] full_document - the markdown text of the entire document prior to any processing
  # @return [String] - the markdown text of the entire document with include files added
  #
  def preprocess(markdown)
     add_abbr(get_includes (markdown))
  end
      
  def get_includes(markdown)
    # look for an include of the form {{filename}} split it into the leftHandString, the filename, and the rightHandString
    if n = markdown.match(/^\{\{.*\}\}/)
        include = n[0].gsub(/^\{\{|\}\}/, '')
        parts = markdown.split(/^\{\{.*\}\}/, 2)
        if File.exists? (include)
            file = File.open(include, "r")
            newmd = file.read
            file.close
        else
            newmd = "\n**dpSlate ERROR**: Include File not found: " + include + "\n"
        end
        return [parts[0], get_includes([newmd, "\n", parts[1]].join(""))].join("")
    else
      return markdown
    end
  end
      
  def add_abbr(markdown)
    abbrRegex = /^\*\[([-A-Z0-9]+)\]: (.+)$/
    abbreviations = markdown.scan(abbrRegex)
    abbreviations = Hash[*abbreviations.flatten]
    if abbreviations.any?
      markdown.gsub!(abbrRegex, "")
      markdown.rstrip!
      abbreviations.each do |key, value|
        html = '<abbr title="' + value +'">' + key + '</abbr>'
        markdown.gsub!(/\b#{key}\b/, html)
      end
    end
    markdown
  end

end      

      