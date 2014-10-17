module Yegor
  class FigureBlock < Liquid::Tag
    def initialize(tag, markup, tokens)
      super
      opts = markup.strip.split(/\s+/, 3)
      @src = opts[0].strip
      @width = opts[1].strip
      file = '.' + @src
      if !File.exists?(file)
        raise "file doesn't exist: #{file}"
      end
    end

    def render(context)
      url = context.registers[:site].config['url']
      html = "<figure><img src='#{CGI.escapeHTML(url + @src)}'" \
      " style='width:#{@width}px;'" \
      " alt='figure'/></figure>\n\n"
    end
  end
end

Liquid::Template.register_tag('figure', Yegor::FigureBlock)
