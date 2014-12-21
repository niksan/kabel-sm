require 'anonymous_anonym'
require 'cableru_grabber/settings'
require 'cableru_grabber/links'
require 'cableru_grabber/requests'

module CableruGrabber

  extend CableruGrabber::Links
  extend CableruGrabber::Requests

  class << self

    def start
      @anonymizer = AnonymousAnonym.new
      @categories_counter = 0
      @goods_counter = 0
      start_time = Time.zone.now
      grab(FIRST_ENTRIES)
      runtime = Time.zone.now - start_time
      puts "RUNTIME - #{ runtime }"
      puts "GOODS - #{ @goods_counter }"
      puts "TOTAL LINKS - #{ @categories_counter }"
    end

    def grab(entries=FIRST_ENTRIES)
      entries.each do |entry|
        @url = entry[:uri]
        puts @url
        source = request(@url, @anonymizer)
        if entry[:type] != :marka
          links = get_links(source, entry[:type], @url)
          puts "Finded #{links.size} links"
          @categories_counter += links.size
          self.grab(links)
        else
          @goods_counter += 1
          puts '!!!MARKA'
        end
      end
    end
      
  end

end
