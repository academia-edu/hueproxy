require 'pry'
require 'faraday'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require 'uri'
require './parser.rb'

ACCESSTOKEN = ENV['HUE_ACCESSTOKEN']
BRIDGEID = ENV['HUE_BRIDGEID']

if ACCESSTOKEN.to_s == "" || BRIDGEID.to_s == ""
  puts "you need to set HUE_ACCESSTOKEN and HUE_BRIDGEID"
  exit 1
end

$conn = Faraday.new(url: 'https://www.meethue.com')

get '/' do
  "hue api proxy"
end

get '/api' do
  response = $conn.get '/api/getbridge', { token: ACCESSTOKEN, bridgeid: BRIDGEID }
  content_type :json
  response.body
end

def put_or_post path, opts={}, &block
  put path, opts, &block
  post path, opts, &block
end

def send_command request_method, api_path, command
  request_data = {
    bridgeid: BRIDGEID,
    clipCommand: {
      url: "/api/0/#{api_path}",
      method: request_method,
      body: command
    }
  }
  request_body = URI::encode_www_form({clipmessage: JSON.dump(request_data)})

  response = $conn.post '/api/sendmessage' do |req|
    req.params = { token: ACCESSTOKEN }
    req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
    req.body = request_body
  end
  JSON.parse(response.body)
end

put_or_post '/api/*' do
  api_path = params[:splat].first.gsub(/^0\//, '')

  content_type :json
  JSON.dump(send_command request.request_method, api_path, JSON.parse(request.body.read))
end

put '/huep/api/lights/:n' do
  body = request.body.read
  if request.media_type == "application/x-www-form-urlencoded"
    body = URI.decode_www_form_component body
  end
  color = ColorTransformer.new.apply(ColorParser.new.parse(body))
  hsl = color.to_hsl

  cmd = { hue: (hsl.h * 65535.0).to_i, sat: (hsl.s * 255).to_i, bri: (hsl.l * 255).to_i }
  hue_response = send_command "PUT", "lights/#{params[:n]}/state", cmd
  content_type :json
  JSON.dump(hue_response)
end
