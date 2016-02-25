require_relative '../lib/pairpro/pair_pro'
require 'spec_helper'
require 'firebase'

RSpec.describe 'PairPro' do
  base_uri = 'https://pair-pro.firebaseio.com/test/'
  @firebase = Firebase::Client.new(base_uri)
  @app = PairPro::PairProgram.new 'https://pair-pro.firebaseio.com/test'

  it "valid? function in PairProgram should return false if empty" do
    @app = PairPro::PairProgram.new 'https://pair-pro.firebaseio.com/test'
    res = @app.valid? ""
    expect(res).to eq false
  end

  it "valid? function in PairProgram should return true if empty" do
    @app = PairPro::PairProgram.new 'https://pair-pro.firebaseio.com/test'
    res = @app.valid? "test"
    expect(res).to eq true
  end

  it 'signup should save to firebase' do
    base_uri = 'https://pair-pro.firebaseio.com/test/'
    @app = PairPro::PairProgram.new 'https://pair-pro.firebaseio.com/test/'
    @firebase = Firebase::Client.new(base_uri)

    @app.signup('tester', 'tester@test.com', 'pass')
    response = @firebase.get('users/tester').body

    expect(response).not_to eq nil
  end

  it 'test login feature from firebase' do
    @app = PairPro::PairProgram.new 'https://pair-pro.firebaseio.com/test/'

    response = @app.login('tester', 'pass')

    expect(response).to eq true
  end

  it 'test login feature from firebase wrong password' do
    @app = PairPro::PairProgram.new 'https://pair-pro.firebaseio.com/test/'

    response = @app.login('tester', 'wrong')

    expect(response).to eq false
  end

  it 'test new session feature from firebase' do
    @app = PairPro::PairProgram.new 'https://pair-pro.firebaseio.com/test/'

    response = @app.new_coding_session('test_session', 'tester')

    expect(response).to eq true
  end

  it 'test new session feature from firebase when conflict' do
    #sleep(20)
    @app_two = PairPro::PairProgram.new 'https://pair-pro.firebaseio.com/test/'


    response = @app_two.new_coding_session('test_session', 'tester')

    expect(response).not_to eq false
  end


  it 'test delete feature against firebase' do
    @app = PairPro::PairProgram.new 'https://pair-pro.firebaseio.com/test/'
    @firebase = Firebase::Client.new "https://pair-pro.firebaseio.com/test/"

    @app.delete_session('test_session', 'tester')

    res = @firebase.get("users/tester/sessions/test_session").body

    expect(res).to eq nil
  end

  it "cleanup" do
    @firebase = Firebase::Client.new "https://pair-pro.firebaseio.com/"
    @firebase.delete("test")

    expect(true).to eq true
  end











end
