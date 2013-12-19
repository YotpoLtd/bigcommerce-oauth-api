module Bigcommerce
  module OAuth
    class Api < Bigcommerce::Api
      def initialize(configuration={})
        @connection = Bigcommerce::OAuth::Connection.new(configuration)
      end

      def store_hash=(store_hash)
        @connection.store_hash = store_hash
      end

      def client_id=(client_id)
        @connection.client_id = client_id
      end

      def token=(token)
        @connection.token = token
      end

      def get_store
        @connection.get '/store'
      end
    end
  end
end