Gem::Specification.new do |s|
    s.name        = 'csr_generation'
    s.version     = '0.0.1'
    s.summary     = 'CSR generation'
    s.description = 'Generates a CSR and encrypted private key for SSL creation'
    s.authors     = ["Shaun Rutherford"]
    s.email       = 'aeonsies@gmail.com'
    s.files       = ["lib/generate_csr.rb"]
    s.add_development_dependency 'mail'
    s.add_development_dependency 'openssl'
    s.add_development_dependency 'io/console'
    s.license       = 'GPL-2.0'
  end
