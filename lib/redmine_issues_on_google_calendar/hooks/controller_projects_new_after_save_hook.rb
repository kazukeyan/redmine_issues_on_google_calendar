module RedmineIssuesOnGoogleCalendar
  module Hooks
    class ControllerProjectsNewAfterSaveHook < Redmine::Hook::ViewListener
      def controller_projects_new_after_save(context={})
        context[:project].create_google_calendar
      end
    end
  end
end