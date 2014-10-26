require File.join(File.dirname(__FILE__), 'hash_cache')
require File.join(File.dirname(__FILE__), 'core_ext', 'string')
require File.join(File.dirname(__FILE__), 'street_use_permit')
require 'faraday'
require 'sinatra'
require 'geocoder'
require 'json'

$cache = HashCache.new

get '/street-use-permits' do
  url = URI(StreetUsePermit::SOCRATA_ENDPOINT)

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

  connection = Faraday.new(:url => url.to_s)

  # Query the data.sfgov.org endpoint
  response = connection.get

  collection = JSON.parse(response.body)

  features = collection.map do |record|
    StreetUsePermit.new(record, $cache).as_geojson_feature
  end

  content_type :json
  JSON.pretty_generate('type' => 'FeatureCollection', 'features' => features)
end
