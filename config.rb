activate :dotenv

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

set :fonts_dir, 'fonts'

set :markdown_engine, :redcarpet

set :markdown, :fenced_code_blocks => true, :smartypants => true, :disable_indented_code_blocks => true, :prettify => true, :tables => true, :with_toc_data => true, :no_intra_emphasis => true

# Env manager
@bucket         = 'docs.processout.ninja'
@distributionId = 'E3GA5RMWGG0DB3'
@host           = 'processout.ninja'

case ENV['TARGET'].to_s.downcase
when 'production'
    @bucket         = 'docs.processout.com'
    @distributionId = 'EX89GBCWQ9F9S'
    @host           = 'processout.com'
end

helpers do
  def website_protocole()
    return 'https'
  end

  def website_host()
    return @host
  end

  def website_link(subdomain, path)
    return website_protocole + '://' + subdomain + '.' + website_host + path
  end

  def api_link(path)
    return website_link('api', path)
  end
end

# Activate the syntax highlighter
activate :syntax

page "/refs/*", :layout => "layout-refs"

activate :directory_indexes

# This is needed for Github pages, since they're hosted on a subdomain
activate :relative_assets
set :relative_links, true

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end

# S3 sync plugin
activate :s3_sync do |s3_sync|
  s3_sync.bucket                     = @bucket
  s3_sync.region                     = 'us-east-1'
  s3_sync.delete                     = true
  s3_sync.after_build                = false
  s3_sync.prefer_gzip                = true
  s3_sync.path_style                 = true
  s3_sync.reduced_redundancy_storage = false
  s3_sync.acl                        = 'public-read'
  s3_sync.encryption                 = false
  s3_sync.prefix                     = ''
  s3_sync.version_bucket             = false
end

# CloudFront plugin
activate :cloudfront do |cf|
  cf.access_key_id     = ENV['AWS_ACCESS_KEY_ID']
  cf.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
  cf.distribution_id   = @distributionId
  # cf.filter          = /\.html$/i  # default is /.*/
  # cf.after_build     = false  # default is false
end
after_s3_sync do |files_by_status|
  puts 'Invalidating files...'
  invalidate files_by_status[:updated]
end