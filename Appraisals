RAILS_VERSIONS = %w[3.2 4.2 6.0]

RAILS_VERSIONS.each do |rails_version|
  appraise "rails-#{rails_version}" do
    gem "rails", "~> #{rails_version}.0"
  end
end
