module DynamicLayouts
  class DynamicLayoutService
    def self.override_layout_config(dynamic_layout, overrides)
      dynamic_layout[:containers].each do |container|
        container[:sections].each do |section|
          section_overrides = overrides[section[:slug].to_sym]
          next if section_overrides.blank?

          if section_overrides.keys.excluding(:elements).any?
            override_section_config(section, section_overrides)
          end

          next if section_overrides[:elements].blank?

          case section[:layout]
          when 'table', 'roster-shift-list'
            override_table_section_element_configs(section, section_overrides)
            override_grid_section_element_configs(section[:config][:modal_section], section_overrides)
          when 'dashboard'
            override_dashboard_section_element_configs(section, section_overrides)
          else
            override_grid_section_element_configs(section, section_overrides)
          end
        end
      end
    end

    def self.override_section_config(section, section_overrides)
      section[:writable] = section_overrides[:writable] if section_overrides.key?(:writable)
      section[:hidden] = section_overrides[:hidden] if section_overrides.key?(:hidden)
      section[:collapsed] = section_overrides[:collapsed] if section_overrides.key?(:collapsed)
    end

    def self.override_table_section_element_configs(section, section_overrides)
      section[:elements].each do |table_column|
        field_overrides = section_overrides[:elements][table_column[:attr].to_sym]
        next if field_overrides.blank?

        table_column[:header] = field_overrides[:label] if field_overrides.key?(:label)
        table_column[:hidden] = field_overrides[:hidden] if field_overrides.key?(:hidden)
      end
    end

    def self.override_dashboard_section_element_configs(section, section_overrides)
      section[:elements].each do |dashboard_widget|
        field_overrides = section_overrides[:elements][dashboard_widget[:slug].to_sym]
        next if field_overrides.blank?

        dashboard_widget[:label] = field_overrides[:label] if field_overrides.key?(:label)
        dashboard_widget[:hidden] = field_overrides[:hidden] if field_overrides.key?(:hidden)
      end
    end

    def self.override_grid_section_element_configs(section, section_overrides)
      section[:elements].each do |grid_field|
        field_overrides = section_overrides[:elements][grid_field[:attr].to_sym]
        next if field_overrides.blank?

        grid_field[:label] = field_overrides[:label] if field_overrides.key?(:label)
        grid_field[:required] = field_overrides[:required] if field_overrides.key?(:required)
        grid_field[:disabled] = field_overrides[:disabled] if field_overrides.key?(:disabled)
        grid_field[:hidden] = field_overrides[:hidden] if field_overrides.key?(:hidden)
        grid_field[:default] = field_overrides[:default] if field_overrides.key?(:default)
        grid_field[:tooltip] = field_overrides[:tooltip] if field_overrides.key?(:tooltip)

        next unless field_overrides.key?(:options)

        grid_field[:options].merge!(field_overrides[:options])
      end
    end

    def self.serialize_options(options, attr_type = nil)
      return {} if options.blank?

      serialized_options = hashify_options(options)

      case attr_type
      when 'dropdown', 'dropdown-md', 'dropdown-lg', 'multiselect', 'multiselect-md', 'multiselect-lg'
        serialize_dropdown_field_values(serialized_options)
      when 'autocomplete'
        serialize_autocomplete_field_values(serialized_options)
      when 'rich-text'
        serialize_rich_text_field_values(serialized_options)
      when 'report-config'
        serialize_report_config(serialized_options)
      when 'chart-config'
        serialize_chart_config(serialized_options)
      end

      serialized_options
    end

    def self.hashify_options(options_string)
      options_hash = {}
      options_string.split(';').each do |option|
        key, val = option.strip.split(':')
        options_hash[key] = val
      end
      options_hash.symbolize_keys!
    end

    def self.serialize_search_values(search_values)
      search_values.each do |search_attr, options|
        search_values[search_attr] = serialize_dropdown_field_values(options)
      end
    end

    def self.serialize_dropdown_field_values(options)
      case options[:mode]
      when 'static'
        options[:values] = serialize_static_dropdown_field_values(options)
      when 'association'
        options[:values] = serialize_association_dropdown_field_values(options)
        options = options.except(:class, :scopes, :label, :value, :hidden)
      end

      options[:values].each { |i| i[:label] = I18n.t(i[:label], default: i[:label]) }

      if options[:disable_sort]
        options[:values]
      else
        options[:values].sort_by! { |i| i[:label] || '' }
      end
    end

    def self.serialize_static_dropdown_field_values(options)
      options[:values].split(',').map do |item|
        if item.include?('=')
          value, label = item.split('=')
        else
          value = label = item
        end
        { value: value.strip, label: label.strip }
      end
    end

    def self.serialize_association_dropdown_field_values(options)
      data_source = options[:scopes].split(',').inject(options[:class].constantize) do |res, scope|
        res.send(scope)
      end

      data_source.map do |item|
        if item.class.respond_to?(:decorator_class?) && item.class.decorator_class?
          item = item.decorate
        end

        result = { label: item.send(options[:label]), value: item.send(options[:value]).to_s }
        result[:hidden] = item.send(options[:hidden]) if options[:hidden].present?
        result
      end
    end

    def self.serialize_autocomplete_field_values(options)
      case options[:mode]
      when 'static'
        options[:values] = serialize_static_autocomplete_field_values(options)
      when 'historic'
        options[:values] = serialize_historic_autocomplete_field_values(options)
        options = options.except(:class, :scopes, :attribute)
      end

      options[:values].sort_by! { |i| i[:label] || '' }
    end

    def self.serialize_static_autocomplete_field_values(options)
      options[:values].split(',').map do |item|
        item.strip!
        { label: item, value: item }
      end
    end

    def self.serialize_historic_autocomplete_field_values(options)
      data_source = options[:scopes].split(',').inject(options[:class].constantize) do |res, scope|
        res.send(scope)
      end

      data_source.where("#{options[:attribute]} IS NOT NULL AND #{options[:attribute]} != ''")
                .select("LOWER(TRIM(#{options[:attribute]})) AS formatted_value")
                .order(:formatted_value).distinct
                .map do |item|
        { label: item.formatted_value.capitalize, value: item.formatted_value.capitalize }
      end
    end

    def self.serialize_rich_text_field_values(options)
      options[:placeholder_attrs] = options[:placeholder_attrs].split(',').map do |item|
        item.strip!
        { key: item, value: item }
      end
      options[:placeholder_attrs].sort_by! { |i| i[:value] || '' }
    end

    def self.serialize_report_config(options)
      dataset_slugs = options[:datasets].split(',').map(&:strip)
      datasets = Dataset.where(slug: dataset_slugs)
      options[:datasets] = datasets.map do |dataset|
        {
          id: dataset.id,
          name: dataset.name,
          columns: AnalyticsPlane::DataSources::Registry.fetch(dataset.slug).column_name_and_types
        }
      end
    end

    def self.serialize_chart_config(options)
      dataset_slugs = options[:datasets].split(',').map(&:strip)
      datasets = Dataset.where(slug: dataset_slugs)
      options[:datasets] = datasets.map do |dataset|
        {
          id: dataset.id,
          name: dataset.name,
          columns: AnalyticsPlane::DataSources::Registry.fetch(dataset.slug).column_name_and_types
        }
      end
    end
  end
end
