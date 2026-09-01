class CreateDynamicLayoutMarkdownElements < ActiveRecord::Migration[7.0]
  def change
    create_table :dynamic_layout_markdown_elements do |t|
      t.references :dynamic_layout_section, foreign_key: true, index: { name: :index_dynamic_layout_markdown_elements_on_section_id }
      t.text :text
      t.integer :ordinal, default: 0

      t.timestamps
    end
  end
end
