#!/usr/bin/env ruby
# MCP over plain JSON (server ignores SSE preference, returns application/json)
#
# Usage: ruby lib/scrapers/pricepertoken_mcp_explore.rb

require 'net/http'
require 'uri'
require 'json'

MCP_URL = 'https://api.pricepertoken.com/mcp/mcp'

def mcp_call(uri, payload, session_id: nil)
  Net::HTTP.start(uri.host, uri.port, use_ssl: true,
                  open_timeout: 10, read_timeout: 30) do |http|
    req = Net::HTTP::Post.new(uri.request_uri)
    req['Content-Type']   = 'application/json'
    req['Accept']         = 'application/json'
    req['Mcp-Session-Id'] = session_id if session_id
    req.body = payload.to_json

    res = http.request(req)
    raise "HTTP #{res.code}: #{res.body}" unless %w[200 202].include?(res.code)

    body = res.body
    parsed = JSON.parse(body)
    { session: res['mcp-session-id'], result: parsed }
  end
end

uri        = URI(MCP_URL)
session_id = nil

# --- initialize ---
puts "Initializing..."
r = mcp_call(uri, {
  jsonrpc: '2.0', id: 1, method: 'initialize',
  params: {
    protocolVersion: '2024-11-05',
    capabilities:    {},
    clientInfo:      { name: 'ruby-explorer', version: '1.0' }
  }
})
session_id = r[:session]
info = r[:result]
puts "Server : #{info.dig('result', 'serverInfo', 'name')} #{info.dig('result', 'serverInfo', 'version')}"
puts "Proto  : #{info.dig('result', 'protocolVersion')}"
puts "Session: #{session_id}" if session_id

# --- notifications/initialized ---
mcp_call(uri, { jsonrpc: '2.0', method: 'notifications/initialized', params: {} },
         session_id: session_id) rescue nil

# --- tools/list ---
puts "\n--- Tools ---"
r = mcp_call(uri, { jsonrpc: '2.0', id: 2, method: 'tools/list', params: {} },
             session_id: session_id)
tools = r[:result].dig('result', 'tools') || []
tools.each { |t| puts "  • #{t['name']}: #{t['description']}" }

# --- resources/list ---
puts "\n--- Resources ---"
r = mcp_call(uri, { jsonrpc: '2.0', id: 3, method: 'resources/list', params: {} },
             session_id: session_id)
resources = r[:result].dig('result', 'resources') || []
if resources.empty?
  puts "  (none)"
else
  resources.each { |r| puts "  • #{r['uri']} — #{r['name']}" }
end

# --- get_all_models ---
puts "\n--- All Models ---"
r = mcp_call(uri, {
  jsonrpc: '2.0', id: 5, method: 'tools/call',
  params: { name: 'get_all_models', arguments: { limit: 500 } }
}, session_id: session_id)

text   = r[:result].dig('result', 'content', 0, 'text')
models = JSON.parse(text)

fmt_price = ->(v) { v ? "$#{'%.4f' % v}" : '    —   ' }
fmt_bool  = ->(v) { v.nil? ? '?' : (v ? 'yes' : 'no') }

puts "%-55s %-20s %10s %10s %8s %8s %8s" % %w[slug author input/1M output/1M vision reason tools]
puts '-' * 125
models.each do |m|
  puts "%-55s %-20s %10s %10s %8s %8s %8s" % [
    m['slug'][0, 54],
    m['author_name'][0, 19],
    fmt_price.(m['input_per_1m']),
    fmt_price.(m['output_per_1m']),
    fmt_bool.(m['supports_vision']),
    fmt_bool.(m['supports_reasoning']),
    fmt_bool.(m['supports_tool_calls'])
  ]
end
puts "\nTotal: #{models.size} models"
