
require 'uuidtools'
require 'uri'

require File.dirname(__FILE__) + "/operation"
require File.dirname(__FILE__) + "/http_client"
require File.dirname(__FILE__) + "/handshake"
require File.dirname(__FILE__) + "/remote_exec"
require File.dirname(__FILE__) + "/config"

class Agent

    DEFAULT_ROOT_DIR = "/opt/devops"

    include HttpClient
    include Config
    include Handshake
    include RemoteExec

    class << self
        attr_accessor :agent_root
    end

    attr_accessor :agent_root
    attr_accessor :manager_uri, :uuid, :mac_address

    def self.create(uri = nil, root_dir = nil, use_config = true)

        agent = load_config(root_dir) if use_config

        if agent.nil? and (uri.nil? or URI.parse(uri).nil?) then
            raise "Missing manager URI"
        end

        return agent if not agent.nil?
        return new(uri, root_dir)
    end

    private_class_method :new

    def initialize(uri, root_dir = nil)
        @new = true

        @manager_uri = uri
        @agent_root = root_dir.nil? ? DEFAULT_ROOT_DIR : root_dir

        @uuid = create_uuid()
        @mac_address = get_mac_address()
        create_keypair()
    end

end

