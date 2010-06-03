# Copyright 2007 Amazon Technologies, Inc.  Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. You may obtain a copy of the License at:
#
# http://aws.amazon.com/apache2.0
#
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and limitations under the License.
class MediaController < ApplicationController
  require 'activemessaging/processor'
  include ActiveMessaging::MessageSender

  # messages 'published' in this controller will be sent to Amazon SQS 'todo' queue by ActiveMessaging
  publishes_to :todo
  
  #
  # We inspect the jobs input to 'todo' and output to 'done' (reading from a database, not Amazon SQS)
  #
  
  def submit_job
    # create database record and upload object to Amazon S3 using AttachmentFu plugin
    @media = Media.new(params[:media])
     
    if @media.save
      
      # make a second request to get Amazon S3 object 'etag' (doesn't re-upload to Amazon S3) 
      #about = AWS::S3::S3Object.about(@media.full_filename, @media.bucket)
      #@media.etag = about[:etag] ; @media.save # TODO: strip quotes from InputKey
  
      # build Amazon SQS message [compatible with the 'boto' project by Mitch Garnaat]
      @message = <<-EOF
Bucket: #{@media.bucket_name}
Date: #{Time.now.httpdate}
OriginalFileName: #{@media.media_file_name}
FullFileName: #{@media.media.path}
Size: #{@media.size}
EOF
      # save copy of message to database
      Todo.create(:body => @message, :received_date => DateTime.new)

      # publish message to Amazon SQS 'todo' queue
      publish :todo, @message
      
      redirect_to :action => "jobs"
      
    else
      redirect_to :action => "index"
    end
    
  end
  
  #
  # We inspect the jobs input to 'todo' and output to 'done' (reading from a database, not Amazon SQS)
  #
  
  def jobs
    todos = Todo.find(:all)
    # we need the message and URL Amazon S3 for use with view
    @jobs_todo = Array.new
    todos.each do |m|
      job = m.to_h
      # for generating a URL to object in Amazon S3
      file_path = job['FullFileName']
      bucket = job['Bucket']
      # returns URL to object in Amazon S3
      image = AWS::S3::S3Object.find file_path, bucket
      # image = image_object.value
      a = [m.body, image]
      @jobs_todo << a
      @jobs_todo.reverse!
    end
    
    dones = Done.find(:all)
    # we need the message and URL Amazon S3 for use with view
    @jobs_done = Array.new
    dones.each do |m|
      job = m.to_h
      # for generating a URL to object in Amazon S3
      file_path = job['OutputFullFileName']
      bucket = job['Bucket']
      # returns URL to object in Amazon S3
      image = AWS::S3::S3Object.find file_path, bucket
      # image = image_object.value
      a = [m.body, image]
      @jobs_done << a
      @jobs_done.reverse!
    end
    
  end
  
end
