-- Standard awesome library
require("awful")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Mpd library
require("lib/mpd")

-- {{{ Load functions
--
loadfile(awful.util.getdir("config").."/functions.lua")()
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
-- The default is a dark theme
theme_path = "/home/isaiah/.config/awesome/themes/default/theme.lua"
-- Uncommment this for a lighter theme
-- theme_path = "/usr/share/awesome/themes/sky/theme"

-- Actually load theme
beautiful.init(theme_path)

-- This is used later as the default terminal and editor to run.
-- terminal = "xterm"
terminal = "urxvt"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
alt    = "Mod1"
control= "Control"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}

-- Table of clients that should be set floating. The index may be either
-- the application class or instance. The instance is useful when running
-- a console app in a terminal like (Music on Console)
--    xterm -name mocp -e mocp
floatapps =
{
    -- by class
    ["MPlayer"] = true,
    ["pinentry"] = true,
    ["gimp"] = true,
    -- by instance
    ["mocp"] = true
}

-- Applications to be moved to a pre-defined tag by class or instance.
-- Use the screen and tags indices.
apptags =
{
    ["Shiretoko"] = { screen = 1, tag = 2 },
    ["Pidgin"] = { screen = 1, tag = 4 },
    ["Stardict"] = { screen = 1, tag = 5}
    -- ["mocp"] = { screen = 2, tag = 4 },
}

-- Define if we want to use titlebar on all applications.
use_titlebar = false
-- Define if we want to use naughty notifications
use_naughty = true
-- }}}

-- {{{ Tags
-- Define tags table.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = {}
    -- Create 9 tags per screen.
    tags[s][1] = tag( "1:W" )
    tags[s][2] = tag( "2:FF" )
    tags[s][3] = tag( "3:R" )
    tags[s][4] = tag( "4:IM" )
    tags[s][5] = tag( "5:D" )
    for tagnumber = 1, 5 do
	tags[s][tagnumber].screen = s
    end
    for tagnumber = 6, 9 do
        tags[s][tagnumber] = tag(tagnumber)
        -- Add tags to screen one by one
        tags[s][tagnumber].screen = s
        awful.layout.set(layouts[1], tags[s][tagnumber])
    end
    awful.layout.set(layouts[7], tags[s][1])
    for tagnumber = 2, 9 do
	    awful.layout.set(layouts[1], tags[s][tagnumber])
    end
    -- I'm sure you want to see at least one tag.
    tags[s][1].selected = true
end
-- }}}

-- {{{ Widgets
function hook_mpd()
    mpdwidget.text = widget_mpd()
end
function bold(text)
	return '<b>' .. text .. '</b>'
end
-- Set foreground color
function fg(color, text)
	return "<span color='" .. color .. "'>" .. text .. "</span>"
end
-- Widget base
-- [content]
function widget_base(content)
	if content and content ~= "" then
		return fg(beautiful.hilight, " [ ") .. content .. fg(beautiful.hilight, " ] ")
	end
end

-- Widget section
-- <b>label:</b> content (| next_section)?
function widget_section(label, content, next_section)
	local section
	if content and content ~= nil then
		if label and label ~= "" then
			section = bold(label .. ": ") .. content
		else
			section = content
		end
		if next_section and next_section ~= "" then
			section = section .. fg(beautiful.hilight, " | ") .. next_section
		end
	else
		section = next_section
	end
	return section
end

-- Widget value
-- content (/ next_value)?
function widget_value(content, next_value)
	local value
	if content and content ~= nil then
		value = content
		if next_value and next_value ~= "" then
			value = value .. fg(beautiful.hilight, " / ") .. next_value
		end
	else
		value = next_value
	end
	return value
end
-- Get and format MPD status
-- (need the mpd lib for lua
last_songid = nil
mpd.scroll = 0
function widget_mpd()
	local function timeformat(t)
		if tonumber(t) >= 60 * 60 then -- more than one hour !
			return os.date("%X", t)
		else
			return os.date("%M:%S", t)
		end
	end
	
	local function unknowize(x)
		return awful.util.escape(x or "(unknow)")
	end

	local now_playing, status, total_time, current_time
	local stats = mpd.send("status")

	if not stats.state then
		return widget_base(widget_section("MPD", "not launched?"))
	end

	if stats.state == "stop" then
		last_songid = false
		return widget_base(widget_section("MPD", "stopped."))
	end

	local zstats = mpd.send("playlistid " .. stats.songid)
	-- now_playing = string.format("%s - %s - %s", unknowize(zstats.artist), unknowize(zstats.album), unknowize(zstats.title))
	now_playing = string.format("%s - %s", unknowize(zstats.artist), unknowize(zstats.title))

	if stats.state ~= "play" then
		now_playing = now_playing .. " (" .. stats.state .. ")"
	end

	current_time = timeformat(stats.time:match("(%d+):"))
	total_time   = timeformat(stats.time:match("%d+:(%d+)"))

	if use_naughty then
		if not last_songid or last_songid ~= stats.songid then
			last_songid = stats.songid
			naughty.notify {
				text = string.format("%s: %s\n%s:  %s\n%s: %s",
				bold("artist"), unknowize(zstats.artist),
				bold("album"), unknowize(zstats.album),
				bold("title"), unknowize(zstats.title)),
				width = 280,
				timeout = 3
			}
		end
	end
	return widget_base(widget_section("playing", now_playing, widget_section("Time", widget_value(current_time, total_time), widget_section("Vol", stats.volume))))
end

-- Create MPD widget
mpdwidget = widget { type = "textbox", align = "right" }
-- Create separator icon
separator = widget({ type = "imagebox", name = "separator", align = "right" })
separator.image = image(awful.util.getdir("config").."/icons/separators/link2.png")
-- Create the memory widget
memwidget = widget({ type = "textbox", name = "memwidget", align = "right"})
memInfo()
-- Create the WIFI widget
wifiwidget = widget({ type = "textbox", name = "wifiwidget", align = "right" })
wifiInfo("wlan0");
-- Create battery widget
batterywidget = widget({ type = "textbox", name = "batterywidget", align = "right" })
batteryInfo("BAT0");
-- Create CPU widget
cpu0graphwidget = widget({ type = 'graph', name = 'cpu0graphwidget', align = 'right' })
cpu0graphwidget.height = 1
cpu0graphwidget.width = 100
cpu0graphwidget.bg = beautiful.bg_normal
cpu0graphwidget.border_color = beautiful.fg_urgent
cpu0graphwidget.grow = 'left'
 
cpu0graphwidget:plot_properties_set('cpu', {
	fg = beautiful.bg_urgent,
	style ='line',
	fg_center = 'green',
	fg_end = 'cyan',
	vertical_gradient = false
})
cpu1graphwidget = widget({ type = 'graph', name = 'cpu1graphwidget', align = 'right' })
cpu1graphwidget.height = 1
cpu1graphwidget.width = 100
cpu1graphwidget.bg = beautiful.bg_normal
cpu1graphwidget.border_color = beautiful.fg_urgent
cpu1graphwidget.grow = 'left'
 
cpu1graphwidget:plot_properties_set('cpu', {
	fg = beautiful.bg_urgent,
	style ='line',
	fg_center = 'green',
	fg_end = 'cyan',
	vertical_gradient = false
})
cpuInfo()
-- Create a textbox widget
mytextbox = widget({ type = "textbox", align = "right" })
-- Set the default text in textbox
mytextbox.text = "<b><small> " .. awesome.release .. " </small></b>"

-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu.new({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                        { "open terminal", terminal }
                                      }
                            })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })

-- Create a systray
mysystray = widget({ type = "systray", align = "right" })
-- }}}

-- {{{ Wibox
-- Create a wibox for each screen and add it
mywibox = {}
mystatusbar = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = { button({ }, 1, awful.tag.viewonly),
                      button({ modkey }, 1, awful.client.movetotag),
                      button({ }, 3, function (tag) tag.selected = not tag.selected end),
                      button({ modkey }, 3, awful.client.toggletag),
                      button({ }, 4, awful.tag.viewnext),
                      button({ }, 5, awful.tag.viewprev) }
mytasklist = {}
mytasklist.buttons = { button({ }, 1, function (c)
                                          if not c:isvisible() then
                                              awful.tag.viewonly(c:tags()[1])
                                          end
                                          client.focus = c
                                          c:raise()
                                      end),
                       button({ }, 3, function () if instance then instance:hide() end instance = awful.menu.clients({ width=250 }) end),
                       button({ }, 4, function ()
                                          awful.client.focus.byidx(1)
                                          if client.focus then client.focus:raise() end
                                      end),
                       button({ }, 5, function ()
                                          awful.client.focus.byidx(-1)
                                          if client.focus then client.focus:raise() end
                                      end) }

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ align = "left" })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = widget({ type = "imagebox", align = "right" })
    mylayoutbox[s]:buttons({ button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                             button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                             button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                             button({ }, 5, function () awful.layout.inc(layouts, -1) end) })
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist.new(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist.new(function(c)
                                                  return awful.widget.tasklist.label.currenttags(c, s)
                                              end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = wibox({ position = "top", fg = beautiful.fg_normal, bg = beautiful.bg_normal })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = { mytaglist[s],
                           mytasklist[s],
                           mypromptbox[s],
			   separators,
                           mytextbox,
                           mylayoutbox[s],
                           s == 1 and mysystray or nil }
    mywibox[s].screen = s

    -- Create the status bar
    mystatusbar[s] = wibox({ position = "bottom", fg = beautiful.fg_normal, bg = beautiful.bg_normal })
    mystatusbar[s].widgets = {mylauncher,
	    		      mpdwidget,
			   wifiwidget,
			   separator,
			   cpu0graphwidget,
			   separator,
			   cpu1graphwidget,
			   separator,
			   memwidget,
			   separator,
			      separator,
	    		      batterywidget}
    mystatusbar[s].screen = s
end
-- }}}

-- {{{ Mouse bindings
root.buttons({
    button({ }, 3, function () mymainmenu:toggle() end),
    button({ }, 4, awful.tag.viewnext),
    button({ }, 5, awful.tag.viewprev)
})
-- }}}

-- {{{ Key bindings
globalkeys =
{
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1) end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1) end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus( 1)       end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus(-1)       end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey }, "w", function() awful.util.spawn("firefox-3.5") end),
    awful.key({ modkey }, "i", function() awful.util.spawn("pidgin") end),
    awful.key({ modkey }, "d", function() awful.util.spawn("stardict") end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
--    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

--    awful.key({ modkey }, "x",
--        function ()
--            awful.prompt.run({ prompt = "Run Lua code: " },
--	    mypromptbox[mouse.screen].widget,
--	    awful.util.eval, nil,
--            awful.util.getdir("cache") .. "/history_eval")
--        end),
    -- Mixer & MPD controls
    awful.key({ alt, control }, "k", function() mpd.volume_up(5); hook_mpd() end),
    awful.key({ alt, control }, "j", function() mpd.volume_down(5); hook_mpd() end),
    awful.key({ alt, control }, "space", function () mpd.toggle_play(); hook_mpd() end),
    awful.key({ alt, control }, "s", function () mpd.stop(); hook_mpd() end),
    awful.key({ alt, control }, "h", function () mpd.previous(); hook_mpd() end),
    awful.key({ alt, control }, "l", function () mpd.next(); hook_mpd() end)
}

-- Client awful tagging: this is useful to tag some clients and then do stuff like move to tag on them
clientkeys =
{
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    -- awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ alt   }, "F4",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey }, "t", awful.client.togglemarked),
    awful.key({ modkey,}, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),
}

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

for i = 1, keynumber do
    table.insert(globalkeys,
        awful.key({ modkey }, i,
            function ()
                local screen = mouse.screen
                if tags[screen][i] then
                    awful.tag.viewonly(tags[screen][i])
                end
            end))
    table.insert(globalkeys,
        awful.key({ modkey, "Control" }, i,
            function ()
                local screen = mouse.screen
                if tags[screen][i] then
                    tags[screen][i].selected = not tags[screen][i].selected
                end
            end))
    table.insert(globalkeys,
        awful.key({ modkey, "Shift" }, i,
            function ()
                if client.focus and tags[client.focus.screen][i] then
                    awful.client.movetotag(tags[client.focus.screen][i])
                end
            end))
    table.insert(globalkeys,
        awful.key({ modkey, "Control", "Shift" }, i,
            function ()
                if client.focus and tags[client.focus.screen][i] then
                    awful.client.toggletag(tags[client.focus.screen][i])
                end
            end))
end


for i = 1, keynumber do
    table.insert(globalkeys, awful.key({ modkey, "Shift" }, "F" .. i,
                 function ()
                     local screen = mouse.screen
                     if tags[screen][i] then
                         for k, c in pairs(awful.client.getmarked()) do
                             awful.client.movetotag(tags[screen][i], c)
                         end
                     end
                 end))
end

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Hooks
-- Hook function to execute when focusing a client.
awful.hooks.focus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_focus
    end
end)

-- Hook function to execute when unfocusing a client.
awful.hooks.unfocus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_normal
    end
end)

-- Hook function to execute when marking a client
awful.hooks.marked.register(function (c)
    c.border_color = beautiful.border_marked
end)

-- Hook function to execute when unmarking a client.
awful.hooks.unmarked.register(function (c)
    c.border_color = beautiful.border_focus
end)

-- Hook function to execute when the mouse enters a client.
awful.hooks.mouse_enter.register(function (c)
    -- Sloppy focus, but disabled for magnifier layout
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

-- Hook function to execute when a new client appears.
awful.hooks.manage.register(function (c, startup)
    -- If we are not managing this application at startup,
    -- move it to the screen where the mouse is.
    -- We only do it for filtered windows (i.e. no dock, etc).
    if not startup and awful.client.focus.filter(c) then
        c.screen = mouse.screen
    end

    if use_titlebar then
        -- Add a titlebar
        awful.titlebar.add(c, { modkey = modkey })
    end
    -- Add mouse bindings
    c:buttons({
        button({ }, 1, function (c) client.focus = c; c:raise() end),
        button({ modkey }, 1, awful.mouse.client.move),
        button({ modkey }, 3, awful.mouse.client.resize)
    })
    -- New client may not receive focus
    -- if they're not focusable, so set border anyway.
    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_normal

    -- Check if the application should be floating.
    local cls = c.class
    local inst = c.instance
    if floatapps[cls] then
        awful.client.floating.set(c, floatapps[cls])
    elseif floatapps[inst] then
        awful.client.floating.set(c, floatapps[inst])
    end

    -- Check application->screen/tag mappings.
    local target
    if apptags[cls] then
        target = apptags[cls]
    elseif apptags[inst] then
        target = apptags[inst]
    end
    if target then
        c.screen = target.screen
        awful.client.movetotag(tags[target.screen][target.tag], c)
    end

    -- Do this after tag mapping, so you don't see it on the wrong tag for a split second.
    client.focus = c

    -- Set key bindings
    c:keys(clientkeys)

    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- awful.client.setslave(c)

    -- Honor size hints: if you want to drop the gaps between windows, set this to false.
    -- c.size_hints_honor = false
end)

-- Hook function to execute when arranging the screen.
-- (tag switch, new client, etc)
awful.hooks.arrange.register(function (screen)
    local layout = awful.layout.getname(awful.layout.get(screen))
    if layout and beautiful["layout_" ..layout] then
        mylayoutbox[screen].image = image(beautiful["layout_" .. layout])
    else
        mylayoutbox[screen].image = nil
    end

    -- Give focus to the latest client in history if no window has focus
    -- or if the current window is a desktop or a dock one.
    if not client.focus then
        local c = awful.client.focus.history.get(screen, 0)
        if c then client.focus = c end
    end
end)

-- Hook called every minute
-- awful.hooks.timer.register(60, function ()
--     mytextbox.text = os.date(" %a %b %d, %H:%M ")
-- end)
-- Hook called every second
awful.hooks.timer.register(1, function ()
        mytextbox.text = " " .. os.date("%X %a, %e %b") .. " "
	cpuInfo()
	hook_mpd()
end)
awful.hooks.timer.register(5, function ()
	wifiInfo("wlan0")
end)
awful.hooks.timer.register(20, function ()
	batteryInfo("BAT0")
	memInfo()
end)
-- }}}
