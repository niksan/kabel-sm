module CableruGrabber

  include HTTParty
  default_timeout 10

  USERAGENTS = [
    'Mozilla/5.0 (X11; U; Linux; pt-PT) AppleWebKit/523.15 (KHTML, like Gecko, Safari/419.3) Arora/0.4',
    'Mozilla/5.0 (X11; U; Linux; nb-NO) AppleWebKit/527+ (KHTML, like Gecko, Safari/419.3) Arora/0.4',
    'Mozilla/5.0 (X11; U; Linux; it-IT) AppleWebKit/527+ (KHTML, like Gecko, Safari/419.3) Arora/0.4 (Change: 413 12f13f8)',
    'Mozilla/5.0 (X11; U; Linux; it-IT) AppleWebKit/523.15 (KHTML, like Gecko, Safari/419.3) Arora/0.4',
    'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.2; Avant Browser; Avant Browser; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30; InfoPath.2)'
    ]

  PROXYES = %W(86.122.124.11 200.29.67.29 218.108.170.163)

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

    def start
      @proxy_number ||= 0
      @proxy_max_number = proxyes.size - 1
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
        @uri = entry[:uri]
        puts @uri
        @proxy_number += 1
        source = request(@uri, proxyes[@proxy_number])
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
    end

    private
      
      def request(uri, proxy_ip)
        begin
          http_proxy proxy_ip, 80
          source = self.get(uri, headers: { 'User-Agent' => useragent })
        rescue SocketError
          request_retrying(uri, proxy_ip)
        rescue Net::OpenTimeout
          request_retrying(uri, proxy_ip)
        rescue Errno::EHOSTUNREACH
          request_retrying(uri, proxy_ip)
        end
      end

      def request_retrying(uri, proxy_ip)
        puts 'retrying!'
        @proxy_number += 1
        @proxy_number = 0 if @proxy_max_number < @proxy_number
        proxy_ip = proxyes[@proxy_number]
        request(uri, proxy_ip)
      end

      def proxyes
        @proxyes ||= PROXYES
      end

      def useragent
        USERAGENTS[rand(USERAGENTS.size)]
      end
      
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
