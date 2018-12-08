-- Copyright (C) 2017 yushi By Alx
-- Licensed to the public under the GNU General Public License v3.

local m, s,sec, o,kcp_enable
local shadowsocksr = "shadowsocksr"
local uci = luci.model.uci.cursor()
local ipkg = require("luci.model.ipkg")
local sys = require "luci.sys"
local gfwmode=0
local pdnsd_flag=0
local Pcap_Dns = 0
local dns2socks = 0
local dnsproxy=0
local dp=0
local ssr_t = 0
if nixio.fs.access("/usr/bin/ssr-tunnel") then
	ssr_t =1
end
if nixio.fs.access("/usr/bin/dns2socks") then
	dns2sockss=1
end
if nixio.fs.access("/usr/bin/dnsproxy") then
	dnsproxy=1
end
if nixio.fs.access("/etc/config/pcap-dnsproxy") then
	Pcap_Dns=1
end
if nixio.fs.access("/etc/dnsmasq.d/gfwlist.conf") then
	gfwmode=1
end
if nixio.fs.access("/etc/pdnsd.conf") then
	pdnsd_flag=1
end
if luci.sys.call("pidof ssr-redir >/dev/null") == 0 then
	redir_run=1
end


if luci.sys.call("pidof ssr-redir >/dev/null") == 0 then
	status = translate("<strong><font color=\"green\">ShadowSocksR is Running</font></strong>")
else
	status = translate("<strong><font color=\"red\">ShadowSocksR is Not Running</font></strong>")
end
if luci.sys.call("pidof v2ray >/dev/null") == 0 then
	status = translate("<strong><font color=\"green\">v2ray is Running</font></strong>")
else
	status = translate("<strong><font color=\"red\">v2ray is Not Running</font></strong>")
end

m = Map(shadowsocksr, translate("ShadowSocksR"))
m.description = translate(string.format("%s<br /><br />", status))
--m.redirect = luci.dispatcher.build_url("admin/services/shadowsocksr/status")
local server_table = {}
local server2_table = {}
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


uci:foreach(shadowsocksr, "servers", function (s)
	if  s.server then
		server_table[s[".name"]] = "%s:%s" %{s.server, s.server_port}
	end
end)

uci:foreach(shadowsocksr, "servers_v2", function (s)
	if  s.server then
		server2_table[s[".name"]] = "%s:%s" %{s.server, s.server_port}
	end
end)



-- [[ Global Setting ]]--






--s = m:section(TypedSection, "global", translate("Global Setting"))
--s.anonymous = true
s = m:section(TypedSection, "global")
s.anonymous = true
o = s:option(Flag, "enable", translate("启用"))
o.rmempty = true
o = s:option(ListValue, "server_type", translate("服务器类型"))
o:value("V2RAY", translate("V2RAY"))
o:value("SSR", translate("SSR"))
o = s:option(ListValue, "global_server", translate("SSR服务器"))
for k, v in pairs(server_table) do o:value(k, v) end
o:depends("server_type", "SSR")
o = s:option(ListValue, "global_server_v2", translate("V2RAY服务器"))
for k, v in pairs(server2_table) do o:value(k, v) end
o:depends("server_type", "V2RAY")
o = s:option(ListValue, "udp_relay_server", translate("UDP游戏服务器"))
o:value("", translate("Disable"))
o:value("same", translate("Same as Global Server"))
for k, v in pairs(server_table) do o:value(k, v) end
o:depends("server_type", "SSR")
o = s:option(ListValue, "gfw_enable", translate("Operating mode"))
o:value("router", translate("大陆IP模式"))
o:value("gfw", translate("GFWList模式"))
o:value("global", translate("全局模式"))
o:value("gm", translate("游戏模式"))
o.rmempty = false
o = s:option(ListValue, "dns_enable", translate("Resolve Dns Mode"))
if ssr_t ==1  then
o:value("0", translate("ssr_tunnel"))
end
if pdnsd_flag==1  then
o:value("1", translate("pdnsd"))
end
if  Pcap_Dns == 1 then
o:value("2", translate("pcap_Dnsproxy"))
end
if  dns2sockss == 1 then
o:value("3", translate("dns2socks"))
end
if dnsproxy == 1 then
o:value("4", translate("dnsproxy"))	
end
o.rmempty = false
o = s:option(ListValue, "tunnel_forward", translate("DNS Server IP and Port"))
o:value("8.8.8.8:53")
o:value("8.8.4.4:53")
o:value("208.67.220.220:443")
o:value("208.67.222.222:5353")
o.rmempty = false

return m


