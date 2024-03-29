class AnonymousAnonym

  SOURCES = {
    hidemyass: {
      all: 'http://proxylist.hidemyass.com/search-1305291',
      web: 'http://proxylist.hidemyass.com/search-1325704',
      ru_ua: 'http://proxylist.hidemyass.com/search-1442047'
    },
    useragentstring: 'http://www.useragentstring.com/pages/All/'
  }
  
  def initialize(list=:all)
    @proxyes = []
    @list = list.to_sym
  end

  def proxy
    @proxyes = get_proxyes if @proxyes.empty? 
    @proxyes.shift
  end

  def useragent
    useragents.sample
  end

  protected

    def get_proxyes
      from_hidemyass
    end

    def useragents
      @useragents ||= get_useragents
    end
  
  private

    def get_useragents
      html_body = HTTParty.get(SOURCES[:useragentstring])
      Nokogiri::HTML(html_body).css('ul li a').map { |el| el.text }
    end

    def from_hidemyass
      proxyes = []
      hided_classes = []
      html_body = HTTParty.get(SOURCES[:hidemyass][@list])
      Nokogiri::HTML(html_body).css('table#listable > tbody > tr').each do |tr|
        td_s = []
        tr.children.each do |tr_ch|
          if tr_ch.name == 'td'
            td_s << tr_ch
          end
        end
        span = td_s[1].children.first
        address = ''
        span.children.each do |el|
          hided_classes.uniq!
          if el.name == 'style'
            el.children.first.text.force_encoding('utf-8').each_line do |line|
              m = line.match(/\.(\S*)({display:(none||inline)})/)
              if m && m[3] == 'none'
                hided_classes << m[1].force_encoding('utf-8')
              end
            end
          end
          unless el.name == 'style'
            display_inline = (el.attributes['style'].to_s.force_encoding('utf-8') != 'display:none')
            hyded_by_css = el.attributes['class'].to_s.force_encoding('utf-8').in?(hided_classes)
            if display_inline && !hyded_by_css
              address += el.text
            end
          end
        end
        proxyes << { ip_address: address, port: td_s[2].text.to_i }
      end
      proxyes
    end

end
