#!/usr/bin/env ruby
require 'net/http'
require 'uri'
require 'rubygems'

require 'json'
require 'sinatra'

$LOAD_PATH << File.expand_path(File.dirname(__FILE__)) + '/lib'
require 'bartron'


##  User-facing matter.

not_found do
  headers["Status"] = "301 Moved Permanently"
  redirect("/")
end

get '/' do
  content_type 'text/html', :charset => 'utf-8'
  erb :index
end


##  API -- raw text or XML, maybe docs.

BART_API_KEY = 'JMDV-QYQA-YHZT-MVWA'
HANDLE = BARTron::QBall.new(BART_API_KEY)

get '/api' do
  content_type 'text/html', :charset => 'utf-8'
  erb :api
end

get '/api/:from/:to' do
  # content_type 'application/json', :charset => 'utf-8'
  from, to = params[:from], params[:to]
  unless BARTron::STATIONS[from] and BARTron::STATIONS[to]
    content_type 'application/json', :charset => 'utf-8'
    halt 400, JSON.dump( 'error' => 'bad station' )
  end
  query = BARTron::Queries.recent_trips(from, to)
  s = HANDLE.query(query)
  content_type 'text/plain', :charset => 'utf-8'
  Net::HTTP.get(URI.parse(s))
end

