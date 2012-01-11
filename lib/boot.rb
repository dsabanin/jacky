require 'singleton'

module Jacky
  class Boot
    include Singleton

    def initialize
      load_requirements
      connect_api
    end

    def load_requirements
      require 'beanstalkapp'
      require "vendor/configuration-file-plugin/lib/configuration"
    end

    def config
      @_config ||= ConfigurationFile.new("~/.beanstalkrc")
    end

    def connect_api
      Beanstalk::API::Base.setup(
        :domain   => config.domain,
        :login    => config.login,
        :password => config.password)
    end

    def load_scope(scope_sym)
      scope_sym = :generic unless scope_sym
      require "lib/#{scope_sym}_scope"
      Jacky.const_get("#{scope_sym.to_s.capitalize}Scope").new(scope_sym.to_sym, ARGV[1..-1])      
    rescue MissingSourceFile
      scope_sym = :generic
      retry
    end
  end
end
