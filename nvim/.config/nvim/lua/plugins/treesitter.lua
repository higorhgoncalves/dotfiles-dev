return {
	{
		"nvim-treesitter/nvim-treesitter-context",
		after = "nvim-treesitter",
		opts = {
			enable = true,
			max_lines = 3,
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		dependencies = {
			{
				"JoosepAlviste/nvim-ts-context-commentstring",
				opts = {
					custom_calculation = function(_, language_tree)
						if
							vim.bo.filetype == "blade"
							and language_tree._lang ~= "javascript"
							and language_tree._lang ~= "php"
						then
							return "{{-- %s --}}"
						end
					end,
				},
			},
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		opts = {
			ensure_installed = {
				"bash",
				"blade",
				"c",
				"css",
				"diff",
				-- "html",
				"javascript",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"php",
				"php_only",
				"query",
				"regex",
				"sql",
				"typescript",
				"vim",
				"vimdoc",
			},
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = {
					"php",
				}
			},
			indent = {
				-- Desabilitado, pois a indentação está sendo feita pelo GuessIndent
				enable = false,
			},
		},
		config = function(_, opts)
			---@class ParserInfo[]
			local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
			parser_config.blade = {
				install_info = {
					url = "https://github.com/EmranMR/tree-sitter-blade",
					files = {
						"src/parser.c",
						-- 'src/scanner.cc',
					},
					branch = "main",
					generate_requires_npm = true,
					requires_generate_from_grammar = true,
				},
				filetype = "blade",
			}

			require("nvim-treesitter.configs").setup(opts)
		end,
	},
}
