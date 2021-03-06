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

  def mview
    redirect_to "http://192.168.0.7:3000/welcome/index", :status => 301 
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

    # response.headers["status"] = 301
    to_url = "#{@@config1['server']}welcome/result?udid=#{device_info['UDID']}&portalid=#{request.params[:portalid]}"
    redirect_to to_url, :status => 301 
  end

  def result
    logger.debug('in result')
    logger.debug(request.params)
    response.headers["status"] = 200
    response.headers["Content-Type"] = "text/html; charset=UTF-8"
    logger.debug("success register, your udid is:#{request.params[:udid]}, and your portalid is:#{request.params[:portalid]}")

    render plain: <<~resultbody
      <html>
        <head>
          <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
          <meta http-equiv="content-type" content="text/html;charset=utf-8">
        </head>
        <body>
          <h3>下载APP</h3>
          <h5>UDID: #{request.params[:udid]}</h5>
          <h5>portalid: #{request.params[:portalid]}</h5>
          <p>
            <a href="itms-services://?action=download-manifest&url=https://www.maganda.space/ios-apps/ios-sign-1.0.1/testsign.plist">点击安装APP</a>
          </p>
        </body>
      </html>
    resultbody
  end

  def appid
    logger.debug('create appid')

    # 登录
    Spaceship::Portal.login('anhui3713@vip.qq.com', 'Admin123$%^')

    # 创建APP id
    # randomid = rand(1000000000..9999999999)
    # app = Spaceship.app.create!(bundle_id: "com.iossign.#{randomid}", name: "Portal-#{randomid}")
    # logger.debug("app: #{app}")

    app = Spaceship::Portal.app.find("com.iossign.2978722036")

    # 获取开发证书
    certs = Spaceship::Portal.certificate.production.all
    logger.debug("certs: #{certs}")

    firstCert = certs.first
    logger.debug("first cert: #{firstCert}")

    profile = Spaceship::Portal.provisioning_profile.ad_hoc.create!(
      bundle_id: app.bundle_id,
      certificate: firstCert,
      name: "adhoc #{app.bundle_id}"
    )

    File.write("/home/hank/fastlane-ruby-test/public/buildspace/profiles/adhoc_#{app.bundle_id}.mobileprovision", profile.download)

    response.headers["status"] = 200  
    render plain: <<~appidresult
      app: #{app}

      certs: #{certs}

      first cert: #{firstCert}

      profile name: #{profile.name}
      profile: #{profile}
    appidresult
  end
end
