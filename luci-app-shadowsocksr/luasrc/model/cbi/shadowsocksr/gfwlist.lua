-- Copyright (C) 2017 yushi By Alx
-- Licensed to the public under the GNU General Public License v3.


local IPK_Version="1.2.1"
local m, s, o
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

if nixio.fs.access("/etc/dnsmasq.d/gfwlist.conf") then
	gfwmode=1
end

local shadowsocksr = "shadowsocksr"
-- html constants
font_blue = [[<font color="blue">]]
font_off = [[</font>]]
bold_on  = [[<strong>]]
bold_off = [[</strong>]]

local fs = require "nixio.fs"
local sys = require "luci.sys"
local kcptun_version=translate("Unknown")
local kcp_file="/usr/bin/ssr-kcptun"
if not fs.access(kcp_file)  then
	kcptun_version=translate("Not exist")
else
	if not fs.access(kcp_file, "rwx", "rx", "rx") then
		fs.chmod(kcp_file, 755)
	end
	kcptun_version=sys.exec(kcp_file .. " -v | awk '{printf $3}'")
	if not kcptun_version or kcptun_version == "" then
		kcptun_version = translate("Unknown")
	end
	
end

if gfwmode==1 then
	gfw_count = tonumber(sys.exec("cat /etc/dnsmasq.d/gfwlist.conf | wc -l"))/2
	if nixio.fs.access("/etc/dnsmasq.ssr/ad.conf") then
		ad_count=tonumber(sys.exec("cat /etc/dnsmasq.d/ad.conf | wc -l"))
	end
end

if nixio.fs.access("/etc/gfwlist/cdnlist") then
	ip_count = sys.exec("cat /etc/gfwlist/cdnlist | wc -l")
end

local icount=sys.exec("ps -w | grep ssr-reudp |grep -v grep| wc -l")
if tonumber(icount)>0 then
	reudp_run=1
else
	icount=sys.exec("ps -w | grep ssr-retcp |grep \"\\-u\"|grep -v grep| wc -l")
	if tonumber(icount)>0 then
		reudp_run=1
	end
end




m = Map("shadowsocksr")
s=m:section(TypedSection,"global",translate("Rule status"))
s.anonymous=true

if gfwmode==1 then
	o=s:option(DummyValue,"gfw_data",translate("GFW名单"))
	o.rawhtml  = true
	o.value =tostring(math.ceil(gfw_count)) .. " " .. translate("Records")
	
	
end

o=s:option(DummyValue,"ip_data",translate("大陆白名单"))
o.rawhtml  = true
o.value =ip_count .. " " .. translate("Records")




s=m:section(TypedSection,"global",translate("Auto Update"))
s.anonymous=true
o=s:option(Flag,"auto_update",translate("Enable auto update rules"))
o.default=0
o.rmempty=false
o=s:option(ListValue,"week_update",translate("Week update rules"))
o:value(7,translate("每天"))
for e=1,6 do
	o:value(e,translate("周"..e))
end
o:value(0,translate("周日"))
o.default=0
o.rmempty=false
o=s:option(ListValue,"time_update",translate("Day update rules"))
for e=0,23 do
	o:value(e,translate(e.."点"))
end
o.default=0
o.rmempty=false



return m
