# Copyright (c) 2014-2017 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so. The Software doesn't include files with .md extension.
# That files you are not allowed to copy, distribute, modify, publish, or sell.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

module Jekyll
  module Filters
    def movies_count(posts)
      with_movies(posts).size
    end

    def movies(posts)
      with_movies(posts).map do |p|
        "<p><a href='#{p.url}'>#{CGI::escapeHTML(p['jb_picture']['caption'])}</a></p>"
      end
    end

    private

    def with_movies(posts)
      posts
        .select{ |p| p['jb_picture'] && p['jb_picture']['caption'] }
        .uniq{ |p| p['jb_picture']['caption'] }
        .sort{ |a,b| a['jb_picture']['caption'] <=> b['jb_picture']['caption'] }
      end
  end
end
