class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :birthday, null: false
      t.string :timezone, null: false, default: 'UTC'

      t.timestamps
    end

    add_index :users, [:first_name, :last_name]
    add_index :users, 'EXTRACT(MONTH FROM birthday), EXTRACT(DAY FROM birthday)', name: 'index_users_on_birthday_month_day'
  end
end
