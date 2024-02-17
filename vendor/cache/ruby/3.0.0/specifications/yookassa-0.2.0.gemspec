# -*- encoding: utf-8 -*-
# stub: yookassa 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "yookassa".freeze
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Andrey Paderin".freeze]
  s.date = "2021-11-01"
  s.email = "andy.paderin@gmail.com".freeze
  s.extra_rdoc_files = ["README.md".freeze]
  s.files = ["README.md".freeze]
  s.homepage = "https://github.com/paderinandrey/yookassa".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6".freeze)
  s.rubygems_version = "3.2.3".freeze
  s.summary = "Yookassa API SDK for Ruby".freeze

  s.installed_by_version = "3.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<dry-struct>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<http>.freeze, ["~> 5.0.1"])
  else
    s.add_dependency(%q<dry-struct>.freeze, [">= 0"])
    s.add_dependency(%q<http>.freeze, ["~> 5.0.1"])
  end
end
