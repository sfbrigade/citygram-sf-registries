require 'faraday'
require 'sinatra'

get '/san-francisco-street-tree-plantings' do
    url = URI('https://data.sfgov.org/api/views/tkzw-k3nq/rows.json')
