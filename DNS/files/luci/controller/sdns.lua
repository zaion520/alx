module("luci.controller.sdns",package.seeall)
function index()
if not nixio.fs.access("/etc/config/sdns")then
return
end

entry({"admin","system","sdns"},cbi("sdns"),_("DNS 设置"),71).leaf = true



end
