require 'puppet'
require 'uri'
require 'net/http'
require 'pp'

module Grafana
  # Class documentation goes here.
  class Api < Puppet::Provider
    def self.parse_config
      path = File.expand_path(File.join(Puppet.settings[:confdir], '/grafana_rest.conf'))
      raise Puppet::Error, "Grafana REST configuration file #{path} missing" unless File.exist?(path)
      begin
        YAML.load_file(path).each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
      rescue
        raise Puppet::Error, "Could not parse Grafana REST configuration file '#{path}': #{e}"
      end
    end

    def self.camelize(term, uppercase = false)
      if uppercase
        term.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
      else
        term[0] + camelize(term, uppercase = true)[1..-1]
      end
    end

    def self.sym_to_bool(value)
      case value
      when true, 'true', :true then true
      when false, 'false', :false then false
      else
        value
      end
    end

    def self.bool_to_sym(value)
      case value
      when true, :true then :true
      when false, :false then :false
      else
        value
      end
    end

    def self.request(method, path, payload = nil)
      verb_map = {
        :get    => Net::HTTP::Get,
        :post   => Net::HTTP::Post,
        :put    => Net::HTTP::Put,
        :delete => Net::HTTP::Delete
      }

      config = parse_config

      begin
        uri = URI.parse("#{config[:grafana_base_url]}/#{path}")
        response = Net::HTTP.start(uri.host, uri.port) do |http|
          request = verb_map[method.to_sym].new(uri.request_uri)
          request.add_field('Content-Type', 'application/json')
          request.basic_auth config[:api_user], config[:api_password]
          if payload
            payload.each {|k, v| payload[k] = sym_to_bool(v); payload }
            request.body = payload.to_json
          end
          http.request(request)
        end

        unless response.code =~ /^2/
          raise Puppet::Error, "[ERROR]: #{method} Request to #{uri} failed: #{response.code} #{response.message}"
        end

        response
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
             Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
        raise Puppet::Error, "[ERROR] Error while creating Grafana notification: #{e}"
      end
    end
  end
end
