class CreateImports < ActiveRecord::Migration[7.1]
  def change
    create_table :imports do |t|
      t.string :title
      t.string :link

      t.timestamps
    end
  end
end
