class HomeController < ApplicationController
  def index
    @rails_version = Rails.version
    @rack_version = Rack.release
    @ruby_version = RUBY_VERSION
    @ruby_description = RUBY_DESCRIPTION
    @yjit_enabled = defined?(RubyVM::YJIT) && RubyVM::YJIT.enabled?
  end
end
