module Utils
  # Poor man's titlecase (without including active_support)
  def self.titleize(str)
    str.gsub(/\b([A-Za-z])+|\b\d+[A-Za-z]{2}\b/) do |match|
      "#{match[0].upcase}#{match[1..-1].downcase}"
    end
  end
end
