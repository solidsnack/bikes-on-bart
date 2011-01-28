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
  content_type 'application/json', :charset => 'utf-8'
  from, to = params[:from], params[:to]
  unless BARTron::STATIONS[from] and BARTron::STATIONS[to]
    halt 400, JSON.dump( 'error' => 'bad station' )
  end
  params = BARTron::Queries.recent_trips(from, to)
  xml = HANDLE.query(params)
  content_type 'text/plain', :charset => 'utf-8'
  res = xml.xpath('//trip').map do |trip|
          trip.xpath('.//leg').map do |leg|
            t0 = BARTron.timestamp_rewrite( leg['origTimeDate'],
                                            leg['origTimeMin'] )
            t1 = BARTron.timestamp_rewrite( leg['destTimeDate'],
                                            leg['destTimeMin'] )
            orig, dest = leg['origin'], leg['destination']
            head = leg['trainHeadStation']
            bikes = leg['bikeflag'] == '1' ? 'yes' : 'no'
            { 'origStationAbbrev' => orig,
              'origStation' => BARTron::STATIONS[orig],
              'destStationAbbrev' => dest,
              'destStation' => BARTron::STATIONS[dest],
              'origTime' => t0,
              'destTime' => t1,
              'finalStationAbbrev' => head,
              'finalStation' => BARTron::STATIONS[head],
              'bikes' => bikes }
          end
        end
  JSON.pretty_generate( 'result' => res )
end

