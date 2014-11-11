module CableruGrabber

  DOMAIN='http://cable.ru'
  FIRST_ENTRIES = [
    { type: :main, uri: '/' }#,
#    { type: :group, uri: '/engines/' },
#    { type: :group, '/pumps/' }
  ]
  TYPES = {
    main: { css_selector: '#content .column div.catalog.module' },
    razdel: {
      link_match: /http:\/\/cable\.ru\/(\D)*\/(razdel-(\d)*\.php)/,
      css_selector: '#content .column2',
    },
    group: {
      link_match: /http:\/\/cable\.ru\/(\D)*\/(group-(\w)*\.php)/,
      selector_method: '#content .column2',
    },
    marka: {
      link_match: /http:\/\/cable\.ru\/(\D)*\/(marka-(\w)*\.php)/,
      selector_method: '#content .column2',
    }
  }

  class << self

    def grab(entries=FIRST_ENTRIES)
      start_time = Time.zone.now
      entries.each do |entry|
        uri = DOMAIN + entry[:uri]
        source = SimpleUri.req(uri)
        puts get_links(source, entry[:type])
      end
      runtime = Time.zone.now - start_time
      puts "RUNTIME - #{ runtime }"
    end

    private

      def get_links(source, type)
        n = Nokogiri::HTML(source)
        n.css TYPES[type][:css_selector]
      end
    
  end

end
