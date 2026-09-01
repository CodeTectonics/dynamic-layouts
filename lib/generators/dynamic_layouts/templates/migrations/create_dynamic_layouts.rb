class CreateDynamicLayouts < ActiveRecord::Migration[7.0]
  def change
    create_table :dynamic_layouts do |t|
      t.string :name

      t.timestamps
    end
  end
end
