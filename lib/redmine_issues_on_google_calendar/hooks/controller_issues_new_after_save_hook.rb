module RedmineIssuesOnGoogleCalendar
  module Hooks
    class ControllerIssuesNewAfterSaveHook < Redmine::Hook::ViewListener
      def controller_issues_new_after_save(context={})
        context[:issue].create_google_calendar_event
      end
    end
  end
end