local reqtime = os.date("%Y%m%d%H%M")
local keyuri = ngx.var.uri
local keyserver = ngx.var.host
local key = keyserver .. keyuri
if not key then
    ngx.log(ngx.ERR, "no host and URI")
    return ngx.exit(400)
end

local redis = require "resty.redis"
local red = redis:new()
red:set_timeout(1000) -- 1 second
local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
    ngx.log(ngx.ERR, "failed to connect to redis: ", err)
    return ngx.exit(500)
end

-- insert host/uri statistic
local gethosturikey , err = red:get("total:" .. reqtime ..":" .. key)
--                  ngx.log(ngx.ERR , "redis key ", gethosturikey)
if gethosturikey == ngx.null then
--                  ngx.log(ngx.ERR , "redis key NULL !!!!")
--    local instmp , err = red:setex(key .. "_15min", 15*60, 1) -- for 15 mins
    local instmp , err = red:setex("15min:" .. reqtime ..":" .. key, 910, 1) -- for 15 mins 15*60+10
    if not instmp then
--                      ngx.log(ngx.ERR, "field to set redis key", err)
    return ngx.exit(400)
    end
    local instmp , err = red:setex("6hour:" .. reqtime ..":" .. key, 21610, 1) -- for 6 hours
    local instmp , err = red:setex("3day:" .. reqtime ..":" .. key, 259210, 1) -- for 3 days
    local instmp , err = red:set("total:" .. reqtime ..":" .. key, 1) -- total
else
--    local instmp , err = red:setex(key, 15*60, gethosturikeytmp) -- for 15 mins
    local instmp , err = red:incr("15min:" .. reqtime ..":" .. key) -- for 15 mins
    local instmp , err = red:expire("15min:" .. reqtime ..":" .. key, 910) -- incremental 1
    local instmp , err = red:incr("6hour:" .. reqtime ..":" .. key) -- for 6 hours
    local instmp , err = red:expire("6hour:" .. reqtime ..":" .. key, 21610) -- for 6 hours
    local instmp , err = red:incr("3day:" .. reqtime ..":" .. key) -- for 3 days
    local instmp , err = red:expire("3day:" .. reqtime ..":" .. key,259210) -- for 3 days
    local instmp , err = red:incr("total:" .. reqtime ..":" .. key) -- total
    if not instmp then
--      ngx.log(ngx.ERR, "field to set redis key", err)
        return ngx.exit(400)
    end
end

ngx.var.keyuri = key

-- coockie

cookie_key    = "YTBiYmU0NGRlMWU1NjUxNGI5MzllMWZiYTUyYTY5ODIgIHJlcS5sdWEK"
cookie_name = "UserID"
cookie_name_rnd = "SessionID"

local function gen_cookie_rand()
    return tostring(math.random(2147483647))
end

local function gen_cookie(prefix, rnd)
    return ngx.encode_base64(
    ngx.sha1_bin(ngx.today() .. prefix .. cookie_key .. rnd)
    )
end

local uri_cookie = ngx.var.request_uri -- req URI
local host_cookie = ngx.var.http_host -- server host
local ip_cookie = ngx.var.remote_addr -- client ip
local user_agent = ngx.var.http_user_agent or ""
if user_agent:len() > 0 then
    user_agent = ngx.encode_base64(ngx.sha1_bin(user_agent))
end
local key_prefix = ip_cookie .. ":" .. user_agent .. ":" .. uri_cookie .. ":" .. host_cookie .. ":".. cookie_key


local rnd = gen_cookie_rand()

-- check cookie
local ck = require "resty.cookie"
local cookie, err = ck:new()
if not cookie then
    ngx.log(ngx.ERR, err)
    return
end

-- get cookie_name
local cookie_name_value, err = cookie:get(cookie_name)
    if not cookie_name_value then
--        ngx.log(ngx.ERR, "Get cookie_name: ", cookie_name, " cookie: ", cookie_name_value, " error: ",  err)
--      return
    end
-- get cookie_name_rnd
local cookie_name_rnd_value, err = cookie:get(cookie_name_rnd)
    if not cookie_name_rnd_value then
--        ngx.log(ngx.ERR, "Get cookie_name: ", cookie_name_rnd, " cookie: ", cookie_name_rnd_value, " error: ",  err)
        cookie_name_rnd_value = gen_cookie_rand()
--      return
    else
--        ngx.log(ngx.ERR, "+ Get cookie_name: ", cookie_name_rnd, " cookie: ", cookie_name_rnd_value, " error: ",  err)
    end

local control_cookie = gen_cookie(key_prefix, cookie_name_rnd_value)
if cookie_name_value ~= control_cookie then
    cookie_name_value = ""
    cookie_name_rnd_value = gen_cookie_rand()
    control_cookie = gen_cookie(key_prefix, cookie_name_rnd_value)
end

-- set cookie_name  cookie
local ok, err = cookie:set({
    key = cookie_name,
    value = control_cookie,
    path = "/",
--      domain = host_cookie,
--      secure = true,
    httponly = true,
--    expires = "Wed, 09 Jun 2021 10:18:14 GMT"
    expires = ngx.cookie_time(ngx.time()+15*60),
--      max_age = 50,
--      extension = "a4334aebaec"
})
if not ok then
    ngx.log(ngx.ERR, err)
--  return
end

-- set cookie_name_rnd cookie
local ok, err = cookie:set({
    key = cookie_name_rnd,
    value = cookie_name_rnd_value,
    path = "/",
    httponly = true,
    expires = ngx.cookie_time(ngx.time()+15*60),
})
if not ok then
    ngx.log(ngx.ERR, err)
--      return
end

