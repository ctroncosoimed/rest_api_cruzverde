class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :user
      t.string :password_digest
      t.string :token

      t.timestamps
    end
  end
end
