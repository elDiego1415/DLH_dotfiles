return function(ctx)
  ctx.hl.config({
    dwindle = {
      preserve_split = true,
    },
    master = {
      new_status = "slave",
      new_on_top = true,
      mfact = 0.65,
    },
    misc = {
      force_default_wallpaper = 0,
      disable_hyprland_logo = true,
    },
  })
end
