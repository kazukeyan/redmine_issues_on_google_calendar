class AddColumnsToProjectCalendars < ActiveRecord::Migration
  def self.up
    add_column :project_calendars, :timezone, :string
    add_column :project_calendars, :display_format, :string
    add_column :project_calendars, :delete_after_close, :boolean
  end

  def self.down
    remove_column :project_calendars, :timezone
    remove_column :project_calendars, :display_format
    remove_column :project_calendars, :delete_after_close
  end
end
