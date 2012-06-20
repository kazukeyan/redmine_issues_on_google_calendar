require 'redmine'

# Patches to the Redmine core.
require 'dispatcher'

Dispatcher.to_prepare :redmine_issues_on_google_calendar do
  require_dependency 'issue'
  require_dependency 'project'

  unless Issue.included_modules.include? RedmineIssuesOnGoogleCalendar::IssuePatch
    Issue.send(:include, RedmineIssuesOnGoogleCalendar::IssuePatch)
  end
  unless Project.included_modules.include? RedmineIssuesOnGoogleCalendar::ProjectPatch
    Project.send(:include, RedmineIssuesOnGoogleCalendar::ProjectPatch)
  end

end

Redmine::Plugin.register :redmine_issues_on_google_calendar do
  name 'Redmine Issues On Google Calendar plugin'
  author 'Kazuki Kitabayashi'
  description 'This is a plugin for Redmine'
  version '0.1.0'
  url 'https://github.com/kazukeyan/redmine_issues_on_google_calendar'
  author_url 'https://github.com/kazukeyan/'
end
