class Category < ActiveRecord::Base
  
  has_ancestry
  extend FriendlyId
  friendly_id :name, use: [:history, :finders]

end
