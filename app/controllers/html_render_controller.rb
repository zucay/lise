# -*- coding: utf-8 -*-
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
    LiseLoader.delay.exec_with_dir_and_zip(dir_path, Lise::Application.config.template_unix_path, out_dir_path)
    #flash[:notice] = "HTML files are going to be created"
    redirect_to(:action => :wait_for_download,
                :dir_path => dir_path, 
                :whole_num => pathnames.size,
                :out_dir_path => out_dir_path
                )
  end
  def wait_for_download
    @html_dir = params[:dir_path] + '_html'
    @whole_num = params[:whole_num]

    zip_file_name = File.basename(@html_dir) + '.zip'
    @zip_path = @html_dir + '/' + zip_file_name

  end
  def update_progress
    @whole_num, @html_dir = 0, ''
    @num, @progress = 0,0
    @html_dir = params[:html_dir]
    @whole_num = params[:whole_num].to_i
    @num = Dir.entries(@html_dir).count - 2 # %w[. ..]
    @progress = 10 + (90 * @num/@whole_num).to_i
  end
  def download
    send_file params[:zip_path]
  end
end
