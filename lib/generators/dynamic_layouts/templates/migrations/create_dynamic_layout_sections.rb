class CreateDynamicLayoutSections < ActiveRecord::Migration[7.0]
  def change
    create_table :dynamic_layout_sections do |t|
      t.references :dynamic_layout_container, foreign_key: true
      t.string :title
      t.string :slug
      t.string :layout_style
      t.references :config, polymorphic: true
      t.boolean :writable, default: true, null: false
      t.boolean :hidden, default: false, null: false
      t.boolean :collapsed, default: false, null: false
      t.integer :ordinal, default: 0
      t.string :options, limit: 2000

      t.timestamps
    end
  end
end
