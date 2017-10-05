-- Copyright (C) 2017 yushi By Alx
-- Licensed to the public under the GNU General Public License v3.

local o=require"luci.dispatcher"
local n=require("luci.model.ipkg")
local s=luci.model.uci.cursor()
local e=require"nixio.fs"
local e=require"luci.sys"
local i="shadowsocksr"
local a,t,e,m
local kcp_file="/usr/bin/ssr-kcptun"
local redir_run=0
local reudp_run=0
local sock5_run=0
local server_run=0
local kcptun_run=0
local tunnel_run=0
local gfw_count=0
local ad_count=0
local ip_count=0
local gfwmode=0
local dns2=0
local pcap=0
local pdnsd=0
local dnsproxy=0

local shadowsocksr = "shadowsocksr"
-- html constants
font_blue = [[<font color="blue">]]
font_red= [[<font color="red">]]
font_green= [[<font color="green">]]
font_off = [[</font>]]
bold_on  = [[<strong>]]
bold_off = [[</strong>]]
if not nixio.fs.access("/usr/bin/ip") then
	luci.sys.call("ln -s /sbin/ip-full /usr/bin/ip")
end
local fs = require "nixio.fs"
local sys = require "luci.sys"


local icount=sys.exec("ps -w | grep ssr-reudp |grep -v grep| wc -l")
if tonumber(icount)>0 then
	reudp_run=1
else
	icount=sys.exec("ps -w | grep ssr-retcp |grep \"\\-u\"|grep -v grep| wc -l")
	if tonumber(icount)>0 then
		reudp_run=1
	end
end


if luci.sys.call("pidof ssr-redir >/dev/null") == 0 then
	redir_run=1
end

if luci.sys.call("pidof ssr-local >/dev/null") == 0 then
	sock5_run=1
end

if luci.sys.call("pidof ssr-kcptun >/dev/null") == 0 then
	kcptun_run=1
end

if luci.sys.call("pidof ssr-server >/dev/null") == 0 then
	server_run=1
end

if luci.sys.call("pidof ssr-tunnel >/dev/null") == 0 then
	tunnel_run=1
end

if luci.sys.call("pidof pdnsd >/dev/null") == 0 then
	pdnsd=1
end

if luci.sys.call("pidof dns2socks >/dev/null") == 0 then
	dns2=1
end

if luci.sys.call("pidof dnsproxy >/dev/null") == 0 then
	dnsproxy=1
end

if luci.sys.call("pidof Pcap_DNSProxy >/dev/null") == 0 then
	pcap=1
end


function is_installed(e)
	return n.installed(e)
end
local n={}
s:foreach(i,"servers", function (e)
	if e.server and e.remarks then
		n[e[".name"]]="%s:%s"%{e.remarks,e.server}
	end
end)




a=Map("shadowsocksr")
a.template="shadowsocksr/index"
t=a:section(TypedSection,"global",translate("Running Status"))
t.anonymous=true

m=t:option(DummyValue,"redir_run",translate("透明代理"))
m.rawhtml  = true
if redir_run == 1 then
	m.value =font_blue  .. translate("Running") ..  font_off
else
	m.value = translate("Not Running")
end


if reudp_run == 1 then
	m=t:option(DummyValue,"reudp_run",translate("UDP Relay"))
	m.rawhtml  = true
	m.value =font_blue  .. translate("Running")  .. font_off
end
if sock5_run == 1 then
	m=t:option(DummyValue,"sock5_run",translate("SOCKS5 Proxy"))
	m.rawhtml  = true
	
	m.value =font_blue  .. translate("Running")  .. font_off
	
end

m=t:option(DummyValue,"tunnel_run",translate("DNS模式"))
m.rawhtml  = true

m.value =translate("Not Running")
if tunnel_run == 1 then
	m.value =font_blue ..  translate("ssr-tunnel") ..  font_off
end

if pdnsd == 1 then
	m.value =font_blue ..  translate("pdnsd") ..  font_off
end

if dns2 == 1 then
	m.value =font_blue ..  translate("dns2socks") ..  font_off
end

if pcap == 1 then
	m.value =font_blue ..  translate("Pcap_DNSProxy") ..  font_off
end
if dnsproxy == 1 then
	m.value =font_blue ..  translate("dnsproxy ") ..  font_off
end

if kcptun_run == 1 then
	m=t:option(DummyValue,"kcptun_run",translate("KcpTun"))
	m.rawhtml  = true
	m.value = translate("Not Running")
end


e=t:option(DummyValue,"china_china",translate("China Connection"))
e.template="shadowsocksr/china"
e.value=translate("......")
e=t:option(DummyValue,"foreign_foreign",translate("Foreign Connection"))
e.template="shadowsocksr/foreign"
e.value=translate("......")
return a

