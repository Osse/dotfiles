return {
    'wtfox/jellybeans.nvim',
    lazy = false,
    priority = 1000,
    init = function()
        vim.cmd.colorscheme("jellybeans")
    end,
    opts = {
        flat_ui = false,
        italics = false,
        on_highlights = function(hl, c)
            hl.Error = { fg = "NvimLightRed" }
            hl.ErrorMsg = { fg = "NvimLightRed" }
            hl.DiagnosticError = { fg = "NvimLightRed" }
            hl.SpellBad = { fg = "NvimLightRed" }
            hl.DiagnosticUnderlineError = { fg = "NvimLightRed" }
        end
    },
}
