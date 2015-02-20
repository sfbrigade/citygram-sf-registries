require 'spec_helper'

response_fixture = <<-JMM
{
  "time" : "23:50",
  "category" : "ASSAULT",
  "pddistrict" : "MISSION",
  "pdid" : "15011294504134",
  "location" : {
    "needs_recoding" : false,
    "longitude" : "-122.419671780296",
    "latitude" : "37.7650501214668",
    "human_address" : {\"address\":\"\",\"city\":\"\",\"state\":\"\",\"zip\":\"\"}
  },
  "address" : "16TH ST / MISSION ST",
  "descript" : "BATTERY",
  "dayofweek" : "Thursday",
  "resolution" : "NONE",
  "date" : "2015-02-05T00:00:00",
  "y" : "37.7650501214668",
  "x" : "-122.419671780296",
  "incidntnum" : "150112945"
}
JMM

describe CrimeIncident do
  let(:api_response) { JSON.parse(response_fixture) }

  describe "#fancy_title" do
    it "returns the nicely formatted title message" do
      crime_incident = CrimeIncident.new(api_response)
      exp_title = "A crime incident happened near you on Feb 5, 2015 at 16th St / Mission St. The SFPD described it as a Battery with the following resolution: none."
      expect(crime_incident.fancy_title).to eq(exp_title)
    end
  end

  describe "#as_geojson_feature" do
    context "there is no location information" do
      it "returns nil" do
        crime_incident = CrimeIncident.new(api_response)
        allow(crime_incident).to receive(:location) { nil }
        expect(crime_incident.as_geojson_feature).to be_nil
      end
    end

    context "location information exists" do
      it "returns the proper geojson feature" do
        crime_incident = CrimeIncident.new(api_response)
        allow(crime_incident).to receive(:location) do
          { "longitude" => "-122.419671780296", "latitude" => "37.7650501214668" }
        end

        exp_geojson = {
          'id' => '150112945',
          'type' => 'Feature',
          'properties' => api_response.merge('title' => crime_incident.fancy_title),
          'geometry' => {
            'type' => 'Point',
            'coordinates' => [-122.419671780296, 37.7650501214668]
          }
        }
        expect(crime_incident.as_geojson_feature).to eq(exp_geojson)
      end
    end
  end
end
