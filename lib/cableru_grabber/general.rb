module CableruGrabber::General

  def start
    @anonymizer = AnonymousAnonym.new
    @categories_counter = 0
    @goods_counter = 0
    start_time = Time.zone.now
    grab(CableruGrabber::FIRST_ENTRIES)
    runtime = Time.zone.now - start_time
    puts "RUNTIME - #{ runtime }"
    puts "GOODS - #{ @goods_counter }"
    puts "TOTAL LINKS - #{ @categories_counter }"
  end

  def grab(entries=CableruGrabber::FIRST_ENTRIES)
    entries.each do |entry|
      @url = entry[:uri]
      puts @url
      source = request(@url, @anonymizer)
      if entry[:type] != :marka
        links = get_links(source, entry[:type], @url)
        puts "(#{links.size})"
        @categories_counter += links.size
        self.grab(links)
      else
        @goods_counter += 1
        puts '(M)'
      end


    end
  end

end
