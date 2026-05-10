local config_dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
package.path = config_dir .. "lua/?.lua;" .. package.path

local ctx = {
  hl = hl,
  dsp = hl.dsp,
  programs = require("programs"),
}

ctx.helpers = require("helpers")(ctx)

for _, module in ipairs({
  "monitors",
  "autostart",
  "environment",
  "permissions",
  "visual",
  "layout",
  "input",
  "keybindings",
  "window_rules",
}) do
  require(module)(ctx)
end
