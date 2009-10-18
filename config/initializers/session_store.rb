# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_cim_v1_session',
  :secret      => 'c0a9c6c9426cbfd2c0275367c88facf17ac77c91c3c850bcf9eebab288fa62b25f8295f5ce8afa4ecb921881bafa2bf9dcbf00b40a666216705f51d5550c4447'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
