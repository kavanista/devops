
require 'sinatra/base'

require "api/json_request"
require "api/json_response"

class Server < Sinatra::Base

    SUPPORTED_OPERATIONS = [ "exec" ]

    DEFAULT_PORT = 18000

    class << self
        attr_accessor :agent
    end

    def agent
        self.class.agent
    end

    get '/*' do
        return JsonResponse.invalid_request.to_json
    end

    post '/*' do
        req = extract_valid_request()
        if req.kind_of? String then
            return req
        end
        return handle_exec(req)
    end

    def extract_valid_request
        body = request.body.read.strip
        if body.nil? or body.empty? then
            return JsonResponse.invalid_request.to_json
        end

        begin
            req = JsonRequest.from_json(body)
        rescue Exception => ex
            return JsonResponse.invalid_request.to_json
        end

        if not SUPPORTED_OPERATIONS.include? req.operation then
            return JsonResponse.invalid_request("unsupported operation: #{req.operation}").to_json
        end

        return req
    end

    def handle_exec(req)
        begin
            status, stdout, stderr = agent.exec(req.params)
        rescue Exception => ex
            if ex.kind_of? BundleNotFound then
                return JsonResponse.bundle_not_found(ex.message).to_json
            elsif ex.kind_of? CommandNotFound then
                return JsonResponse.command_not_found(ex.message).to_json
            end
            raise ex
        end
        data = { :result => status, :stdout => stdout, :stderr => stderr }
        return JsonResponse.new("success", nil, data).to_json
    end

end
