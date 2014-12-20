class AnonymousAnonym

  SOURCES = {
    hidemyass: 'http://proxylist.hidemyass.com/search-1325704',
    useragentstring: 'http://www.useragentstring.com/pages/All/'
  }
  
  def initialize
    @proxyes = []
  end

  def useragents
    @useragents ||= self.class.useragents
  end

  def proxy
    @proxyes = self.class.fresh! if @proxyes.empty? 
    @proxyes.shift
  end

  def useragent
    useragents.sample
  end
  
  class << self

    def fresh!
      from_hidemyass
    end

    def useragents
      html_body = HTTParty.get(SOURCES[:useragentstring])
      Nokogiri::HTML(html_body).css('ul li a').map { |el| el.text }
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
