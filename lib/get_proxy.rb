class GetProxy

  SOURCES = {
    hidemyass: 'http://proxylist.hidemyass.com/search-1325704',
    localhost: 'http://localhost:3000/404.html'
  }

  USERAGENTS = [
    'Mozilla/5.0 (X11; U; Linux; pt-PT) AppleWebKit/523.15 (KHTML, like Gecko, Safari/419.3) Arora/0.4',
    'Mozilla/5.0 (X11; U; Linux; nb-NO) AppleWebKit/527+ (KHTML, like Gecko, Safari/419.3) Arora/0.4',
    'Mozilla/5.0 (X11; U; Linux; it-IT) AppleWebKit/527+ (KHTML, like Gecko, Safari/419.3) Arora/0.4 (Change: 413 12f13f8)',
    'Mozilla/5.0 (X11; U; Linux; it-IT) AppleWebKit/523.15 (KHTML, like Gecko, Safari/419.3) Arora/0.4',
    'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.2; Avant Browser; Avant Browser; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30; InfoPath.2)',
    'Mozilla/5.0 (X11; U; Linux; pt-PT) AppleWebKit/523.15 (KHTML, like Gecko, Safari/419.3) Arora/0.4',
    'Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/537.13+ (KHTML, like Gecko) Version/5.1.7 Safari/534.57.2',
    'Mozilla/5.0 (Windows; U; Windows NT 6.1; tr-TR) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.4 Safari/533.20.27',
    'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/534.7 (KHTML, like Gecko) RockMelt/0.8.36.128 Chrome/7.0.517.44 Safari/534.7',
    'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_6; en-US) AppleWebKit/534.16 (KHTML, like Gecko) RockMelt/0.9.50.518 Chrome/10.0.648.205 Safari/534.16'
    ]
  
  def initialize
    @proxyes = []
  end

  def proxy
    @proxyes = self.class.fresh! if @proxyes.empty? 
    @proxyes.shift
  end

  def useragent
    USERAGENTS.sample
  end
  
  class << self

    def fresh!
      from_hidemyass
    end

    def from_hidemyass
      addresses = []
      none_classes = []
      html_body = HTTParty.get(SOURCES[:hidemyass])
      Nokogiri::HTML(html_body).css('table#listable > tbody > tr > td:nth-child(2) > span').each do |span|
        address = ''
        span.children.each do |el|
          none_classes.uniq!
          if el.name == 'style' #find styles with display-none
            el.children.first.text.force_encoding("utf-8").each_line do |line|
              if m = line.match(/\.(\S*)({display:(none||inline)})/)
                if m[3] == 'none'
                  none_classes << m[1].force_encoding("utf-8")
                end
              end
            end
          end
          unless el.name == 'style'
            if el.attributes['style'].to_s.force_encoding("utf-8") != 'display:none'
              unless el.attributes['class'].to_s.force_encoding("utf-8").in?(none_classes)
                address += el.text
              end
            end
          end
        end
        addresses << address
      end
      addresses
    end

  end

end
