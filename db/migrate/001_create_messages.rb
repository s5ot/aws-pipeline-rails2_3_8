# Copyright 2007 Amazon Technologies, Inc.  Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. You may obtain a copy of the License at:
#
# http://aws.amazon.com/apache2.0
#
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and limitations under the License.
class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.column :body, :text
      t.column :received_date, :datetime
      t.column :type, :string
    end
  end

  def self.down
    drop_table :messages
  end
end
