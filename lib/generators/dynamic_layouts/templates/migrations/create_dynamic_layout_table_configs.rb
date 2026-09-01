class CreateDynamicLayoutTableConfigs < ActiveRecord::Migration[7.0]
  def change
    create_table :dynamic_layout_table_configs do |t|
      t.string :attr_name
      t.boolean :can_add, default: true, null: false
      t.boolean :can_edit, default: true, null: false
      t.boolean :can_delete, default: true, null: false
      t.references :modal_section, foreign_key: { to_table: :dynamic_layout_sections }

      t.timestamps
    end
  end
end
