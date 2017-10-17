# frozen_string_literal: true
$:.unshift __dir__
$:.unshift File.join(__dir__, "bcdice", "src")
$:.unshift File.join(__dir__, "lib")

require 'sinatra'
require 'sinatra/jsonp'
require 'bcdice_wrap'
require 'exception'
require 'hashids'

module BCDiceAPI
  VERSION = "0.5.1"
end


helpers do

  def logger
    return @logger unless @logger.nil?
    @logger = ::Logger.new($stdout) # こうしないとstrerrに吐いてしまう
  end

  def get_serial(increment=1)

    serial_path = ENV['bcdice.serial_path']
    serial = nil

    File.open(serial_path, File::RDWR|File::CREAT, 0644) do |f|
      f.flock(File::LOCK_EX)
      serial = f.read.to_i
      serial += increment
      f.rewind
      f.write(serial)
      f.flush
      f.truncate(f.pos)
    end

    return serial
  end

  def diceroll(system, command)

    if(system.nil?)
      system = 'DiceBot'
    end
    if(system.empty?)
      system = 'DiceBot'
    end

    dicebot = BCDice::DICEBOTS[system]
    if dicebot.nil?
      raise UnsupportedDicebot
    end
    if command.nil?
      raise CommandError
    end

    command = command.gsub(/[\s　]/, ' ')

    bcdice = BCDiceMaker.new.newBcDice
    bcdice.setDiceBot(dicebot)
    bcdice.setMessage(command)
    bcdice.setDir("bcdice/extratables",system)
    bcdice.setCollectRandResult(true)

    system = bcdice.getGameType()
    result, secret = bcdice.dice_command
    dices = bcdice.getRandResults.map {|dice| {faces: dice[1], value: dice[0]}}

    logger.info(sprintf('[%s] (%s) "%s" %s (%s) %s',request.ip,system,command,result.to_s,secret.to_s,dices.inspect))
  
    if result.nil?
      raise CommandError
    end

    return system, result, secret, dices
  end
end

get "/" do
  "Hello. This is BCDice-API."
end

get "/v1/version" do
  jsonp api: BCDiceAPI::VERSION, bcdice: BCDice::VERSION
end

get "/v1/systems" do
  jsonp systems: BCDice::SYSTEMS
end

get "/v1/systeminfo" do
  dicebot = BCDice::DICEBOTS[params[:system]]
  if dicebot.nil?
    raise UnsupportedDicebot
  end

  jsonp ok: true, systeminfo: dicebot.info
end

get "/v1/diceroll" do
  system, result, secret, dices = diceroll(params[:system], params[:command])

  jsonp ok: true, result: result, secret: secret, dices: dices, system: system
end

# 逐次結果を作るという意味ではPOSTで受けても良いのでは説
# POSTならcacheされないし
post "/v1/diceroll" do
  system, result, secret, dices = diceroll(params[:system], params[:command])

  jsonp ok: true, result: result, secret: secret, dices: dices, system: system
end

# 連番生成
post "/v1/serial" do
  result = {}
  result['server_id'] = ENV['bcdice.serverid'].to_i
  result['serial'] = get_serial()

  logger.info(sprintf('[%s] (serial) -> %d',request.ip,result['serial']))

  jsonp ok: true, result: result
end

# pidとtimestamp(to_f)でhashids生成
# 簡易的uniqidとしての用途
post "/v1/hashid" do
  salt     = ENV['bcdice.salt'] || 'hogehoge'
  serverid = ENV['bcdice.serverid'].to_i
  hashids = Hashids.new(salt)
  serial = get_serial()

  result = {}
  result['server_id'] = serverid
  result['serial'] = serial

  values = []
  values.push(serverid)
  values.push(serial + 10000)
  result['hashid'] = hashids.encode(values)

  logger.info(sprintf('[%s] (hashids) %s -> %s',request.ip,values.inspect,result))

  jsonp ok: true, result: result
end

get "/v1/onset" do
  if params[:list] == "1"
    return BCDice::SYSTEMS.join("\n")
  end

  begin
    system, result, secret, dices = diceroll(params[:sys] || "DiceBot", params[:text])
    "onset" + result
  rescue UnsupportedDicebot, CommandError
    "error"
  end
end

not_found do
  jsonp ok: false, reason: "not found"
end

error UnsupportedDicebot do
  status 400
  jsonp ok: false, reason: "unsupported dicebot"
end

error CommandError do
  status 400
  jsonp ok: false, reason: "unsupported command"
end

error do
  jsonp ok: false
end
