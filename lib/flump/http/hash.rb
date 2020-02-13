# frozen_string_literal: true

module Flump
  module HTTP
    module Hash
      def http_headers
        map { "#{_1}: #{_2}" }.join("\r\n")
      end

      def sec_websocket_accept
        "#{fetch('Sec-WebSocket-Key')}#{HTTP::WEBSOCKET_MAGIC_UUID}".base64digest
      end

      def websocket_upgrade?
        self['Connection'] == 'Upgrade' && self['Upgrade'] == 'websocket'
      end
    end

    ::Hash.include(Hash)
  end
end
