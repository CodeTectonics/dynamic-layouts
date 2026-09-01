class CreateDynamicLayoutDashboardWidgets < ActiveRecord::Migration[7.0]
  def change
    create_table :dynamic_layout_dashboard_widgets do |t|
      t.references :dynamic_layout_section, foreign_key: true, index: { name: :index_dynamic_layout_dashboard_widgets_on_section_id }
      t.string :label
      t.string :widget_slug
      t.integer :ordinal, default: 0
      t.boolean :hidden, default: false, null: false

      t.timestamps
    end
  end
end
