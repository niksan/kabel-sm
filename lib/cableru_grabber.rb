module CableruGrabber

  DOMAIN='http://cable.ru'
  FIRST_ENTRIES = [
    { type: :main, uri: '/' }#,
#    { type: :group, uri: '/engines/' },
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
      li_match: /<li><a href="((\/([a-z_-])*\/)?(razdel-(\w)*\.php))"( title="\W*")?>(\W*)<\/a><\/li>/,
      css_selector: '#content .column-2',
    },
    group: {
      link_match: /http:\/\/cable\.ru\/(\D)*\/(group-(\w)*\.php)/,
      li_match: /<li><a href="((\/([a-z_-])*\/)?(group-(\w)*\.php))"( title="\W*")?>(\W*)<\/a><\/li>/,
      css_selector: '#content .column-2',
    },
    marka: {
      link_match: /http:\/\/cable\.ru\/(\D)*\/(marka-(\w)*\.php)/,
      li_match: /<li><a href="((\/([a-z_-])*\/)?(marka-(\w)*\.php))"( title="\W*")?>(\W*)<\/a><\/li>/,
      css_selector: '#content .column-2',
    },
    related:{
      link_match: /http:\/\/cable\.ru\/(related\/(\w)*\.php)/,
      li_match: /<li><a href="(\/related\/(\w)*\.(php))(")( title="\W*")?(>)(\W*)<\/a><\/li>/,
      css_selector: '#content .column-2',
    }
  }

  class << self

    def grab(entries=FIRST_ENTRIES)
      start_time = Time.zone.now
      entries.each do |entry|
        @uri = DOMAIN + entry[:uri]
        source = SimpleUri.req(@uri)
        puts compact_links(get_links(source, entry[:type])).inspect
      end
      runtime = Time.zone.now - start_time
      puts "RUNTIME - #{ runtime }"
    end

    private
      
      def compact_links(links)
        links.select { |l| l.size>0 }
      end

      def get_links(source, type)
        result = []
        n = Nokogiri::HTML(source)
        part = n.css(TYPES[type][:css_selector]).to_s
        TYPES.each do |type_name, type_params|
          r = part.scan(type_params[:li_match]).map { |r| { uri: build_uri(r[0]), title: r[6], type: detect_uri_type(@uri+r[0]) } }
          result << r
        end
        result
      end

      def build_uri(last)
        @uri + last.match(/^(\/)?(.*)/)[2]
      end

      def detect_uri_type(uri)
        h = {}
        TYPES.each { |k,v| h[k] = v[:link_match] }
        h.each do |k, v|
          return k if uri.match v
        end
        nil
      end
    
  end

end
