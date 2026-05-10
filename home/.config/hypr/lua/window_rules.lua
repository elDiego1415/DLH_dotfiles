return function(ctx)
  ctx.helpers.each({
    {
      name = "suppress-maximize-events",
      match = {
        class = ".*",
      },
      suppress_event = "maximize",
    },
    {
      name = "fix-xwayland-drags",
      match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
      },
      no_focus = true,
    },
    {
      name = "move-hyprland-run",
      match = {
        class = "hyprland-run",
      },
      move = "20 monitor_h-120",
      float = true,
    },
  }, ctx.hl.window_rule)

  ctx.hl.config({
    xwayland = {
      force_zero_scaling = true,
    },
  })
end
