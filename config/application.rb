require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module OsPhoneBook
  class Application < Rails::Application
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.active_support.escape_html_entities_in_json = true
    config.assets.enabled = true
    config.assets.version = '1.0'

    ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
      tag_string = html_tag.to_s
      if tag_string =~ /<(input|textarea|select)/ and not tag_string =~ /<input[^>]+type=\"hidden\"[^>]*>/
        center_class = tag_string =~ /class=\".*center.*\"/ ? " center" : ""
        tag_string = "<span class=\"fieldWithErrors#{center_class}\">#{tag_string}</span>".html_safe
      end
      tag_string
    end
  end
end
