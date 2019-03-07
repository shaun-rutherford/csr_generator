#!/usr/bin/env ruby
require 'generate_csr'
require 'optparse'

# COMMAND LINE OPTIONS VARAIBLE
  options = {}

# PARSE COMMAND LINE OPTIONS
  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: generate_csr.rb [OPTIONS]"

    options[:common_name] = nil
    opts.on('-n', '--common_name NAME', 'REQUIRED: Host + Domain eg. yoursite.com') do |name|
      options[:common_name] = name
    end

    options[:organization] = "Blizzard Entertainment Inc"
    opts.on('-o', '--organization NAME', 'Legal name of the Organization Default: Blizzard Entertainment Inc.') do |org|
      options[:organization] = org
    end

    options[:country] = "US"
    opts.on('-c', '--country NAME', 'Two letter code for the Country Default: US') do |c|
      options[:country] = c
    end

    options[:state_name] = "California"
    opts.on('-s', '--state_name NAME', 'State or Region do not abbreviate Default: California') do |state|
      options[:state_name] = state
    end

    options[:locality] = "Irvine"
    opts.on('-l', '--locality NAME', 'City do not abbreviate Default: Irvine') do |loc|
      options[:locality] = loc
    end

    options[:domain_list] = []
    opts.on('-d', '--domain_list x,y,z', Array, 'REQUIRED: SAN list of names NO SPACES between entries eg. test.corp.blizzard.net,test') do |san|
      options[:domain_list] = san
    end

    options[:passphrase] = nil
    opts.on('-p', '--passphrase PASSWORD', 'REQUIRED: Private key encryption password') do |pass|
      options[:passphrase] = pass
    end

    options[:email] = nil
    opts.on('-e', '--email EMAIL', 'REQUIRED: Email address to send the private key too') do |mail|
      options[:email] = mail
    end

    options[:decrypt] = false
    opts.on('-t', '--decrypt', 'Decrypt private key generated with this script to stdout, requires -f') do |dcrypt|
      options[:decrypt] = dcrypt
    end

    options[:private_key] = nil
    opts.on('-f', '--file PRIVATEKEY', 'File name of the private key you want decrypted') do |private|
      options[:private_key] = private
    end

    opts.on( '-h', '--help', 'Display this screen' ) do
      puts opts
      exit
    end
  end
  opt_parser.parse!

# COMMAND LINE OPTION VARIABLE ASSIGNMENT
  @common_name        = "#{options[:common_name]}"
  @organization       = "#{options[:organization]}"
  @country            = "#{options[:country]}"
  @state_name         = "#{options[:state_name]}"
  @locality           = "#{options[:locality]}"
  @passphrase         = "#{options[:passphrase]}"
  @email              = "#{options[:email]}"
  @filename           = "#{@common_name}.pem"
  @filename_encrypted = "#{@filename}.encrypted"
  @decrypt            = options[:decrypt]
  @filename_decrypt   = "#{options[:private_key]}"
  @domain_list        = []

# WRITE OPTIONS[:DOMAIN_LIST] ENTRIES INTO NEW INSTANCE ARRAY

  options[:domain_list].each do |list|
    @domain_list << list
  end

# ENSURE REQUIRED FLAGS ARE PASSED OTHERWISE ABORT
  unless @decrypt == true
    if @common_name.empty? 
      abort("You must provide a common_name via -n or --common_name, run -h for options")

    elsif @domain_list.empty?
      abort("You must provide a SAN entry even if it's the common name, run -h for options")

    elsif @passphrase.empty?
      puts "You must provide an encryption password: "
      puts "Password: "
      @passphrase = STDIN.noecho(&:gets).chomp

    elsif @email.empty?
      abort("You must provide an email address to send the private key, run -h for options")
    end
  end

csr = Csr_creation.new

if @decrypt == true and ! @filename_decrypt.empty?
  csr.decrypt_data(@filename_decrypt, @passphrase)
  exit 0
end

csr.generate_csr(@common_name, @organization, @country, @state_name, @locality, @domain_list)

csr.encrypt_data(@filename, @passphrase)

csr.mail(@email, @filename_encrypted)
