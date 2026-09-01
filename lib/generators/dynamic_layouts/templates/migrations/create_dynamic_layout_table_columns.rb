class CreateDynamicLayoutTableColumns < ActiveRecord::Migration[7.0]
  def change
    create_table :dynamic_layout_table_columns do |t|
      t.references :dynamic_layout_section, foreign_key: true
      t.string :label
      t.string :attr_name
      t.string :attr_type
      t.string :options, limit: 2000
      t.boolean :hidden, default: false, null: false
      t.integer :ordinal, default: 0

      t.timestamps
    end
  end
end
