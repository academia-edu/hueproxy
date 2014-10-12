require 'pry'
require 'faraday'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require 'uri'

ACCESSTOKEN = ENV['HUE_ACCESSTOKEN']
BRIDGEID = ENV['HUE_BRIDGEID']

if ACCESSTOKEN.to_s == "" || BRIDGEID.to_s == ""
  puts "you need to set HUE_ACCESSTOKEN and HUE_BRIDGEID"
  exit 1
end

conn = Faraday.new(url: 'https://www.meethue.com')

get '/' do
  "hue api proxy"
end

get '/api' do
  response = conn.get '/api/getbridge', { token: ACCESSTOKEN, bridgeid: BRIDGEID }
  content_type :json
  response.body
end

def put_or_post path, opts={}, &block
  put path, opts, &block
  post path, opts, &block
end

put_or_post '/api/*' do
  api_path = params[:splat].first.gsub(/^0\//, '')
  cmd={
    bridgeid: BRIDGEID,
    clipCommand: {
      url: "/api/0/#{api_path}",
      method: request.request_method,
      body: JSON.parse(request.body.read)
    }
  }
  request_body = URI::encode_www_form({clipmessage: JSON.dump(cmd)})

  response = conn.post '/api/sendmessage' do |req|
    req.params = { token: ACCESSTOKEN }
    req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
    req.body = request_body
  end
  response.body
end
