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

require 'rss'
require 'securerandom'

module Jekyll
  class YegorBufferFile < StaticFile
    def write(dest)
      target = File.join(dest, @dir, @name)
      FileUtils.copy_file(
        File.join(dest, "/../_temp/#{@name}"),
        target
      )
      puts "#{target} created (#{File.size(target)} bytes)"
      true
    end
  end
  class YegorBufferGenerator < Generator
    priority :low
    safe true
    def generate(site)
      home = 'http://www.yegor256.com'
      rss = RSS::Maker.make("atom") do |maker|
        maker.channel.author = "yegor256"
        maker.channel.updated = Time.now.to_s
        maker.channel.about = "For buffer.com only"
        maker.channel.title = "yegor256.com for buffer.com only"
        site.posts.docs.each do |p|
          tags = p['tags'] ? " #{p['tags'].map {|t| "##{t}"}.join(' ')}" : ''
          if p['buffer']
            p['buffer'].each do |quote|
              raise "Quote too log in #{p.url}" if quote.length > 200
              maker.items.new_item do |item|
                item.id = SecureRandom.uuid
                item.link = home + p.url
                item.title = quote + tags
                item.updated = Time.now.to_s
              end
            end
          end
          months = ((Time.now - p['date']) / (30 * 24 * 60 * 60)).to_i
          if months > 3
            maker.items.new_item do |item|
              item.id = SecureRandom.uuid
              item.link = home + p.url
              if months < 6
                item.title = "I wrote this #{months} months ago: \"#{p['title']}\"#{tags}"
              elsif months < 12
                item.title = "I wrote this almost a year ago: \"#{p['title']}\"#{tags}"
              else
                item.title = "I wrote this over a year ago: \"#{p['title']}\"#{tags}"
              end
              item.updated = Time.now.to_s
            end
          end
        end
        key = ENV['YOUTUBE_API_KEY'] # configured in .travis.yml
        unless key.nil?
          uri = URI.parse("https://www.googleapis.com/youtube/v3/playlistItems?playlistId=UUr9qCdqXLm2SU0BIs6d_68Q&part=snippet&maxResults=100&key=#{key}")
          JSON.parse(Net::HTTP.get(uri))['items'].each do |video|
            date = Time.parse(video['snippet']['publishedAt'])
            maker.items.new_item do |item|
              item.id = SecureRandom.uuid
              item.link = "https://www.youtube.com/watch?v=#{video['resourceId']['videoId']}"
              item.title = "Watch it again: \"#{video['snippet']['title']}\""
              item.updated = Time.now.to_s
            end
          end
        end
        {
          'Don\'t forget to follow me in Facebook, here is the link': 'https://www.facebook.com/yegor256',
          'Don\'t forget to subscribe to my YouTube channel, I post videos a few times a month': 'https://www.youtube.com/c/yegor256?sub_confirmation=1',
          'Don\'t forget to follow my Angel.co account, if you are also there': 'https://angel.co/yegor256',
          'BTW, here is my GitHub account, don\'t hesitate to follow it': 'https://github.com/yegor256?tab=followers'
        }.each do |tweet, link|
          maker.items.new_item do |item|
            item.id = SecureRandom.uuid
            item.link = link
            item.title = tweet
            item.updated = Time.now.to_s
          end
        end
        {
          'yegor256/xembly': 'Xembly is an XML building and manipulation language and a library',
          'yegor256/tacit': 'Tacit is a class-less CSS framework, for clueless programmers like me',
          'yegor256/takes': 'Takes is a unique truly objet-oriented Java web framework',
          'yegor256/rultor': 'Rultor is a chatbot DevOps assistant to automate deployment and merge operations',
          'teamed/qulice': 'Qulice is an aggregator of Java static analyzers',
          'yegor256/cactoos': 'Cactoos is a library of truly object-oriented Java primitives'
        }.each do |repo, tweet|
          maker.items.new_item do |item|
            item.id = SecureRandom.uuid
            item.link = "https://github.com/#{repo}"
            item.title = "#{tweet}. Please, add your GitHub star, help the project:"
            item.updated = Time.now.to_s
          end
        end
      end
      FileUtils.mkdir_p('_temp')
      File.write('_temp/buffer.rss', rss.to_s)
      site.static_files << Jekyll::YegorBufferFile.new(site, site.dest, '', 'buffer.rss')
    end
  end
end
