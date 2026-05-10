return function(ctx)
  ctx.helpers.each({
    { "XCURSOR_SIZE", "24" },
    { "HYPRCURSOR_SIZE", "24" },
    { "ELECTRON_OZONE_PLATFORM_HINT", "wayland" },
    { "HYPRSHOT_DIR", "/home/diego/capturas" },
  }, function(env)
    ctx.hl.env(env[1], env[2])
  end)
end
