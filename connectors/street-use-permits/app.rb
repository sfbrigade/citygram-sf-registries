require 'faraday'
require 'sinatra'
require 'json'

get '/tow-away-zones' do
  url = URI('http://data.sfgov.org/resource/cqn5-muyy.json')
  url.query = Faraday::Utils.build_query(
	  '$order' => 'updatedat DESC',
	  '$limit' => 100,
	  '$where' => "mta_status_code = 'Approved'"+
	  " AND dbi_application_number IS NOT NULL"+
	  " AND frontage IS NOT NULL"+
	  " AND fromaddress IS NOT NULL"+
	  " AND toaddress IS NOT NULL"+
	  " AND streetname IS NOT NULL"+
	  " AND updatedat > '#{(DateTime.now - 7).iso8601}'"
  )
  connection = Faraday.new(url: url.to_s)
  response = connection.get
  collection = JSON.parse(response.body)
  features = collection.map do |record|
	  {
		  'id' => record['dbi_application_number'],
		  'type' => 'Feature',
			  'properties' => record.merge(
				  'title' => record['frontage'],
				  ),
			  'geometry' => {
			  'type' => 'Point',
			  'coordinates' => [
				  record['longitude'].to_f,
				  record['latitude'].to_f
		  ]
		  }
	  }
  end

  content_type :json
  JSON.pretty_generate('type' => 'FeatureCollection', 'features' => features)
end
