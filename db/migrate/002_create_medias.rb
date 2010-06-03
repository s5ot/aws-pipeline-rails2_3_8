# Copyright 2007 Amazon Technologies, Inc.  Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. You may obtain a copy of the License at:
#
# http://aws.amazon.com/apache2.0
#
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and limitations under the License.
class CreateMedias < ActiveRecord::Migration
  def self.up
    create_table :medias do |t|
      t.column :parent_id,  :integer
      t.column :content_type, :string
      t.column :media_file_name, :string
      t.column :media_content_type, :string
      t.column :media_file_size, :string
      t.column :thumbnail, :string
      t.column :size, :integer
      t.column :width, :integer
      t.column :height, :integer
      t.column :etag, :string
      t.column :full_filename, :string
    end
  end

  def self.down
    drop_table :medias
  end
end
