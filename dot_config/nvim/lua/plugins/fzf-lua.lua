local is_inside_work_tree = {}

local function project_files(opts)
  opts = opts or {} -- define here if you want to define something

  if is_inside_work_tree[opts.cwd] == nil then
    vim.fn.system("git rev-parse --is-inside-work-tree")
    is_inside_work_tree[opts.cwd] = vim.v.shell_error == 0
  end

  if is_inside_work_tree[opts.cwd] then
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
        { '<C-P>', function() project_files({ cwd = vim.fn.getcwd() }) end, desc = "project files under current directory" },
        { '<Leader><C-P>', function() project_files({ cwd = vim.fn.getcwd(), fzf_opts = { ["--query"] = vim.fn.expand("<cword>") } }) end, desc = "project files containing word under current directory" },
        { '<Leader>/<C-P>', function() require('fzf-lua').git_files() end, desc = "project files from root" },
    },
    init = function()
	require('fzf-lua').register_ui_select()
    end
}
