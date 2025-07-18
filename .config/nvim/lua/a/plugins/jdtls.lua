return {
  "mfussenegger/nvim-jdtls",
  ft = { "java" },
  config = function()
    local jdtls = require("jdtls")
    local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
    local root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })

    if not root_dir then return end

    local workspace_dir = vim.fn.stdpath("data") .. "/eclipse/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

    jdtls.start_or_attach({
      cmd = { jdtls_path .. "/bin/jdtls", "-data", workspace_dir },
      root_dir = root_dir,
      settings = {
        java = {
          format = { enabled = true },
        },
      },
      init_options = {
        bundles = {},
      },
    })
  end,
}
