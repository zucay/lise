class HtmlRenderController < ApplicationController
  def show
    
  end
  def load_files
    dir_name = Time.now.to_s(:number)
    dir_path = Pathname(Rails.root) + 'tmp' + 'uploads' + dir_name
    FileUtils.mkdir_p(dir_path) unless FileTest.exist?(dir_path)

    pathnames = params[:file][:names].map do |fi|
      file_name = fi.original_filename
      path = (dir_path + file_name).to_s
      open(path, 'wb') do |fo|
        fo.write(fi.read)
      end
      path
    end
    #Session.delay.load(params[:id], pathnames)
    flash[:notice] = "FILE_LOAD is queued."
    redirect_to(:action => :wait_for_download,
                :dir_path => dir_path, :whole_num => pathnames.size
                )
  end
  def wait_for_download
    @dir_path = params[:dir_path]
    @whole_num = params[:whole_num]
  end
  def update_progress
    @dir_path = params[:dir_path]
    @whole_num = params[:whole_num].to_i
    @num = rand(@whole_num)

    @progress = (100 * @num/@whole_num).to_i
  end
end
