module CableruGrabber::Requests

  def request(uri, anonymizer)
    @anonymizer = anonymizer
    source = begin
               http_proxy(@anonymizer.proxy, 80)
               self.get(uri, headers: { 'User-Agent' => useragent })
             rescue SocketError
               request_retrying uri
             rescue Net::OpenTimeout
               request_retrying uri
             rescue Errno::EHOSTUNREACH
               request_retrying uri
             rescue Net::ReadTimeout
               request_retrying uri
             rescue Exception => e
               puts e
               sleep(5)
               request_retrying uri
             end
    if source.match(/id=\"map_europe\"/) && source.match(/id=\"map_ukraine\"/) && source.match(/id=\"map_east\"/)
       print '!'
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
