#
# Based on undress gem source . Corrections by Alexey Kalmykov (alexey.kalmykov@lanit-tercom.com), Lanit-Tercom, Inc
# Further corrections for redmine_aloha_wiki by Nikolay Gniteev (godhart@gmail.com)
#
require File.expand_path(File.dirname(__FILE__) + "/../undress")

module Undress
  class Textile < Grammar
    whitelist_attributes :class, :id, :lang, :style, :colspan, :rowspan

    # entities
    post_processing(/&nbsp;/, " ")

    # whitespace handling
    post_processing(/\n\n+/, "\n\n")
    post_processing(/\A\s+/, "")
    post_processing(/\s+\z/, "\n")

    # special characters introduced by textile
    post_processing(/&#8230;/, "...")
    post_processing(/&#8217;/, "'")
    post_processing(/&#822[01];/, '"')
    post_processing(/&#8212;/, "--")
    post_processing(/&#8211;/, "-")
    post_processing(/(\d+\s*)&#215;(\s*\d+)/, '\1x\2')
    post_processing(/&#174;/, "(r)")
    post_processing(/&#169;/, "(c)")
    post_processing(/&#8482;/, "(tm)")

    # inline elements
    rule_for(:a) {|e|
      if(e.has_attribute?("class"))
       if (e["class"].match('wiki-page'))
         link = e["href"]
          link.gsub!(/.*\/(\w+)\/wiki\/(\w+)(#(?:(?:\w+|\+)+))?$/) do |m|
            project = $~[1]
            wikiPage = $~[2]
            anchor = $~[3]
            # Replace '+' from anchor and convert them to spaces
            if (!anchor.nil?)
              anchor.gsub!(/\+/, ' ')
            end            
            # Replace '_' from wiki page name and conver them to spaces
            wikiPage.gsub!(/_/, ' ')
            alter=""
            if(wikiPage != content_of(e))
              alter="|#{content_of(e)}"
            end
            if @@options.has_key?(:project_id)  #TODO: I still don't get why it's CLASS variable that works, not INSTANCE...
             if (@@options[:project_id] == project)
                project=""
              else
                project="#{project}:"
              end
            end
            "\[\[#{project}#{wikiPage}#{anchor}#{alter}\]\]"
            end
        # LocalWiki class means that link is local wiki page(belongs to current project). #TODO: probably not needed at all for aloha WYSIWYG
       elsif (e["class"] == "localWiki")
          link = e["href"]
          # Parses link like "wiki/Long_name_of_Wiki_page#+anchor+for+this+page"
          link.gsub!(/.*\/(\w+)((#)((\w|\+)+))?/) do |m|
            wikiPage = $~[1]
            delimeter = $~[3]
            anchor = $~[4]
            # Replace '+' from anchor and convert them to spaces
            if(delimeter == "#")
            anchor.gsub!(/\+/, ' ')
            end
            # Replace '_' from wiki page name and conver them to spaces
            wikiPage.gsub!(/_/, ' ')
            # Check for anchor "#"
            if(delimeter.nil?)
              if(wikiPage == content_of(e))
                "[[#{wikiPage}]]"
              else
                "\[\[#{wikiPage}|#{content_of(e)}\]\]"
              end
            else
              if(!anchor.nil?)
                "\[\[#{wikiPage}##{anchor}\]\]"
              end
            end
          end
        # ExternalWiki class means that link is wiki page from other project. #TODO: probably not needed at all for aloha WYSIWYG
        elsif(e["class"] == "externalWiki")
          link = e["href"]
          # parses link like "../../../projectidentifier/wiki/wiki_page_name"
          link.gsub!(/(\.\.\/)+(\w+)\/wiki\/(\w+)/) do |m|
            projectName = $~[2]
            wikiPage = $~[3]
            "\[\[#{projectName}\:#{wikiPage}\]\]"
          end
        # Parse revision links  
        elsif(e["class"] == "revisionLink")
          link = e["href"]
          link.gsub!(/(\.\.\/)+repository\/revisions\/(\d+)/) do |m|
            revision_number = $~[2]
            "r#{revision_number}"
          end
        # Parse issues links
        elsif(e["class"] == "issueLink")
          link = e["href"]
          link.gsub!(/(\.\.\/)+issues\/(\d+)/) do |m|
            issue_number = $~[2]
            "\##{issue_number}"
          end
        # Parse document links 
        elsif(e["class"] == "documentLink")
          link = e["href"]
          link.gsub!(/(\.\.\/)+documents\/(\d+)/) do |m|
            document_id = $~[2]
            "document##{document_id}"
          end
        # Parse version links  
        elsif(e["class"] == "versionLink")
          link = e["href"]
          link.gsub!(/(\.\.\/)+versions\/(\d+)/) do |m|
            version_id = $~[2]
            "version##{version_id}"
          end
        # Parse attachments links  
        elsif(e["class"] == "attachmentLink")
          link = e["href"]
          link.gsub!(/(\.\.\/)+attachments\/(\d+)/) do |m|
            attachment_id = $~[2]
            "attachment:#{content_of(e)}"
          end
        elsif(e["class"] == "email")
          content_of(e)
        # External class means that link is global and links to other resource 
        elsif ((e["class"] != "wiki-anchor") and (e.has_attribute?("href")) )
          #NOTE: all other links with href are treated as external for now
          #NOTE: all those condition in the end ignores anchors and it's fine
          title = e.has_attribute?("title") ? " (#{e["title"]})" : ""
          if (content_of(e) != e["href"])
            "\"#{content_of(e)}#{title}\":#{e["href"]}"
          else
            "#{e["href"]}"
          end
        end
      end
    }
    rule_for(:img) {|e|
      alt = (e.has_attribute?("alt") and e["alt"]!="") ? "(#{e["alt"]})" : ""
      "!#{e["src"]}#{alt}!"
    }
#TODO: is a complete_word like !\b.+\b! expression? Cause it looks like it fails on things like '*text_to_be_bold*:'
    rule_for(:strong, :b)  {|e| complete_word?(e) ? "*#{attributes(e)}#{content_of(e)}*" : "#{content_of(e)}"}
#NOTE: removed that [* ... *] around non-complete word as it never worked for me on my redmine-1.4
    rule_for(:em, :i)      {|e| complete_word?(e) ? "_#{attributes(e)}#{content_of(e)}_" : "#{content_of(e)}"}
#NOTE: removed that [_ ... _] around non-complete word as it never worked for me on my redmine-1.4
    rule_for(:code)    {|e| "\<code\>\n#{content_of(e)}\n\<\/code\>"}
#TODO: check if it's single line. If so - put it into @...@ instead of <code>...</code>
    rule_for(:cite)    {|e| "??#{attributes(e)}#{content_of(e)}??" }
    rule_for(:sup)     {|e| surrounded_by_whitespace?(e) ? "^#{attributes(e)}#{content_of(e)}^" : "#{content_of(e)}" }
#NOTE: removed that [^ ... ^] around non-complete word as it never worked for me on my redmine-1.4
    rule_for(:sub)     {|e| surrounded_by_whitespace?(e) ? "~#{attributes(e)}#{content_of(e)}~" : "#{content_of(e)}" }
#NOTE: removed that [~ ... ~] around non-complete word as it never worked for me on my redmine-1.4
    rule_for(:ins)     {|e| complete_word?(e) ? "+#{attributes(e)}#{content_of(e)}+" : "#{content_of(e)}"}
#NOTE: removed that [+ ... +] around non-complete word as it never worked for me on my redmine-1.4
    rule_for(:del, :s, :strike)     {|e| complete_word?(e) ? "-#{attributes(e)}#{content_of(e)}-" : "#{content_of(e)}"}
#NOTE: removed that [- ... -] around non-complete word as it never worked for me on my redmine-1.4
    rule_for(:acronym) {|e| e.has_attribute?("title") ? "#{content_of(e)}(#{e["title"]})" : content_of(e) }
    rule_for(:span)    {|e|
      # means number of line from CodeRay conversion, should be deleted and replaced with new line
      if(e["class"] == "no")
        "\n"
      else
        content_of(e)
      end
    }
    

    # text formatting and layout
    rule_for(:p) do |e| 
#      at = attributes(e) != "" ? "p#{at}#{attributes(e)}. " : ""
#      e.parent && e.parent.name == "blockquote" ? "#{at}#{content_of(e)}\n\n" : "\n\n#{at}#{content_of(e)}\n\n"
#NOTE: can't get code above, specialy about "blockqoute" so I rewrote this chunk by myself. Maybe later I would get it :)
       at = ""
       if e.has_attribute?("style")
         if e["style"].match('text-align:center')
           at = "p=. "
         elsif e["style"].match('text-align:right')
           at = "p>. "
         end
       end
       preceeding = e.parent && e.parent.name == "blockquote" ? "" : "\n\n"
       "#{preceeding}#{at}#{content_of(e)}\n\n"
    end
    rule_for(:br)         {|e| "\n" }
    rule_for(:blockquote) {|e| "\n\nbq#{attributes(e)}. #{content_of(e)}\n\n" }
    rule_for(:pre)        {|e|
      if e.children && e.children.all? {|n| n.text? && n.content =~ /^\s+$/ || n.elem? && n.name == "code" }
        "\n\n<pre>#{attributes(e)}#{content_of(e)}</pre>\n\n"
      else
        "<pre>#{content_of(e)}</pre>"
      end
    }

    # headings
    rule_for(:h1) {|e| "\n\nh1#{attributes(e)}. #{content_of(e)}\n\n" }
    rule_for(:h2) {|e| "\n\nh2#{attributes(e)}. #{content_of(e)}\n\n" }
    rule_for(:h3) {|e| "\n\nh3#{attributes(e)}. #{content_of(e)}\n\n" }
    rule_for(:h4) {|e| "\n\nh4#{attributes(e)}. #{content_of(e)}\n\n" }
    rule_for(:h5) {|e| "\n\nh5#{attributes(e)}. #{content_of(e)}\n\n" }
    rule_for(:h6) {|e| "\n\nh6#{attributes(e)}. #{content_of(e)}\n\n" }

    # lists
    rule_for(:li) {|e|
      token = e.parent.name == "ul" ? "*" : "#"
      nesting = e.ancestors.inject(1) {|total,node| total + (%(ul ol).include?(node.name) ? 0 : 1) }
      "\n#{token * nesting} #{content_of(e)}"
    }
    rule_for(:ul, :ol) {|e|
      toc=:none
      if e.has_attribute?("class")
        if e["class"]=="toc"
          toc=:left
        elsif e["class"]=="toc right"
          toc=:right
        end
      end

      if toc==:left
        "{{toc}}"
      elsif toc==:right
        "{{>toc}}"
      else
        if e.ancestors.detect {|node| %(ul ol).include?(node.name) }
          content_of(e)
        else
          "\n#{content_of(e)}\n\n"
        end
      end
    }

    # definition lists
    rule_for(:dl) {|e| "\n\n#{content_of(e)}\n" }
    rule_for(:dt) {|e| "- #{content_of(e)} " }
    rule_for(:dd) {|e| ":= #{content_of(e)} =:\n" }

    # tables
    rule_for(:table)   {|e| "\n\n#{content_of(e)}\n" }
    rule_for(:tr)      {|e| "#{content_of(e)}|\n" }
    rule_for(:td, :th) {|e| "|#{e.name == "th" ? "_. " : attributes(e)}#{content_of(e)}" }

    def attributes(node) #:nodoc:
      filtered = super(node)
      
      if filtered
        
        if filtered.has_key?(:colspan)
          return "\\#{filtered[:colspan]}. "
        end

        if filtered.has_key?(:rowspan)
          return "/#{filtered[:rowspan]}. "
        end

        if filtered.has_key?(:lang)
          return "[#{filtered[:lang]}]"
        end

        if filtered.has_key?(:class) || filtered.has_key?(:id)
          klass = filtered.fetch(:class, "")
          id = filtered.fetch(:id, false) ? "#" + filtered[:id] : ""
          return "(#{klass}#{id})"
        end

        if filtered.has_key?(:style)
          return "{#{filtered[:style]}}"
        end
      end  
      ""
    end
  end

  add_markup :textile, Textile
end
