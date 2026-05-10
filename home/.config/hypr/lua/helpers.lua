return function(ctx)
  local helpers = {}

  function helpers.each(items, callback)
    for _, item in ipairs(items) do
      callback(item)
    end
  end

  function helpers.with_mod(key)
    return ctx.programs.main_mod .. " + " .. key
  end

  function helpers.exec(command)
    return ctx.dsp.exec_cmd(command)
  end

  function helpers.bind(key, action, opts)
    ctx.hl.bind(key, action, opts)
  end

  function helpers.bind_mod(key, action, opts)
    helpers.bind(helpers.with_mod(key), action, opts)
  end

  function helpers.bind_exec(key, command, opts)
    helpers.bind(key, helpers.exec(command), opts)
  end

  return helpers
end
