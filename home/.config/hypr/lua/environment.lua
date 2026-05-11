return function(ctx)
  ctx.helpers.each({
    { "XCURSOR_SIZE", "24" },
    { "XCURSOR_THEME", "Moga-Black" },
    { "HYPRCURSOR_THEME", "Moga-Black" },
    { "HYPRCURSOR_SIZE", "24" },
    { "ELECTRON_OZONE_PLATFORM_HINT", "wayland" },
    { "HYPRSHOT_DIR", "/home/diego/capturas" },
  }, function(env)
    ctx.hl.env(env[1], env[2])
  end)
end
