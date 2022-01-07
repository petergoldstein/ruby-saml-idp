# frozen_string_literal: true

require_relative 'acceptance_helper'

feature 'IdpController' do
  let(:idp_port) { 8009 }
  let(:sp_port) { 8022 }

  before do
    create_app('idp')
    create_app('sp')
    @idp_pid = start_app('idp', idp_port)
    @sp_pid = start_app('sp', sp_port)
  end

  after do
    stop_app('sp', @sp_pid)
    stop_app('idp', @idp_pid)
  end

  scenario 'Login via default signup page' do
    saml_request = make_saml_request("http://localhost:#{sp_port}/saml/consume")
    visit "http://localhost:#{idp_port}/saml/auth?SAMLRequest=#{CGI.escape(saml_request)}"
    fill_in 'Email', with: 'brad.copa@example.com'
    fill_in 'Password', with: 'okidoki'
    click_button 'Sign in'
    expect(current_url).to eq("http://localhost:#{sp_port}/saml/consume")
    expect(page).to have_content('brad.copa@example.com')
  end
end
