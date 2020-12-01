local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local HOME = os.getenv("HOME")
local text_widget = {}
local grid_widget = {}
local image_widget = {}
local popup_widget = {}

local function worker(args)
    local args = args or {}
    local bg_color = beautiful.bg_color or args.bg_color
    local font = args.font or  "Play 6"
    local image = HOME .. '/.config/awesome/updates-widget/updates.svg' or args.image

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

    text_widget = wibox.widget {
        text_with_background,
        rounded_edge = true,
        forced_height = 18,
        forced_width = 22,
        bg = bg_color,
        paddings = 2,
        widget = wibox.widget.textbox
    }

    popup_widget = wibox.widget{
        text_with_background,
        rounded_edge = true,
        bg = bg_color,
        paddings = 2,
        widget = wibox.widget.textbox
    }

    grid_widget = wibox.widget {
        image_widget,
        text_widget,
        spacing = 10,
        forced_num_cols = 2,
        forced_num_rows = 1,
        homogeneous     = true,
        expand          = true,
        layout = wibox.layout.grid
    }

    local function update_widget(widget, stdout)
        local apps = io.popen("checkupdates")
        popup_widget.text= "Updates Available:\n\n" .. apps:read("*a")
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
