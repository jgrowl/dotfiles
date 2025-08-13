print 'Loaded gp_project.lua!'

return {
  'robitx/gp.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local ok, gp = pcall(require, 'gp')
    if not ok then
      vim.notify('gp.nvim not found', vim.log.levels.ERROR)
      return
    end

    local model = 'gpt-4o'

    -- Optional pretty name for display in chat header
    local model_pretty = ({
      ['gpt-4o'] = 'ChatGPT-o3',
      ['gpt-4'] = 'ChatGPT-4',
      ['gpt-3.5-turbo'] = 'ChatGPT-3.5',
      ['gpt-4-0613'] = 'ChatGPT-4 (0613)',
    })[model] or model

    gp.setup {
      openai_api_key = os.getenv 'OPENAI_API_KEY',
      -- gpt-4, gpt-4, gpt-3.5-turbo, gpt-4-0613
      model = model, -- or "gpt-4" if you want GPT-4 legacy
    }

    local function get_project_patterns()
      local ft = vim.bo.filetype
      local patterns = {
        rust = { 'Cargo.toml', 'Readme.md', '*.md', 'src/**/*.rs', 'src/*.rs' },
        lua = { '*.lua' },
        python = { '*.py', 'pyproject.toml', 'requirements.txt' },
        javascript = { '*.js', '*.ts', 'package.json' },
        typescript = { '*.ts', '*.tsx', 'tsconfig.json' },
      }
      return patterns[ft] or { '*.txt', '*.md' }
    end

    vim.api.nvim_create_user_command('GpProjectChat', function()
      local root = vim.fn.getcwd()
      local patterns = get_project_patterns()

      local all_files = {}
      for _, pattern in ipairs(patterns) do
        local files = vim.fn.globpath(root, pattern, false, true)
        vim.list_extend(all_files, files)
      end

      -- De-duplicate
      local seen, unique_files = {}, {}
      for _, f in ipairs(all_files) do
        if not seen[f] then
          seen[f] = true
          table.insert(unique_files, f)
        end
      end

      -- Gather context
      local context_parts = {}
      for _, file in ipairs(unique_files) do
        if vim.fn.getfsize(file) < 100000 then
          local lines = vim.fn.readfile(file)
          if #lines < 1500 then
            table.insert(context_parts, ('-- FILE: %s --\n%s'):format(vim.fn.fnamemodify(file, ':~:.'), table.concat(lines, '\n')))
          end
        end
      end
      local context = table.concat(context_parts, '\n\n')

      -- Start new chat
      vim.cmd 'GpChatNew'

      vim.defer_fn(function()
        local buf = vim.api.nvim_get_current_buf()
        local filename = vim.api.nvim_buf_get_name(buf):match '([^/]+)$' or 'project.md'

        local header = {
          '# topic: ?',
          '',
          ('- file: %s'):format(filename),
          '',
          'Write your queries after 💬:. Use <C-g><C-g> or :GpChatRespond to generate a response.',
          'Response generation can be terminated by using <C-g>s or :GpChatStop command.',
          'Chats are saved automatically. To delete this chat, use <C-g>d or :GpChatDelete.',
          'Be cautious of very long chats. Start a fresh chat by using <C-g>c or :GpChatNew.',
          '',
          '---',
          '',
          '💬:',
          '',
          'PROJECT CONTEXT BELOW:',
          '',
        }

        local context_lines = vim.split(context, '\n', { plain = true })
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.list_extend(header, context_lines))
      end, 100)
    end, {})

    -- Keymap
    vim.keymap.set('n', '<leader>gP', ':GpProjectChat<CR>', { desc = 'Start GPT persistent chat with context' })
  end,
}
