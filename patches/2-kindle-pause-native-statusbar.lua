-- 2-kindle-pause-native-statusbar.lua
-- On Kindle firmware 5.16+, the native status bar (JunoStatusBarDriver)
-- keeps drawing its clock on top of KOReader every minute.
-- This patch pauses that process while KOReader runs and resumes it on exit.

local Device = require("device")
if not Device:isKindle() then return end

local logger = require("logger")

local CMD = [[for p in /proc/[0-9]*; do
  case "$(tr '\0' ' ' < "$p/cmdline" 2>/dev/null)" in
    /app/bin/JunoStatusBarDriver*) kill -%s "${p#/proc/}" ;;
  esac
done]]

local function signal(sig)
  os.execute(string.format(CMD, sig))
  logger.info("pause-native-statusbar: sent SIG" .. sig .. " to JunoStatusBarDriver")
end

signal("STOP")

local UIManager = require("ui/uimanager")
local orig_quit = UIManager.quit
UIManager.quit = function(self, ...)
  signal("CONT")
  return orig_quit(self, ...)
end
