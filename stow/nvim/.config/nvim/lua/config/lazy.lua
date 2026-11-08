local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- /usr/bin/java is only a stub on macOS.
local function has_jdk()
  if vim.fn.has("mac") == 1 then
    return vim.fn.isdirectory("/opt/homebrew/opt/openjdk") == 1
  end
  return vim.fn.executable("java") == 1
end

local function has_own_plugins()
  return #vim.api.nvim_get_runtime_file("lua/plugins/*.lua", false) > 0
end

require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- All other extras live in lazyvim.json; these two need a JDK.
    { import = "lazyvim.plugins.extras.lang.java", cond = has_jdk },
    { import = "lazyvim.plugins.extras.lang.kotlin", cond = has_jdk },
    { "mfussenegger/nvim-jdtls", enabled = has_jdk }, -- keeps its lazy-lock.json entry without a JDK
    { import = "plugins", cond = has_own_plugins },
  },
  -- Set during the first headless install, which would rewrite the lockfile with partial data.
  lockfile = vim.env.LAZY_LOCKFILE,
  defaults = { lazy = false, version = false },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true, notify = false },
  performance = {
    rtp = { disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" } },
  },
})
