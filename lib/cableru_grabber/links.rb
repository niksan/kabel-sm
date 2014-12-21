module CableruGrabber::Links

  def compact_links(links)
    links.select { |l| l.size>0 }
  end

  def get_links(source, type, url)
    result = []
    n = Nokogiri::HTML(source)
    part = n.css(CableruGrabber::TYPES[type][:css_selector]).to_s
    CableruGrabber::TYPES.each do |type_name, type_params|
      matches =  part.scan(type_params[:li_match])
      r = if !matches.empty?
        matches.map do |r|
          {
            uri: build_uri(r[1], url),
            title: r[7],
            type: detect_uri_type(build_uri(r[1], url))
          }
        end
      else
        []
      end
      result += r
    end
    result
  end

  def build_uri(last, url)
    url.match(/(http:\/\/([а-яА-Яa-zA-Z \(\)-_]*)?)(\/[а-яА-Яa-zA-Z \(\)-_]*(\.php)?)/)[1] + '/' + last.match(/^(\/)?(.*)/)[2]
  end

  def detect_uri_type(uri)
    h = {}
    CableruGrabber::TYPES.each { |k,v| h[k] = v[:link_match] }
    h.each do |k, v|
      return(k) if uri.match(v)
    end
    nil
  end

end
