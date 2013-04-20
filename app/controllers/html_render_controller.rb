class HtmlRenderController < ApplicationController
  def show
    
  end
  def load_files
    dir_name = Time.now.to_s(:number)
    dir_path = Pathname(Rails.root) + 'tmp' + 'html_render' + dir_name
    FileUtils.mkdir_p(dir_path) unless FileTest.exist?(dir_path)

    pathnames = params[:file][:names].map do |fi|
      file_name = fi.original_filename
      path = (dir_path + file_name).to_s
      open(path, 'wb') do |fo|
        fo.write(fi.read)
      end
      path
    end
    out_dir_path = Pathname(Rails.root) + 'tmp' + 'html_render' + (dir_name + '_html')
    LiseLoader.exec_with_dir_and_zip(dir_path, Lise::Application.config.template_unix_path, out_dir_path)
    flash[:notice] = "HTML files are going to be created"
    redirect_to(:action => :wait_for_download,
                :dir_path => dir_path, 
                :whole_num => pathnames.size,
                :out_dir_path => out_dir_path
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
    #if(@progress == 100)
    if(true)
      # download
      redirect_to('show')
    end
  end

end
