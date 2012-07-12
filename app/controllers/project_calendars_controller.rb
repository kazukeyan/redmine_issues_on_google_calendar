class ProjectCalendarsController < ApplicationController
  unloadable

  def edit
    @project = Project.find(params[:project_id])
  end
  
  def update
    @project = Project.find(params[:project_id])
    if @project.calendar.update_attributes(params[:project_calendar])
      @project.update_google_calendar
      flash[:notice] = l(:notice_successful_update)

      respond_to do |format|
        format.html { redirect_back_or_default project_edit_google_calendar_path }
        format.api  { head :ok }
      end
    else
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.api  { render_validation_errors(@project.calendar) }
      end
    end
  end
end
