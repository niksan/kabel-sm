class CreateNews < ActiveRecord::Migration
  def change
    create_table :news do |t|
      t.string :title
      t.date :date
      t.text :body
      t.string :slug

      t.timestamps
    end
  end
end
