start = os.clock()*1000

local redis = require "resty.redis"
local red = redis:new()
red:set_timeout(1000) -- 1 second
local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
    ngx.log(ngx.ERR, "failed to connect to redis: ", err)
return ngx.exit(500)
end

local res_count = 0
local res , err = red:keys("15min*")
table.sort(res)
for key,value in next,res,nil do
    local res_value , err = red:get(value)
    ngx.say(value, " : ", res_value)
    res_count = res_count + res_value
end
ngx.say("total link 15 minutes: ", table.getn(res), ", request count: ", res_count)

res_count = 0
local res , err = red:keys("6hour*")
table.sort(res)
for key,value in next,res,nil do
    local res_value , err = red:get(value)
    ngx.say(value, " : ", res_value)
    res_count = res_count + res_value
end
ngx.say("total link 6 hours: ", table.getn(res), ", request count: ", res_count)

res_count = 0
local res , err = red:keys("3day*")
table.sort(res)
for key,value in next,res,nil do
    local res_value , err = red:get(value)
    ngx.say(value, " : ", res_value)
    res_count = res_count + res_value
end
ngx.say("total link 3 days : ", table.getn(res), ", request count: ", res_count)

res_count = 0
local res , err = red:keys("total*")
table.sort(res)
for key,value in next,res,nil do
--                  ngx.say(key, " : ", value)
    local res_value , err = red:get(value)
    ngx.say(value, " : ", res_value)
    res_count = res_count + res_value
end
ngx.say("total link total: ", table.getn(res), ", request count: ", res_count)

ngx.say("time: ", os.clock()*1000 - start)

-- ngx.say("time: ", os.date("%Y%m%d%H%M"))
ngx.say("time: ", os.clock()*1000 - start, " msec")

