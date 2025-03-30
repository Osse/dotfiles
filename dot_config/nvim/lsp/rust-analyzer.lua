return {
    cmd = { 'rust-analyzer' },
    root_dir = function(buf, cb)
        local root = vim.fs.root(buf, "Cargo.toml")
        local cmd = {"cargo", "metadata", "--no-deps", "--format-version", "1"}
        if root then
            vim.system(cmd, { cwd = root }, function(out)
                if out.code == 0 then
                    local json = vim.json.decode(out.stdout)
                    cb(json.workspace_root)
                end
            end)
        end
    end,
    filetypes = { 'rust' },
}
