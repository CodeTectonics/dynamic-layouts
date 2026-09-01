# frozen_string_literal: true

require_relative "dynamic_layouts/dynamic_layout_builder"
require_relative "dynamic_layouts/dynamic_layout_service"
require_relative "dynamic_layouts/dynamic_layout_transformer"
require_relative "dynamic_layouts/version"

module DynamicLayouts
  class Error < StandardError; end
end
