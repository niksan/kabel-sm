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
      parent_page = is_category?(entry[:type]) ? @url : nil
      if entry[:type] != :marka
        links = get_links(source, entry[:type], @url)
        detect_zero_links(links.size, source)
        puts "(#{links.size})"
        @categories_counter += links.size
        page_to_application(source, entry[:type], @url, parent_page)
        grab(links)
      else
        @goods_counter += 1
        page_to_application(source, entry[:type], @url, parent_page)
        puts '(M)'
      end
    end
  end

  private

    def is_category?(entry_type)
      (entry_type != :main) && (entry_type != :marka)
    end

    def detect_zero_links(count, source)
      if count.zero? 
        filepath = Rails.root + 'public/cableru_debug.html'
        File.write(filepath, source.force_encoding('utf-8'))
        raise CableruGrabber::ZeroLinksError
      end
      nil
    end

end
