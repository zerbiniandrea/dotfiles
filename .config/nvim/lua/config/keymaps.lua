-- ~/.config/nvim/lua/config/keymaps.lua
-- LazyVim keybindings inspired by ThePrimeagen

local map = vim.keymap.set

-- Delete to void register (doesn't replace clipboard)
-- This is Prime's "greatest remap ever" - prevents losing your clipboard when deleting
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete to void register" })

-- Half page jumping with centered cursor
-- Much better than default - keeps your cursor in the middle of screen
--map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
--map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Search with centered results
-- Keeps search results in the center of your screen
--map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
--map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Join lines but keep cursor position
-- Better than default J which moves cursor to end
--map("n", "J", "mzJ`z", { desc = "Join line (keep cursor position)" })

-- Paste over selection without yanking deleted text
-- This prevents losing your clipboard when pasting over text
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

-- Better escape alternative (optional - some love it, some hate it)
-- map("i", "<C-c>", "<Esc>", { desc = "Escape with Ctrl-C" })

-- Caps Lock to Escape (Neovim only - no system changes needed)
-- This maps the caps lock key to escape only within Neovim
map("i", "<C-[>", "<Esc>", { desc = "Escape with Caps Lock" })
map("n", "<C-[>", "<Esc>", { desc = "Escape with Caps Lock" })
map("v", "<C-[>", "<Esc>", { desc = "Escape with Caps Lock" })

-- Disable arrow keys in normal mode (forces you to use hjkl)
map("n", "<left>", "<cmd>echo 'Use h to move!!'<CR>")
map("n", "<right>", "<cmd>echo 'Use l to move!!'<CR>")
map("n", "<up>", "<cmd>echo 'Use k to move!!'<CR>")
map("n", "<down>", "<cmd>echo 'Use j to move!!'<CR>")

-- Also disable in insert mode to build muscle memory
--map("i", "<left>", "<nop>")
--map("i", "<right>", "<nop>")
--map("i", "<up>", "<nop>")
--map("i", "<down>", "<nop>")

-- Disable in visual mode too
map("v", "<left>", "<nop>")
map("v", "<right>", "<nop>")
map("v", "<up>", "<nop>")
map("v", "<down>", "<nop>")

-- Quick word replacement under cursor
-- Starts a search/replace for the word under cursor
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })

-- Move lines up/down in visual mode
-- Super useful for reorganizing code blocks
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Disable Ex mode (easy to hit accidentally)
map("n", "Q", "<nop>", { desc = "Disable Ex mode" })
