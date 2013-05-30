class HTMLBuilder
  def initialize(template_file, opts={})
    opts[:enc] ||= nil
    f = NKF.nkf("--utf8", File.open(template_file).read)
    @doc = Nokogiri::HTML(f, nil, 'utf-8')

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


