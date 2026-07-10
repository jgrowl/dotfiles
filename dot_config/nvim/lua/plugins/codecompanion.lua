return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },

  keys = {
    { '<leader>mx', '<cmd>CodeCompanionActions<cr>', mode = { 'n', 'v' }, desc = 'AI prompt actions' },
    { '<leader>mt', '<cmd>CodeCompanionChat Toggle<cr>', mode = 'n', desc = 'AI prompt chat' },
    { '<leader>mN', '<cmd>CodeCompanionChat<cr>', mode = 'n', desc = 'New AI prompt chat' },
    { '<leader>mi', '<cmd>CodeCompanion<cr>', mode = { 'n', 'v' }, desc = 'AI prompt inline' },
  },

  opts = {
    interactions = {
      chat = {
        keymaps = {
          close = false,
        },

        adapter = {
          name = 'openai',
          model = 'gpt-5.5',
        },

        -- Keep CodeCompanion's default system prompt.
        -- Project-specific behavior is added through rules below.
        opts = {
          system_prompt = function(ctx)
            return ctx.default_system_prompt
          end,
        },

        tools = {
          opts = {
            -- Tools and/or groups that are always loaded in a chat buffer.
            -- Built-in groups include: agent, files.
            default_tools = { 'agent' },

            -- Send tool output back to the model automatically.
            auto_submit_success = true,
            auto_submit_errors = true,
          },
        },
      },

      inline = {
        adapter = {
          name = 'openai',
          model = 'gpt-5.5',
        },
      },

      cmd = {
        adapter = {
          name = 'openai',
          model = 'gpt-5.5',
        },
      },
    },

    rules = {
      -- Personal defaults that should apply everywhere.
      global = {
        description = 'General coding preferences',
        files = {
          vim.fn.expand '~/.config/nvim/ai/codecompanion/global.md',
        },
      },

      -- Rust/Leptos-specific defaults.
      rust_leptos = {
        description = 'Rust, Leptos, wasm, and UI conventions',
        files = {
          vim.fn.expand '~/.config/nvim/ai/codecompanion/rust-leptos.md',
        },
      },

      -- Repository-local instruction files.
      -- These let each repo override or extend the global rules without
      -- hardcoding all instructions in your Neovim config.
      project = {
        description = 'Repository-local project instructions',
        files = {
          'AGENTS.md',
          'CLAUDE.md',
          '.codecompanion/rules.md',
          '.codecompanion/project.md',
          '.github/copilot-instructions.md',
        },
      },

      -- Optional: Ourania-specific rules.
      -- This file can exist only inside the Ourania repo.
      urania = {
        description = 'Urania astrology app rules',
        files = {
          '.codecompanion/urania.md',
        },
      },

      -- Optional: Kleio-specific rules.
      -- This file can exist only inside the Kleio repo.
      kleio = {
        description = 'Kleio genealogy/data rules',
        files = {
          '.codecompanion/kleio.md',
        },
      },

      opts = {
        chat = {
          enabled = true,

          -- These rule groups are loaded into every new chat.
          -- If a referenced repo-local file does not exist, CodeCompanion
          -- may warn in the log; that is usually harmless.
          autoload = function()
            local cwd = vim.fn.getcwd()
            local groups = {
              'global',
              'project',
            }

            local is_rust = vim.fn.filereadable(cwd .. '/Cargo.toml') == 1
            local is_urania = cwd:find('urania', 1, true) ~= nil
            local is_kleio = cwd:find('kleio', 1, true) ~= nil

            if is_rust or is_urania or is_kleio then
              table.insert(groups, 'rust_leptos')
            end

            if is_urania then
              table.insert(groups, 'urania')
            end

            if is_kleio then
              table.insert(groups, 'kleio')
            end

            return groups
          end,
        },
      },
    },

    opts = {
      log_level = 'DEBUG',
    },
  },
}
