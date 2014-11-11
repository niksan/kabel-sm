module CableruGrabber

  DOMAIN='http://cable.ru'
  FIRST_ENTRIES = [
#    { type: :main, uri: '/' },
    { type: :group, uri: '/engines/' }#,
#    { type: :group, uri: '/pumps/' }
  ]
  TYPES = {
    main: {
      link_match: /@@!!@@!!\)\)XuiPizdaaa/,
      li_match: /@@!!@@!!\)\)XuiPizdaaa/,
      css_selector: '#content .column div.catalog.module'
    },
    razdel: {
      link_match: /http:\/\/cable\.ru\/(\D)*\/(razdel-(\d)*\.php)/,
      li_match: /<li><a href="((\/(\D)*\/)?(razdel-(\w)*\.php))"( title="\W*")?>(\W*)<\/a><\/li>/,
      css_selector: '#content .column-2',
    },
    group: {
      link_match: /http:\/\/cable\.ru\/(\D)*\/(group-(\w)*\.php)/,
      li_match: /<li><a href="((\/(\D)*\/)?(group-(\w)*\.php))"( title="\W*")?>(\W*)<\/a><\/li>/,
      css_selector: '#content .column-2',
    },
    marka: {
      link_match: /http:\/\/cable\.ru\/(\D)*\/(marka-(\w)*\.php)/,
      li_match: /<li><a href="((\/(\D)*\/)?(marka-(\w)*\.php))"( title="\W*")?>(\W*)<\/a><\/li>/,
      css_selector: '#content .column-2',
    }
  }

  class << self

    def grab(entries=FIRST_ENTRIES)
      start_time = Time.zone.now
      entries.each do |entry|
        @uri = DOMAIN + entry[:uri]
        source = SimpleUri.req(@uri)
        puts get_links(source, entry[:type]).inspect
      end
      runtime = Time.zone.now - start_time
      puts "RUNTIME - #{ runtime }"
    end

    private

      def get_links(source, type)
        result = []
        n = Nokogiri::HTML(source)
        part = n.css(TYPES[type][:css_selector]).to_s
        TYPES.each do |type_name, type_params|
          r = part.scan(type_params[:li_match]).map { |r| { uri: @uri+r[0], title: r[6] } }
          result << r
        end
        result.select { |r| r.size > 2 }[0]
      end

      def detect_uri_type(uri)
       # 
      end
    
  end

end
