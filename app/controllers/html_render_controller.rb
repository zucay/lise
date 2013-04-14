class HtmlRenderController < ApplicationController
  def show
    
  end
  def load_files
    pathnames = params[:file][:names].map do |fi|
      uniq_name = Time.now.to_s(:number) + '_' + fi.original_filename
      path = (Pathname(Rails.root) + 'tmp' + 'uploads' + uniq_name).to_s
      open(path, 'wb') do |fo|
        fo.write(fi.read)
      end
      path
    end
    #Session.delay.load(params[:id], pathnames)
    flash[:notice] = "FILE_LOAD is queued."
    redirect_to :action => :wait_for_download, :pathnames => pathnames
  end
  def wait_for_download
    @pathnames = params[:pathnames]
  end
  def update_progress
    @progress = rand(100)
  end
end
