# frozen_string_literal: true

module Recorder
  # Adds few mandatory methods to any recorder object to be compatible with the application
  module AdapterInterface
    # The only method every adapter must to implement
    # @raise NotImplementedError
    def write(_data)
      raise NotImplementedError
    end

    # @param data [Hash]
    def fatal(data)
      write(data.merge(level: :fatal))
    end

    # @param data [Hash]
    def error(data)
      write(data.merge(level: :error))
    end

    # @param data [Hash]
    def warn(data)
      write(data.merge(level: :warn))
    end

    # @param data [Hash]
    def info(data)
      write(data.merge(level: :info))
    end

    # @param data [Hash]
    def debug(data)
      write(data.merge(level: :debug))
    end
  end
end
