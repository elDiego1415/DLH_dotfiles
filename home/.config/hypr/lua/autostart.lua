return function(ctx)
  local h = ctx.helpers

  ctx.hl.on("hyprland.start", function()
    h.each({
      "waybar",
      "hyprpaper",
      "/usr/lib/polkit-kde-authentication-agent-1",
      "mako",
      "sh -c 'command -v hypridle >/dev/null && hypridle'",
      "/home/diego/scripts/aviso-bateria.sh",
    }, ctx.hl.exec_cmd)
  end)
end
