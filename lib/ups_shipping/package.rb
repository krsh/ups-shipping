require "nokogiri"

module Shipping
  class Package
    attr_accessor :length, :width, :height , :weight, :description, :reference, :monetary_value, :delivery_confirmation

    def initialize(options={})
      @length = options[:length]
      @width = options[:width]
      @height= options[:height]
      @weight = options[:weight]
      @description = options[:description]
      @reference = options[:reference]
      @monetary_value = options[:monetary_value]
      @delivery_confirmation = options[:delivery_confirmation]
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
        xml.PackageServiceOptions{
          xml.InsuredValue{
            xml.CurrencyCode "USD"
            xml.MonetaryValue @monetary_value || "0.0"
          }
          if @delivery_confirmation
            xml.DeliveryConfirmation {
              DCISType @delivery_confirmation
            }
          end
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