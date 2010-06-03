#!/usr/bin/ruby

# Copyright 2007 Amazon Technologies, Inc.  Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. You may obtain a copy of the License at:
#
# http://aws.amazon.com/apache2.0
#
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and limitations under the License.

require 'rubygems'
require 'RMagick'
require 'right_aws'
require 'aws/s3'
require 'pp'

# Make sure stdout and stderr write out without delay for using with daemon like scripts
STDOUT.sync = true; STDOUT.flush
STDERR.sync = true; STDERR.flush

# ------------------------------------ config

AWS_ACCESS_KEY = ENV['AWS_ACCESS_KEY'] || ARGV[0]
AWS_SECRET_ACCESS_KEY = ENV['AWS_SECRET_ACCESS_KEY'] || ARGV[1]
DEFAULT_POLL_FREQUENCY = 10
WATERMARK_STRING = "Amazon Web Services"

TODO_QUEUE = 'todo'
DONE_QUEUE = 'done'

# ------------------------------------ helper methods

# watermarks single image with string
def mark_image(image)
  images = Magick::Image.from_blob(image) # from_blob returns array of images
  image = images[0] # method is receiving just one image

  mark = Magick::Image.new(image.columns, image.rows)

  gc = Magick::Draw.new
  gc.gravity = Magick::CenterGravity
  gc.pointsize = 32
  gc.font_family = "Arial"
  gc.font_weight = Magick::BoldWeight
  gc.stroke = 'none'
  gc.annotate(mark, 0, 0, 0, 0, WATERMARK_STRING)

  mark = mark.shade(true, 310, 30)

  image.composite!(mark, Magick::CenterGravity, Magick::HardLightCompositeOp)

  image = image.to_blob
  return image
end

# convert key, pair values in string to hash
def to_h(m)
  kv = Array.new
  kvs = Array.new
  key_values = Hash.new
  m.each do |l|
    l.strip!
    kv = l.split(': ', 2)
    kv.each { |s| s.strip! }
    kvs << kv
  end
  key_values = kvs.inject({}) do |hash, value|
	  hash[value.first] = value.last 
	  hash
	end
  return key_values
end

# ------------------------------------ watermark a single image

# grab queues
sqs = RightAws::SqsGen2.new(AWS_ACCESS_KEY, AWS_SECRET_ACCESS_KEY)
todo_q = sqs.queue(TODO_QUEUE)
done_q = sqs.queue(DONE_QUEUE)

while true
  begin
    # read a single message (if any) and set MessageVisibility on it
    m = todo_q.receive
    
    # if we didn't receive message check again later
    if m.nil? 
      sleep DEFAULT_POLL_FREQUENCY
      
    # if we got a message - go!
    else 
      # record time message read
      message_time_read = Time.now.httpdate

      # convert message to a Hash
      puts "message body:\n"
      puts m.body
      job = to_h(m.body)
      puts "job:\n"
      puts job

      # get image name and bucket name from message
      file_path = job["FullFileName"]
      bucket    = job["Bucket"]

      # read image from S3
      AWS::S3::Base.establish_connection!(
          :access_key_id     => AWS_ACCESS_KEY,
          :secret_access_key => AWS_SECRET_ACCESS_KEY
        )
      image_object = AWS::S3::S3Object.find file_path, bucket
      puts "sucessfully received image"
      pp image_object.about

      # use S3Object.value for actual Magick::Image BLOB
      image = mark_image(image_object.value)
      puts "sucessfully processed image"

      # write result to S3 as new image
      file_path = file_path.sub(/\./, "-done.")
      obj = AWS::S3::S3Object.store(file_path, image, bucket, :authenticated => false)
      puts "sucessfully stored image"

      # prepare message for done queue
      done = m.body
      done +=  "OutputKey: #{obj.etag};type=image/jpeg\n"
      done +=  "OutputFullFileName: #{file_path}\n"
      done +=  "Server: Watermarker\n"
      done +=  "Host: #{`hostname`.chomp!}\n"
      done +=  "Service-Read: #{message_time_read}\n"
      done +=  "Service-Write: #{Time.now.httpdate}\n"

      # write message to done queue
      done_q.send_message done
      puts "done: \n" + done

      # delete message from todo queue
      m.delete
    end
  end
end
