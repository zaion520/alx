local e=require"nixio.fs"
local t=require"luci.sys"
local o
m=Map("sdns",translate("Dns/Hosts"))
s=m:section(TypedSection,"sdns",translate("Set Dns"))
s.addremove = false
s.anonymous=true




o = s:option(Flag, "dns_enabled", translate("自定义DNS"))
o.rmempty = false
local dns = {
"223.5.5.5",
"223.6.6.6",
"114.114.114.114",
"114.114.115.115",
"1.2.4.8",
"210.2.4.8",
"112.124.47.27",
"114.215.126.16",
"180.76.76.76",
"119.29.29.29",
}

o=s:option(Value,"dns1",translate("DNS1"))
for _, v in ipairs(dns) do o:value(v) end
o.rmempty = fals
o=s:option(Value,"dns2",translate("DNS2"))
for _, v in ipairs(dns) do o:value(v) end
o.rmempty = fals

s=m:section(TypedSection,"sdns",translate("Set Hosts"))
s.anonymous=true
local t="/etc/hosts"
o=s:option(TextValue,"weblist")
--o.description=translate("These had been joined websites will use proxy,but only GFW model.Please input the domain names of websites,every line can input only one website domain.For example,google.com.")
o.rows=18
o.wrap="off"
o.cfgvalue=function(a,a)
return e.readfile(t)or""
end

o.write=function(o,o,a)
e.writefile(t,a:gsub("\r\n","\n"))
end




local apply = luci.http.formvalue("cbi.apply")
if apply then
     io.popen("/etc/init.d/sdns start")
end

return m
