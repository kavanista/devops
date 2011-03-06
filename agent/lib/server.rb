
require 'sinatra/base'

require File.dirname(__FILE__) + "/rpc"

class Server < Sinatra::Base

    SUPPORTED_OPERATIONS = [ "exec" ]

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

        body = request.body.read.strip
        if body.blank? then
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

        return handle_exec(req)
    end

    def handle_exec(req)
        status, stdout, stderr = agent.exec(req.params)
        data = { :result => status, :stdout => stdout, :stderr => stderr }
        return JsonResponse.new("success", nil, data).to_json
    end

end
