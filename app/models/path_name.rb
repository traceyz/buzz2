module PathName

  def image_name
    "#{clean_name(name)}.jpg"
  end

  def page_name
    "#{clean_name(name)}.html"
  end

  def clean_name(str)
    str.gsub(/[^A-z0-9_]/,'').downcase
  end

end
