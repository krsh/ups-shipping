require "nokogiri"

module Shipping
  class Organization
    attr_accessor :company_name, :name, :phone, :email, :address

    def initialize(options={})
      @company_name = options[:company_name]
      @name = options[:name]
      @phone = options[:phone]
      @address = options[:address]
    end

    def build(xml, rootname)
      xml.send(rootname) {
        xml.CompanyName @company_name
        xml.AttentionName @name
        xml.PhoneNumber @phone

        @address.build(xml)
      }
    end

    def to_xml(rootname)
      builder = Nokogiri::XML::Builder.new do |xml|
        build(xml, rootname)
      end
      builder.to_xml
    end
  end
end
