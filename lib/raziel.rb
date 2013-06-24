require 'rubygems'
require 'gpgme'
require 'base64'
require 'pp'
require 'highline/import'

class RazielCrypto
  def initialize(key, debug=false)
    @key = key
    @debug = debug
  end

  def debug(msg)
    puts msg if @debug
  end

  def decrypt(value)
    raise "Unable to load key file" unless @key
    debug "Will decrypt: #{value}"

    crypto = GPGME::Crypto.new(:password => @key)
    cipher = GPGME::Data.new(Base64.decode64(value))
    red = crypto.decrypt(cipher).read

    debug "Decrypt #{value} - #{red}"
    return red
  end

  def encrypt(value)
    raise "Unable to load key file" unless @key

    crypto = GPGME::Crypto.new(:password => @key)
    black = crypto.encrypt(value, :symmetric => true)
    black = Base64.encode64(black.read).gsub("\n", "")

    debug "Encrypt #{value} - #{black}"
    return black
  end
end

class RazielKeyring
  def initialize(file, debug=false)
    @file = file
    @debug = debug
  end

  def password
    pw = case @file
         when /.key$/
           YAML.load_file(@file)["password"]
         when /.asc$/
           crypto = GPGME::Crypto.new :passphrase_callback => Raziel.method(:ask_for_passwd)
           File.open(@file) do |fd|
             dec = crypto.decrypt fd
             YAML.load(StringIO.new(dec.read))["password"]
           end
         else
           raise "Unsupported file extension."
         end
    return pw
  end
end

module Raziel
  def self.encrypt(red, crypto)
    debug "encrypting #{red.class}: #{red}"
    black = {}
    red.each do |k,v|
      debug "found hash value of type #{v.class}"
      if v.is_a? Array
        black[k] = encryt_array(v, crypto)
      elsif v.is_a? Hash
        black[k] = encrypt(v, crypto)
      elsif v =~ /^PLAIN\((.*)\)$/m
        black[k] = "ENC(#{crypto.encrypt($1)})"
      else
        black[k] = v
      end
    end
    return black
  end

  def self.encryt_array(red, crypto)
    debug "encrypting #{red.class}: #{red}"
    black = []
    red.each_with_index do |v, i|
      debug "found array value of type #{v.class} at index #{i}"
      if v.is_a? Array
        black[i] = encryt_array(v, crypto)
      elsif v.is_a? Hash
        black[i] = encrypt(v, crypto)
      elsif v =~ /^PLAIN\((.*)\)$/m
        black[i] = "ENC(#{crypto.encrypt($1)})"
      else
        black[i] = v
      end
    end
    return black
  end

  def self.decrypt(black, crypto, surround_with_plain=false)
    if black.is_a? Array
      return decrypt_array(black, crypto, surround_with_plain)
    elsif black.is_a? Hash
      return decrypt_hash(black, crypto, surround_with_plain)
    else
      return decrypt_item(black, crypto, surround_with_plain)
    end
  end

  def self.decrypt_hash(black, crypto, surround_with_plain=false)
    debug "decrypting #{black.class}: #{black}"
    red = {}
    black.each do |k, v|
      debug "found hash value of type #{v.class}"
      if v.is_a? Array
        red[k] = decrypt_array(v, crypto, surround_with_plain)
      elsif v.is_a? Hash
        red[k] = decrypt_hash(v, crypto, surround_with_plain)
      else
        red[k] = decrypt_item(v, crypto, surround_with_plain)
      end
    end
    return red
  end

  def self.decrypt_array(black, crypto, surround_with_plain=false)
    debug "decrypting #{black.class}: #{black}"
    red = []
    black.each_with_index do |v, i|
      debug "found array value of type #{v.class} at index #{i}"
      if v.is_a? Array
        red[i] = decrypt_array(v, crypto, surround_with_plain)
      elsif v.is_a? Hash
        red[i] = decrypt_hash(v, crypto, surround_with_plain)
      else
        red[i] = decrypt_item(v, crypto, surround_with_plain)
      end
    end
    return red
  end

  def self.decrypt_item(v, crypto, surround_with_plain=false)
    res = v
    if v =~ /^[\n]*ENC\((.*)\)$/m
      plain = crypto.decrypt($1)
      debug "Hit enc: -#{$1}- -> decrypted: -#{plain}- (type #{v.class})"
      res = surround_with_plain ? "PLAIN(#{plain})" : plain
      begin
        require 'styledyaml'
        res = StyledYAML.literal res if res.include? "\n"
      rescue LoadError
        debug 'StyledYAML not available'
      end
    end
    return res
  end

  def self.ask_for_passwd(obj, uid_hint, passphrase_info, prev_was_bad, fd)
#    $stderr.write("Passphrase for #{uid_hint}: ")
#    begin
#      system('stty -echo')
#      io = IO.for_fd(fd, 'w')
#      io.puts(STDIN.gets)
#      io.flush
#    ensure
#      (0 ... $_.length).each do |i| $_[i] = ?0 end if $_
#      system('stty echo')
#    end
#    warn "HERE"
#    $stderr.puts
    password = ask("Passphrase for #{uid_hint}: ") { |q| q.echo = false }
    io = IO.for_fd(fd, 'w')
    io.puts(password)
    io.flush
  end

  def self.debug(msg)
    # puts msg
  end
end
