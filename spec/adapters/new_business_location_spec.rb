require 'spec_helper'

response_fixture = <<-JMM
{
  "mailing_city_state_zip_code": "SAN FRANCISCO CA 94109-",
  "location": {
    "needs_recoding": false,
    "longitude": "-122.41951604499997",
    "latitude": "37.79330702100003"
  },
  "certificate_number": "1006623",
  "mailing_address_1": "1664 LARKIN ST",
  "full_business_address": "1664 LARKIN ST",
  "state": "CA",
  "class_code": "n.a.",
  "dba_name": "CHRIS LENNON HANDYMAN",
  "dba_start_date": "2014-12-08T00:00:00",
  "city": "SAN FRANCISCO",
  "ttxid": "1013614-12-141",
  "business_zip": "94109",
  "pbc_code": "n.a.",
  "ownership_name": "LENNON CHRIS",
  "location_start_date": "2014-12-08T00:00:00"
}
JMM

describe NewBusinessLocation do
  let(:api_response) { JSON.parse(response_fixture) }

  describe "#fancy_title" do
    it "returns the nicely formatted title message" do
      new_business_location = NewBusinessLocation.new(api_response)
      exp_title = "A new business called Chris Lennon Handyman is opening soon at 1664 Larkin St."
      expect(new_business_location.fancy_title).to eq(exp_title)
    end
  end

  describe "#formatted_street_address" do
    context "the address is in SF" do
      it "returns the street address" do
        new_business_location = NewBusinessLocation.new(api_response)
        expect(new_business_location.formatted_street_address).to eq("1664 LARKIN ST")
      end
    end

    context "the address is outside SF" do
      it "returns the street address along with the city & state" do
        api_response2 = api_response
        api_response2["city"] = "SAN PABLO"
        new_business_location = NewBusinessLocation.new(api_response2)
        expect(new_business_location.formatted_street_address).to eq("1664 LARKIN ST, SAN PABLO, CA")
      end
    end
  end

  describe "#as_geojson_feature" do
    context "there is no location information" do
      it "returns nil" do
        new_business_location = NewBusinessLocation.new(api_response)
        allow(new_business_location).to receive(:location) { nil }
        expect(new_business_location.as_geojson_feature).to be_nil
      end
    end

    context "location information exists" do
      it "returns the proper geojson feature" do
        new_business_location = NewBusinessLocation.new(api_response)
        allow(new_business_location).to receive(:location) do
          { "longitude" => "-122.41951604499997", "latitude" => "37.79330702100003" }
        end

        exp_geojson = {
          'id' => '1013614-12-141',
          'type' => 'Feature',
          'properties' => api_response.merge('title' => new_business_location.fancy_title),
          'geometry' => {
            'type' => 'Point',
            'coordinates' => [-122.41951604499997, 37.79330702100003]
          }
        }
        expect(new_business_location.as_geojson_feature).to eq(exp_geojson)
      end
    end
  end
end
