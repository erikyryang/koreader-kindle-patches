-- 2-reader-center-double-tap-goto.lua
-- In the reader, a double tap in the center of the screen opens the
-- "Go to page" dialog (same as KOReader's built-in "Go to" action).
-- Center zone: the middle half of the screen (25%..75% horizontally and vertically).
-- Requires double tap detection to be enabled (disable_double_tap = false).

local Device = require("device")
if not Device:isTouchDevice() then return end

local ReaderUI = require("apps/reader/readerui")
local Event = require("ui/event")

local orig_init = ReaderUI.init
ReaderUI.init = function(self, ...)
    local ret = orig_init(self, ...)
    self:registerTouchZones({
        {
            id = "center_double_tap_goto_page",
            ges = "double_tap",
            screen_zone = { ratio_x = 0.25, ratio_y = 0.25, ratio_w = 0.5, ratio_h = 0.5 },
            -- takes priority over the double tap zones of the gestures plugin
            overrides = {
                "double_tap_left_side", "double_tap_right_side",
                "double_tap_top_left_corner", "double_tap_top_right_corner",
                "double_tap_bottom_left_corner", "double_tap_bottom_right_corner",
            },
            handler = function()
                self:handleEvent(Event:new("ShowGotoDialog"))
                return true
            end,
        },
    })
    return ret
end
