require './lib/racker'
require 'rack/test'

describe Racker do
  include Rack::Test::Methods

  let(:response) { Racker.call(env) }
  context 'GET to /' do
    let(:env) { { 'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/', 'rack.session' => { 'session_id' => '_' } } }

    it 'The HTTP response code is 200' do
      expect(response[0]).to eq 200
    end

    it { expect(response[2].body.to_s).to include('Enter your name') }
  end

  # context 'POST to /set_name' do
  #   let(:response) { post '/' }
  #   let(:env) { { 'REQUEST_METHOD' => 'POST', 'PATH_INFO' => '/set_name', 'rack.session' => { 'session_id' => '_' } } }

  #   it { expect(response.status).to eq 302 }
  #   # it { expect(response.body).to eq 'Method not allowed: POST' }
  # end

end
