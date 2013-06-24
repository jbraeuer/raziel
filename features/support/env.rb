require 'aruba/cucumber'
require 'ptools'

require 'aruba/api'
World(Aruba::Api)

ENV['RUBYLIB'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../lib')}#{File::PATH_SEPARATOR}#{ENV['RUBYLIB']}"
ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
ENV['GNUPGHOME'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../.gnupg')}"
