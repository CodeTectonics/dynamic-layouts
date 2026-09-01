class DynamicLayoutMarkdownElement < ApplicationRecord
  belongs_to :dynamic_layout_section

  def serialize
    {
      text: text,
      ordinal: ordinal
    }
  end
end
