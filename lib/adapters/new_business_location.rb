class NewBusinessLocation
  SOCRATA_ENDPOINT = 'http://data.sfgov.org/resource/g8m3-pdis.json'

  # Text from https://github.com/citygram/citygram-services/issues/25
  TITLE_TEMPLATE = <<-CFA.gsub(/\s*\n/,' ').chomp(' ')
A new business called %{dba_name} is opening soon at %{street_address}.
CFA

  def self.query_url
    url = URI(SOCRATA_ENDPOINT)

    url.query = Faraday::Utils.build_query(
      '$order' => 'location_start_date DESC',
      '$limit' => 100,
      '$where' => "location_start_date > '#{(DateTime.now - 7).iso8601}'"
    )
    url.to_s
  end

  def initialize(record)
    @record = record
  end

  def fancy_title
    title_pieces = {
      :dba_name => Utils.titleize(@record['dba_name']),
      :street_address => Utils.titleize(formatted_street_address)
    }

    TITLE_TEMPLATE % title_pieces
  end

  def formatted_street_address
    if @record['city'].downcase == "san francisco"
      @record['full_business_address']
    else
      "#{@record['full_business_address']}, #{@record['city']}, #{@record['state']}"
    end
  end

  def location
    @record['location']
  end

  def as_geojson_feature
    # We're trying to return geojson records, so return nil if
    # we don't have a location.
    return nil if location.nil?

    # Return the feature as a hash, which we will convert to json.
    {
      'id' => @record['ttxid'],
      'type' => 'Feature',
      'properties' => @record.merge('title' => fancy_title),
      'geometry' => {
        'type' => 'Point',
        'coordinates' => [
          location['longitude'].to_f,
          location['latitude'].to_f
        ]
      }
    }
  end

end
