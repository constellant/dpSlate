require "middleman-core/renderers/redcarpet"
require "middleman-core/logger"
require "pp"

$headCount =0                             # create a sequential counter use in rendering headers to ensure each has a unique ID cross the site
      
class DpSlateRenderer < Middleman::Renderers::MiddlemanRedcarpetHTML

  $footnoteDefs = {}  # create a hash that contains the footnote defs for creating the popovers in cleanup
  $footnoteDiv = ""   # a global string with the ordered list of all of the footnotes
  $abbrList = []      # create an array of strings that contain all of the abbreviations for the end of the document

  #
  # add_abbr - Change abbreviation markdown into HMTL and span each occurance in the document
  #
  # @param [String] full_document - the markdown text of the entire document prior to any processing
  # @return [String] - the markdown text with all of the abbreviations processed
  #      
      
  def add_abbr(markdown)
    abbrRegex = /^\*\[([-A-Z0-9]+)\]: (.+)$(?=(?:[^`]*`[^`]*`)*[^`]*\Z)/
    # Regex to scan for the abbreviations and definitions but ignoring those in code blocks
    abbreviations = markdown.scan(abbrRegex)
    abbreviations = Hash[*abbreviations.flatten]
    if abbreviations.any?
      markdown.gsub!(abbrRegex, "")
      markdown.rstrip!
      abbreviations.each do |key, value|
        html = "<a href='javascript: void(0)' data-toggle='popover' data-placement='bottom' data-trigger='focus' data-content='#{value}'>#{key}</a>"
        markdown.gsub!(/(\b#{key}\b)(?=(?:[^`]*`[^`]*`)*[^`]*\Z)/, html)
        # look for the key, but ignore occurances inside of code blocks
        $abbrList.push ("<p><em>#{key}</em> - #{value}</p>")  
      end
    end
    markdown
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

  
  # footnote_def - create the list element for each footnote definition.  Take the number of the footnote and the defintion and
  # place it into a global hash such that it can be used in postprocessing to insert the definition into the footnote ref's popover
  #
  # @param [String] content - the string content of the footnote
  # @param [integer] number - the cardinal value sequentially assigned to the footnote
  # @return [String] - the HTML that will be inserted for the footnote reference
  #        
  def footnote_def(content, number)
     numberStr = number.to_s
     content.gsub!(/\<p\>|\<\/p\>/, "")
     key = "replaceFnDef#{numberStr}"
     $footnoteDefs[key] = content 
     return "<li>#{content}</li>" 
  end

  #
  # footnote_ref - create a footnote reference for each occurance as a bootstrap popover.  Create a dummy string for the contents of the
  # popover that will be replaced by the footnote definition in postprocessing
  #
  # @param [integer] number - the cardinal value sequentially assigned to the footnote
  # @return [String] - the HTML that will be inserted for the footnote reference
  #        
  def footnote_ref(number)
      ref = number.to_s
      return "<sup id='fnref#{ref}'>
                <a href='javascript: void(0)' data-toggle='popover' data-container='body' data-placement='bottom' data-trigger='focus' data-html='true' data-content='replaceFnDef#{ref}'>#{ref}</a>
              </sup>"
  end

  #
  # footnotes - take the final list of footnotes (as <li>) and save them to a global variable for subsequent use in the {{$footnotes}} include.  Then
  # exit without doing anything such that the user can control if and when footnotes are output for print.
  #
  # @param [String] content - the text string with all of the <li> for the footnotes
  # @return [String] - always return and empty string
  #
  def footnotes(content)
    $footnoteDiv = "<ol>#{content}</ol>"
    return ""
  end

  #
  # get the the includes - markdown {{filename}}
  #
  # @param [String] full_document - the markdown text of the entire document prior to any processing
  # @return [String] - the markdown text of the entire document with includes files added
  #
      
  def get_includes(markdown)
    # look for an include of the form {{filename}} split it into the leftHandString, the filename, and the rightHandString
    if n = markdown.match(/^\{\{.*\}\}(?=(?:[^`]*`[^`]*`)*[^`]*\Z)/)
        include = n[0].gsub(/^\{\{|\}\}(?=(?:[^`]*`[^`]*`)*[^`]*\Z)/, '')
        parts = markdown.split(/^\{\{.*\}(?=(?:[^`]*`[^`]*`)*[^`]*\Z)\}/, 2)
        if include.strip[0] == '=' or include.strip[0] == '$'
            newmd = ""
            parts[0] = parts[0] + "{{" +include + "}}"
        else 
          if File.exists? (include.strip)
            file = File.open(include.strip, "r")
            newmd = "\n<!--include markdown-section data-src='#{include}' include-->\n" + file.read + "\n\n<!--include /markdown-section include-->\n"
            file.close
          else
            parts[0] = parts[0] + "{{ #{include} }}"
            newmd = ""
          end
        end
        return [parts[0], get_includes([newmd, parts[1]].join(""))].join("")
    else
      return markdown
    end
  end 
  
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
  # Postprocess the HTML comments for Markdown includes to fix up the markdown include placeholders and to place the footnote definitions into the
  # bootstrap popovers in the references
  #
  # @param [String] text - the text of a markdown paragraph
  # @return [String] - the text of the markdown paragraph with the include bracket transformed into xHTML
  #
  def postprocess(document)
    document.gsub!(/^\<\!\-\-include /, "<!--")                                 # fix the start of the include markers
    document.gsub!(/ include\-\-\>/, "-->")                                     # fix the end of the include markets
    $footnoteDefs.each_pair { |ref, fndef| document.gsub!(/#{ref}/,fndef) }     # Loop through the footnote refs replace with popover text
    document.gsub!(/\{\{\s*\$abbreviations\s*\}\}/, $abbrList.sort.map { |s| "#{s}" }.join(' ') )  
                                                                                # output the list of abbreviations
    document.gsub!(/\{\{\s*\$footnotes\s*\}\}/, $footnoteDiv )                  # output the list of footnotes
    return document
  end      
      
  #
  # Preprocess the document with extensions 
  # 
  # input
  #   markdown - the full document in markdown prior to any processing
  # output
  #   preprocessed markdown - the full document but with abbreviations, includes, and sections resolved
  #
      
  def preprocess(document)
    add_abbr(get_includes (document))
  end

end      

      