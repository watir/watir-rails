RAILS_VERSIONS = %w[3.0 3.1 3.2 4.0 4.1 4.2 5.0 5.1 5.2 6.0 6.1]

RAILS_VERSIONS.each do |rails_version|
  appraise "rails-#{rails_version}" do
    gem "rails", "~> #{rails_version}.0"
    # Webrick is missing on ruby-3
    gem "webrick"
  end
end
