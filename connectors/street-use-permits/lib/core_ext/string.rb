# Poor man's titleize w/o ActiveSupport
class String
  def titleize
    gsub(/\b([A-Za-z])+|\b\d+[A-Za-z]{2}\b/) do |match|
      "#{match[0].upcase}#{match[1..-1].downcase}"
    end
  end
end


