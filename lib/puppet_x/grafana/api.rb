require 'puppet'
require 'uri'
require 'net/http'

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

    def self.to_bool(value)
      case value
      when 'true', :true then true
      when 'false', :false then false
      else
        value
      end
    end

    def self.bool_to_sym(value)
      case value
      when true then :true
      when false then :false
      else
        value
      end
    end

    def self.underscore(term)
      term.gsub(/::/, '/').sub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
    end

    def self.get_properties(api_root, id)
      properties = {}
      response = request(:get, "#{api_root}/#{id}")
      data     = JSON.parse(response.body)
      data.each do |k, v|
        properties[underscore(k).to_sym] = bool_to_sym(v)
      end
      properties[:ensure] = :present
      properties
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
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
          request = verb_map[method.to_sym].new(uri.request_uri)
          request.add_field('Content-Type', 'application/json')
          request.basic_auth config[:api_user], config[:api_password]
          if payload
            redacted_payload = Hash[payload.map { |k, v| [k, k =~ /pass/i ? '<REDACTED>' : v] }]
            request.body     = payload.to_json
          end
          Puppet.debug "Sending #{request.method} request to #{uri}"
          Puppet.debug "=> Payload: #{redacted_payload.to_json}" if redacted_payload
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

    def request(*args)
      self.class.request(*args)
    end

    def create_payload(hash)
      payload = Hash[hash.map { |k, v| [camelize(k).to_sym, self.class.to_bool(v)] }]
      [:ensure, :provider, :secureJsonFields].each { |k| payload.delete(k) }
      payload
    end

    def camelize(term, uppercase = false)
      if uppercase
        term.to_s
            .gsub(%r{/(.?)}) { '::' + Regexp.last_match[1].upcase }
            .gsub(/(^|_)(.)/) { Regexp.last_match[2].upcase }
      else
        term[0] + camelize(term, true)[1..-1]
      end
    end
  end
end
