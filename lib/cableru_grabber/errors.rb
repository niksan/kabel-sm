module CableruGrabber::Errors

  CableruError = Class.new(StandardError)
  ZeroLinksError = Class.new(CableruError)
  EntryTypeError = Class.new(CableruError)

end
