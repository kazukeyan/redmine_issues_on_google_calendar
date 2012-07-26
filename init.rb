require 'redmine'

Redmine::Plugin.register :redmine_issues_on_google_calendar do
  name 'Redmine Issues On Google Calendar plugin'
  author 'Kazuki Kitabayashi'
  description 'This is a plugin for Redmine'
  version '0.1.4'
  url 'https://github.com/kazukeyan/redmine_issues_on_google_calendar'
  author_url 'https://github.com/kazukeyan/'
  project_module :redmine_issues_on_google_calendar do |map|
    map.permission :manage_google_calendar, {:project_calendars => [:edit, :update]}, :require => :member
    map.permission :migrate_issues, {:migrate_issues => [:migrate_to_google_calendar_events]}, :require => :member
  end
  menu :project_menu, :project_calendars, { :controller => 'project_calendars', :action => 'edit' }, :caption => 'Google Calendar', :before => :settings, :param => :project_id
end

# Patches to the Redmine core.
require 'dispatcher'

Dispatcher.to_prepare :redmine_issues_on_google_calendar do
  require_dependency 'issue'
  unless Issue.included_modules.include? RedmineIssuesOnGoogleCalendar::IssuePatch
    Issue.send(:include, RedmineIssuesOnGoogleCalendar::IssuePatch)
  end

  require_dependency 'project'
  unless Project.included_modules.include? RedmineIssuesOnGoogleCalendar::ProjectPatch
    Project.send(:include, RedmineIssuesOnGoogleCalendar::ProjectPatch)
  end
end

require 'redmine_issues_on_google_calendar/hooks/view_issues_index_bottom_hook'