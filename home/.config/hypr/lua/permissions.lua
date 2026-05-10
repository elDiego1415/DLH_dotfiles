return function(ctx)
  -- See https://wiki.hypr.land/Configuring/Permissions/
  -- Permission changes require a Hyprland restart and are not applied on-the-fly.

  -- ctx.hl.config({
  --   ecosystem = {
  --     enforce_permissions = true,
  --   },
  -- })

  -- ctx.hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
  -- ctx.hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
  -- ctx.hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")
end
