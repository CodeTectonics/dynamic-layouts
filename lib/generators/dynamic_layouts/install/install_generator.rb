require "rails/generators"
require "rails/generators/named_base"
require "rails/generators/migration"

module DynamicLayouts
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("../templates", __dir__)

      desc "Creates the models and migrations used by a Dynamic Layout."

      def create_models
        template "models/dynamic_layout.rb", "app/models/dynamic_layout.rb"
        template "models/dynamic_layout_container.rb", "app/models/dynamic_layout_container.rb"
        template "models/dynamic_layout_section.rb", "app/models/dynamic_layout_section.rb"
        template "models/dynamic_layout_grid_field.rb", "app/models/dynamic_layout_grid_field.rb"
        template "models/dynamic_layout_table_column.rb", "app/models/dynamic_layout_table_column.rb"
        template "models/dynamic_layout_table_config.rb", "app/models/dynamic_layout_table_config.rb"
        template "models/dynamic_layout_markdown_element.rb", "app/models/dynamic_layout_markdown_element.rb"
        template "models/dynamic_layout_dashboard_widget.rb", "app/models/dynamic_layout_dashboard_widget.rb"
      end

      def create_migrations
        migration_template "migrations/create_dynamic_layouts.rb", "db/migrate/create_dynamic_layouts.rb"
        migration_template "migrations/create_dynamic_layout_containers.rb", "db/migrate/create_dynamic_layout_containers.rb"
        migration_template "migrations/create_dynamic_layout_sections.rb", "db/migrate/create_dynamic_layout_sections.rb"
        migration_template "migrations/create_dynamic_layout_grid_fields.rb", "db/migrate/create_dynamic_layout_grid_fields.rb"
        migration_template "migrations/create_dynamic_layout_table_columns.rb", "db/migrate/create_dynamic_layout_table_columns.rb"
        migration_template "migrations/create_dynamic_layout_table_configs.rb", "db/migrate/create_dynamic_layout_table_configs.rb"
        migration_template "migrations/create_dynamic_layout_markdown_elements.rb", "db/migrate/create_dynamic_layout_markdown_elements.rb"
        migration_template "migrations/create_dynamic_layout_dashboard_widgets.rb", "db/migrate/create_dynamic_layout_dashboard_widgets.rb"
      end

      def self.next_migration_number(dirname)
        if @next_migration_number
          @next_migration_number += 1
        else
          @next_migration_number = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
        end
        @next_migration_number.to_s
      end
    end
  end
end
