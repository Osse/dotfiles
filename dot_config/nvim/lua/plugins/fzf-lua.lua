local is_inside_work_tree = {}

local function project_files(opts)
  opts = opts or {} -- define here if you want to define something

  local cwd = vim.fn.getcwd()
  if is_inside_work_tree[cwd] == nil then
    vim.fn.system("git rev-parse --is-inside-work-tree")
    is_inside_work_tree[cwd] = vim.v.shell_error == 0
  end

  if is_inside_work_tree[cwd] then
    require('fzf-lua').git_files(opts)
  else
    require('fzf-lua').files(opts)
  end
end

return {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- or if using mini.icons/mini.nvim
    -- dependencies = { "echasnovski/mini.icons" },
    opts = { 'telescope' },
    keys = {
        { "<leader>F", '<cmd>FzfLua live_grep<cr>', desc = "Live grep" },
        { 'Q', '<cmd>FzfLua buffers<CR>', desc = "Switch buffers" },
        { "<Leader>f", '<cmd>FzfLua grep_cword<cr>', desc = "grep string" },
        { '<C-P>', project_files, desc = "project files" },
        { '<Leader><C-P>', function() require('fzf-lua').git_files({ fzf_opts = { ["--query"] = vim.fn.expand("<cword>") } }) end, desc = "project files" },
        -- { '<C-P>', function() project_files({ default_text = vim.fn.expand("<cword>")}) end },
        -- { '<Leader>.<C-P>', function() tb.find_files({ cwd = vim.fn.expand("%:p:h")}) end },
    },
    init = function()
	require('fzf-lua').register_ui_select()
    end
}
