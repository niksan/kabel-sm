class News < ActiveRecord::Base

  extend FriendlyId
  friendly_id :title, use: [:history, :finders]

end
