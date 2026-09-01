class CreateDynamicLayoutGridFields < ActiveRecord::Migration[7.0]
  def change
    create_table :dynamic_layout_grid_fields do |t|
      t.references :dynamic_layout_section, foreign_key: true
      t.string :label
      t.string :attr_name
      t.string :attr_type
      t.string :options, limit: 2000
      t.string :default
      t.boolean :required, default: false, null: false
      t.boolean :disabled, default: false, null: false
      t.boolean :hidden, default: false, null: false
      t.integer :ordinal, default: 0
      t.string :tooltip

      t.timestamps
    end
  end
end
