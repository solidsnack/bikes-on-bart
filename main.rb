#!/usr/bin/env ruby
require 'rubygems'

require 'sinatra'
require 'json'

$LOAD_PATH << File.expand_path(File.dirname(__FILE__)) + '/lib'
require 'bartron'


##  User-facing matter.

not_found do
  headers["Status"] = "301 Moved Permanently"
  redirect("/")
end

get '/' do
  content_type 'text/html', :charset => 'utf-8'
  File.read('./public/index.html')
end

get '/images/bicycle-road.png' do
  content_type 'image/png'
  File.read('./public/images/bicycle-road.png')
end

##  API -- raw text or XML, maybe docs.

BART_API_KEY = 'JMDV-QYQA-YHZT-MVWA'
HANDLE = BARTron::Q.new(BARTron::QBall.new(BART_API_KEY))

get '/api' do
  content_type 'text/html', :charset => 'utf-8'
  erb :api
end

get '/api/:from/:to' do
  content_type 'application/json', :charset => 'utf-8'
  from, to = params[:from], params[:to]
  res = HANDLE.recent_trips(from, to) 
  unless not res['error']
    halt 400, JSON.pretty_generate(res)
  end
  JSON.pretty_generate(res)
end

