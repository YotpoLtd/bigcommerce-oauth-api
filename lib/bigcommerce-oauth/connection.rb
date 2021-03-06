module Bigcommerce
  module OAuth
    class Connection < Bigcommerce::Connection
      def store_hash=(store_hash)
        @configuration[:store_hash] = store_hash
      end

      def client_id=(client_id)
        @configuration[:client_id] = client_id
      end

      def token=(token)
        @configuration[:token] = token
      end

      def request(method, path, options, headers={})
        loop do
          begin
            return request_impl(method, path, options, headers)
          rescue RestClient::TooManyRequests => e
            retry_after = e.response.headers[:x_retry_after].to_i
            sleep(retry_after)
          end
        end
      end

      def request_impl(method, path, options, headers={})
        headers.merge!({ :'x-auth-client' => @configuration[:client_id], :'x-auth-token'  => @configuration[:token] })
        url = "https://api.bigcommerce.com/stores/#{@configuration[:store_hash]}/v2#{path}"

        restclient = RestClient::Resource.new(url)
        if @configuration[:ssl_client_key] && @configuration[:ssl_client_cert] && @configuration[:ssl_ca_file]
          restclient = RestClient::Resource.new(
            url,
            :ssl_client_cert => @configuration[:ssl_client_cert],
            :ssl_client_key  => @configuration[:ssl_client_key],
            :ssl_ca_file     => @configuration[:ssl_ca_file],
            :verify_ssl      => @configuration[:verify_ssl]
          )
        end
        begin
          response = case method
                       when :get then
                         restclient.get headers.merge({:params => options, :accept => :json, :content_type => :json})
                       when :post then
                         restclient.post(options.to_json, headers.merge({:content_type => :json, :accept => :json}))
                       when :put then
                         restclient.put(options.to_json, headers.merge({:content_type => :json, :accept => :json}))
                       when :delete then
                         restclient.delete
                     end
          if((200..201) === response.code)
            JSON.parse response
          elsif response.code == 204
            nil
          end
        rescue RestClient::TooManyRequests => e
          raise e
        rescue RestClient::NotModified, RestClient::NotFound
          nil
        rescue RestClient::Unauthorized, RestClient::Forbidden => e
          raise Bigcommerce::HTTPUnauthorized.new "invalid bigcommerce credentials, #{e}"
        rescue SocketError, RestClient::RequestFailed => e
          raise Bigcommerce::HTTPNotFound.new "unable to reach bigcommerce site url, #{e}"
        rescue => e
          raise "Failed to parse Bigcommerce response: #{e}"
        end
      end
    end
  end
end
