# -*- coding: utf-8 -*-

require 'active_support/all'
require 'mymatrix'
require 'nokogiri'
require 'pp'
require 'pathname'
require 'html_builder'

class LiseLoader
  SEASON = %w[A1 A2 B1 B2 C1 C2 SP1 SP2 SP3]
  COLOR = %w[smn pnk bgr ppl ylw ybk gre lim fgr] # specified at 2013-03-23 Mail
  def self.parse_xls(file)
    out = []
    mx = MyMatrix.new(file, {sheet:'シーズナリ設定' })
    mx.shift # 2行目のヘッダ分shift
    mx.each do |row|
      begin
        ent_date = Date.parse(mx.val(row, '入校日'))
      rescue
        next
      end
      season = ''
      9.times do |i|
        season_var = mx.val(row, 'シーズナリ設定', i)
        if '1' == season_var
          season = SEASON[i]
          break
        end
      end
      if mx.val(row, '普通車AT') != ''
        gdu_date = ent_date + mx.val(row, '普通車AT').to_i.days
        out << {ent_date: ent_date, type:'at', season: season, gdu_date: gdu_date}
      end
      if mx.val(row, '普通車MT') != ''
        gdu_date = ent_date + mx.val(row, '普通車MT').to_i.days
        out << {ent_date: ent_date, type:'mt', season: season, gdu_date: gdu_date}
      end
    end
    return out
  end
  def self.exec(file, template, out_dir=nil)
    parse_data = self.parse_xls(file)
    builder = HTMLBuilder.new(template)
    parse_data.each do |data|
      begin
        ent_id = "#{data[:type]}_ent_#{data[:ent_date].to_s}".gsub(/-/, '_')
        gdu_id = "#{data[:type]}_gdu_#{data[:ent_date].to_s}".gsub(/-/, '_')
        ent_class = "ent_#{COLOR[SEASON.index(data[:season])]}"
        gdu_class = "gdu_#{COLOR[SEASON.index(data[:season])]}"
        builder.set_attribute("//td[@id='#{ent_id}']", 'class', ent_class)
        builder.set_attribute("//td[@id='#{gdu_id}']", 'class', gdu_class)
        builder.set_content("//td[@id='#{gdu_id}']", data[:gdu_date].strftime("%m/%d").gsub(/^0/, "").gsub(/\/0/, "/"))
      rescue
        p "!!!!invalid data!!!! #{file}"
        pp data
        next
      end
    end
    builder.remove_attribute("//td", 'id')
    out_file_name = File.basename(file, '.*').gsub(/.*?_([a-zA-Z0-9_]+)$/, '\1') + '.html'
    if(out_dir)
      FileUtils.mkdir_p(out_dir.to_s)
    end
    out_path = (Pathname.new(out_dir.to_s) + out_file_name).to_s
    builder.to_file(out_path)
  end
  def self.exec_with_dir(dir, template, out_dir=nil)
    Dir.entries(dir).each do |ele|
      if ele =~ /\.xls$/
        file = File.expand_path(ele, dir)
        exec(file, template, out_dir)
      end
    end
  end
  def self.exec_with_dir_and_zip(dir, template, out_dir=nil)
    out_dir ||= self.make_dir
    self.exec_with_dir(dir, template, out_dir)
    zip_name = File.basename(out_dir) + '.zip'
    zip_path = (Pathname.new(out_dir) + zip_name).to_s
    Zip::Archive.open(zip_path, Zip::CREATE) do |ar|
      Dir.entries(out_dir).delete_if{|f| f =~ /^\./}.each do |file|
        path = (Pathname.new(out_dir) + file).to_s
        ar.add_file(path)
      end
    end

    return zip_path
  end
  def self.make_dir
    return Time.now.strftime('%Y%m%d%H%M%S') + '_out_html'
  end
end
if __FILE__ == $0
  LiseLoader.exec_dir(ARGV[0], 'app/templates/sample_price2.html')
end
