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

class ShortUrl < ApplicationRecord
  BASE = 62
  RANDOM_STRING_GENERATOR_LENGTH = 6

  validates :long_url, presence: true
  validates :hash_integer, uniqueness: true
  after_validation :ensure_hash_integer_has_value, on: :create

  def ensure_hash_integer_has_value
    self.hash_integer
  end

  def hash_integer
    self[:hash_integer] ||= decode(self.hash_string)
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
    "http://139.59.61.15:3000/short_urls" + "/" + self.hash_string
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
    return @hash_string if @hash_string
    if self[:hash_integer].present?
      return (@hash_string = encode(self[:hash_integer]))
    end

    loop do
      str = ""
      while str.length != RANDOM_STRING_GENERATOR_LENGTH
        str << random_str_range[Random.new.rand(BASE)]
      end

      this_integer_hash = decode(str)
      # check if generator are not colliding
      unless ShortUrl.find_by_hash_integer(this_integer_hash).present?
	@hash_string = str
        break
      end
    end
    return @hash_string
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

  def random_str_range
    [*('0'..'9'), *('a'..'z'), *('A'..'Z')].freeze
  end
  
  def encode(decimal_val)
    str = ""
    while(decimal_val > 0)
      str << int_char_base_mapping[decimal_val % BASE]
      decimal_val /= BASE
    end
    str
  end

  def decode(str)
    value = 0
    save_hash = {}
    str_length = str.length
    str.reverse.split('').each_with_index do |c, i|
      value += char_to_int_base_mapping[c] * calculate_power( str_length - i - 1, save_hash)
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

  def int_char_base_mapping
    @hash ||= {
      0 => '0',
      1 => '1',
      2 => '2',
      3 => '3',
      4 => '4',
      5 => '5',
      6 => '6',
      7 => '7',
      8 => '8',
      9 => '9',
      10 => 'a',
      11 => 'b',
      12 => 'c',
      13 => 'd',
      14 => 'e',
      15 => 'f',
      16 => 'g',
      17 => 'h',
      18 => 'i',
      19 => 'j',
      20 => 'k',
      21 => 'l',
      22 => 'm',
      23 => 'n',
      24 => 'o',
      25 => 'p',
      26 => 'q',
      27 => 'r',
      28 => 's',
      29 => 't',
      30 => 'u',
      31 => 'v',
      32 => 'w',
      33 => 'x',
      34 => 'y',
      35 => 'z',
      36 => 'A',
      37 => 'B',
      38 => 'C',
      39 => 'D',
      40 => 'E',
      41 => 'F',
      42 => 'G',
      43 => 'H',
      44 => 'I',
      45 => 'J',
      46 => 'K',
      47 => 'L',
      48 => 'M',
      49 => 'N',
      50 => 'O',
      51 => 'P',
      52 => 'Q',
      53 => 'R',
      54 => 'S',
      55 => 'T',
      56 => 'U',
      57 => 'V',
      58 => 'W',
      59 => 'X',
      60 => 'Y',
      61 => 'Z'
    } 
  end
end
