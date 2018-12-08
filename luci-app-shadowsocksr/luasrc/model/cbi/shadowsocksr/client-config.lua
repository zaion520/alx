-- Copyright (C) 2017 yushi By Alx
-- Licensed to the public under the GNU General Public License v3.


local m, s, o,kcp_enable
local shadowsocksr = "shadowsocksr"
local uci = luci.model.uci.cursor()
local ipkg = require("luci.model.ipkg")
local fs = require "nixio.fs"
local sys = require "luci.sys"
local sid = arg[1]

local function isKcptun(file)
	if not fs.access(file, "rwx", "rx", "rx") then
		fs.chmod(file, 755)
	end
	
	local str = sys.exec(file .. " -v | awk '{printf $1}'")
	return (str:lower() == "kcptun")
end


local server_table = {}

local encrypt_methods = {
"none",
"rc4-md5",
"rc4-md5-6",
"aes-128-cfb",
"aes-192-cfb",
"aes-256-cfb",
"aes-128-ctr",
"aes-192-ctr",
"aes-256-ctr",
"bf-cfb",
"camellia-128-cfb",
"camellia-192-cfb",
"camellia-256-cfb",
"cast5-cfb",
"des-cfb",
"idea-cfb",
"rc2-cfb",
"seed-cfb",
"salsa20",
"chacha20",
"chacha20-ietf",

}

local protocol = {
"origin",
"verify_simple",
"auth_sha1_v4",
"auth_aes128_sha1",
"auth_aes128_md5",
"auth_chain_a",
"auth_chain_b",
"auth_chain_c",
"auth_chain_d",
"auth_chain_e",
}

obfs = {
"plain",
"http_simple",
"http_post",
"tls1.2_ticket_auth",
}
local securitys = {
    "auto",
    "none",
    "aes-128-gcm",
    "chacha20-poly1305"
}
m = Map(shadowsocksr)
m.redirect = luci.dispatcher.build_url("admin/services/shadowsocksr/clientlist")
if m.uci:get(shadowsocksr, sid) == "servers" then

-- [[SS Servers Setting ]]--
s = m:section(NamedSection, sid, "servers")
s.anonymous = true
s.addremove   = false

o = s:option(ListValue, "server_type", translate("server type"))
o:value("SSR", translate("SSR"))
o.rmempty = false

--o = s:option(Value, "alias", translate("Alias(optional)"))

--o = s:option(Flag, "auth_enable", translate("Onetime Authentication"))
--o.rmempty = false

o = s:option(Flag, "switch_enable", translate("Auto Switch"))
o.rmempty = false

o = s:option(Value, "server", translate("Server Address"))
o.datatype = "host"
o.rmempty = false

o = s:option(Value, "server_port", translate("Server Port"))
o.datatype = "port"
o.rmempty = false

o = s:option(Value, "timeout", translate("Connection Timeout"))
o.datatype = "uinteger"
o.default = 60
o.rmempty = false

o = s:option(Value, "password", translate("Password"))
o.password = true
o.rmempty = false

o = s:option(ListValue, "encrypt_method", translate("Encrypt Method"))
for _, v in ipairs(encrypt_methods) do o:value(v) end
o.rmempty = false

o = s:option(ListValue, "protocol", translate("Protocol"))
for _, v in ipairs(protocol) do o:value(v) end
o.rmempty = false


o = s:option(ListValue, "obfs", translate("Obfs"))
for _, v in ipairs(obfs) do o:value(v) end
o.rmempty = false

o = s:option(Value, "obfs_param", translate("Obfs param(optional)"))

else


-- [[ V2ray Servers Setting ]]--

s = m:section(NamedSection, sid, "servers")
s.anonymous = true
s.addremove   = false

o = s:option(ListValue, "server_type", translate("server type"))
o:value("V2ray", translate("V2ray"))

o.rmempty = true

o = s:option(Value, "server", translate("Server Address"))
o.datatype = "host"
o.rmempty = false

o = s:option(Value, "server_port", translate("Server Port"))
o.datatype = "port"
o.rmempty = false

-- VmessId
o = s:option(Value, "vmess_id", translate("VmessId (UUID)"))
o.default = uuid
o.rmempty = false


-- AlterId
o = s:option(Value, "alter_id", translate("AlterId"))
o.datatype = "port"
o.default = 100
o.rmempty = true




-- 加密方式
o = s:option(ListValue, "security", translate("Encrypt Method"))
for _, v in ipairs(securitys) do o:value(v, v:upper()) end
o.rmempty = true


-- 传输协议
o = s:option(ListValue, "transport", translate("Transport"))
o:value("tcp", "TCP")
o:value("kcp", "mKCP")
o:value("ws", "WebSocket")
o:value("h2", "HTTP/2")
o.rmempty = true
-- [[ TCP部分 ]]--

-- TCP伪装
o = s:option(ListValue, "tcp_guise", translate("Camouflage Type"))
o:depends("transport", "tcp")
o:value("none", translate("None"))
o:value("http", "HTTP")
o.rmempty = true

-- HTTP域名
o = s:option(DynamicList, "http_host", translate("HTTP Host"))
o:depends("tcp_guise", "http")
o.rmempty = true

-- HTTP路径
o = s:option(DynamicList, "http_path", translate("HTTP Path"))
o:depends("tcp_guise", "http")
o.rmempty = true

-- [[ WS部分 ]]--

-- WS域名
o = s:option(Value, "ws_host", translate("WebSocket Host"))
o:depends("transport", "ws")
o.rmempty = true

-- WS路径
o = s:option(Value, "ws_path", translate("WebSocket Path"))
o:depends("transport", "ws")
o.rmempty = true

-- [[ H2部分 ]]--

-- H2域名
o = s:option(DynamicList, "h2_host", translate("HTTP/2 Host"))
o:depends("transport", "h2")
o.rmempty = true

-- H2路径
o = s:option(Value, "h2_path", translate("HTTP/2 Path"))
o:depends("transport", "h2")
o.rmempty = true

-- [[ mKCP部分 ]]--

o = s:option(ListValue, "kcp_guise", translate("Camouflage Type"))
o:depends("transport", "kcp")
o:value("none", translate("None"))
o:value("srtp", translate("VideoCall (SRTP)"))
o:value("utp", translate("BitTorrent (uTP)"))
o:value("wechat-video", translate("WechatVideo"))
o:value("dtls", "DTLS 1.2")
o:value("wireguard", "WireGuard")
o.rmempty = true


o = s:option(Flag, "congestion", translate("Congestion"))
o:depends("transport", "kcp")
o.rmempty = true

-- [[ allowInsecure ]]--
o = s:option(Flag, "insecure", translate("allowInsecure"))
o.rmempty = true


-- [[ TLS ]]--
o = s:option(Flag, "tls", translate("TLS"))
o.rmempty = true
o.default = "0"


-- [[ Mux ]]--
o = s:option(Flag, "mux", translate("Mux"))
o.rmempty = true
o.default = "0"




end


return m


