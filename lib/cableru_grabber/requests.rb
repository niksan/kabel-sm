module CableruGrabber::Requests

  def request(uri, anonymizer)
    @anonymizer = anonymizer
    source = begin
               http_proxy(@anonymizer.proxy[:ip_address], @anonymizer.proxy[:port])
               self.get(uri, headers: { 'User-Agent' => useragent })
             rescue SocketError
               request_retrying uri
             rescue Net::OpenTimeout
               request_retrying uri
             rescue Errno::EHOSTUNREACH
               request_retrying uri
             rescue Net::ReadTimeout
               request_retrying uri
             rescue Errno::ECONNREFUSED
               request_retrying uri
             rescue Exception => e
               puts e
               sleep(5)
               request_retrying uri
             end
    if source.match(/id=\"map_europe\"/) && source.match(/id=\"map_ukraine\"/) && source.match(/id=\"map_east\"/)
      # блокировка на стороне cable.ru
      print '!'
      request_retrying uri
    elsif !source.match(/Кабель.РФ/)
      # страница не cable.ru, предположительно, страница прокси-сервера
      print '#'
      request_retrying uri
    else
      source
    end
  end

  def request_retrying(uri)
    print '.'
    request(uri, @anonymizer)
  end

  def useragent
    @anonymizer.useragent
  end

end
