-- Disable default macro recording key
vim.keymap.set('n', 'q', '<nop>', { desc = 'Disable accidental macro recording' })

-- Remap macro recording to Q
vim.keymap.set('n', 'Q', 'q', { desc = 'Start macro recording' })
