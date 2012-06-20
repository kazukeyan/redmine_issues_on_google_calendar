class IssueEvent < ActiveRecord::Base
  unloadable
  
  belongs_to :issue
  
  validates_presence_of :issue_id, :event_id
end
