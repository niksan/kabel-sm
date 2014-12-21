module CableruGrabber::ToApplication

  def page_to_application(source, type, current_url, parent_url)
    n = Nokogiri::HTML(source)
    case type
    when :razdel
      body = ''
      title = n.css('#content > .column-2 > .clean.module0 > h1').text
      body += n.css('#content > .column-2 > .clean.module0 > p').text
      n.css('#content > .column-2 > .clean.module0 > #desc').each do |el|
        body += el.text if el.name == 'p'
      end
      puts title
      puts body
    when :group
      ###
    when :related
      ###
    when :marka
      ###
    when :main
      nil
    else
      raise CableruGrabber::EntryTypeError
    end
  end

end
