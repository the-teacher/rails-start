#!/usr/bin/env ruby
require 'net/http'
require 'uri'
require 'json'

uri = URI('https://api.pricepertoken.com/mcp/mcp')

payload = {
  jsonrpc: '2.0', id: 1, method: 'initialize',
  params: {
    protocolVersion: '2024-11-05',
    capabilities:    {},
    clientInfo:      { name: 'ruby-explorer', version: '1.0' }
  }
}

Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: 15) do |http|
  req = Net::HTTP::Post.new(uri.request_uri)
  req['Content-Type'] = 'application/json'
  req['Accept']       = 'text/event-stream, application/json'
  req.body = payload.to_json

  http.request(req) do |res|
    puts "STATUS : #{res.code} #{res.message}"
    puts "HEADERS:"
    res.each_header { |k, v| puts "  #{k}: #{v}" }
    puts "\nBODY (raw):"
    res.read_body do |chunk|
      puts chunk.inspect
    end
  end
end
