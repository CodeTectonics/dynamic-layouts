class DynamicLayoutDashboardWidget < ApplicationRecord
  belongs_to :dynamic_layout_section

  validates :label, presence: true

  def serialize
    {
      label: label,
      slug: widget_slug
    }
  end
end
