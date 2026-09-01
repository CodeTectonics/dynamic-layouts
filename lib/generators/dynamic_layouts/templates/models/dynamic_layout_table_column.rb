class DynamicLayoutTableColumn < ApplicationRecord
  belongs_to :dynamic_layout_section

  validates :attr_name, presence: true
  validates :attr_type, presence: true
  validates :label, presence: true

  def serialize
    {
      header: label,
      attr: attr_name,
      type: attr_type,
      options: DynamicLayouts::DynamicLayoutService.serialize_options(options, attr_type),
      hidden: hidden
    }
  end
end
