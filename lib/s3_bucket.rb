# --------------- use for inline testing ---------------
require 'aws-sdk'
require 'pg'

load 'local_env.rb' if File.exist?('local_env.rb')

Aws.use_bundled_cert!  # resolves "certificate verify failed"
# ------------------------------------------------------

# Method to connect to AWS S3 bucket
def connect_to_s3()

  Aws::S3::Client.new(
    access_key_id: ENV['S3_KEY'],
    secret_access_key: ENV['S3_SECRET'],
    region: ENV['AWS_REGION'],
    force_path_style: ENV['PATH_STYLE']
  )

end


# Method to clean up temp file after uploading to AWS S3 bucket
def cleanup_swap_dir(file)

  image_path = "./public/swap/#{file}"

  if File.exist?(image_path)
    File.delete(image_path)  # delete temp file from /public/swap
  else
    puts "temp file does not exist!"
  end

end


# Method to generate secure URL for target file (expires after 15 minutes)
def generate_url(file)

  bucket = "timbersafe-s3"
  s3_file_path = "testresize/#{file}"

  connect_to_s3()
  signer = Aws::S3::Presigner.new
  url = signer.presigned_url(:get_object, bucket: bucket, key: s3_file_path)

end


# Method to generate an array of secure URLs for photos in S3 bucket
def query_s3(db)

  secure_urls = []
  query = db.exec("select photos from exposure_details where audit_number = 'testresize'")
  photos = query.to_a[0]["photos"].split(",")

  photos.each do |photo|
    secure_url = generate_url(photo)
    secure_urls.push(secure_url)
  end

  return secure_urls

end


# Method to download specified S3 folder/file to ./public/swap
def download_s3_file(image_info)

  folder = image_info[0]
  filename = image_info[1]
  bucket = "timbersafe-s3"
  s3_file_path = "#{folder}/#{filename}"
  swap_file = "./public/swap/#{filename}"  # use when running via app.rb
  # swap_file = "../public/swap/#{file}"  # use when running locally from /lib/s3_bucket.rb
  
  s3 = connect_to_s3()
  file = File.new(swap_file, 'wb')
  s3.get_object({ bucket:bucket, key:s3_file_path }, target: swap_file)
  file.close if file

end