class CreateProjectCalendars < ActiveRecord::Migration
  def self.up
    create_table :project_calendars do |t|
      t.column :project_id, :integer, :default => 0, :null => false
      t.column :calendar_id, :string, :default => "", :null => false
    end
  end

  def self.down
    drop_table :project_calendars
  end
end
