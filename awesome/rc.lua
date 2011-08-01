-- {{{ Load libraries 
-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Mpd lib
require("lib/mpd")
-- Revelation
require("revelation")
-- }}}

-- {{{ Load functions
loadfile(awful.util.getdir("config").."/functions.lua")()
loadfile(awful.util.getdir("config").."/lib/orglendar.lua")()
-- }}}

-- {{{ Variable definition
-- Themes define colours, icons, and wallpapers
-- beautiful.init("/usr/share/awesome/themes/sky/theme.lua")
-- beautiful.init(awful.util.getdir("config") .. "/themes/dust/theme.lua")
beautiful.init(awful.util.getdir("config") .. "/themes/sky/theme.lua")
-- Import custom widgets
--require("wi")
-- Import drop-down terminal code
require("teardrop")

-- This is used later as the default terminal and editor to run.
browser = "firefox"
terminal = "xterm +si"
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
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
    names = { "1:W", "2:FF", "3:R", "4:IM", "5:D", "6", "7", "8", "9" },
    layouts = { layouts[10], layouts[1], layouts[1], layouts[2], layouts[1],
                layouts[1], layouts[2], layouts[12], layouts[1]}
}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    -- tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
    tags[s] = awful.tag(tags.names, s, tags.layouts)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.arch_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.arch_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Widgets
-- {{{ Functions
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
-- Wiget value
-- content (/ next_value)?
function widget_value(content, next_value)
	local value
	if content and content ~= nil then
		value = content
		if next_value and next_value ~= "" then
			value = value .. fg(beautiful.fg_urgent, " / ") .. next_value
		end
	else
		value = next_value
	end
	return value
end
-- Get and format MPD status
-- (need the mpd lib for lua
last_songid = nil
use_naughty = true
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
mpdwidget = widget({ type = "textbox" })
mpdwidget.text = widget_mpd()
-- }}}

-- {{{ SPACERS
spacer_1 = widget({ type = "textbox" })
spacer_1.text = " "
tab = widget({ type = "textbox" })
tab.text = "       "
separator = widget({ type = "imagebox" })
separator.image = image(beautiful.separator_icon)
-- }}}

-- {{{ PROCESSOR
-- cpu0 graph
cpu0graphwidget = awful.widget.graph()
cpu0graphwidget:set_width(60)
cpu0graphwidget:set_height(14)
cpu0graphwidget:set_max_value(100)
cpu0graphwidget:set_background_color(beautiful.bg_normal)
cpu0graphwidget:set_border_color(beautiful.fg_urgent)
cpu0graphwidget:set_gradient_colors({ "red", "cyan" })
cpu0graphwidget:set_gradient_angle(90)

-- cpu1 graph
cpu1graphwidget = awful.widget.graph()
cpu1graphwidget:set_width(60)
cpu1graphwidget:set_height(14)
cpu1graphwidget:set_max_value(100)
cpu1graphwidget:set_background_color(beautiful.bg_normal)
cpu1graphwidget:set_border_color(beautiful.fg_urgent)
cpu1graphwidget:set_gradient_colors({ "red", "cyan" })
cpu1graphwidget:set_gradient_angle(90)
cpuInfo()

-- }}}
-- {{{ MEMORY
memwidget = widget({ type = "textbox" })
memInfo()
-- }}}

-- {{{ MPD
-- mpdwidget = widget({ type = 'textbox' })
-- vicious.register(mpdwidget,vicious.widgets.mpd,
-- function (widget, args)
-- 	if   args[1] == 'Stopped' then return ''
-- 	else return '<span color="white">MPD:</span> '..args[1]
-- 	end 
-- end)
-- }}}

-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({}, "<span color='#d6d6d6'>%a, %m/%d</span> @ %l:%M %p ")
orglendar.files = {"/home/isaiah/.org/tasks.org"}
orglendar.register(mytextclock)

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mygraphbox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", height = 14, screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
	    mylauncher,
            mytaglist[s], separator,
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mytextclock, separator,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }

    -- Create the graphbox
    if s == 1 then
            mygraphbox[s] = awful.wibox({ position = "bottom", height = 16, screen = s })
            mygraphbox[s].widgets = {
                mylayoutbox[s], spacer_1, separator,
                cpu0graphwidget, spacer_1, cpu1graphwidget, separator,
                memwidget, tab,
                mpdwidget,
                layout = awful.widget.layout.horizontal.leftright,
                {
                    separator, s == 1 and mysystray or nil,
                    layout = awful.widget.layout.horizontal.rightleft
                }
            }
    end
end

-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
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
    awful.key({ modkey,           }, "w", function () mymainmenu:show(true)        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
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
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Mixer & MPD controls
    awful.key({ alt, control }, "k", function() mpd.volume_up(5); hook_mpd() end),
    awful.key({ alt, control }, "j", function() mpd.volume_down(5); hook_mpd() end),
    awful.key({ alt, control }, "space", function () mpd.toggle_play(); hook_mpd() end),
    awful.key({ alt, control }, "s", function () mpd.stop(); hook_mpd() end),
    awful.key({ alt, control }, "h", function () mpd.previous(); hook_mpd() end),
    awful.key({ alt, control }, "l", function () mpd.next(); hook_mpd() end),

    -- Drop-down Terminal
    awful.key({ modkey }, "`", function ()
	    teardrop("urxvt", "bottom", "right", 700, .40, true)
    end),
    awful.key({ modkey }, "e", function() revelation.revelation() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][2] } },
    { rule = { class = "Chromium" },
      properties = { tag = tags[1][3] } },
    { rule = { class = "Eclipse" },
      properties = { tag = tags[1][9] } },
    { rule = { class = "Pidgin" },
      properties = { tag = tags[2][4], floating = true } },
    { rule = { class = "Empathy" },
      properties = { floating = true } },
    { rule = { class = "Stardict" },
      properties = { tag = tags[1][5] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Timers
mytimer = timer({ timeout = 1 })
mytimer:add_signal("timeout", function() hook_mpd() cpuInfo() memInfo() end )
mytimer:start()
-- }}}

--{{{ Autostart programs
-- os.execute("nm-applet &")
--}}}
