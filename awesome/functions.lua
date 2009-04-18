---{{{ Functions

  --Marup functions
  --- {{{ splitbywhitespace stolen from wicked.lua
    function splitbywhitespace(str)
    values = {}
    start = 1
    splitstart, splitend = string.find(str, ' ', start)

    while splitstart do
      m = string.sub(str, start, splitstart-1)
      if m:gsub(' ','') ~= '' then
        table.insert(values, m)
      end

      start = splitend+1
      splitstart, splitend = string.find(str, ' ', start)
    end

    m = string.sub(str, start)
    if m:gsub(' ','') ~= '' then
      table.insert(values, m)
    end

    return values
  end
---}}}
spacer = ' '
function setBg(color, text)
return '<bg color="'..color..'" />'..text
end

function setFg(color, text)
return '<span color="'..color..'">'..text..'</span>'
end

function setBgFg(bgcolor, fgcolor, text)
return '<bg color="'..bgcolor..'" /><span color="'..fgcolor..'">'..text..'</span>'
end

function setFont(font, text)
return '<span font_desc="'..font..'">'..text..'</span>'
end

---- Layouttext function
function returnLayoutText(layout)
return setFg(beautiful.fg_focus, " | ")..layoutText[layout]..setFg(beautiful.fg_focus, " | ")
end

---- Widget functions
-- Clock
function clockInfo(dateformat, timeformat)
local date = os.date(dateformat)
local time = os.date(timeformat)

clockwidget.text = spacer..date..spacer..setFg(beautiful.fg_focus, time)..spacer
end

-- Wifi signal strength
function wifiInfo(adapter)
local f = io.open("/sys/class/net/"..adapter.."/wireless/link")
local wifiStrength = f:read()
f:close()

if wifiStrength == "0" then
wifiStrength = setFg("#ff6565", wifiStrength.."%")
naughty.notify({ title = "Wifi Warning"
, text = "Wireless Network is Down! ("..wifiStrength.."% connectivity)"
, timeout = 3
, position = "top_right"
, fg = beautiful.fg_focus
, bg = beautiful.bg_focus
})
else
wifiStrength = wifiStrength.."%"
end

wifiwidget.text = spacer..setFg(beautiful.fg_focus, "Wifi:")..spacer..wifiStrength..spacer
end

-- Battery(BAT1)
function batteryInfo(adapter)
local fcur = io.open("/sys/class/power_supply/"..adapter.."/charge_now")
local fcap = io.open("/sys/class/power_supply/"..adapter.."/charge_full")
local fsta = io.open("/sys/class/power_supply/"..adapter.."/status")
local cur = fcur:read()
fcur:close()
local cap = fcap:read()
fcap:close()
local sta = fsta:read()
fsta:close()

local battery = math.floor(cur * 100 / cap)

if sta:match("Charging") then
dir = "^"
battery = "A/C"..spacer.."("..battery..")"
elseif sta:match("Discharging") then
dir = "v"
if tonumber(battery) >= 25 and tonumber(battery) <= 50 then
battery = setFg("#e6d51d", battery)
elseif tonumber(battery) < 25 then
if tonumber(battery) <= 10 then
naughty.notify({ title = "Battery Warning"
, text = "Battery low!"..spacer..battery.."%"..spacer.."left!"
, timeout = 5
, position = "top_right"
, fg = beautiful.fg_focus
, bg = beautiful.bg_focus
})
end
battery = setFg("#ff6565", battery)
else
battery = battery
end
else
dir = "="
battery = "A/C"
end

batterywidget.text = spacer..setFg(beautiful.fg_focus, "Bat:")..spacer..dir..battery..dir..spacer
end

-- Memory
function memInfo()
local f = io.open("/proc/meminfo")

for line in f:lines() do
if line:match("^MemTotal.*") then
memTotal = math.floor(tonumber(line:match("(%d+)")) / 1024)
elseif line:match("^MemFree.*") then
memFree = math.floor(tonumber(line:match("(%d+)")) / 1024)
elseif line:match("^Buffers.*") then
memBuffers = math.floor(tonumber(line:match("(%d+)")) / 1024)
elseif line:match("^Cached.*") then
memCached = math.floor(tonumber(line:match("(%d+)")) / 1024)
end
end
f:close()

memFree = memFree + memBuffers + memCached
memInUse = memTotal - memFree
memUsePct = math.floor(memInUse / memTotal * 100)

memwidget.text = spacer..setFg(beautiful.fg_focus, "Mem:")..spacer..memUsePct.."%"..spacer.."("..memInUse.."M)"..spacer
end

-- CPU usage
cpu0_total = 0
cpu0_active = 0
cpu1_total = 0
cpu1_active = 0

function cpuInfo()
-- Return CPU usage percentage
-- Get /proc/stat\
local f = io.open('/proc/stat')
for l in f:lines() do
cpu_usage = splitbywhitespace(l)
if cpu_usage[1] == "cpu0" then
---- Calculate totals
total_new = cpu_usage[2]+cpu_usage[3]+cpu_usage[4]+cpu_usage[5]
active_new = cpu_usage[2]+cpu_usage[3]+cpu_usage[4]
---- Calculate percentage
diff_total = total_new-cpu0_total
diff_active = active_new-cpu0_active
usage_percent = math.floor(diff_active/diff_total*100)
-- Store totals
cpu0_total = total_new
cpu0_active = active_new

cpu0graphwidget:plot_data_add("cpu",usage_percent)
elseif cpu_usage[1] == "cpu1" then
-- Caculate totals
total_new = cpu_usage[2]+cpu_usage[3]+cpu_usage[4]+cpu_usage[5]
active_new = cpu_usage[2]+cpu_usage[3]+cpu_usage[4]
---- Calculate percentage
diff_total = total_new-cpu1_total
diff_active = active_new-cpu1_active
usage_percent = math.floor(diff_active/diff_total*100)
---- Store totals
cpu1_total = total_new
cpu1_active = active_new

cpu1graphwidget:plot_data_add("cpu",usage_percent)

end

end
f:close()
end

---}}}
