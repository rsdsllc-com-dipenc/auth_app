class CreateApiKeys < ActiveRecord::Migration[7.1]
  def change
    create_table :api_keys do |t|
      t.belongs_to :bearer, polymorphic: true
      t.string :common_token_prefix, null: false
      t.string :random_token_prefix, null: false
      t.string :token_digest, null: false

      t.timestamps
    end

    add_index :api_keys, :token_digest, unique: true
    add_index :api_keys, [:random_token_prefix, :bearer_id, :bearer_type], unique: true, name: 'index_api_keys_on_random_token_and_bearer'
  end
end
