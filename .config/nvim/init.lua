-- Bootstrap lazy.nvim
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

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- Lualine
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("lualine").setup({
          options = { theme = "everforest" },
          sections = {
            lualine_a = { "mode" },
	    lualine_c = { "filename" },
	    lualine_x = { "encoding", "filetype" },
	    lualine_y = { "progress" },
	    lualine_z = { "location" }
	  }
	})
      end
    },
    -- Kanagawa
    {
      "rebelot/kanagawa.nvim",
      config = function()
        require("kanagawa").setup{}
	vim.cmd[[colorscheme kanagawa]]
      end
    },
    -- Treesitter
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        local configs = require("nvim-treesitter.configs")

	configs.setup({
          ensure_installed = { "bash", "markdown", "typescript" },
	  sync_install = false,
	  highlight = { enable = true },
	  indent = { enable = true },
	})

        vim.opt.conceallevel = 2
      end
    },
    -- LSP Zero
    { "VonHeikemen/lsp-zero.nvim", branch = "v4.x" },
    -- LSP Config
    { "neovim/nvim-lspconfig" },
    -- Cmp
    { "hrsh7th/cmp-nvim-lsp" },
    {
      "hrsh7th/nvim-cmp",
      config = function()
        local cmp = require"cmp"
        cmp.setup{
          snippet = {
            expand = function(args)
              vim.snippet.expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<CR>'] = cmp.mapping.confirm {
              behavior = cmp.ConfirmBehavior.Replace,
              select = true,
            },
            ['<Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              else
                fallback()
              end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              else
                fallback()
              end
            end, { 'i', 's' }),
        }),
        sources = {
          { name = 'nvim_lsp' },
        }
      }
      end
    },
    -- Telescope
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope.nvim" },
  },
  install = { colorscheme = { "kanagawa" } },
})

vim.cmd([[
  set number
  set shiftwidth=2 smarttab
  set expandtab
  set tabstop=8 softtabstop=0
  set mouse=
  nnoremap <C-L><C-L> :set invrelativenumber<CR>

  nnoremap <leader>ff <cmd>Telescope find_files<CR>
  nnoremap <leader>fb <cmd>Telescope buffers<CR>
  nnoremap <leader>fg <cmd>Telescope live_grep<CR>
  nnoremap <leader>fh <Cmd>Telescope help_tags<CR>
  nnoremap <leader>ft <cmd>Telescope treesitter<CR>
]])

-- LSP Configurations
vim.opt.signcolumn = "yes"
local lspconfig_defaults = require("lspconfig").util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lspconfig_defaults.capabilities,
  require("cmp_nvim_lsp").default_capabilities()
)

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
  end,
})

local lspconfig = require("lspconfig")

lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = {
          "vim",
          "require",
        },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true)
      },
      telemetry = {
        enable = false,
      },
    },
  },
}

