-- Standard awesome library
local gears = require("gears")
gears.color = require("gears.color")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local teardrop = require("teardrop")
local revelation = require("revelation")
local vicious = require("vicious")
local mpd = require("lib/mpd")

-- {{{ Load functions
loadfile(awful.util.getdir("config").."/functions.lua")()
loadfile(awful.util.getdir("config").."/lib/orglendar.lua")()
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/isaiah/.config/awesome/themes/sky/theme.lua")

-- This is used later as the default terminal and editor to run.
browser = "firefox"
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
local layouts =
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

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
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
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.arch_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.arch_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Widgets
-- {{{ Functions
-- Create MPD widget
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
-- }}}
-- Spacers

tab = wibox.widget.textbox("      ", true)
separator = wibox.widget.imagebox()
separator:set_image(beautiful.separator_icon)

-- Get and format MPD status
-- (need the mpd lib for lua
local last_songid = nil
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

local mpdwidget = wibox.widget.textbox(widget_mpd(), false)

function hook_mpd()
  mpdwidget:set_markup(widget_mpd())
end

-- Battery
batterywidget = wibox.widget.textbox()
-- Memory
memwidget = wibox.widget.textbox()
-- Processor
-- gradient = gears.color.create_pattern("radial:50,50,10:55,55,30:0,#ff0000:0.5,#00ff00:1,#0000ff")
-- cpu0 graph
cpu0graphwidget = awful.widget.graph({width = 60, height = 14})
cpu0graphwidget:set_max_value(100)
cpu0graphwidget:set_background_color(beautiful.bg_normal)
-- cpu0graphwidget:set_color(gradient)
cpu0graphwidget:set_border_color(beautiful.fg_urgent)

-- cpu1 graph
cpu1graphwidget = awful.widget.graph({width = 60, height = 14})
cpu1graphwidget:set_max_value(100)
cpu1graphwidget:set_background_color(beautiful.bg_normal)
-- cpu1graphwidget:set_color(gradient)
cpu1graphwidget:set_border_color(beautiful.fg_urgent)

-- HOOKS
function hooks()
  batterywidget:set_markup(batteryInfo(beautiful, "BAT0"))
  memwidget:set_markup(memInfo(beautiful))
  local cpuinfo = cpuInfo()
  cpu0graphwidget:add_value(cpuinfo.cpu0)
  cpu1graphwidget:add_value(cpuinfo.cpu1)
end
hooks()
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

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
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
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
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    -- if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mytextclock)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)

    -- Create the graphbox
    if s == 1 then
      mygraphbox[s] = awful.wibox({position = "bottom", height = 14, screen =s })
      local bottom_left_layout = wibox.layout.fixed.horizontal()
      bottom_left_layout:add(mylayoutbox[s])
      bottom_left_layout:add(tab)
      bottom_left_layout:add(cpu0graphwidget)
      bottom_left_layout:add(cpu1graphwidget)
      bottom_left_layout:add(tab)
      bottom_left_layout:add(memwidget)
      bottom_left_layout:add(tab)
      bottom_left_layout:add(mpdwidget)
      bottom_left_layout:add(tab)
      bottom_left_layout:add(batterywidget)
      -- bottom_left_layout:add(memwidget)
      local bottom_right_layout = wibox.layout.fixed.horizontal()
      bottom_right_layout:add(wibox.widget.systray())
      local bottom_widgets = wibox.layout.align.horizontal()
      bottom_widgets:set_left(bottom_left_layout)
      bottom_widgets:set_right(bottom_right_layout)
      mygraphbox[s]:set_widget(bottom_widgets)
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
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

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

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end),

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
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
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
                     focus = awful.client.focus.filter,
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
    { rule = { class = "Pidgin" },
      properties = { tag = tags[1][4], floating = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
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

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Timers
mytimer = timer({ timeout = 1 })
mytimer:connect_signal("timeout", function() hooks() end)
mytimer:start()
-- }}}
