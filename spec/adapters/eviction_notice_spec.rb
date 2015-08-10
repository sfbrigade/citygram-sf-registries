require 'spec_helper'

response_fixture = <<-JMM
{
  "other_cause": false,
  "failure_to_sign_renewal": false,
  "demolition": false,
  "ellis_act_withdrawal": false,
  "development": false,
  "state": "CA",
  "city": "San Francisco",
  "client_location": {
    "needs_recoding": false,
    "longitude": "-122.413273080076",
    "latitude": "37.7914675528019",
    "human_address": {\"address\":\"\",\"city\":\"\",\"state\":\"\",\"zip\":\"\"}
  },
  "breach": false,
  "owner_move_in": true,
  "access_denial": false,
  "non_payment": false,
  "lead_remediation": false,
  "roommate_same_unit": false,
  "zip": "94108",
  "capital_improvement": false,
  "condo_conversion": false,
  "neighborhood": "Nob Hill",
  "constraints": "0",
  "file_date": "2015-06-30T00:00:00",
  "nuisance": false,
  "eviction_id": "M151616",
  "supervisor_district": "3",
  "illegal_use": false,
  "constraints_date": "2018-06-27T00:00:00",
  "unapproved_subtenant": false,
  "late_payments": false,
  "address": "1100 Block of California  Street",
  "substantial_rehab": false
}
JMM

describe EvictionNotice do
  let(:api_response) { JSON.parse(response_fixture) }

  describe "#fancy_title" do
    it "returns the nicely formatted title message" do
      subject = EvictionNotice.new(api_response)
      exp_title = "An eviction notice was filed near you on Jun 30, 2015 for 1100 Block Of California Street. The notice listed the owner is moving in as the grounds for eviction."
      expect(subject.fancy_title).to eq(exp_title)
    end
  end

  describe "#as_geojson_feature" do
    context "there is no location information" do
      it "returns nil" do
        subject = EvictionNotice.new(api_response)
        allow(subject).to receive(:location) { nil }
        expect(subject.as_geojson_feature).to be_nil
      end
    end

    context "location information exists" do
      it "returns the proper geojson feature" do
        subject = EvictionNotice.new(api_response)
        allow(subject).to receive(:location) do
          { "longitude" => "-122.419671780296", "latitude" => "37.7650501214668" }
        end

        exp_geojson = {
          'id' => 'M151616',
          'type' => 'Feature',
          'properties' => api_response.merge('title' => subject.fancy_title),
          'geometry' => {
            'type' => 'Point',
            'coordinates' => [-122.419671780296, 37.7650501214668]
          }
        }
        expect(subject.as_geojson_feature).to eq(exp_geojson)
      end
    end
  end
end
