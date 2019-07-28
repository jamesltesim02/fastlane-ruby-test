require "spaceship"

@@config1 = {
  "server" => "https://www.maganda.space/"
}

class WelcomeController < ApplicationController
  protect_from_forgery :except => :index
  skip_before_action :verify_authenticity_token
  def index
    logger.debug('in index')
    render plain: "plain text#{@@config1['server']}"
  end

  def udid
    logger.debug('in udid')
    logger.debug(request)
    response.headers["Content-Type"] = "application/x-apple-aspen-config; charset=UTF-8"
    render plain: <<~mobileconfig
      <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
          <dict>
            <key>PayloadContent</key>
            <dict>
            <key>URL</key>
            <string>#{@@config1['server']}welcome/receive?portalid=#{request.params[:portalid]}</string>
            <key>DeviceAttributes</key>
            <array>
              <string>UDID</string>
              <string>IMEI</string>
              <string>ICCID</string>
              <string>VERSION</string>
              <string>PRODUCT</string>
            </array>
            </dict>
            <key>PayloadOrganization</key>
            <string>#{@@config1['server']}</string>
            <key>PayloadDisplayName</key>
            <string>查询设备UDID</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
            <key>PayloadUUID</key>
            <string>3C4DC7D2-E475-3375-489C-0BB8D737A653</string>
            <key>PayloadIdentifier</key>
            <string>dev.skyfox.profile-service</string>
            <key>PayloadDescription</key>
            <string>本文件仅用来获取设备ID</string>
            <key>PayloadType</key>
            <string>Profile Service</string>
          </dict>
        </plist>
    mobileconfig
  end

  def receive
    logger.debug('in receive')
    logger.debug(request)
    udid_content = request.body.read
    dict_content = udid_content.gsub(/.*<dict>|<\/dict>.*|[\n\t]/m, "")
    dict_content = dict_content.gsub(/<(key|string)>/m, "")

    bkvs = dict_content.split(/<\/string>\s*/m)
    device_info = Hash.new
    bkvs.each do |e|
      kv = e.split(/<\/key>\s*/)
      device_info[kv[0]] = kv[1]
    end

    logger.debug("udid:#{device_info['UDID']}, name:#{device_info['UDID']}, poralid:#{request.params[:portalid]}")
    Spaceship.login('anhui3713@vip.qq.com', 'Admin123$%^')
    Spaceship.device.create!(name: device_info['UDID'], udid: device_info['UDID'])

    response.headers["status"] = 301
    redirect_to "#{@@config1['server']}welcome/result?udid=#{device_info['UDID']}&portalid=#{request.params[:portalid]}"
  end

  def result
    logger.debug('in result')
    logger.debug(request.params)
    response.headers["status"] = 200
    response.headers["Content-Type"] = "text/html; charset=UTF-8"
    logger.debug("success register, your udid is:#{request.params[:udid]}, and your portalid is:#{request.params[:portalid]}")
    render plain: "success register, your udid is:#{request.params[:udid]}, and your portalid is:#{request.params[:portalid]}"
  end
end
