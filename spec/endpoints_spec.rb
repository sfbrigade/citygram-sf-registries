require 'spec_helper'

describe "street-use-permits" do
  context "the geocoder is over it's api limit" do
    it "returns a 503 status" do
      VCR.use_cassette('geocoder_api_limit_error', :record => :new_episodes) do
        get '/street-use-permits'
        expect(last_response.status).to eq(503)
      end
    end
  end
end
