module DynamicLayouts
  class DynamicLayoutTransformer
    def initialize(dynamic_layout, record, controller, current_user)
      @dynamic_layout = dynamic_layout
      @record = record
      @controller = controller
      @current_user = current_user
    end
  end
end
