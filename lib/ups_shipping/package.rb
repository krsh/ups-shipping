require "nokogiri"

module Shipping
  class Package
    attr_accessor :length, :width, :height , :weight, :description, :reference

    def initialize(options={})
      @length = options[:length]
      @width = options[:width]
      @height= options[:height]
      @weight = options[:weight]
      @description = options[:description]
      @reference = options[:reference]
    end

    def build(xml)
      xml.Package {
        xml.PackagingType {
          xml.Code "02"
          xml.Description "Customer Supplied"
        }
        xml.Description @description
        xml.ReferenceNumber {
          xml.Code "00"
          xml.Value @reference || "Package"
        }
        xml.PackageWeight {
          xml.UnitOfMeasurement{
            xml.Code "LBS"
          }
          xml.Weight @weight
        }

        xml.Dimensions {
          xml.UnitOfMeasurement{
            xml.Code "IN"
          }
          xml.Length @length
          xml.Width @width
          xml.Height @height
        }
      }
    end

    def to_xml()
      builder = Nokogiri::XML::Builder.new do |xml|
        build(xml)
      end
      builder.to_xml
    end
  end
end