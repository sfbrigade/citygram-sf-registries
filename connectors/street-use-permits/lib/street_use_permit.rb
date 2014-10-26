class StreetUsePermit

TITLE_TEMPLATE = <<-CFA.gsub(/\s*\n/,' ').chomp(' ')
A new permit has been issued for %{permit_type}, at %{streetname}
between %{cross_street_1} and %{cross_street_2}, from %{permit_start_date}
to %{permit_end_date}.
CFA

  def initialize(record, cache)
    @record = record
    @cache = cache
  end

  def date_cleanup(date_str)
    date_str.gsub!(/T[\d\:]+$/,'')
    Time.parse(date_str).strftime("%b %e, %Y")
  end

  def fancy_title
    # Apply any transformations needed to the text being sent to our
    # title "mad lib" above.
    title_pieces = {
      :permit_type => @record['permit_type'],
      :streetname => @record['streetname'].titleize,
      :cross_street_1 => @record['cross_street_1'].titleize,
      :cross_street_2 => @record['cross_street_2'].titleize,
      :permit_start_date => date_cleanup(@record['permit_start_date']),
      :permit_end_date => date_cleanup(@record['permit_end_date'])
    }

    TITLE_TEMPLATE % title_pieces
  end

  def address_to_geocode
    @address_to_geocode ||= [
      @record.has_key?('permit_address') ? @record['permit_address'] : [@record['streetname'], @record['cross_street_1']].join(' and '),
      ", San Franciso, CA"
    ].join
  end

  def location
    @cache.fetch(address_to_geocode) do
      result = Geocoder.search(address_to_geocode).first
      unless result.nil?
        result.data["geometry"]["location"]
      end
    end
  end

  def as_geojson_feature
    # Return the feature as a hash, which we will convert to json.
    {
      'id' => @record['permit_number'],
      'type' => 'Feature',
      'properties' => @record.merge('title' => fancy_title),
      'geometry' => {
        'type' => 'Point',
        'coordinates' => [
          location['lng'].to_f,
          location['lat'].to_f
        ]
      }
    }
  end
end


