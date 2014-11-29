module CustomJsonMatchers

  class BeValidJson
    def initialize(expected)
      @expected = expected
    end

    def matches?(target)
      @target = target

      res = true

      begin
        JSON.parse(target)
      rescue JSON::ParserError => e
        res = false
      end

      res
    end

    def failure_message
      "expected #{@target.inspect} to be valid JSON"
    end

    def failure_message_when_negated
      "expected #{@target.inspect} not to be valid json"
    end
  end

  def be_valid_json
    BeValidJson.new(@expected)
  end

  class BeValidGeojson < BeValidJson
    VALID_TYPES = %w[Point MultiPoint LineString MultiLineString Polygon MultiPolygon GeometryCollection Feature FeatureCollection]

    # TODO: I don't have time at the moment to put together a whole geojson
    #       validator, so this is just doing a top-level check.
    #
    #       I looked for a gem that does this, but could only find the
    #       rgeo-geojson extension for rgeo, but that seemed kind of heavy
    #       for an rspec matcher.
    def matches?(target)
      super

      json = JSON.parse(target)

      # The GeoJSON object must have a member with the name "type". This member's value is a string that determines the type of the GeoJSON object.
      return false unless json.has_key? 'type'

      # The value of the type member must be one of: "Point", "MultiPoint", "LineString", "MultiLineString", "Polygon", "MultiPolygon", "GeometryCollection", "Feature", or "FeatureCollection". The case of the type member values must be as shown here.
      return false unless VALID_TYPES.include?(json['type'])

      true
    end

    def failure_message
      "expected #{@target.inspect} to be valid GeoJSON"
    end

    def failure_message_when_negated
      "expected #{@target.inspect} not to be valid GeoJSON"
    end
  end

  def be_valid_geojson
    BeValidGeojson.new(@expected)
  end

end
