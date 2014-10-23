require 'faraday'
require 'sinatra'
require 'json'

get '/tree-planting' do
  url = URI('http://data.sfgov.org/resource/tkzw-k3nq.json')
  url.query = Faraday::Utils.build_query(
    '$order' => 'plantdate DESC',
    '$limit' => 100,
    '$where' => "treeid IS NOT NULL"+
    " AND permitnotes IS NOT NULL"+
    " AND latitude IS NOT NULL"+
    " AND longitude IS NOT NULL"+
    " AND plantdate > '#{(DateTime.now - 365).iso8601}'"
  )
  connection = Faraday.new(url: url.to_s)
  response = connection.get
  collection = JSON.parse(response.body)
  features = collection.map do |record|
    {
      'id' => record['treeid'],
      'type' => 'Feature',
      'properties' => record.merge('title' => record['permitnotes']),
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
