# Copyright 2007 Amazon Technologies, Inc.  Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. You may obtain a copy of the License at:
#
# http://aws.amazon.com/apache2.0
#
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and limitations under the License.
class Media < ActiveRecord::Base
  has_attached_file :media,
                 :styles => {:medium => "300x300>",
			     :thumb => "100x100>"},
		 :storage => :s3,
		 :s3_credentials => "#{RAILS_ROOT}/config/amazon_s3.yml",
	         :url => "/:attachemnt/:id/:style/:basename.:extension",
		 :path => ":attachment/:id/:style.:extention"

   def bucket_name 
     @bucket_name ||= YAML.load(File.new("#{RAILS_ROOT}/config/amazon_s3.yml"))[RAILS_ENV]["bucket"] 
   end
end
