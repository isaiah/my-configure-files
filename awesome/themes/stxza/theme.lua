-------------------------------
-- STxza's Awesome Theme --
-------------------------------

-- BASICS
theme = {}
theme.font          = "Terminus 6"

theme.bg_focus      = "#1C1C1C"
theme.bg_normal     = "#000000"
theme.bg_urgent     = "#3579A8"
theme.bg_minimize   = "#0067ce"

theme.fg_normal     = "#C4C4C4"
theme.fg_focus      = "#3579A8"
theme.fg_urgent     = "#EFEFEF"
theme.fg_minimize   = "#2e3436"

theme.border_width  = "1"
theme.border_normal = "#4C4C4C"
theme.border_focus  = "#3579A8"
theme.border_marked = "#FF0000"

-- IMAGES
theme.layout_fairh           = "/usr/share/awesome/themes/sky/layouts/fairh.png"
theme.layout_fairv           = "/usr/share/awesome/themes/sky/layouts/fairv.png"
theme.layout_floating        = "/usr/share/awesome/themes/sky/layouts/floating.png"
theme.layout_magnifier       = "/usr/share/awesome/themes/sky/layouts/magnifier.png"
theme.layout_max             = "/usr/share/awesome/themes/sky/layouts/max.png"
theme.layout_fullscreen      = "/usr/share/awesome/themes/sky/layouts/fullscreen.png"
theme.layout_tilebottom      = "/usr/share/awesome/themes/sky/layouts/tilebottom.png"
theme.layout_tileleft        = "/usr/share/awesome/themes/sky/layouts/tileleft.png"
theme.layout_tile            = "/usr/share/awesome/themes/sky/layouts/tile.png"
theme.layout_tiletop         = "/usr/share/awesome/themes/sky/layouts/tiletop.png"

theme.awesome_icon           = "/usr/share/awesome/themes/sky/awesome-icon.png"
theme.tasklist_floating_icon = "/usr/share/awesome/themes/sky/layouts/floating.png"

-- from default for now...
theme.menu_submenu_icon     = "/usr/share/awesome/themes/default/submenu.png"
theme.taglist_squares_sel   = "/usr/share/awesome/themes/default/taglist/squarefw.png"
theme.taglist_squares_unsel = "/usr/share/awesome/themes/default/taglist/squarew.png"

-- MISC
theme.wallpaper_cmd         = { "awsetbg /home/isaiah/.config/awesome/themes/stxza/background.jpg" }
theme.taglist_squares       = "true"
theme.titlebar_close_button = "true"
theme.menu_height           = "14"
theme.menu_width            = "100"

-- Define the image to load
theme.titlebar_close_button_normal = "/usr/share/awesome/themes/default/titlebar/close_normal.png"
theme.titlebar_close_button_focus = "/usr/share/awesome/themes/default/titlebar/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive = "/usr/share/awesome/themes/default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = "/usr/share/awesome/themes/default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active = "/usr/share/awesome/themes/default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive = "/usr/share/awesome/themes/default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = "/usr/share/awesome/themes/default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active = "/usr/share/awesome/themes/default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive = "/usr/share/awesome/themes/default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = "/usr/share/awesome/themes/default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active = "/usr/share/awesome/themes/default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive = "/usr/share/awesome/themes/default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = "/usr/share/awesome/themes/default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active = "/usr/share/awesome/themes/default/titlebar/maximized_focus_active.png"

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
