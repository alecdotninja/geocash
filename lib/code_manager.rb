class CodeManager
  CODE_CHARS = %w( 2 3 4 5 6 7 8 9 A B C D E F G H J K L M N P Q R S T U V W X Y Z )
  CODE_SEPARATOR = '-'
  MAX_AMOUNT_MAGNITUDE = 100

  CODE_ENTROPY = CODE_CHARS.count ** 8

  AMOUNT_SIGN_BIT_ENTROPY = 2
  AMOUNT_MAGNITUDE_ENTROPY = MAX_AMOUNT_MAGNITUDE + 1
  AMOUNT_ENTROPY = AMOUNT_SIGN_BIT_ENTROPY * AMOUNT_MAGNITUDE_ENTROPY

  RANDOMNESS_ENTROPY = CODE_CHARS.count ** 4

  # Leave whatever space is left for the digest
  DIGEST_ENTROPY = CODE_ENTROPY / (AMOUNT_ENTROPY * RANDOMNESS_ENTROPY)

  def self.generate(amount:, secret:)
    new(amount: amount, secret: secret).code
  end

  def self.verified_amount(code:, secret:)
    code_manager = new(code: code, secret: secret)
    code_manager.amount if code_manager.valid?
  end

  attr_reader :secret, :amount

  def initialize(amount: nil, code: nil, secret:)
    if code.present?
      amount_sign_bit, amount_magnitude, @randomness, @digest = unpack(numberify(code), AMOUNT_SIGN_BIT_ENTROPY, AMOUNT_MAGNITUDE_ENTROPY, RANDOMNESS_ENTROPY, DIGEST_ENTROPY)
      amount = amount_sign_bit > 0 ? amount_magnitude : -amount_magnitude
    end

    @amount, @secret = amount, secret
  end

  def code
    @code ||= compute_code
  end

  def valid?
    digest == compute_digest
  end

  private

  def compute_code
    stringify pack(
      [amount_sign_bit, AMOUNT_SIGN_BIT_ENTROPY],
      [amount_magnitude, AMOUNT_MAGNITUDE_ENTROPY],
      [randomness, RANDOMNESS_ENTROPY],
      [digest, DIGEST_ENTROPY]
    )
  end

  def pack(*parts)
    number = 0

    parts.each do |value, entropy|
      number = value + number * entropy
    end

    number
  end

  def unpack(number, *entropies)
    values = []

    entropies.reverse_each do |entropy|
      values.unshift number % entropy
      number /= entropy
    end

    values
  end

  def digest
    @digest ||= compute_digest
  end

  def compute_digest
    Digest::SHA256.hexdigest("#{amount}#{randomness}#{secret}").to_i(16) % DIGEST_ENTROPY
  end

  def randomness
    @randomness ||= rand(0...RANDOMNESS_ENTROPY)
  end

  def amount_sign_bit
    amount > 0 ? 1 : 0
  end

  def amount_magnitude
    amount.abs
  end

  def stringify(number)
    base = CODE_CHARS.count
    string = ''

    9.times do |idx|
      if idx == 4
        string << CODE_SEPARATOR
      else
        string << CODE_CHARS[number % base]
        number /= base
      end
    end

    raise RangeError unless number == 0

    string
  end

  def numberify(code)
    base = CODE_CHARS.count
    number = 0

    code.reverse.each_char do |char|
      value = CODE_CHARS.index(char)

      if value.present?
        number *= base
        number += value
      end
    end

    number
  end
end