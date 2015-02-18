require "nokogiri"

module Shipping
  class Shipper
    attr_accessor :name, :shipper_number, :address

    def initialize(options={})
      @name = options[:name]
      @shipper_number = options[:shipper_number]
      @address = options[:address]
    end

    def build(xml, rootname)
      xml.send(rootname) {
        xml.Name @name
        xml.ShipperNumber @shipper_number
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