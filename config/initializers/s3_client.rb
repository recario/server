# frozen_string_literal: true
Aws.config[:credentials] = Aws::Credentials.new(ENV['DO_SPACE_KEY'], ENV['DO_SPACE_SECRET'])
S3_CLIENT = Aws::S3::Client.new(region: ENV['DO_SPACE_REGION'], endpoint: "https://#{ENV['DO_SPACE_REGION']}.digitaloceanspaces.com")
