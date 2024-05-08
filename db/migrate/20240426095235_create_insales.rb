class CreateInsales < ActiveRecord::Migration[7.1]
  def change
    create_table :insales do |t|
      t.string :api_key
      t.string :api_password
      t.string :api_link

      t.timestamps
    end
  end
end
