return {
    'mhinz/vim-startify',
    init = function()
        vim.g.startify_relative_path = 1
        vim.g.startify_bookmarks = {
            { ['m'] = '~/.vim/vimrc' },
            { ['n'] = '~/.config/nvim/init.lua' },
            { ['i'] = '~/.i3/config' },
            { ['z'] = '~/.zshrc' },
            { ['b'] = '~/.bashrc' },
            { ['g'] = '~/.gitconfig' },
        }
        vim.g.startify_change_to_dir = 0
        vim.g.startify_change_to_vcs_root = 1
    end
}
