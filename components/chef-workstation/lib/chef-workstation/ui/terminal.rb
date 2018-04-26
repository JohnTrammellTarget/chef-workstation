require "tty-spinner"
require "chef-workstation/status_reporter"
require "chef-workstation/config"
require "chef-workstation/log"
require "chef-workstation/ui/plain_text_element"

module ChefWorkstation
  module UI
    class Terminal
      class << self
        # To support matching in test
        attr_accessor :location

        def init(location)
          @location = location
          # In Ruby 2.5+ threads print out to stdout when they raise an exception. This is an agressive
          # attempt to ensure debugging information is not lost, but in our case it is not necessary
          # because we handle all the errors ourself. So we disable this to keep output clean.
          # See https://ruby-doc.org/core-2.5.0/Thread.html#method-c-report_on_exception
          Thread.report_on_exception = false
        end

        def write(msg)
          @location.write(msg)
        end

        def output(msg)
          @location.puts msg
        end

        def spinner(msg, prefix: "", &block)
          klass = Object.const_get("ChefWorkstation::UI::#{ChefWorkstation::Config.dev.spinner}")
          spinner = klass.new("[:spinner] :prefix :status", output: @location)
          reporter = StatusReporter.new(spinner, prefix: prefix, key: :status)
          reporter.update(msg)
          spinner.run { yield(reporter) }
        end
      end
    end
  end
end
