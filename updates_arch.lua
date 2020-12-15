local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local HOME = os.getenv("HOME")
local text_widget = {}
local grid_widget = {}
local image_widget = {}
local popup_widget = {}
local button_widget = {}
local button_text_widget = {}

local function worker(args)
    local args = args or {}
    local bg_color = beautiful.bg_color or args.bg_color
    local font = args.font or  "Play 6"
    local image = HOME .. '/.config/awesome/updates-arch-widget/updates.svg' or args.image

    local text = wibox.widget {
        font = font,
        align = 'center',
        valign = 'center',
        widget = wibox.widget.textbox
    }

    local text_with_background = wibox.container.background(text)

    image_widget = wibox.widget {
        image  = image,
        resize = true,
        widget = wibox.widget.imagebox
    }

    button_widget = wibox.widget{
        text_with_background,
        bg = bg_color,
        widget = wibox.widget.textbox
    }

    button_widget.text = "update"

    text_widget = wibox.widget {
        text_with_background,
        rounded_edge = true,
        forced_height = 18,
        forced_width = 22,
        bg = bg_color,
        paddings = 1,
        widget = wibox.widget.textbox
    }

    button_text_widget = wibox.widget{
        text_with_background,
        bg = bg_color,
        widget = wibox.widget.textbox
    }

    popup_widget = wibox.widget{
        button_text_widget,
        button_widget,
        spacing = 1,
        forced_num_cols = 1,
        forced_num_rows = 2,
        homogeneous     = false,
        expand          = true,
        layout = wibox.layout.grid
    }

    grid_widget = wibox.widget {
        image_widget,
        text_widget,
        spacing = 5,
        forced_num_cols = 2,
        forced_num_rows = 1,
        homogeneous     = true,
        expand          = true,
        layout = wibox.layout.grid
    }

    button_widget.visible = false

    local function update_widget(widget, stdout)
        local _string
        local apps_file = io.popen("checkupdates")
        local apps = apps_file:read("a")
        if string.len(apps) > 0 then
            button_widget.visible = true
            _string = "Updates Available:\n"
        else
            _string = "No update"
            button_widget.visible = false
        end
        button_text_widget.text= _string .. apps
        widget.text = stdout
    end

    awful.widget.watch("bash -c \"echo $(checkupdates | wc -l )\"", 100, update_widget, text_widget)

    local popup = awful.popup{
        ontop = true,
        visible = false,
        shape = gears.shape.rounded_rect,
        border_width = 10,
        border_color = beautiful.bg_normal,
        maximum_width = 300,
        maximum_height = 200,
        widget = popup_widget
    }

    button_widget:connect_signal('button::press', function (c)
        awful.spawn(terminal.." -e sudo pacman -Syu")
        popup.visible = false
    end)

    grid_widget:connect_signal('button::press', function (c)
        if popup.visible then
            popup.visible = not popup.visible
        else
            popup:move_next_to(mouse.current_widget_geometry)
        end
    end)

    return grid_widget

end

return setmetatable(grid_widget, { __call = function(_, ...)
    return worker(...)
end })
