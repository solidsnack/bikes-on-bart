#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'

not_found do
  headers["Status"] = "301 Moved Permanently"
  redirect("/")
end

get '/' do
  content_type 'text/html', :charset => 'utf-8'
  erb :index
end

get '/api' do
  content_type 'text/html', :charset => 'utf-8'
  erb :api
end

