require 'spec_helper'

response_fixture = <<-JMM
{
  "permit_address": "65 WAVERLY PL",
  "permit_type": "Excavation",
  "status": "APPROVED",
  "permit_start_date": "2014-11-07T00:00:00",
  "permit_purpose": "45 WAVERLY PL",
  "contact": "650-670-6021",
  "agent": "CableCom",
  "cross_street_2": "CLAY ST",
  "cnn": "13464000",
  "cross_street_1": "SACRAMENTO ST",
  "permit_number": "14EXC-6225",
  "permit_zipcode": "94108",
  "agentphone": "650-544-4467",
  "approved_date": "2014-11-07T08:06:40",
  "permit_end_date": "2014-12-20T00:00:00",
  "streetname": "WAVERLY PL"
}
JMM

describe StreetUsePermit do
  let(:api_response) { JSON.parse(response_fixture) }

  describe "#as_geojson_feature" do
    context "there is no location information" do
      it "returns nil" do
        street_use_permit = StreetUsePermit.new(api_response, {})
        allow(street_use_permit).to receive(:location) { nil }
        expect(street_use_permit.as_geojson_feature).to be_nil
      end
    end

    context "location information exists" do
      it "returns the proper geojson feature" do
        street_use_permit = StreetUsePermit.new(api_response, {})
        allow(street_use_permit).to receive(:location) do
          { 'lng' => '-122.406867', 'lat' => '37.794118' }
        end

        exp_geojson = {
          'id' => '14EXC-6225',
          'type' => 'Feature',
          'properties' => api_response.merge('title' => street_use_permit.fancy_title),
          'geometry' => {
            'type' => 'Point',
            'coordinates' => [-122.406867, 37.794118]
          }
        }
        expect(street_use_permit.as_geojson_feature).to eq(exp_geojson)
      end
    end
  end

  describe "#fancy_title" do
    it "returns the nicely formatted title message" do
      street_use_permit = StreetUsePermit.new(api_response, {})
      exp_title = "A permit has been issued for Excavation, at Waverly Pl between Sacramento St and Clay St, from Nov 7, 2014 to Dec 20, 2014."
      expect(street_use_permit.fancy_title).to eq(exp_title)
    end
  end

  describe "#address_to_geocode" do
    context "permit address is available" do
      it "geocodes using the permit address" do
        street_use_permit = StreetUsePermit.new(api_response, {})
        exp_address = "65 WAVERLY PL, San Francisco, CA"
        expect(street_use_permit.address_to_geocode).to eq(exp_address)
      end
    end

    context "permit address is not available" do
      it "geocodes using the streetname and cross_street_1" do
        api_response_2 = api_response
        api_response_2.delete('permit_address')
        street_use_permit = StreetUsePermit.new(api_response_2, {})
        exp_address = "WAVERLY PL and SACRAMENTO ST, San Francisco, CA"
        expect(street_use_permit.address_to_geocode).to eq(exp_address)
      end
    end
  end

  describe "#date_cleanup" do
    it "formats date string from the source API" do
      street_use_permit = StreetUsePermit.new({},{})
      date_string = "2006-10-16T00:00:00"
      expect(street_use_permit.date_cleanup(date_string)).to eq("Oct 16, 2006")
    end
  end
end
