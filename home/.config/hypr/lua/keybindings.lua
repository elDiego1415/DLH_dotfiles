return function(ctx)
  local dsp = ctx.dsp
  local h = ctx.helpers
  local programs = ctx.programs

  h.each({
    { "Return", h.exec(programs.terminal) },
    { "C", dsp.window.close() },
    { "M", h.exec("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'") },
    { "E", h.exec(programs.file_manager) },
    { "V", dsp.window.float({ action = "toggle" }) },
    { "R", h.exec(programs.menu) },
    { "P", dsp.window.pseudo() },
    { "J", dsp.layout("togglesplit") },
    { "SPACE", h.exec("menu-ia") },
    { "SHIFT + S", h.exec("hyprshot -m region") },
    { "L", h.exec("~/scripts/hyprlock-current-wallpaper.sh") },
    { "S", h.exec("hyprshot -m output") },
    { "W", h.exec("pkill wofi || ~/scripts/wallpaper-menu.sh") },
  }, function(mapping)
    h.bind_mod(mapping[1], mapping[2])
  end)

  h.each({
    { "left", "left" },
    { "right", "right" },
    { "up", "up" },
    { "down", "down" },
  }, function(focus)
    h.bind_mod(focus[2], dsp.focus({ direction = focus[1] }))
  end)

  for workspace = 1, 10 do
    local key = workspace % 10
    h.bind_mod(key, dsp.focus({ workspace = workspace }))
    h.bind_mod("SHIFT + " .. key, dsp.window.move({ workspace = workspace }))
  end

  h.bind_mod("mouse_down", dsp.focus({ workspace = "e+1" }))
  h.bind_mod("mouse_up", dsp.focus({ workspace = "e-1" }))

  h.bind_mod("mouse:272", dsp.window.drag(), { mouse = true })
  h.bind_mod("mouse:273", dsp.window.resize(), { mouse = true })

  local locked_repeating = { locked = true, repeating = true }
  local locked = { locked = true }

  h.each({
    { "XF86AudioRaiseVolume", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+" },
    { "XF86AudioLowerVolume", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" },
    { "XF86AudioMute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" },
    { "XF86AudioMicMute", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" },
    { "XF86MonBrightnessUp", "~/scripts/noti-brillo.sh up" },
    { "XF86MonBrightnessDown", "~/scripts/noti-brillo.sh down" },
  }, function(mapping)
    h.bind_exec(mapping[1], mapping[2], locked_repeating)
  end)

  h.each({
    { "XF86AudioNext", "playerctl next" },
    { "XF86AudioPause", "playerctl play-pause" },
    { "XF86AudioPlay", "playerctl play-pause" },
    { "XF86AudioPrev", "playerctl previous" },
  }, function(mapping)
    h.bind_exec(mapping[1], mapping[2], locked)
  end)
end
