# -*- coding: utf-8 -*-
require 'mymatrix'
require 'active_support/all'
require 'nokogiri'
require 'pp'
class LiseLoader
  SEASON = %w[A1 A2 B1 B2 C1 C2 SP1 SP2 SP3]
  COLOR = %w[smn pnk bgr ppl ylw ybk gre lim fgr] # specified at 2013-03-23 Mail
  def parse_xls(file)
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
  def main(file, template)
    parse_data = parse_xls(file)
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
    out_path = File.basename(file, '.*').gsub(/.*?_([a-zA-Z0-9_]+)$/, '\1.html')
    builder.to_file(out_path)
  end
  def main_dir(dir, template)
    Dir.entries(dir).each do |ele|
      if ele =~ /\.xls$/
        file = File.expand_path(ele, dir)
        p file
        main(file, template)
      end
    end
  end
end
class HTMLBuilder
  def initialize(template_file)
    f = File.open(template_file)
    @doc = Nokogiri::HTML(f)
    f.close
  end
  def set_attribute(q, attr, value_str)
    ele = @doc.at_xpath(q)
    ele[attr] = value_str if ele
  end
  def remove_attribute(q, attr)
    @doc.xpath(q).each do |ele|
      ele.delete(attr)
    end
  end
  def set_content(q, value_str)
    ele = @doc.at_xpath(q)
    ele.content = value_str if ele
  end
  def to_file(file)
    f = open(file, 'w')
    f.write(@doc)
    f.close
  end
end


if __FILE__ == $0
=begin
  ARGV.each do |file|
    LiseLoader.new.main(file, '/Users/zuka/Dropbox/work/130317_LMC/input/sample_price.html')
  end
=end
  LiseLoader.new.main_dir(ARGV[0], 'app/templates/sample_price2.html')
end
