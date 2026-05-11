return function(ctx)
  local h = ctx.helpers

  ctx.hl.on("hyprland.start", function()
    h.each({
      "sh -c 'pgrep -x waybar >/dev/null || exec waybar -c /home/diego/.config/waybar/config -s /home/diego/.config/waybar/style.css'",
      "hyprpaper",
      "sh -c 'command -v blueman-applet >/dev/null && blueman-applet'",
      "/usr/lib/polkit-kde-authentication-agent-1",
      "mako",
      "sh -c 'command -v hypridle >/dev/null && hypridle'",
      "/home/diego/scripts/aviso-bateria.sh",
    }, ctx.hl.exec_cmd)
  end)
end
