class CreateTranslationTables < ActiveRecord::Migration
  def self.up
    create_table :translation_keys do |t|
      t.string :key, :unique=>true, :null=>false
      t.add_index :key
      t.timestamps
    end
    
    create_table :translation_texts do |t|
      t.text :text
      t.string :locale
      t.integer :translation_key_id, :null=>false
      t.add_index :translation_key_id
      t.timestamps
    end
  end

  def self.down
    drop_table :translation_keys
    drop_table :translation_texts
  end
end