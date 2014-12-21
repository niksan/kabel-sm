module CableruGrabber::Errors

  CableruError = Class.new(StandardError)
  CableruError::ZeroLinksError = Class.new(CableruError)

end
