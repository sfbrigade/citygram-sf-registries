class FoodTruckPermit
  SOCRATA_ENDPOINT = 'http://data.sfgov.org/resource/rqzj-sfat.json'

  # Text from https://github.com/citygram/citygram-services/issues/8
  TITLE_TEMPLATE = <<-CFA.gsub(/\s*\n/,' ').chomp(' ')
A new mobile food %{facility_type}, operated by %{applicant}, has been
approved for a location near you! It will be at %{location_description}
and will serve %{food_items}. For a full schedule, see %{schedule}.
CFA

  def self.query_url
    url = URI(SOCRATA_ENDPOINT)

    url.query = Faraday::Utils.build_query(
      '$order' => 'approved DESC',
      '$limit' => 100,
      '$where' => "approved > '#{(DateTime.now - 70).iso8601}'"
    )
    url.to_s
  end

  def initialize(record)
    @record = record
  end

  def fancy_title
    title_pieces = {
      :facility_type => @record['facilitytype'].downcase,
      :applicant => @record['applicant'],
      :location_description => location_description,
      :food_items => food_items,
      :schedule => @record['schedule']
    }

    TITLE_TEMPLATE % title_pieces
  end

  def location_description
    str = @record['locationdescription'].dup
    str.gsub!(':', ',').gsub!('\\','/')
    str.gsub(/\b([A-Z]+)\b|\b\d+([A-Z]+)/) do |match|
      "#{match[0].upcase}#{match[1..-1].downcase}"
    end
  end

  def food_items
    str = @record['fooditems'].dup
    str.gsub(":",",")
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
      'id' => @record['permit'],
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
