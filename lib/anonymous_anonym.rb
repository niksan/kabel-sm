class AnonymousAnonym

  SOURCES = {
    hidemyass: {
      all: 'http://proxylist.hidemyass.com/search-1292985',
      web: 'http://proxylist.hidemyass.com/search-1325704'
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
      none_classes = []
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
        proxyes << { ip_address: address, port: td_s[2].text.to_i }
      end
      proxyes
    end

end
