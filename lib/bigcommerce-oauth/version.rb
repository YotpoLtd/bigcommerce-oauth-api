module Bigcommerce
  module OAuth
    major = 0
    minor = 1
    VERSION = [major, minor].join('.') unless defined? Bigcommerce::OAuth::VERSION
  end
end