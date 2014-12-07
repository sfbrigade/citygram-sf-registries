require 'spec_helper'

response_fixture = <<-JMM
{
  "location" : {
    "needs_recoding" : false,
    "longitude" : "-122.403952784111",
    "latitude" : "37.7662174644741"
  },
  "status" : "APPROVED",
  "expirationdate" : "2015-03-15T00:00:00",
  "permit" : "14MFF-0002",
  "block" : "3935",
  "received" : "Jan 24 2014  9:13AM",
  "facilitytype" : "Truck",
  "blocklot" : "3935005",
  "locationdescription" : "16TH ST: KANSAS ST to VERMONT ST (1700 - 1799)",
  "cnn" : "711000",
  "priorpermit" : "0",
  "approved" : "2014-12-02T12:04:27",
  "schedule" : "http://bsm.sfdpw.org/PermitsTracker/reports/report.aspx?title=schedule&report=rptSchedule&params=permit=14MFF-0002&ExportPDF=1&Filename=14MFF-0002_schedule.pdf",
  "address" : "1700 16TH ST",
  "applicant" : "Tres Agaves Mexican Kitchen & Tequila Lounge LLC. dba Tres Truck",
  "lot" : "005",
  "fooditems" : "Multiple Trucks - Everything",
  "longitude" : "-122.403952784121",
  "latitude" : "37.76621745068",
  "objectid" : "512358",
  "y" : "2107057.15",
  "x" : "6011356.434"
}
JMM

describe FoodTruckPermit do
  let(:api_response) { JSON.parse(response_fixture) }

  describe "#fancy_title" do
    it "returns the nicely formatted title message" do
      food_truck_permit = FoodTruckPermit.new(api_response)
      exp_title = "A new mobile food truck, operated by Tres Agaves Mexican Kitchen & Tequila Lounge LLC. dba Tres Truck, has been approved for a location near you! It will be at 16th St, Kansas St to Vermont St (1700 - 1799) and will serve Multiple Trucks - Everything. For a full schedule, see http://bsm.sfdpw.org/PermitsTracker/reports/report.aspx?title=schedule&report=rptSchedule&params=permit=14MFF-0002&ExportPDF=1&Filename=14MFF-0002_schedule.pdf."
      expect(food_truck_permit.fancy_title).to eq(exp_title)
    end
  end

  describe "#location_description" do
    it "cleans up the locationdescription attribute from the source API" do
      record = { 'locationdescription' => '16TH ST: KANSAS ST \\ IOWA ST to VERMONT ST (1700 - 1799)' }
      food_truck_permit = FoodTruckPermit.new(record)
      expect(food_truck_permit.location_description).to eq("16th St, Kansas St / Iowa St to Vermont St (1700 - 1799)")
    end
  end

  describe "#food_items" do
    it "replaces colons with commas in the list of food items" do
      source = { 'fooditems' => "Tacos: Burritos: Tortas: Quesadillas: Sodas: Chips: Candy" }
      food_truck_permit = FoodTruckPermit.new(source)
      expect(food_truck_permit.food_items).to eq("Tacos, Burritos, Tortas, Quesadillas, Sodas, Chips, Candy")
    end
  end

  describe "#as_geojson_feature" do
    context "there is no location information" do
      it "returns nil" do
        food_truck_permit = FoodTruckPermit.new(api_response)
        allow(food_truck_permit).to receive(:location) { nil }
        expect(food_truck_permit.as_geojson_feature).to be_nil
      end
    end

    context "location information exists" do
      it "returns the proper geojson feature" do
        food_truck_permit = FoodTruckPermit.new(api_response)
        allow(food_truck_permit).to receive(:location) do
          { "longitude" => "-122.403952", "latitude" => "37.766217" }
        end

        exp_geojson = {
          'id' => '14MFF-0002',
          'type' => 'Feature',
          'properties' => api_response.merge('title' => food_truck_permit.fancy_title),
          'geometry' => {
            'type' => 'Point',
            'coordinates' => [-122.403952, 37.766217]
          }
        }
        expect(food_truck_permit.as_geojson_feature).to eq(exp_geojson)
      end
    end
  end
end
