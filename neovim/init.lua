-- # initialization
-- ## disable netrw early
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- ## define vim-lua bridge functions
---@param v string | number | boolean value to be compared
---@return boolean
local is_true = function(v)
  -- vimscript variables and functions may not always return boolean, so wrapping up function can be useful
  return v == true or v == 1 or v == '1' or v == 'yes'
end

-- # native config
if not vim.g.vscode then
-- ## editor
-- ### tabstop
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
-- ### indent style
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
-- ### parentheses
vim.opt.showmatch = true
vim.opt.matchpairs:append '<:>' -- match xml-alike
-- ### folding
vim.opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
-- ## appearance / window
-- ### true color
if string.match(vim.env.TERM, '256-col') or vim.env.TERM == 'alacritty' then
  vim.opt.termguicolors = true
end
-- ### colorscheme
vim.opt.background = 'light'
-- ### font
if is_true(vim.fn.has('gui')) then
  vim.opt.guifont = 'SF Mono Square:h20'
end
-- ## appearance / editor
-- ### line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'
-- ### invisible chars
vim.opt.list = true
vim.opt.listchars = {
  tab = '>-',
  eol = '↴',
  trail = '_',
  extends ='>',
  precedes = '<',
  nbsp = '%'
}
-- ## misc
-- ### use mouse
vim.opt.mouse = 'a'
-- ### use system clipboard
vim.opt.clipboard = 'unnamedplus'
-- ### filesystem interaction
vim.opt.autochdir = true
-- ### how many lines to expect for modelines
vim.opt.modelines = 3
end

-- # package manager
-- ## load package manager
vim.cmd.packadd('vim-jetpack') -- need to manually call packadd as jetpack is vimscript plugin
-- ### define util functions
local p = {
  items = {},
  push = function(this, t)
    table.insert(this.items, t)
  end,
  load = function(this)
    require('jetpack.packer').add(this.items)
  end,
  sync = function(this)
    this:load()
    local jetpack = require('jetpack')
    for _, name in ipairs(jetpack.names()) do
      if not is_true(jetpack.tap(name)) then
        jetpack.sync() -- sync when any of the plugins uninstalled
        break
      end
    end
  end,
}
-- ## add packages
-- ### self
p:push {'tani/vim-jetpack', opt = 1} -- manage self
-- ### editor
p:push {'lewis6991/gitsigns.nvim', -- git-integration, require nvim v0.8+
  config = function()
    require('gitsigns').setup()
  end,
}
p:push {'tani/vim-typo'} -- auto-fix typos
p:push {'windwp/nvim-autopairs', -- auto-close pairs, require nvim v0.7+
  config = function()
    require('nvim-autopairs').setup()
  end,
}
p:push {'kylechui/nvim-surround', -- enhance surrounding chars, require nvim v0.8+
  config = function()
    require('nvim-surround').setup()
  end,
}
p:push {'tomtom/tcomment_vim'} -- enhance comment toggle
-- ## completion
-- ### util functions
local add_sources = function(arr)
  local sources = {}
  for _, v in ipairs(arr) do
    table.insert(sources, { name = v })
  end
  return sources
end
-- ### snippets
p:push {'dcampos/nvim-snippy'}
-- ### cmp sources
p:push {'hrsh7th/cmp-nvim-lsp'} -- lsp
p:push {'hrsh7th/cmp-nvim-lsp-signature-help'} -- function signatures
p:push {'hrsh7th/cmp-buffer'} -- buffer
p:push {'hrsh7th/cmp-path'} -- path
p:push {'hrsh7th/cmp-cmdline'} -- cmdline
p:push {'hrsh7th/cmp-nvim-lsp-document-symbol'} -- lsp document symbols
--- ### cmp formating
p:push {'onsails/lspkind.nvim'} -- icons for lsp
--- ### cmp
p:push {'hrsh7th/nvim-cmp', -- completion engine
  config = function()
    local cmp = require('cmp')
    cmp.setup{
      snippet = {
        expand = function(args)
          require('snippy').expand_snippet(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered{
          side_padding = 0.5,
        },
        documentation = cmp.config.window.bordered({
          border = 'single',
        }),
      },
      sources = cmp.config.sources(
        add_sources{'nvim_lsp', 'nvim_lsp_signature_help', 'snippy'},
        add_sources{'buffer'}
      ),
      mapping = cmp.mapping.preset.insert{
        ['<C-j>'] = cmp.mapping.select_next_item(),
        ['<C-k>'] = cmp.mapping.select_prev_item(),
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
      },
      formatting = {
        format = require('lspkind').cmp_format{
          mode = 'symbol_text',
          maxwidth = 50,
          ellipsis_char = '...',
        }
      },
    }
    cmp.setup.cmdline({'/', '?'}, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources(
        add_sources{'nvim_lsp_document_symbol'},
        add_sources{'buffer'}
      ),
    })
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources(
        add_sources{'cmdline'},
        add_sources{'path'}
      ),
    })
  end,
  after = {'hrsh7th/cmp-buffer', 'hrsh7th/cmp-path', 'hrsh7th/cmp-cmdline', 'hrsh7th/cmp-nvim-lsp'}
}
-- ## diagnostics / lsp
-- ### util functions
local lsp_langs = {}
local add_lsp = function(lsp)
  for _, value in ipairs(lsp) do
    table.insert(lsp_langs, value)
  end
end
if is_true(vim.fn.executable('node')) then -- require node.js
  add_lsp({
    'lua_ls',
    'bashls',
    'vimls',
    'dockerls', -- Dockerfile
    'docker_compose_language_service', -- Docker compose
    'yamlls' -- YAML
  })
end
if is_true(vim.fn.executable('go')) then -- require go
  add_lsp({'golangci_lint_ls'})
end
add_lsp({
  -- containers
  'helm_ls', -- helm
  -- plain text files
  'taplo', -- TOML
  'marksman', -- Markdown
})
local default_handlers = function(server_name)
  require('lspconfig')[server_name].setup{
    capabilities = require('cmp_nvim_lsp').default_capabilities()
  }
end
-- lua ls configuration, focusing on neovim lua
-- adapoted from: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
local lua_handlers = function()
  require('lspconfig').lua_ls.setup {
    on_init = function(client)
      local path = client.workspace_folders[1].name
      if not vim.loop.fs_stat(path..'/.luarc.json') and not vim.loop.fs_stat(path..'/.luarc.jsonc') then
        client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
          Lua = {
            runtime = { version = 'LuaJIT' },
            workspace = {
              checkThirdParty = false,
              library = { vim.env.VIMRUNTIME }
            },
          },
        })
        client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
      end
      return true
    end,
    capabilities = require('cmp_nvim_lsp').default_capabilities()
  }
end
-- ### packages
p:push {'neovim/nvim-lspconfig'} -- lsp configs, require nvim v0.8+
p:push {'williamboman/mason.nvim', -- lsp manager, require nvim v0.7+
  config = function()
    require("mason").setup()
  end,
}
p:push {'williamboman/mason-lspconfig.nvim', -- bridges lsfconfig and mason, require nvim v0.7+
  config = function()
    require("mason-lspconfig").setup {
      ensure_installed = lsp_langs,
      handlers = {
        default_handlers,
        ["lua_ls"] = lua_handlers,
      },
    }
  end,
  after = {'williamboman/mason.nvim', 'neovim/nvim-lspconfig', 'hrsh7th/cmp-nvim-lsp'}
}
p:push {'https://git.sr.ht/~whynothugo/lsp_lines.nvim', -- pretty diagnostics messages
  config = function()
    vim.diagnostic.config { virtual_text = false, virtual_lines = true }
    require('lsp_lines').setup()
  end,
}
p:push {'j-hui/fidget.nvim', -- stand-alone ui for lsp progress, require nvim v0.7+
  config = function()
    require("fidget").setup()
  end,
  tag = 'legacy',
}

-- ## syntax
-- ### util functions
-- link highlight groups introduced by nvim-treesitter:
-- some groups are linked by default, but some are not, so manually linking

-- adapted from: https://github.com/nvim-treesitter/nvim-treesitter/commit/42ab95d5e11f247c6f0c8f5181b02e816caa4a4f#commitcomment-87014462
local hl = function(group, opts)
  opts.default = true
  vim.api.nvim_set_hl(0, group, opts)
end

-- how to select highlight groups to be added:
--   a) those used by treesitter (details at nvim-treesitter/CONTRIBUTING.md)
--   b) those linked by default (details at h: treesitter-highlight-groups)
--   union a*b minus b
-- below have full list, with b commented out, to help future update

-- Misc {{{
-- hl('@comment', {link = 'Comment'})
hl('@comment.documentation', {link = 'SpecialComment'})
hl('@error', {link = 'Error'})
hl('@none', {bg = 'NONE', fg = 'NONE'})
-- hl('@preproc', {link = 'PreProc'})
-- hl('@define', {link = 'Define'})
-- hl('@macro', {link = 'Macro'})
-- hl('@operator', {link = 'Operator'})
-- hl('@structure', {link = 'Structure'}) -- not in highlighter.scm
-- }}}
-- Punctuation {{{
-- hl('@punctuation', {link = 'Delimiter'}) -- not in high  .scm
hl('@punctuation.delimiter', {link = 'Delimiter'})
hl('@punctuation.bracket', {link = 'Delimiter'})
hl('@punctuation.special', {link = 'Delimiter'})
-- }}}
-- Literals {{{
-- hl('@string', {link = 'String'})
hl('@string.documentation', {link = 'SpecialComment'})
hl('@string.regex', {link = 'String'})
-- hl('@string.escape', {link = 'SpecialChar'})
-- hl('@string.special', {link = 'SpecialChar'})
-- hl('@character', {link = 'Character'})
-- hl('@character.special', {link = 'SpecialChar'})
-- hl('@boolean', {link = 'Boolean'})
-- hl('@number', {link = 'Number'})
-- hl('@float', {link = 'Float'})
-- }}}
-- Functions {{{
-- hl('@function', {link = 'Function'})
-- hl('@function.builtin', {link = 'Special'})
hl('@function.call', {link = 'Function'})
-- hl('@function.macro', {link = 'Macro'})
-- hl('@method', {link = 'Function'})
hl('@method.call', {link = 'Function'})
-- hl('@constructor', {link = 'Special'})
-- hl('@parameter', {link = 'Identifier'})
-- }}}
-- Keywords {{{
-- hl('@keyword', {link = 'Keyword'})
hl('@keyword.coroutine', {link = 'Keyword'})
hl('@keyword.function', {link = 'Keyword'})
hl('@keyword.operator', {link = 'Keyword'})
hl('@keyword.return', {link = 'Keyword'})
-- hl('@conditional', {link = 'Conditional'})
hl('@conditional.tenary', {link = 'Conditional'})
-- hl('@repeat', {link = 'Repeat'})
-- hl('@debug', {link = 'Debug'})
-- hl('@label', {link = 'Label'})
-- hl('@include', {link = 'Include'})
-- hl('@exception', {link = 'Exception'})
-- }}}
--
-- Types {{{
-- hl('@type', {link = 'Type'})
hl('@type.builtin', {link = 'Special'})
-- hl('@type.definition', {link = 'Typedef'})
hl('@type.qualifier', {link = 'Type'})
-- hl('@storageclass', {link = 'StorageClass'})
hl('@attribute', {link = 'PreProc'})
-- hl('@field', {link = 'Identifier'})
-- hl('@property', {link = 'Identifier'})
-- }}}
-- Identifiers {{{
-- hl('@variable', {link = 'Identifier'})
hl('@variable.builtin', {link = 'Special'})
-- hl('@constant', {link = 'Constant'})
-- hl('@constant.builtin', {link = 'Special'})
-- hl('@constant.macro', {link = 'Define'})
-- hl('@namespace', {link = 'Include'})
hl('@symbol', {link = 'Identifier'})
-- }}}
-- Text {{{
hl('@text', {link = 'Normal'})
hl('@text.strong', {bold = true})
hl('@text.emphasis', {italic = true})
-- hl('@text.underline', { link = 'Underlined' })
hl('@text.strike', {strikethrough = true})
-- hl('@text.title', {link = 'Title'})
hl('@text.quote', {link = 'Normal'})
-- hl('@text.uri', {link = 'Underlined'})
hl('@text.math', {link = 'Special'})
hl('@text.environment', {link = 'Macro'})
hl('@text.environment.name', {link = 'Type'})
-- hl('@text.reference', {link = 'Identifier'})
-- hl('@text.literal', {link = 'Comment'})
hl('@text.literal.block', {link = 'Comment'})
--  hl('@text.todo', {link = 'Todo'})
hl('@text.note', {link = 'SpecialComment'})
hl('@text.warning', {link = 'WarningMsg'})
hl('@text.warning', {link = 'WarningMsg'})
hl('@text.diff.add', {link = 'DiffAdd'})
hl('@text.diff.delete', {link = 'DiffDelete'})
-- }}}
-- Tags {{{
-- hl('@tag', {link = 'Tag'})
hl('@tag.attribute', {link = 'Identifier'})
hl('@tag.delimiter', {link = 'Delimiter'})
-- }}}
-- Conceal {{{
hl('@conceal', {link = 'Conceal'})
-- }}}
-- Spell {{{
hl('@spell', {link = 'Normal'})
hl('@nospell', {link = 'Normal'})
--- }}}
-- }
-- ### packages
p:push {'nvim-treesitter/nvim-treesitter', -- intelligent syntax highlight, require nvim v0.9.1+
  run = function()
    local ok, _ = pcall(require, 'nvim-treesitter')
    if ok then
      vim.cmd.TSUpdate()
    end
  end,
}

-- ## appearance
-- ### util functions
-- adapted from: https://github.com/kevinhwang91/nvim-ufo#customize-fold-text
local handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = (' ↙%d '):format(endLnum - lnum)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
        else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, {chunkText, hlGroup})
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
        end
        curWidth = curWidth + chunkWidth
    end
    table.insert(newVirtText, {suffix, 'MoreMsg'})
    return newVirtText
end
-- ### packages
p:push {'zefei/vim-wintabs'} --- tabbar
p:push {'kevinhwang91/nvim-ufo', -- advanced folding
  config = function()
    require('ufo').setup({
      provider_selector = function(...)
          return {'treesitter', 'indent'}
      end,
      fold_virt_text_handler = handler
    })
    vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
    vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
  end,
  requires = {'kevinhwang91/promise-async'},
}
p:push {'overcache/NeoSolarized', -- colorscheme
  config = function()
    vim.cmd.colorscheme('NeoSolarized')
  end,
}
p:push {'stevearc/oil.nvim', -- file tree, require nvim 0.8+
  config = function()
    require("oil").setup()
  end,
  requires = {'nvim-tree/nvim-web-devicons'},
}
p:push {'mvllow/modes.nvim', -- line decoration
  config = function()
    require('modes').setup{
      colors = {
        copy = "#b58900", -- gui_yellow
        delete = "#cb4b16", -- gui_orange
        insert = "#073642", -- gui_base02
        visual = "#6c71c4", -- gui_violet
      },
    }
  end,
  after = {'lukas-reineke/indent-blankline.nvim'}
}
p:push {'lukas-reineke/indent-blankline.nvim', -- indent line
  config = function()
    require('ibl').setup {}
  end,
}
p:push {'luochen1990/rainbow', -- rainbow parentheses
  config = function()
    vim.g.rainbow_active = true
  end,
}

-- add packages by conditions
if is_true(vim.fn.executable('node')) then -- require node.js
  p:push {'github/copilot.vim',
    run = function() -- AI copilot
      vim.cmd.Copilot('setup')
    end,
  }
end

-- load and sync packages
p:sync()

-- syntax
vim.cmd.syntax 'on'
