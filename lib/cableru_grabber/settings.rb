module CableruGrabber

  include HTTParty
  default_timeout 2

  DOMAIN='http://cable.ru'
  FIRST_ENTRIES = [
    { type: :main, uri: DOMAIN+'/' },
    { type: :group, uri: DOMAIN+'/engines/' },
    { type: :group, uri: DOMAIN+'/pumps/' }
  ]
  REGEXPS = {
    title: '[а-яА-Яa-zA-Z \(\)-_]*',
    href_uri: {
      razdel: '((\/([a-z_-])*\/)?(razdel-(\w)*\.php))',
      group: '((\/([a-z_-])*\/)?(group-(\w)*\.php))',
      marka: '((\/([a-z_-])*\/)?(marka-(\w)*\.php))',
      related: '(\/related\/(\w)*\.(php))',
    }
  }
  TYPES = {
    main: {
      link_match: /@@!!@@!!\)\)XuiPizdaaa/,
      li_match: /@@!!@@!!\)\)XuiPizdaaa/,
      css_selector: '#content .column div.catalog.module'
    },
    razdel: {
      link_match: /http:\/\/cable\.ru\/(\D)*\/(razdel-(\w)*\.php)/,
      li_match: /<a( style="display: block;")? href="#{ REGEXPS[:href_uri][:razdel] }"( title="#{ REGEXPS[:title] }")?>(#{ REGEXPS[:title] })<\/a>/,
      css_selector: '#content .column-2',
    },
    group: {
      link_match: /http:\/\/cable\.ru\/(\D)*\/(group-(\w)*\.php)/,
      li_match: /<a( style="display: block;")? href="#{ REGEXPS[:href_uri][:group] }"( title="#{ REGEXPS[:title] }")?>(#{ REGEXPS[:title] })<\/a>/,
      css_selector: '#content .column-2',
    },
    marka: {
      link_match: /http:\/\/cable\.ru\/(\D)*\/(marka-(\w)*\.php)/,
      li_match: /<a( style="display: block;")? href="#{ REGEXPS[:href_uri][:marka] }"( title="#{ REGEXPS[:title] }")?>(#{ REGEXPS[:title] })<\/a>/,
      css_selector: '#content .column-2',
    },
    related: {
      link_match: /http:\/\/cable\.ru\/(related\/(\w)*\.php)/,
      li_match: /<a( style="display: block;")? href="#{ REGEXPS[:href_uri][:related] }(")( title="#{ REGEXPS[:title] }")?(>)(#{ REGEXPS[:title] })<\/a>/,
      css_selector: '#content .column-2',
    }
  }
end
