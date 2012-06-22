class AddIndexToIssueEvents < ActiveRecord::Migration
  def self.up
    add_index :issue_events, :issue_id, :unique => true
  end

  def self.down
    remove_index :issue_events, :issue_id
  end
end
