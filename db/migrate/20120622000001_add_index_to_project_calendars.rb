class AddIndexToProjectCalendars < ActiveRecord::Migration
  def self.up
    add_index :project_calendars, :project_id, :unique => true
  end

  def self.down
    remove_index :project_calendars, :project_id
  end
end
