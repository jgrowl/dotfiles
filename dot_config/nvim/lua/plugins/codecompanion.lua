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

    opts = {
      log_level = 'DEBUG',
    },
  },
}
