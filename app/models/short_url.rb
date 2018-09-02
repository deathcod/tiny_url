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

require 'digest'

class ShortUrl < ApplicationRecord
  BASE = 62

  validates :long_url, presence: true
  validates :hash_integer, uniqueness: true
  after_validation :ensure_hash_integer_has_value, on: :create

  def ensure_hash_integer_has_value
    self.hash_integer
  end

  def hash_integer
    self[:hash_integer] ||= convert_base_to_decimal(self.hash_string)
  end

  def long_url
    add_scheme_if_not_present(self[:long_url]) if self[:long_url]
  end

  def self.filtered_long_url(str)
    str.dup.tap do |s|
      s.gsub!(/^https?:\/\//, '')         # remove scheme
      s.gsub!(/^www./, '')                # remove_subdomin
    end
  end

  def generate_short_url
    # Rails.configuration.settings['BASE_URL'] + "/" + self.hash_string
    "http://localhost:3000/short_urls" + "/" + self.hash_string
  end

  def self.find_by_long_url(long_url)
    return nil unless long_url.present?
    s = ShortUrl.new
    s.long_url = long_url
    return ShortUrl.find_by_hash_integer(s.hash_integer)
  end

  def self.find_by_hash_string(hash_string)
    s = ShortUrl.new
    s.hash_string = hash_string
    return ShortUrl.find_by_hash_integer(s.hash_integer)
  end

  def hash_string
    @hash_string ||= Digest::MD5.hexdigest(ShortUrl.filtered_long_url(self.long_url))[0..6]
  end

  def hash_string=(hash_string)
    @hash_string = hash_string
  end

  private

  def add_scheme_if_not_present(str)
    unless str =~ /^https?:\/\//
      return "http://" + str
    else
      return str
    end
  end

  def convert_base_to_decimal(rand_str)
    value = 0
    save_hash = {}
    rand_str_length = rand_str.length
    rand_str.reverse.split('').each_with_index do |c, i|
      value += char_to_int_base_mapping[c] * calculate_power( rand_str_length - i - 1, save_hash)
    end
    return value
  end

  def calculate_power(power, save_hash = {})
    if power == 1
      return BASE
    elsif power.zero?
      return 1
    elsif save_hash[power].present?
      return save_hash[power]
    end

    if (power%2).zero?
      save_hash[power] = calculate_power(power/2, save_hash) * calculate_power(power/2, save_hash)
      return save_hash[power]
    else
      save_hash[power] = BASE * calculate_power(power/2, save_hash) * calculate_power(power/2, save_hash)
      return save_hash[power]
    end
  end

  def char_to_int_base_mapping
    @hash ||= {
      '0' => 0,
      '1' => 1,
      '2' => 2,
      '3' => 3,
      '4' => 4,
      '5' => 5,
      '6' => 6,
      '7' => 7,
      '8' => 8,
      '9' => 9,
      'a' => 10,
      'b' => 11,
      'c' => 12,
      'd' => 13,
      'e' => 14,
      'f' => 15,
      'g' => 16,
      'h' => 17,
      'i' => 18,
      'j' => 19,
      'k' => 20,
      'l' => 21,
      'm' => 22,
      'n' => 23,
      'o' => 24,
      'p' => 25,
      'q' => 26,
      'r' => 27,
      's' => 28,
      't' => 29,
      'u' => 30,
      'v' => 31,
      'w' => 32,
      'x' => 33,
      'y' => 34,
      'z' => 35,
      'A' => 36,
      'B' => 37,
      'C' => 38,
      'D' => 39,
      'E' => 40,
      'F' => 41,
      'G' => 42,
      'H' => 43,
      'I' => 44,
      'J' => 45,
      'K' => 46,
      'L' => 47,
      'M' => 48,
      'N' => 49,
      'O' => 50,
      'P' => 51,
      'Q' => 52,
      'R' => 53,
      'S' => 54,
      'T' => 55,
      'U' => 56,
      'V' => 57,
      'W' => 58,
      'X' => 59,
      'Y' => 60,
      'Z' => 61
    } 
  end
end
