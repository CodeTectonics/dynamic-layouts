class DynamicLayoutTableConfig < ApplicationRecord
  belongs_to :modal_section, class_name: 'DynamicLayoutSection', optional: true

  def serialize
    {
      attr: attr_name,
      modal_section: modal_section.try(:serialize),
      can_add: can_add,
      can_edit: can_edit,
      can_delete: can_delete
    }
  end
end
