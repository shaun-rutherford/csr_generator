#!/usr/bin/env ruby
require 'openssl'
require 'io/console'
require 'mail'

class Csr
# Generate X509 CSR (certificate signing request) with SAN (Subject Alternative Name) extension and sign it with the RSA key
  def generate(common_name, organization, country, state_name, locality, domain_list)
    # create signing key
    signing_key = OpenSSL::PKey::RSA.new 2048

    # create certificate subject
    subject = OpenSSL::X509::Name.new [
      ['CN', common_name],
      ['O', organization],
      ['C', country],
      ['ST', state_name],
      ['L', locality]
    ]

    # create CSR
    csr = OpenSSL::X509::Request.new
    csr.version = 0
    csr.subject = subject
    csr.public_key = signing_key.public_key
    csr.to_pem()

    # prepare SAN extension
    san_list = domain_list.map do |domain|
      "DNS:#{domain}"
    end

    extensions = [
      OpenSSL::X509::ExtensionFactory.new.create_extension('subjectAltName', san_list.join(','))
    ]

    # add SAN extension to the CSR
    attribute_values = OpenSSL::ASN1::Set [OpenSSL::ASN1::Sequence(extensions)]
    [
      OpenSSL::X509::Attribute.new('extReq', attribute_values),
      OpenSSL::X509::Attribute.new('msExtReq', attribute_values)
    ].each do |attribute|
      csr.add_attribute attribute
    end

    # sign CSR with the signing key
    csr.sign signing_key, OpenSSL::Digest::SHA256.new
    
    # write signing key to the file
    open "#{common_name}.pem", 'w' do |io|
      io.write signing_key.to_pem
    end

    # write certificate signing request to the file
    open "#{common_name}.csr", 'w' do |io|
      io.write csr.to_pem
    end

  end

# ENCRYPT PRIVATE KEY
  def encrypt(filename, passphrase)
    # ENCRYPTION
    pass_phrase = "#{passphrase}"
    salt = '8 octets'

    encrypter = OpenSSL::Cipher.new 'AES-128-CBC'
    encrypter.encrypt
    encrypter.pkcs5_keyivgen pass_phrase, salt
    data = File.read("#{filename}")
    encrypted = encrypter.update "#{data}"
    encrypted << encrypter.final

    encrypted_file = File.new("#{filename}.encrypted", 'w')
    encrypted_file.write(encrypted)
    encrypted_file.close

    File.delete("#{filename}")
  end

# DECRYPT PRIVATE KEY
  def decrypt(filename, passphrase)
    pass_phrase = "#{passphrase}"
    salt = '8 octets'
    decrypter = OpenSSL::Cipher.new 'AES-128-CBC'
    decrypter.decrypt
    decrypter.pkcs5_keyivgen pass_phrase, salt

    unencrypt = File.read("#{filename}")

    plain = decrypter.update unencrypt
    plain << decrypter.final

    puts plain
  end

# EMAIL PRIVATE KEY
  def mail(email_address, attachment)
    Mail.deliver do
      from     'svc_jiraapi_sslcreation@blizzard.com'
      to       "#{email_address}"
      subject  "SSL Automation - #{attachment}"
      body     'Please see attached for your private key'
      add_file "#{attachment}"
    end
  end

end
