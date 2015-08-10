class EvictionNotice < SocrataBase
  SOCRATA_ENDPOINT = 'http://data.sfgov.org/resource/tmnf-yvry.json'

TITLE_TEMPLATE = <<-CFA.gsub(/\s*\n/,' ').chomp(' ')
An eviction notice was filed near you on %{date} for %{address}. The notice
listed %{reason} as the grounds for eviction.
CFA

  REASON_MAPPINGS = {
    "non_payment" => "non-payment of rent",
    "breach" => "breach of lease",
    "nuisance" => "nuisance",
    "illegal_use" => "an illegal use of the rental unit",
    "failure_to_sign_renewal" => "failure to sign a lease renewal",
    "access_denial" => "unlawful denial of access to unit",
    "unapproved_subtenant" => "the tenant had an unapproved subtenant",
    "owner_move_in" => "the owner is moving in",
    "demolition" => "demolistion of the property",
    "capital_improvement" => "a capital improvement",
    "substantial_rehab" => "substantial rehabilitaion",
    "ellis_act_withdrawal" => "an Ellis Act withdrawal (going out of business)",
    "condo_conversion" => "a condo conversion",
    "roomate_same_unit" => "evicting a roomate",
    "other_cause" => "a non-standard reason"
  }

  def self.query_url
    url = URI(SOCRATA_ENDPOINT)

    url.query = Faraday::Utils.build_query(
      '$order' => 'file_date DESC',
      '$limit' => 100,
      '$where' => "file_date > '#{(DateTime.now - 19).iso8601}'"
    )
    url.to_s
  end

  def fancy_title
    # Apply any transformations needed to the text being sent to our
    # title "mad lib" above.
    title_pieces = {
      :date => date_cleanup(@record['file_date']),
      :address => Utils.titleize(@record['address']).gsub(/\s+/, ' '),
      :reason => translate_reason
    }

    TITLE_TEMPLATE % title_pieces
  end

  def as_geojson_feature
    # We're trying to return geojson records, so return nil if
    # we don't have a location.
    return nil if location.nil?

    # Return the feature as a hash, which we will convert to json.
    {
      'id' => @record['eviction_id'],
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

  def location
    @record['client_location']
  end

  private

  def translate_reason
    REASON_MAPPINGS.each do |k, v|
      if @record[k] == true
        return v
      end
    end

    "no reason"
  end
end
