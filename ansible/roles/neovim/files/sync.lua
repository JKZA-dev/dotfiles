-- Blocks until the Mason tools and Tree-sitter parsers LazyVim wants are installed.
local TIMEOUT_MS = 20 * 60 * 1000

require("lazy").load({ plugins = { "mason.nvim", "mason-lspconfig.nvim", "nvim-lspconfig", "nvim-treesitter" } })

local registry = require("mason-registry")
local refreshed = false
registry.refresh(function()
  refreshed = true
end)
vim.wait(TIMEOUT_MS, function()
  return refreshed
end, 200)

local tools = vim.deepcopy(LazyVim.opts("mason.nvim").ensure_installed or {})
local to_package = require("mason-lspconfig").get_mappings().lspconfig_to_package
for server, opts in pairs(LazyVim.opts("nvim-lspconfig").servers or {}) do
  local managed = opts == true or (type(opts) == "table" and opts.mason ~= false and opts.enabled ~= false)
  if managed and to_package[server] then
    table.insert(tools, to_package[server])
  end
end

local pending = {}
for _, name in ipairs(tools) do
  local pkg = registry.get_package(name)
  if not pkg:is_installed() and not pkg:is_installing() then
    pkg:install()
  end
  table.insert(pending, pkg)
end

vim.wait(TIMEOUT_MS, function()
  return vim.iter(pending):all(function(pkg)
    return not pkg:is_installing()
  end)
end, 500)

for _, pkg in ipairs(pending) do
  if not pkg:is_installed() then
    io.stderr:write("Mason install failed: " .. pkg.name .. "\n")
  end
end

require("nvim-treesitter").install(LazyVim.opts("nvim-treesitter").ensure_installed):wait(TIMEOUT_MS)

vim.cmd("qa!")
