return function(ctx)
  local h = ctx.helpers

  ctx.hl.config({
    general = {
      gaps_in = 5,
      gaps_out = 7,
      border_size = 2,
      col = {
        active_border = {
          colors = { "rgba(cba6f7ff)", "rgba(f38ba8ff)" },
          angle = 90,
        },
        inactive_border = "rgba(44475aff)",
      },
      resize_on_border = false,
      allow_tearing = false,
      layout = "dwindle",
    },
    decoration = {
      rounding = 5,
      rounding_power = 2,
      active_opacity = 1.0,
      inactive_opacity = 1.0,
      shadow = {
        enabled = false,
        range = 10,
        render_power = 3,
        color = "rgba(00000088)",
      },
      blur = {
        enabled = false,
        size = 8,
        passes = 2,
        vibrancy = 0.1696,
      },
    },
    animations = {
      enabled = true,
    },
  })

  ctx.hl.workspace_rule({ workspace = "2", layout = "master" })

  h.each({
    { "easeOutQuint", { { 0.23, 1 }, { 0.32, 1 } } },
    { "easeInOutCubic", { { 0.65, 0.05 }, { 0.36, 1 } } },
    { "linear", { { 0, 0 }, { 1, 1 } } },
    { "almostLinear", { { 0.5, 0.5 }, { 0.75, 1 } } },
    { "quick", { { 0.15, 0 }, { 0.1, 1 } } },
  }, function(curve)
    ctx.hl.curve(curve[1], { type = "bezier", points = curve[2] })
  end)

  h.each({
    { "global", 10, "default" },
    { "border", 5.39, "easeOutQuint" },
    { "windows", 4.79, "easeOutQuint" },
    { "windowsIn", 4.1, "easeOutQuint", "popin 87%" },
    { "windowsOut", 1.49, "linear", "popin 87%" },
    { "fadeIn", 1.73, "almostLinear" },
    { "fadeOut", 1.46, "almostLinear" },
    { "fade", 3.03, "quick" },
    { "layers", 4.2, "easeOutQuint" },
    { "layersIn", 4.8, "easeOutQuint", "fade" },
    { "layersOut", 2.2, "almostLinear", "fade" },
    { "fadeLayersIn", 1.79, "almostLinear" },
    { "fadeLayersOut", 1.39, "almostLinear" },
    { "workspaces", 1.94, "almostLinear", "fade" },
    { "workspacesIn", 1.21, "almostLinear", "fade" },
    { "workspacesOut", 1.94, "almostLinear", "fade" },
    { "zoomFactor", 7, "quick" },
  }, function(animation)
    ctx.hl.animation({
      leaf = animation[1],
      enabled = true,
      speed = animation[2],
      bezier = animation[3],
      style = animation[4],
    })
  end)
end
