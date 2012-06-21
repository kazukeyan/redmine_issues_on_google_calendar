require 'redmine'

Redmine::Plugin.register :redmine_issues_on_google_calendar do
  name 'Redmine Issues On Google Calendar plugin'
  author 'Kazuki Kitabayashi'
  description 'This is a plugin for Redmine'
  version '0.1.0'
  url 'https://github.com/kazukeyan/redmine_issues_on_google_calendar'
  author_url 'https://github.com/kazukeyan/'
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

require 'redmine_issues_on_google_calendar/hooks/controller_issues_new_after_save_hook'