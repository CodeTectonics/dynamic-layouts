# Dynamic Layouts

A Ruby on Rails gem for building flexible, database-driven UI layouts. Dynamic Layouts allows you to define and manage complex form layouts, tables, dashboards, and markdown content through a hierarchical structure stored in your database.

## Features

- **Grid Layouts**: Create responsive form layouts with various field types
- **Table Layouts**: Build dynamic tables with configurable columns
- **Dashboard Widgets**: Design dashboard interfaces with customizable widgets
- **Markdown Elements**: Add rich text content and documentation
- **Layout Overrides**: Programmatically customize layouts at runtime
- **Custom Transformers**: Implement business logic to modify layouts dynamically
- **Easy Setup**: Rails generator creates all necessary migrations and models

## Requirements

- Ruby >= 3.2.0
- Rails >= 6.1

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dynamic_layouts'
```

Then execute:

```bash
bundle install
```

Run the generator to create migrations and models:

```bash
rails generate dynamic_layouts:install
rails db:migrate
```

This will create the following database tables and models:
- `dynamic_layouts`
- `dynamic_layout_containers`
- `dynamic_layout_sections`
- `dynamic_layout_grid_fields`
- `dynamic_layout_table_configs`
- `dynamic_layout_table_columns`
- `dynamic_layout_dashboard_widgets`
- `dynamic_layout_markdown_elements`

## Architecture

Dynamic Layouts uses a hierarchical structure:

```
Layout
  └── Container
        └── Section
              └── Elements (Grid Fields, Table Columns, Dashboard Widgets, or Markdown)
```

- **Layout**: The top-level container for a complete UI layout
- **Container**: Groups related sections together
- **Section**: Defines a specific layout type (grid, table, dashboard, or markdown)
- **Elements**: Individual components within a section

## Usage

### Basic Layout Building

Build and retrieve a layout:

```ruby
# Simple build
layout = DynamicLayouts::DynamicLayoutBuilder.build('user_form')

# Build with transformation
layout = DynamicLayouts::DynamicLayoutBuilder.build(
  'user_form',
  record: @user,
  controller: self,
  user: current_user
)
```

The builder will:
1. Find the layout by name
2. Eager load all associated sections and elements
3. Serialize the layout to a hash structure
4. Apply transformations if a transformer is provided

### Custom Transformers

Create custom transformers to modify layouts based on business logic:

```ruby
class UserLayoutTransformer < DynamicLayouts::DynamicLayoutTransformer
  def transform
    # Hide email field for non-admin users
    if @current_user && !@current_user.admin?
      hide_field('contact_info', :email)
    end
    
    # Make fields read-only for archived records
    if @record&.archived?
      make_section_readonly('personal_details')
    end
    
    @dynamic_layout
  end
  
  private
  
  def hide_field(section_slug, field_attr)
    section = find_section(section_slug)
    return unless section
    
    field = section[:elements].find { |f| f[:attr] == field_attr.to_s }
    field[:hidden] = true if field
  end
  
  def make_section_readonly(section_slug)
    section = find_section(section_slug)
    return unless section
    
    section[:writable] = false
  end
  
  def find_section(slug)
    @dynamic_layout[:containers].each do |container|
      section = container[:sections].find { |s| s[:slug] == slug.to_s }
      return section if section
    end
    nil
  end
end
```

The transformer will be automatically discovered if it follows the naming convention: `{Controller}LayoutTransformer`.

### Layout Overrides

Override layout configuration at runtime:

```ruby
layout = DynamicLayouts::DynamicLayoutBuilder.build('user_form')

overrides = {
  contact_info: {
    writable: false,
    collapsed: true,
    elements: {
      email: { 
        required: true,
        tooltip: 'A valid email address is required'
      },
      phone: { 
        hidden: true 
      }
    }
  },
  personal_details: {
    elements: {
      first_name: { 
        label: 'First Name (Required)',
        required: true 
      }
    }
  }
}

DynamicLayouts::DynamicLayoutService.override_layout_config(layout, overrides)
```

### Grid Layout

Grid layouts are ideal for forms with various field types:

```ruby
# In your layout configuration
section = dynamic_layout.containers.first.sections.create!(
  name: 'Contact Information',
  slug: 'contact_info',
  layout: 'grid',
  position: 1,
  writable: true
)

# Add fields
section.grid_fields.create!(
  label: 'Email',
  attr: 'email',
  attr_type: 'email',
  required: true,
  position: 1
)

section.grid_fields.create!(
  label: 'Phone',
  attr: 'phone',
  attr_type: 'tel',
  position: 2
)
```

### Table Layout

Table layouts display data in columns:

```ruby
section = dynamic_layout.containers.first.sections.create!(
  name: 'Users List',
  slug: 'users_list',
  layout: 'table',
  position: 1
)

table_config = section.table_config
table_config.table_columns.create!(
  header: 'Name',
  attr: 'name',
  position: 1
)

table_config.table_columns.create!(
  header: 'Email',
  attr: 'email',
  position: 2
)
```

### Dashboard Layout

Dashboard layouts create widget-based interfaces:

```ruby
section = dynamic_layout.containers.first.sections.create!(
  name: 'Analytics Dashboard',
  slug: 'analytics',
  layout: 'dashboard',
  position: 1
)

section.dashboard_widgets.create!(
  label: 'Total Users',
  slug: 'total_users',
  widget_type: 'stat',
  position: 1
)

section.dashboard_widgets.create!(
  label: 'Revenue Chart',
  slug: 'revenue_chart',
  widget_type: 'chart',
  position: 2
)
```

### Markdown Layout

Markdown layouts add documentation and rich text:

```ruby
section = dynamic_layout.containers.first.sections.create!(
  name: 'Instructions',
  slug: 'instructions',
  layout: 'markdown',
  position: 1
)

section.markdown_elements.create!(
  content: '# Welcome
  position: 1
)
```

### Field Options

#### Dropdown Fields

```ruby
grid_field.update!(
  attr_type: 'dropdown',
  options: 'mode:static;values:active=Active,inactive=Inactive,pending=Pending'
)

# Or with associations
grid_field.update!(
  attr_type: 'dropdown',
  options: 'mode:association;class:Department;scopes:active;label:name;value:id'
)
```

#### Autocomplete Fields

```ruby
grid_field.update!(
  attr_type: 'autocomplete',
  options: 'mode:static;values:New York,Los Angeles,Chicago,Houston'
)
```

#### Rich Text Fields

```ruby
grid_field.update!(
  attr_type: 'rich-text',
  options: 'placeholder_attrs:first_name,last_name,email'
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

## Testing

Run the test suite:

```bash
bundle exec rspec
```

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/CodeTectonics/dynamic-layouts.
