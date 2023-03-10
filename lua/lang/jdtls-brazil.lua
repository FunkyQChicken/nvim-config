JDTLS_SETUP = function()
  local root_dir = require('jdtls.setup').find_root({'packageInfo'}, 'Config')
  --local home = os.getenv('HOME')
  --local eclipse_workspace = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, ':p:h:t')

  local ws_folders_lsp = {}
  local ws_folders_jdtls = {}
  if root_dir then
    local file = io.open(root_dir .. "/.bemol/ws_root_folders", "r");
    if file then
      for line in file:lines() do
        table.insert(ws_folders_lsp, line);
        table.insert(ws_folders_jdtls, string.format("file://%s", line))
      end
      file:close()
    end
  end

  require('jdtls').start_or_attach({
    on_attach = require('aerial').on_attach,
    -- The command that starts the language server
    -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
    cmd = {'jdtls'},
    root_dir = root_dir,
    init_options = {
      workspaceFolders = ws_folders_jdtls,
      -- Language server `initializationOptions`
      -- You need to extend the `bundles` with paths to jar files
      -- if you want to use additional eclipse.jdt.ls plugins.
      --
      -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
      --
      -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
      bundles = {},
    },

    -- Here you can configure eclipse.jdt.ls specific settings
    -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
    -- for a list of options
    settings = { java = { } },

    capabilities = owo.cmp.capabilities,
  })

  for _,line in ipairs(ws_folders_lsp) do
    vim.lsp.buf.add_workspace_folder(line)
  end
end

vim.cmd [[
augroup lsp
  autocmd!
  autocmd FileType java luado JDTLS_SETUP()
augroup end
]]
