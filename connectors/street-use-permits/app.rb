require 'faraday'
require 'sinatra'
require 'json'

TITLE_TEMPLATE = <<-CFA.gsub(/\s*\n/,' ').chomp(' ')
A new permit has been issued for %{permit_type}, at %{streetname}
between %{cross_street_1} and %{cross_street_2}, from %{permit_start_date}
to %{permit_end_date}.
CFA

# Poor man's titleize w/o ActiveSupport
class String
  def titleize
    gsub(/\b([A-Za-z])+|\b\d+[A-Za-z]{2}\b/) do |match|
      "#{match[0].upcase}#{match[1..-1].downcase}"
    end
  end
end

def date_cleanup(date_str)
  date_str.gsub!(/T[\d\:]+$/,'')
  Time.parse(date_str).strftime("%b %e, %Y")
end

get '/street-use-permits' do
  url = URI('http://data.sfgov.org/resource/b6tj-gt35.json')
  url.query = Faraday::Utils.build_query(
	  '$order' => 'approved_date DESC',
	  '$limit' => 100,
	  '$where' => "permit_type IS NOT NULL"+
	  " AND streetname IS NOT NULL"+
	  " AND cross_street_1 IS NOT NULL"+
	  " AND cross_street_2 IS NOT NULL"+
	  " AND permit_start_date IS NOT NULL"+
	  " AND permit_end_date IS NOT NULL"+
	  " AND approved_date > '#{(DateTime.now - 7).iso8601}'"
  )

  connection = Faraday.new(url: url.to_s)

  # Query the data.sfgov.org endpoint
  response = connection.get

  collection = JSON.parse(response.body)

  features = collection.map do |record|
    # Apply any transformations needed to the text being sent to our
    # title "mad lib" above.
    title_pieces = {
      :permit_type => record['permit_type'],
      :streetname => record['streetname'].titleize,
      :cross_street_1 => record['cross_street_1'].titleize,
      :cross_street_2 => record['cross_street_2'].titleize,
      :permit_start_date => date_cleanup(record['permit_start_date']),
      :permit_end_date => date_cleanup(record['permit_end_date'])
    }

    # Return the feature as a hash, which we will convert to json.
    {
      'id' => record['permit_number'],
      'type' => 'Feature',
      'properties' => record.merge('title' => TITLE_TEMPLATE % title_pieces),
      'geometry' => {
        'type' => 'Point',
        'coordinates' => [0.0, 0.0]
      }
    }
  end

  content_type :json
  JSON.pretty_generate('type' => 'FeatureCollection', 'features' => features)
end
