local wk = owo.wk
local modes = {}
owo.modes = modes

local aug = vim.api.nvim_create_augroup("owo modes", {clear = true})

function modes.dbsys()
  wk.register({
    X = {"Send "},
  }, {
      mode   = "n",
      prefix = " ",
      buffer = 0,
    })
end

function modes.debug()
  wk.register ({
    [";"] = {owo.plug.dap.repl.toggle,  "debug toggle repl"},
    ["?"] = {owo.plug.dap.toggle_breakpoint,  "debug toggle breakpoint"},
    [","] = {owo.plug.dap.step_into,  "debug step into"},
    ["."] = {owo.plug.dap.step_over,  "debug step over"},
    [">"] = {owo.plug.dap.continue,    "debug continue"},
  }, {
      mode   = "n",
      prefix = "",
      buffer = 0,
    })
end

function modes.amazon()
  wk.register({
    t = {
      n = {owo.amazon.test_nearest, "test nearest"},
      w = {owo.amazon.test_suite, "test suite"},
      s = {owo.amazon.select_test_strategy, "select test strategy"},
    },
    b = {
      name = "build",
      c = {owo.amazon.run_checkstyle, "checkstyle"},
    },
  }, {prefix="<leader>"})
end

function modes.redirect_man_to_doc()
  wk.register({
    K = {"yiw:vert bel help \"<cr>", "Lookup symbol in vim help"}
  }, {mode="n", prefix="", buffer=0})

  wk.register({
    K = {"y:vert bel help \"<cr>", "Lookup symbol in vim help"}
  }, {mode="v", prefix="", buffer=0})
end

vim.api.nvim_create_autocmd("FileType", {
  group = aug,
  pattern={"lua","vim","help"},
  callback=modes.redirect_man_to_doc})


function modes.q_to_close()
  wk.register({
    q = {":q<cr>", "close window with q"}
  }, {mode="n", prefix="", buffer=0})
end

vim.api.nvim_create_autocmd("FileType", {
  group = aug,
  pattern={
    "help",
    "git",
    "fugitive",
    "fugitiveblame",
  },
  callback=modes.q_to_close})

function modes.luadev()
  wk.register({
  X = {owo.plug.luadev.exec_motion, "lua exec motion"},
  [""] = {owo.plug.luadev.exec_buffer, "lua exec buffer"},

  [';'] = {function() owo.plug.luadev.toggle() end, "focus repl"}
  }, {
    modes = "n",
    prefix = "",
    buffer = 0,
  })
end

vim.api.nvim_create_autocmd("FileType", {
  group = aug,
  pattern={
    "lua",
  },
  callback=modes.luadev})

local repls = {}

local function create_repl(ft)
  local curr = vim.api.nvim_get_current_buf()
  local rep = owo.plug.iron.repl_here(ft)
  owo.std.make_toggle_buffer(0)
  repls[ft] = rep.bufnr
  vim.api.nvim_set_current_buf(curr)
  vim.api.nvim_create_autocmd("BufUnload", {
    group = aug,
    buffer = rep.bufnr,
    callback = function()
      repls[ft] = nil
    end
  })
end

local function toggle_repl(ft)
  if not repls[ft] then
    create_repl(ft)
  end
  owo.std.toggle_buf(repls[ft])
end

local function ensure_open(ft)
  if not repls[ft] then
    create_repl(ft)
  end
  owo.std.ensure_open(repls[ft])
end

local function create_dev_mode(ft)
  wk.register({
  X = {
      function()
        owo.std.motion_cmd(
          function(s)
            ensure_open(ft)
            owo.plug.iron.send(ft, s)
          end)
      end,
      ft .. " exec motion"},

  [""] = {
      function()
        ensure_open(ft)
        owo.plug.iron.send_file()
      end,
      ft .. " exec buffer"},

  [';'] = {function() toggle_repl(ft) end, ft.." toggle repl"}
  }, {
    modes = "n",
    prefix = "",
    buffer = 0,
  })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = {"scheme", "ruby", "python", "sql", "haskell"},
  group = aug,
  callback = function(m)
    create_dev_mode(m.match)
  end
})


-- Treesitter indent isn't perfect, lol
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"go", "ruby"},
  group = aug,
  callback = function(_)
    owo.std.notify("Disabliing treesitter indentexpr")
    vim.defer_fn(function()
      vim.bo.indentexpr=nil
      vim.bo.smartindent=true
    end, 30)
  end
})
