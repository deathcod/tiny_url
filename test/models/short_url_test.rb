# == Schema Information
#
# Table name: short_urls
#
#  id           :integer          not null, primary key
#  hash_integer :integer
#  long_url     :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'test_helper'

class ShortUrlTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
