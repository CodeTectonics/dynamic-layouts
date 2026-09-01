class DynamicLayoutContainer < ApplicationRecord
  belongs_to :dynamic_layout
  has_many :dynamic_layout_sections, -> { order(:ordinal) }, inverse_of: :dynamic_layout_container,
                                                             dependent: :destroy

  accepts_nested_attributes_for :dynamic_layout_sections, allow_destroy: true

  def serialize
    {
      slug: slug,
      container_style: container_style,
      sections: dynamic_layout_sections.map(&:serialize)
    }
  end
end
