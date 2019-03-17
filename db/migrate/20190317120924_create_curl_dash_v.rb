class CreateCurlDashV < ActiveRecord::Migration[5.2]
  def change
    create_table :curl_dash_vs do |t|
      t.string :dump
      t.integer :count, :default => 0

      t.timestamps
    end
  end
end
