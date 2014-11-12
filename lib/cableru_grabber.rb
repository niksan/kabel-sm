module CableruGrabber

  DOMAIN='http://cable.ru'
  FIRST_ENTRIES = [
    { type: :main, uri: DOMAIN+'/' },
    { type: :group, uri: DOMAIN+'/engines/' },
    { type: :group, uri: DOMAIN+'/pumps/' }
  ]
  REGEXPS = {
    title: '[а-яА-Яa-zA-Z \(\)-_]*',
    href_uri: {
      razdel: '((\/([a-z_-])*\/)?(razdel-(\w)*\.php))',
      group: '((\/([a-z_-])*\/)?(group-(\w)*\.php))',
      marka: '((\/([a-z_-])*\/)?(marka-(\w)*\.php))',
      related: '(\/related\/(\w)*\.(php))',
    }
  }
  TYPES = {
    main: {
      link_match: /@@!!@@!!\)\)XuiPizdaaa/,
      li_match: /@@!!@@!!\)\)XuiPizdaaa/,
      css_selector: '#content .column div.catalog.module'
    },
    razdel: {
      link_match: /http:\/\/cable\.ru\/(\D)*\/(razdel-(\w)*\.php)/,
      li_match: /<a( style="display: block;")? href="#{ REGEXPS[:href_uri][:razdel] }"( title="#{ REGEXPS[:title] }")?>(#{ REGEXPS[:title] })<\/a>/,
      css_selector: '#content .column-2',
    },
    group: {
      link_match: /http:\/\/cable\.ru\/(\D)*\/(group-(\w)*\.php)/,
      li_match: /<a( style="display: block;")? href="#{ REGEXPS[:href_uri][:group] }"( title="#{ REGEXPS[:title] }")?>(#{ REGEXPS[:title] })<\/a>/,
      css_selector: '#content .column-2',
    },
    marka: {
      link_match: /http:\/\/cable\.ru\/(\D)*\/(marka-(\w)*\.php)/,
      li_match: /<a( style="display: block;")? href="#{ REGEXPS[:href_uri][:marka] }"( title="#{ REGEXPS[:title] }")?>(#{ REGEXPS[:title] })<\/a>/,
      css_selector: '#content .column-2',
    },
    related: {
      link_match: /http:\/\/cable\.ru\/(related\/(\w)*\.php)/,
      li_match: /<a( style="display: block;")? href="#{ REGEXPS[:href_uri][:related] }(")( title="#{ REGEXPS[:title] }")?(>)(#{ REGEXPS[:title] })<\/a>/,
      css_selector: '#content .column-2',
    }
  }

  class << self

    def grab(entries=FIRST_ENTRIES)
      @categories_counter = 0
      @goods_counter = 0
      start_time = Time.zone.now
      entries.each do |entry|
        @uri = entry[:uri]
        puts @uri
        source = SimpleUri.req(@uri)
        if entry[:type] != :marka
          links = get_links(source, entry[:type])
          puts "Finded #{links.size} links"
          @categories_counter += links.size
          self.grab(links)
        else
          @goods_counter += 1
          puts '!!!MARKA'
        end
      end
      runtime = Time.zone.now - start_time
      puts "RUNTIME - #{ runtime }"
      puts "GOODS - #{ @goods_counter }"
      puts "TOTAL LINKS - #{ @categories_counter }"
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
          matches =  part.scan(type_params[:li_match])
          r = if !matches.empty?
            matches.map do |r|
              {
                uri: build_uri(r[1]),
                title: r[7],
                type: detect_uri_type(build_uri(r[1]))
              }
            end
          else
            []
          end
          result += r
        end
        result
      end

      def build_uri(last)
        @uri.match(/(http:\/\/([а-яА-Яa-zA-Z \(\)-_]*)?)(\/[а-яА-Яa-zA-Z \(\)-_]*(\.php)?)/)[1] + '/' + last.match(/^(\/)?(.*)/)[2]
      end

      def detect_uri_type(uri)
        h = {}
        TYPES.each { |k,v| h[k] = v[:link_match] }
        h.each do |k, v|
          return(k) if uri.match(v)
        end
        nil
      end
    
  end

end
