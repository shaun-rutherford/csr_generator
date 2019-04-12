Gem::Specification.new do |s|
  s.name        = 'csr_generation'
  s.homepage    = 'https://github.com/shaun-rutherford/csr_generator'
  s.version     = '1.1.0'
  s.summary     = 'CSR generation'
  s.description = 'Generates a CSR and encrypted private key for SSL creation'
  s.authors     = ["Shaun Rutherford"]
  s.email       = 'aeonsies@gmail.com'
  s.files       = ["lib/generate_csr.rb"]
  s.license     = 'GPL-2.0'
  s.required_ruby_version = '>= 2.3.0'
  s.add_runtime_dependency 'mail', ["=2.5.5"]
end
