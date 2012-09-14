class MigrateIssuesController < ApplicationController
  unloadable

  before_filter :find_issues, :authorize

  def migrate_to_google_calendar_events
    @projects.each do |project|
      project.save_google_calendar
    end
    @issues.each do |issue|
      issue.save_google_calendar_event
    end
  end
end
