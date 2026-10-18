return {
  'olimorris/codecompanion.nvim',

  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },

  -- Display API failures, including exhausted credits and rate limits.
  init = function()
    local group = vim.api.nvim_create_augroup('CodeCompanionErrors', {
      clear = true,
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'CodeCompanionChatCreated',
      group = group,
      callback = function(args)
        local chat = require('codecompanion').buf_get_chat(args.data.bufnr)

        if not chat then
          return
        end

        chat:add_callback('on_completed', function(_, result)
          if result.status ~= 'error' then
            return
          end

          local message = result.error

          if type(message) == 'table' then
            message = message.message or vim.inspect(message)
          end

          message = tostring(message or 'Unknown request error')

          vim.schedule(function()
            vim.notify('CodeCompanion request failed:\n' .. message, vim.log.levels.ERROR, { title = 'CodeCompanion' })
          end)
        end)
      end,
    })
  end,

  keys = {
    {
      '<leader>mx',
      '<cmd>CodeCompanionActions<cr>',
      mode = { 'n', 'v' },
      desc = 'AI prompt actions',
    },
    {
      '<leader>mt',
      '<cmd>CodeCompanionChat Toggle<cr>',
      mode = 'n',
      desc = 'AI prompt chat',
    },
    {
      '<leader>mN',
      '<cmd>CodeCompanionChat<cr>',
      mode = 'n',
      desc = 'New AI prompt chat',
    },
    {
      '<leader>mi',
      '<cmd>CodeCompanion<cr>',
      mode = { 'n', 'v' },
      desc = 'AI prompt inline',
    },
  },

  opts = {
    mcp = {
      servers = {
        ['firefox-devtools'] = {
          cmd = {
            'npx',
            '-y',
            '@mozilla/firefox-devtools-mcp@latest',
            '--connect-existing',
            '--marionette-port',
            '2828',
          },
        },
      },

      opts = {
        default_servers = { 'firefox-devtools' },
      },
    },

    interactions = {
      chat = {
        keymaps = {
          close = false,
        },

        adapter = {
          name = 'openai_responses',
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
            -- Tools and/or groups loaded in every new chat.
            default_tools = { 'agent' },

            -- Run normal editing tools automatically while restricting shell
            -- commands to the safe_commands list below.
            approval_mode = 'auto',

            -- Send tool output back to the model automatically.
            auto_submit_success = true,
            auto_submit_errors = true,
          },

          ['run_command'] = {
            opts = {
              safe_commands = {
                'pwd',
                'ls',
                'git status',
                'git diff',
                'cargo test',
                'cargo check',
                'cargo build',
                'cargo clippy',
                'cargo fmt',
              },
            },
          },

          ['delete_file'] = {
            opts = {
              protect = true,
            },
          },
        },
      },

      inline = {
        adapter = {
          name = 'openai_responses',
          model = 'gpt-5.5',
        },
      },

      cmd = {
        adapter = {
          name = 'openai_responses',
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

      coding = {
        description = 'General software-development workflow and standards',
        files = {
          vim.fn.expand '~/.config/nvim/ai/codecompanion/coding.md',
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

      -- Optional: Urania-specific rules.
      urania = {
        description = 'Urania astrology app rules',
        files = {
          '.codecompanion/urania.md',
        },
      },

      -- Optional: Kleio-specific rules.
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
          autoload = function()
            local cwd = vim.fn.getcwd()
            local groups = {
              'global',
              'coding',
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
