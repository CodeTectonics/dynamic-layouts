class DynamicLayout < ApplicationRecord
  has_many :dynamic_layout_custom_schemas, dependent: :destroy
  has_many :dynamic_layout_containers, -> { order(:ordinal) }, inverse_of: :dynamic_layout,
                                                               dependent: :destroy
  has_many :dynamic_layout_sections, through: :dynamic_layout_containers
  has_many :dynamic_layout_grid_fields, through: :dynamic_layout_sections
  has_many :dynamic_layout_dashboard_widgets, through: :dynamic_layout_sections
  has_many :dynamic_layout_markdown_elements, through: :dynamic_layout_sections
  has_many :dynamic_layout_table_columns, through: :dynamic_layout_sections

  accepts_nested_attributes_for :dynamic_layout_containers, allow_destroy: true

  def eager_load_sections
    self.dynamic_layout_containers =
      dynamic_layout_containers.includes(
        dynamic_layout_sections: [
          :dynamic_layout_grid_fields,
          :dynamic_layout_table_columns,
          :dynamic_layout_dashboard_widgets,
          :dynamic_layout_markdown_elements,
          config: [
            modal_section: :dynamic_layout_grid_fields
          ]
        ]
      )
    self
  end

  def serialize
    {
      name: name,
      containers: dynamic_layout_containers.map(&:serialize)
    }
  end
end
