class CreateDynamicLayoutContainers < ActiveRecord::Migration[7.0]
  def change
    create_table :dynamic_layout_containers do |t|
      t.references :dynamic_layout, foreign_key: true
      t.string :slug
      t.string :container_style
      t.integer :ordinal, default: 0

      t.timestamps
    end
  end
end
