--[[
    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html
If you experience any errors while trying to install kickstart, run `:checkhealth` for more info
--]]

vim.g.mapleader = " " -- See `:help mapleader`
vim.g.maplocalleader = " "

-- [[ Install `lazy.nvim` plugin manager ]]. See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]. To check the current status of your plugins, run :Lazy. To update, :Lazy update
require("lazy").setup({
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },
  {
    "kyazdani42/nvim-tree.lua",
    opts = { view = { side = "right" }, git = { enable = true, ignore = false, timeout = 500 } },
  },
  { "JoosepAlviste/nvim-ts-context-commentstring", opts = {} },
  { -- Comments!
    "numToStr/Comment.nvim",
    opts = {
      toggler = { line = "<leader>c", block = "<leader>bc" },
      opleader = { line = "<leader>c", block = "<leader>bc" },
    },
  },
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VimEnter",
    config = function()               -- This is the function that runs, AFTER loading
      require("which-key").setup()
      require("which-key").register({ -- Document existing key chains
        ["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
        ["<leader>d"] = { name = "[D]ocument", _ = "which_key_ignore" },
        ["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
        ["<leader>s"] = { name = "[S]earch", _ = "which_key_ignore" },
        ["<leader>w"] = { name = "[W]orkspace", _ = "which_key_ignore" },
      })
    end,
  },
  { -- Fuzzy Finder (files, lsp, etc)
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    branch = "0.1.x",
    opts = {
      defaults = {
        vimgrep_arguments = vimgrep_arguments, -- `hidden = true` is not supported in text grep commands.
      },
      pickers = {
        find_files = {
          find_command = {
            "rg",
            "--files",
            "--hidden",           -- make :Telescope find_files find hidden files
            "--no-ignore",        -- make :Telescope find_files not respect gitignore
            "--glob",
            "!**/.git/*",         -- But it still won't look inside of these folders
            "--glob",
            "!**/node_modules/*", -- But it still won't look inside of these folders
          },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-tree/nvim-web-devicons" }, -- Ensure Nerd Font is being used
      { "nvim-telescope/telescope-ui-select.nvim" },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",   -- `build` is used to run some command when the plugin is installed/updated. This is only run then, not every time Neovim starts up.
        cond = function() -- `cond` is a condition used to determine whether this plugin should be installed and loaded.
          return vim.fn.executable("make") == 1
        end,
      },
    },
    config = function()
      -- Use Normal mode: ? to opens a window that shows you all of the keymaps for the current telescope picker. This is really useful to discover what Telescope can do as well as how to actually do it!
      require("telescope").setup({ -- See `:help telescope` and `:help telescope.setup()`
        -- You can put your default mappings / updates / etc. in here. All the info you're looking for is in `:help telescope.setup()`
        -- defaults = { mappings = { i = { ['<c-enter>'] = 'to_fuzzy_refine' }, }, },
        -- pickers = {}
        extensions = { ["ui-select"] = { require("telescope.themes").get_dropdown() } },
      })

      -- Enable telescope extensions, if they are installed
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")

      local builtin = require("telescope.builtin") -- See `:help telescope.builtin`
      vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
      vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
      vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
      vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
      vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
      vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
      vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
      vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
      vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

      -- Slightly advanced example of overriding default behavior and theme. Also possible to pass additional configuration options. See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set("n", "<leader>/", function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        builtin.current_buffer_fuzzy_find(
          require("telescope.themes").get_dropdown({ winblend = 10, previewer = false })
        )
      end, { desc = "[/] Fuzzily search in current buffer" })

      vim.keymap.set("n", "<leader>s/", function()
        builtin.live_grep({ grep_open_files = true, prompt_title = "Live Grep in Open Files" })
      end, { desc = "[S]earch [/] in Open Files" })

      vim.keymap.set("n", "<leader>sn", function() -- Shortcut for searching your neovim configuration files
        builtin.find_files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "[S]earch [N]eovim files" })
    end,
  },

  { -- LSP Configuration & Plugins
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for neovim
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim", opts = {} }, -- Useful status updates for LSP. `opts = {}` is the same as calling `require('fidget').setup({})`
    },
    config = function()
      --  This function gets run when an LSP attaches to a particular buffer. That is to say, every time a new file is opened that is associated with an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          -- We create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          local override_formatters = {
            astro = function()
              vim.cmd("silent !prettier --write --experimental-ternaries " ..
                vim.fn.shellescape(vim.api.nvim_buf_get_name(0)))
            end,
            rust = function()
              vim.cmd("silent !cargo fmt -- " .. vim.fn.shellescape(vim.api.nvim_buf_get_name(0)))
            end,
            templ = function()
              vim.cmd("!templ fmt -- " .. vim.fn.shellescape(vim.api.nvim_buf_get_name(0)))
            end,
          }

          vim.lsp.buf.format = override_formatters[vim.bo.filetype] or vim.lsp.buf.format

          map("<leader>lf", vim.lsp.buf.format, "[L]SP [F]ormat")                                      -- Format file
          map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")               -- Jump to the definition of the word under your cursor. To jump back, press <C-T>.
          map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")                -- Find references for the word under your cursor.
          map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")       -- Jump to the implementation of the word under your cursor. Useful when your language has ways of declaring types without an actual implementation.
          map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")     -- Jump to the type of the word under your cursor. Useful when you're not sure what type a variable is and you want to see the definition of its *type*, not where it was *defined*.
          map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols") -- Fuzzy find all the symbols in your current document. Symbols are things like variables, functions, types, etc.
          map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")                                          -- Rename the variable under your cursor. Most Language Servers support renaming across files, etc
          map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")                                -- Execute a code action, usually your cursor needs to be on top of an error or a suggestion from your LSP for this to activate.
          map("H", vim.lsp.buf.hover, "[H]over Documentation")                                         -- Opens a popup that displays documentation about the word under your cursor See `:help K` for why this keymap
          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")                                   -- This is not Goto Definition, this is Goto Declaration. For example, in C this would take you to the header
          map(
            "<leader>ws",
            require("telescope.builtin").lsp_dynamic_workspace_symbols,
            "[W]orkspace [S]ymbols"
          ) -- Fuzzy find all the symbols in your current workspace Similar to document symbols, except searches over your whole project.

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities() -- LSP servers and clients are able to communicate to each other what features they support. By default, Neovim doesn't support everything that is in the LSP Specification. When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities. So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      --  See `:help lspconfig-all` for a list of all the pre-configured LSPs
      vim.filetype.add({ extension = { templ = "templ" } })
      vim.filetype.add({ extension = { mdx = "mdx" } })
      vim.treesitter.language.register("markdown", "mdx")
      local servers = {
        html = { filetypes = { "html", "templ" } },
        htmx = { filetypes = { "html", "templ" } },
        tailwindcss = {
          filetypes = { "templ", "astro", "javascript", "typescript", "react" },
          init_options = { userLanguages = { templ = "html" } },
        },
        astro = {},
        templ = {},
        clangd = {},
        gopls = {
          settings = {
            gopls = {
              semanticTokens = true,
              staticcheck = true,
              analyses = { unusedparams = true },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
            },
          },
        },
        pyright = {},
        rust_analyzer = {},
        tsserver = {},
        lua_ls = {
          -- cmd = {...},
          -- filetypes {...},
          -- capabilities = {...},
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              workspace = { -- Tells lua_ls where to find all the Lua files that you have loaded for your neovim configuration. If lua_ls is really slow on your computer, you can try this instead: library = { vim.env.VIMRUNTIME },
                library = {
                  checkThirdParty = false,
                  "${3rd}/luv/library",
                  unpack(vim.api.nvim_get_runtime_file("", true)),
                },
              },
              completion = {
                callSnippet = "Replace",
              },
              -- diagnostics = { disable = { "missing-fields" } }, -- You can toggle this to ignore Lua_LS's noisy `missing-fields` warnings
              diagnostics = { enable = false }, -- You can toggle this to ignore Lua_LS's noisy `missing-fields` warnings
            },
          },
        },
      }

      require("mason").setup()
      -- You can add other tools here that you want Mason to install for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, { "stylua" })
      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {}) -- This handles overriding only values explicitly passed by the server configuration above. Useful when disabling certain features of an LSP (for example, turning off formatting for tsserver)
            require("lspconfig")[server_name].setup(server)
          end,
        },
      })
    end,
  },
  { -- Autocompletion
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        "L3MON4D3/LuaSnip",
        build = (function()
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
            return
          end -- Build Step is needed for regex support in snippets This step is not supported in many windows environments Remove the below condition to re-enable on windows
          return "make install_jsregexp"
        end)(),
      },
      "saadparwaiz1/cmp_luasnip",

      -- Adds other completion capabilities. nvim-cmp does not ship with all sources by default. They are split into multiple repos for maintenance purposes.
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",

      "rafamadriz/friendly-snippets", -- If you want to add a bunch of pre-configured snippets, you can use this plugin to help you. It even has snippets for various frameworks/libraries/etc. but you will have to set up the ones that are useful for you.
    },
    config = function()
      -- See `:help cmp`
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      luasnip.config.setup({})

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = "menu,menuone,noinsert" },

        -- For an understanding of why these mappings were chosen, you will need to read `:help ins-completion`. No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert({
          ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
          ["<C-Space>"] = cmp.mapping.complete({}),
          ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
          ["<C-u>"] = cmp.mapping.scroll_docs(-4),
          ["<C-d>"] = cmp.mapping.scroll_docs(4),
          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ["<C-l>"] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { "i", "s" }),
          ["<C-h>"] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        },
      })
    end,
  },

  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then change the command in the config to whatever the name of that colorscheme is
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`
    "catppuccin/nvim",
    lazy = false,                             -- make sure we load this during startup if it is your main colorscheme
    priority = 1000,                          -- make sure to load this before all the other start plugins
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha") -- Load the colorscheme here
      vim.cmd.hi("Comment gui=none")          -- You can configure highlights by doing something like
    end,
  },

  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  }, -- Highlight todo, notes, etc in comments

  {  -- Collection of various small independent plugins/modules
    "echasnovski/mini.nvim",
    config = function()
      -- Better Around/Inside textobjects
      -- Examples:
      --  va)  - [V]isually select [A]round [)]paren
      --  yinq - [Y]ank [I]nside [N]ext [']quote
      --  ci'  - [C]hange [I]nside [']quote
      require("mini.ai").setup({ n_lines = 500 })

      -- seems cool but disabled because it changes default behavior of 's' by itself - me 05apr2024
      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --  saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      --  sd'   - [S]urround [D]elete [']quotes
      --  sr)'  - [S]urround [R]eplace [)] [']
      -- require("mini.surround").setup()
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      options = { icons_enabled = false },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 3 }, "filesize", "encoding" },
        lualine_x = { "searchcount" },
        lualine_y = {
          function() -- Get a list of all LSPs active, and return them in a comma-separated string.
            local clients = vim.lsp.get_active_clients()
            if next(clients) == nil then
              return "No LSP"
            else
              local client_names = {}
              for _, client in ipairs(clients) do
                table.insert(client_names, client.name)
              end
              return table.concat(client_names, ", ")
            end
          end,
        },
        lualine_z = { "hostname", "location" },
      },
    },
  },

  { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
      -- Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      -- Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
      -- Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "bash", "c", "html", "lua", "markdown", "vim", "vimdoc" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  {                                 -- Markdown
    "iamcco/markdown-preview.nvim", -- https://github.com/iamcco/markdown-preview.nvim
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },
  { -- LaTeX
    "lervag/vimtex",
    dependencies = { "debian-tex/latexmk" },
  },
  -- The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`. This is the easiest way to modularize your config.
  -- Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going. For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
  --
  -- { import = 'custom.plugins' },
})

-- Nvim-Tree recipe. https://github.com/nvim-tree/nvim-tree.lua/wiki/Open-At-Startup#open-for-files-and-no-name-buffers
-- vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = function open_nvim_tree(data)
-- 	local directory = vim.fn.isdirectory(data.file) == 1 -- buffer is a directory
-- 	if not directory then return end -- If opening a file, don't open nvim-tree!
-- 	vim.cmd.cd(data.file) -- change to the directory
-- 	require("nvim-tree.api").tree.open() -- open the tree
-- end })

-- See `:help vim.opt`. For more options, you can see `:help option-list`
-- vim.opt.clipboard = "unnamedplus" -- Sync clipboard between OS and Neovim. Remove this option if you want your OS clipboard to remain independent. See `:help 'clipboard'`
vim.opt.number = true        -- alternatively, vim.opt.relativenumber = true
vim.opt.mouse = "a"          -- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.showmode = false     -- Don't show the mode, since it's already in status line
vim.opt.breakindent = true   -- Enable break indent
vim.opt.undofile = true      -- Save undo history
vim.opt.ignorecase = true    -- Case-insensitive searching
vim.opt.smartcase = true     -- UNLESS \C or capital in search
vim.opt.signcolumn =
"yes"                        -- Keep signcolumn on by default (extra column beside line number for information e.g. git, diagnostic)
vim.opt.updatetime = 250     -- Decrease update time
vim.opt.timeoutlen = 300
vim.opt.splitright = true    -- Configure how new splits should be opened
vim.opt.splitbelow = true
vim.opt.list = false         -- Sets how neovim will display certain whitespace in the editor. See `:help 'list'` and `:help 'listchars'`
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split" -- Preview substitutions live, as you type!
vim.opt.cursorline = true    -- Show which line your cursor is on
vim.opt.scrolloff = 10       -- Minimal number of screen lines to keep above and below the cursor.
vim.wo.wrap = false          -- Disable line wrap
vim.opt.shiftwidth = 8
vim.opt.expandtab = true

vim.g["vimtex_view_method"] = "zathura"
vim.g["vimtex_view_general_viewer"] = "okular"
vim.g["vimtex_view_general_options"] = "-unique file:@pdf\\#src:@line@tex"
vim.g["vimtex_compiler_method"] = "latexmk"

-- [[ Basic Keymaps ]] See `:help vim.keymap.set()`
vim.opt.hlsearch = true                             -- Set highlight on search
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>") -- Clear search on pressing <Esc> in normal mode
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Use CTRL+<hjkl> to switch between windows. See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<C-1>", "<cmd>1wincmd w<CR>", { desc = "Move focus to window 1" })
vim.keymap.set("n", "<C-2>", "<cmd>2wincmd w<CR>", { desc = "Move focus to window 2" })
vim.keymap.set("n", "<C-3>", "<cmd>3wincmd w<CR>", { desc = "Move focus to window 3" })
vim.keymap.set("n", "<C-4>", "<cmd>4wincmd w<CR>", { desc = "Move focus to window 4" })
vim.keymap.set("n", "<C-0>", "<Cmd>NvimTreeFocus<CR>", { desc = "Focus NvimTree" })
vim.keymap.set("n", "<C-)>", "<Cmd>NvimTreeClose<CR>", { desc = "Close NvimTree" })
vim.keymap.set("n", "<C-_>", "<cmd>vertical resize -16<CR>", { desc = "Shrink window" })
vim.keymap.set("n", "<C-+>", "<cmd>vertical resize +16<CR>", { desc = "Grow window" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("n", "J", "mzJ`z", { desc = "When Jing, keep cursor at start" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Keep cursor in middle when going up" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Keep cursor in middle when going down" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Keep cursor in middle when searching" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Keep cursor in middle when searching" })
vim.keymap.set("n", "<leader>h", "<cmd>noh<CR>", { desc = "Unhighlight find selections" })
vim.keymap.set({ "n", "v", "x" }, "<leader>p", [["_dP]], { desc = "System clipboard paste" })
vim.keymap.set({ "n", "v", "x" }, "<leader>y", [["+y]], { desc = "System clipboard yank" })
vim.keymap.set({ "n", "v", "x" }, "<leader>d", [["_d]], { desc = "Delete text into empty buffer" })
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Next entry in quickfix list" })
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Previous entry in quickfix list" })
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Next entry in location list" })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Previous entry in location list" })
vim.keymap.set(
  "n",
  "<leader>s",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Find and replace word on hover" }
)
--
-- [[ Basic Autocommands ]] See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text. Try it with `yap` in normal mode. See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- vim.api.nvim_create_autocmd("BufEnter", {
-- 	pattern = "*.templ",
-- 	callback = function()
-- 		vim.cmd("TSBufEnable highlight")
-- 	end,
-- })

-- Go automatic import sorting
-- https://github.com/golang/tools/blob/master/gopls/doc/vim.md#imports-and-formatting
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
    require("conform").format() -- Using conform to format
    -- vim.lsp.buf.format({ async = false })
  end,
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
