# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_aws-pipeline-rails2_3_8_session',
  :secret      => 'b11e82860d05db22f9558b102f7a3c8f2d2645587f03af8532097e3e8c04070b9db06a32abadaaf41990b9a8ac0bc5f71dfd67671de71684599c75805ffacd6c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
