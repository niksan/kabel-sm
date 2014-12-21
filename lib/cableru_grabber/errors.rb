module CableruGrabber::Errors

  CableruError = Class.new(StandardError)
  CableruError::ZeroLinksError = Class.new(CableruError)
  CableruError::EntryTypeError = Class.new(CableruError)

end
