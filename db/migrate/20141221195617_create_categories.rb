class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.text :body
      t.string :image
      t.string :ancestry
      t.string :slug
      t.string :type
      t.string :external_url

      t.timestamps
    end
    add_index :categories, :ancestry
    add_index :categories, :slug
    add_index :categories, :type
    add_index :categories, :external_url
  end
end
