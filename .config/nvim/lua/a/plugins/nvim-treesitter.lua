return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        local configs = require("nvim-treesitter.configs")

        configs.setup({
            ensure_installed = { "lua", "vim", "markdown", "markdown_inline", "python", "java" },
            sync_install = false,
            highlight = { enable = true },
            indent = { enable = true },
        })
    end,
}
