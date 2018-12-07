module("luci.controller.dnspod",package.seeall)
function index()
entry({"admin","services","dnspod"},cbi("dnspod"),_("Dnspod 客户端"),101)
end
