# -*- encoding: utf-8 -*-
# stub: telegram-bot 0.15.6 ruby lib

Gem::Specification.new do |s|
  s.name = "telegram-bot".freeze
  s.version = "0.15.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Max Melentiev".freeze]
  s.bindir = "exe".freeze
  s.date = "2022-03-13"
  s.email = ["melentievm@gmail.com".freeze]
  s.homepage = "https://github.com/telegram-bot-rb/telegram-bot".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4".freeze)
  s.rubygems_version = "3.2.3".freeze
  s.summary = "Library for building Telegram Bots with Rails integration".freeze

  s.installed_by_version = "3.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<actionpack>.freeze, [">= 4.0", "< 7.1"])
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 4.0", "< 7.1"])
    s.add_runtime_dependency(%q<httpclient>.freeze, ["~> 2.7"])
    s.add_development_dependency(%q<bundler>.freeze, ["> 1.16"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  else
    s.add_dependency(%q<actionpack>.freeze, [">= 4.0", "< 7.1"])
    s.add_dependency(%q<activesupport>.freeze, [">= 4.0", "< 7.1"])
    s.add_dependency(%q<httpclient>.freeze, ["~> 2.7"])
    s.add_dependency(%q<bundler>.freeze, ["> 1.16"])
    s.add_dependency(%q<rake>.freeze, ["~> 13.0"])
  end
end
