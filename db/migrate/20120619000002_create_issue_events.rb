class CreateIssueEvents < ActiveRecord::Migration
  def self.up
    create_table :issue_events, :id => false do |t|
      t.column :issue_id, :integer, :default => 0, :null => false
      t.column :event_id, :string, :default => "", :null => false
    end
  end

  def self.down
    drop_table :issue_events
  end
end
