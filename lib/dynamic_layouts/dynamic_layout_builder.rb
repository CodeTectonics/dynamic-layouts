module DynamicLayouts
  class DynamicLayoutBuilder
    attr_accessor :dynamic_layout

    def initialize(name)
      self.dynamic_layout = DynamicLayout.find_by name: name
    end

    def eager_load_sections
      dynamic_layout.eager_load_sections
      self
    end

    def serialize
      self.dynamic_layout = dynamic_layout.serialize
      self
    end

    def transform(record: nil, controller: nil, user: nil, transformer_class: nil)
      transformer_class ||= implied_transformer_class(controller)

      if transformer_class.present?
        transformer_class.new(dynamic_layout, record, controller, user).transform
      end

      self
    end

    def implied_transformer_class(controller)
      return nil if controller.nil?

      "#{controller.controller_name.classify}LayoutTransformer".constantize
    rescue NameError
      nil
    end

    def self.build(name, **transform_params)
      DynamicLayoutBuilder.new(name)
                          .eager_load_sections
                          .serialize
                          .transform(**transform_params)
                          .dynamic_layout
    end
  end
end
