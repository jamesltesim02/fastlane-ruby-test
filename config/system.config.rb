# systemconfig = Hash.new

# systemconfig['server'] = "http://www.maganda.com/"
# systemconfig['server'] = "http://192.168.12.159:3000/"

class Configs
  @@defaultValue = Hash[
    "server" => "http://192.168.12.159:3000/"
  ]
end
