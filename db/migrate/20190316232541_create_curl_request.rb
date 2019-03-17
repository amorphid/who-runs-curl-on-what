class CreateCurlRequest < ActiveRecord::Migration[5.2]
  def change
    create_table :curl_requests do |t|
      t.string :architecture
      t.integer :count, :default => 0
      t.string :operating_system

      t.timestamps
    end
  end
end
