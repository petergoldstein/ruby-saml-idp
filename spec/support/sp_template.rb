# frozen_string_literal: true

# Set up a SAML SP

gem 'ruby-saml'
gem 'stub_saml_idp', path: File.expand_path('../..', __dir__)
gem 'thin'

insert_into_file('Gemfile', after: /\z/) do
  <<~GEMFILE
    if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new("3.1")
      gem 'net-smtp', require: false
      gem 'net-imap', require: false
      gem 'net-pop', require: false
    end
  GEMFILE
end

route "post '/saml/consume' => 'saml#consume'"

file 'app/controllers/saml_controller.rb', <<-CODE
  # frozen_string_literal: true

  class SamlController < ApplicationController
    skip_before_action :verify_authenticity_token

    def consume
      response = ::OneLogin::RubySaml::Response.new(params[:SAMLResponse])
      render plain: response.name_id
    end
  end
CODE
