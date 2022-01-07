# Stub SAML Identity Provider (IdP)

The Stub SAML Identity Provider library allows users to easily spin up stub SAML IdP
servers in test environments.  
  The intention is that 
for testing against the server side of SAML authentication. It allows your application to act as an IdP (Identity Provider) using the [SAML v2.0](http://en.wikipedia.org/wiki/Security_Assertion_Markup_Language) protocol. It provides a means for managing authentication requests and confirmation responses for SPs (Service Providers).

This is not a "real" IdP and should not be used in production environments.  It is intended
only for use in testing environments.


Installation and Usage
----------------------

Add this to the Gemfile of your Rails app in your test environment:

    gem 'stub_saml_idp'

Add to your `routes.rb` file, for example:

``` ruby
get '/saml/auth' => 'saml_idp#new'
post '/saml/auth' => 'saml_idp#create'
```

Create a controller that looks like this, customize to your own situation:

``` ruby
class SamlIdpController < StubSamlIdp::IdpController
  before_action :find_account
  # layout 'saml_idp'

  def idp_authenticate(email, password)
    user = @account.users.where(:email => params[:email]).first
    user && user.valid_password?(params[:password]) ? user : nil
  end

  def idp_make_saml_response(user)
    encode_SAMLResponse(user.email)
  end

  private

    def find_account
      @subdomain = saml_acs_url[/https?:\/\/(.+?)\.example.com/, 1]
      @account = Account.find_by_subdomain(@subdomain)
      render :status => :forbidden unless @account.saml_enabled?
    end

end
```

The most minimal example controller would look like:

``` ruby
class SamlIdpController < StubSamlIdp::IdpController

  def idp_authenticate(email, password)
    true
  end

  def idp_make_saml_response(user)
    encode_SAMLResponse("you@example.com")
  end

end
```

Keys and Secrets
----------------

To generate the SAML Response it uses a default X.509 certificate and secret key... which isn't so secret. You can find them in `SamlIdp::Default`. The X.509 certificate is valid until year 2032. Obviously you shouldn't use these if you intend to use this in production environments. In that case, within the controller set the properties `x509_certificate` and `secret_key` using a `prepend_before_action` callback within the current request context or set them globally via the `SamlIdp.config.x509_certificate` and `SamlIdp.config.secret_key` properties.

The fingerprint to use, if you use the default X.509 certificate of this gem, is:

```
9E:65:2E:03:06:8D:80:F2:86:C7:6C:77:A1:D9:14:97:0A:4D:F4:4D
```


Service Providers
-----------------

To act as a Service Provider which generates SAML Requests and can react to SAML Responses use the excellent [ruby-saml](https://github.com/onelogin/ruby-saml) gem.


Copyright
-----------

Copyright (c) 2012 Lawrence Pit. See MIT-LICENSE for details.
