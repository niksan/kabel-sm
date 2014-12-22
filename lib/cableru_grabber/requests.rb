module CableruGrabber::Requests

  def request(uri, anonymizer)
    @anonymizer = anonymizer
    source = begin
               http_proxy(@anonymizer.proxy[:ip_address], @anonymizer.proxy[:port])
               self.get(uri, headers: { 'User-Agent' => useragent })
             rescue SocketError, Net::OpenTimeout, Net::ReadTimeout, Errno::EHOSTUNREACH, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError, URI::InvalidURIError
               request_retrying uri
             rescue SystemExit, Interrupt; SignalException raise
             rescue Exception => e
               puts e
               request_retrying uri
             end
    request_retrying(uri) unless ((source.code.to_i == 200) || (source.code.to_i == 304))
    begin
      if source.force_encoding('utf-8').match(/id=\"map_europe\"/) && source.match(/id=\"map_ukraine\"/) && source.match(/id=\"map_east\"/)
        # блокировка на стороне cable.ru
        print '!'
        request_retrying uri
      elsif !source.force_encoding('utf-8').match(/Кабель.РФ/)
        # страница не cable.ru, предположительно, страница прокси-сервера
        print '#'
        request_retrying uri
      else
        source
      end
    rescue Exception => e
      puts source.code
      puts source.inspect
      puts e
      raise
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
