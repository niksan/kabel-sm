module CableruGrabber::ToApplication

  def page_to_application(source, type)
    n = Nokogiri::HTML(source)
    case type
    when :razdel
      title = n.css('#content > .column-2 > .clean.module0 > h1').text
      puts title
    when :group
      ###
    when :related
      ###
    when :marka
      ###
    end
  end

end
