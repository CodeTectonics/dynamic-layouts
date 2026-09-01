class DynamicLayoutSection < ApplicationRecord
  belongs_to :dynamic_layout_container, optional: true
  belongs_to :config, polymorphic: true, optional: true
  has_many :dynamic_layout_grid_fields, -> { order(:ordinal) },
           inverse_of: :dynamic_layout_section, dependent: :destroy
  has_many :dynamic_layout_dashboard_widgets, -> { order(:ordinal) },
           inverse_of: :dynamic_layout_section, dependent: :destroy
  has_many :dynamic_layout_markdown_elements, -> { order(:ordinal) },
           inverse_of: :dynamic_layout_section, dependent: :destroy
  has_many :dynamic_layout_table_columns, -> { order(:ordinal) },
           inverse_of: :dynamic_layout_section, dependent: :destroy

  accepts_nested_attributes_for :dynamic_layout_grid_fields, allow_destroy: true
  accepts_nested_attributes_for :dynamic_layout_dashboard_widgets, allow_destroy: true
  accepts_nested_attributes_for :dynamic_layout_markdown_elements, allow_destroy: true
  accepts_nested_attributes_for :dynamic_layout_table_columns, allow_destroy: true

  before_save :ensure_config_exists

  def serialize
    result = {
      title: title,
      slug: slug,
      layout: layout_style,
      config: config.try(:serialize),
      elements: [],
      writable: writable,
      hidden: hidden,
      collapsed: collapsed,
      options: DynamicLayouts::DynamicLayoutService.serialize_options(options)
    }

    case layout_style
    when 'grid', 'report'
      result[:elements] = dynamic_layout_grid_fields.map(&:serialize)
    when 'table', 'roster-shift-list'
      result[:elements] = dynamic_layout_table_columns.map(&:serialize)
    when 'dashboard'
      result[:elements] = dynamic_layout_dashboard_widgets.map(&:serialize)
    when 'markdown'
      result[:elements] = dynamic_layout_markdown_elements.map(&:serialize)
    end

    result
  end

  private

  def ensure_config_exists
    return unless layout_style.in? %w[table roster-shift-list board]
    return if config.is_a? DynamicLayoutTableConfig

    self.config = DynamicLayoutTableConfig.create
  end
end
