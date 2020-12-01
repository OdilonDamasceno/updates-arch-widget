local beautiful = require("beautiful")
local wibox = require("wibox")
local watch = require("awful.widget.watch")
local HOME = os.getenv("HOME")
local updates = HOME .. '/.config/awesome/updates-widget/updates'
local image = HOME .. '/.config/awesome/updates-widget/updates.svg'
local text_widget = {}
local grid_widget = {}
local image_widget = {}

local function worker(args)
    local text = wibox.widget {
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
        bg = beautiful.bg_color,
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
        widget.text = stdout
    end

    watch(updates, 100, update_widget, text_widget)

    return grid_widget

end

return setmetatable(grid_widget, { __call = function(_, ...)
    return worker(...)
end })
