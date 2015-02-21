class SocrataBase
  def initialize(record, cache=nil)
    @record = record
    @cache = cache
  end

  # Helper method to make the dates look nice in the "fancy title".
  def date_cleanup(date_str, format_string="%b %-e, %Y")
    date_str.gsub!(/T[\d\:]+$/,'')
    Time.parse(date_str).strftime(format_string)
  end

  def location
    @record['location']
  end

end
