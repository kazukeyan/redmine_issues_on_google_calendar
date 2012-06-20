class ProjectCalendar < ActiveRecord::Base
  unloadable
  
  belongs_to :project
  
  validates_presence_of :project_id, :calendar_id
end
