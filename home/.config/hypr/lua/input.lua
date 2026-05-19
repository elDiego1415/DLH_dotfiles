return function(ctx)
  ctx.hl.config({
    input = {
      kb_layout = "es",
      kb_variant = "",
      kb_model = "",
      kb_options = "",
      kb_rules = "",
      follow_mouse = 1,
      sensitivity = 0,
      touchpad = {
        natural_scroll = true,
        scroll_factor = 0.3,
      },
    },
  })

  ctx.hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
  ctx.hl.gesture({
    fingers = 4,
    direction = "down",
    action = function()
      ctx.hl.exec_cmd("~/scripts/hyprlock-current-wallpaper.sh")
    end,
  })

  ctx.hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
  })
end
