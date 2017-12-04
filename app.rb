require 'aws-sdk'
require 'pg'
require 'sinatra'

require_relative './lib/s3_bucket.rb'

Aws.use_bundled_cert!  # resolves "certificate verify failed" error

load './lib/local_env.rb' if File.exist?('./lib/local_env.rb')


# Method to open a connection to the PostgreSQL database
def connection()

  begin
    db_params = {
          host: ENV['dbhost'],
          port:ENV['dbport'],
          dbname:ENV['dbname'],
          user:ENV['dbuser'],
          password:ENV['dbpass']
        }
    db = PG::Connection.new(db_params)
  rescue PG::Error => e
    puts 'Exception occurred'
    puts e.message
  end

end


get '/' do

  images = query_s3(connection)  # S3 bucket images

  erb :images, locals: {images: images}

end


# Route to receive/queue data from JavaScript via AJAX request
post '/cache_image' do

  image_info = params[:image_info]

  download_s3_file(image_info)  # download S3 image to ./public/swap

  # update HTML to trigger JS function retrieveImage()
  "<p>AJAX request successfully received - image cached.</p>"  # use to view update on page
  # "<p hidden>AJAX request successfully received - image cached.</p>"  # use for base64-only output

end


# Route to receive/queue data from JavaScript via AJAX request
post '/purge_image' do

  image_name = params[:image_name]

  cleanup_swap_dir(image_name)  # delete image from ./public/swap

  # update HTML to trigger JS function cleanupSwap()
  "<p>AJAX request successfully received - image purged.</p>"  # use to view update on page
  # "<p hidden>AJAX request successfully received - image purged.</p>"  # use for base64-only output

end