return {
    cmd = { 'clangd-21', '--header-insertion=never', '--background-index' },
    root_markers = { 'compile_commands.json', '.git' },
    filetypes = { 'c', 'cpp' },
}
