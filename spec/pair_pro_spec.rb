require_relative "../lib/pairpro/pair_pro"
require "spec_helper"
require "firebase"

RSpec.describe 'PairPro' do
  base_uri = 'https://pair-pro.firebaseio.com/test/'
  @firebase = Firebase::Client.new(base_uri)
  @app = PairPro::PairProgram.new "https://pair-pro.firebaseio.com/test"


  it 'signup should save to firebase' do
    @app = PairPro::PairProgram.new "https://pair-pro.firebaseio.com/test"
    @firebase = Firebase::Client.new(base_uri)

    @app.signup("tester", "tester@test.com", "pass")
    response = @firebase.get("/users/tester")
    res = response.body

    res.should_not == nil
  end
end
