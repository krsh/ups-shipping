require "nokogiri"
require "httparty"
require 'ups_shipping/address'
require 'ups_shipping/organization'
require 'ups_shipping/shipper'
require 'ups_shipping/package'
require 'ups_shipping/pickup'

module Shipping

  class UPS

    TEST_URL = "https://wwwcie.ups.com"
    LIVE_URL = "https://onlinetools.ups.com"

    class Http
      include HTTParty
      base_uri LIVE_URL

      def initialize(access_request, options={})
        @access_request = access_request

        if (options[:test])
          self.class.base_uri TEST_URL
        end
      end

      def commit(url, request)
        request = @access_request + request
        self.class.post(url, :body => request).parsed_response
      end
    end

    def initialize(user, password, license, options={})
      @options = options
      @shipper = options[:shipper]
      @access_request = access_request(user, password, license)
      @http = Http.new(@access_request, :test => @options[:test])

      @services = {
        "01" => "Next Day Air",
        "02" => "2nd Day Air",
        "03" => "Ground",
        "07" => "Express",
        "08" => "Expedited",
        "11" => "UPS Standard",
        "12" => "3 Day Select",
        "13" => "Next Day Air Saver",
        "14" => "Next Day Air Early AM",
        "54" => "Express Plus",
        "59" => "2nd Day Air A.M.",
        "65" => "UPS Saver",
        "82" => "UPS Today Standard",
        "83" => "UPS Today Dedicated Courier",
        "84" => "UPS Today Intercity",
        "85" => "UPS Today Express",
        "86" => "UPS Today Express Saver",
        "96" => "UPS Worldwide Express Freight"
      }
    end

    def request_shipment(packages, origin, destination, service, options={})
      saturday_delivery = options[:saturday_delivery]
      shipment_request = Nokogiri::XML::Builder.new do |xml|
        xml.ShipmentConfirmRequest {
          xml.Request {
            xml.RequestAction "ShipConfirm"
            xml.RequestOption "validate"
          }
          xml.LabelSpecification {
            xml.LabelPrintMethod {
              xml.Code "GIF"
              xml.Description "gif file"
            }
            xml.HTTPUserAgent "Mozilla/4.5"
            xml.LabelImageFormat {
              xml.Code "GIF"
              xml.Description "gif"
            }
          }
          xml.Shipment {
            @shipper.build(xml, "Shipper")
            destination.build(xml, "ShipTo")
            origin.build(xml, "ShipFrom")
            xml.PaymentInformation {
              xml.Prepaid {
                xml.BillShipper {
                  xml.AccountNumber @shipper.shipper_number
                }
              }
            }
            xml.Service {
              xml.Code service
              xml.Description @services[service]
            }
            if(saturday_delivery) 
              xml.ShipmentServiceOptions {
                xml.SaturdayDelivery
              }
            end
            packages.each do |package|
              package.build(xml)
            end
          }
        }
      end
      @http.commit("/ups.app/xml/ShipConfirm", shipment_request.to_xml)
    end

    def accept_shipment(digest)
      accept_request = Nokogiri::XML::Builder.new do |xml|
        xml.ShipmentAcceptRequest {
          xml.Request {
            xml.RequestAction "ShipAccept"
          }
          xml.ShipmentDigest digest
        }

      end
      @http.commit("/ups.app/xml/ShipAccept", accept_request.to_xml)

    end


    def track_shipment(tracking_number)
      track_request = Nokogiri::XML::Builder.new do
        TrackRequest {
          Request {
            RequestAction "Track"
            RequestOption "activity"
          }
          TrackingNumber tracking_number
        }
      end

      @http.commit("/ups.app/xml/Track", track_request.to_xml)
    end


    private
    def access_request(user, password, license)
      access_request = Nokogiri::XML::Builder.new do
        AccessRequest {
          AccessLicenseNumber license
          UserId user
          Password password
        }
      end

      access_request.to_xml
    end

  end
end