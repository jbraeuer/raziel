require 'raziel'

class Hiera
  module Backend
    class Yamlenc_backend
      include Raziel

      def initialize
        Hiera.debug("Hiera YAMLENC backend starting")
      end

      def lookup(key, scope, order_override, resolution_type)
        answer = nil

        Hiera.debug("Looking up #{key} in YAMLENC backend")

        Backend.datasources(scope, order_override) do |source|
          Hiera.debug("Looking for data source #{source}")

          yamlencfile = Backend.datafile(:yamlenc, scope, source, "yaml.enc") || next
          yamlkeyfile = Backend.datafile(:yamlenc, scope, source, "yaml.key.asc") || next

          Hiera.debug("Looking in data source #{yamlencfile}")

          data = YAML.load_file(yamlencfile)
          next if data.empty?
          next unless data.include?(key)

          password = RazielKeyring.new(yamlkeyfile).password
          crypto = RazielCrypto.new(password)
          new_answer = Raziel.decrypt(data[key], crypto)

          Hiera.debug("Lookup result: #{new_answer}")

          Backend.parse_answer(new_answer, scope)

          case resolution_type
          when :array
            answer ||= []
            answer << new_answer
          else
            answer = new_answer
            break
          end
        end

        return answer
      end
    end
  end
end
