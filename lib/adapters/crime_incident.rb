class CrimeIncident
  SOCRATA_ENDPOINT = 'http://data.sfgov.org/resource/tmnf-yvry.json'

# Text from https://github.com/citygram/citygram-services/issues/23
TITLE_TEMPLATE = <<-CFA.gsub(/\s*\n/,' ').chomp(' ')
A crime incident happened near you on %{date} at %{address}. The SFPD
described it as a %{descript} with the following resolution: %{resolution}.
CFA

  def self.query_url
    url = URI(SOCRATA_ENDPOINT)

    url.query = Faraday::Utils.build_query(
      '$order' => 'date DESC',
      '$limit' => 100,
      '$where' => "date > '#{(DateTime.now - 19).iso8601}'"
    )
    url.to_s
  end

  def initialize(record, cache=nil)
    @record = record
    @cache = cache
  end

  # Helper method to make the dates look nice in the "fancy title".
  def date_cleanup(date_str)
    date_str.gsub!(/T[\d\:]+$/,'')
    Time.parse(date_str).strftime("%b %-e, %Y")
  end

  def fancy_title
    # Apply any transformations needed to the text being sent to our
    # title "mad lib" above.
    title_pieces = {
      :date => date_cleanup(@record['date']),
      :address => Utils.titleize(@record['address']),
      :descript => Utils.titleize(@record['descript']),
      :resolution => @record['resolution'].downcase
    }

    TITLE_TEMPLATE % title_pieces
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
      'id' => @record['incidntnum'],
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
