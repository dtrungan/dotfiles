return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
    end,
    config = function()
        local wk = require("which-key")

        -- wk.setup({
        --     preset = "modern",
        -- })

        wk.add({
            { "<leader>f", group = "Telescope" },
            { "<leader>c", group = "Code action" },
            { "<leader>l", group = "Format document" },
            { "<leader>r", group = "Rename symbol" },
            { "<leader>w", group = "Workspace" },
        })
    end,
}
