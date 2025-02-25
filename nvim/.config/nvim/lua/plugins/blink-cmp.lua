return {
	{
		"saghen/blink.cmp",
		-- optional: provides snippets for the snippet source
		dependencies = {
			"rafamadriz/friendly-snippets",
			-- "giuxtaposition/blink-cmp-copilot",
			{ "L3MON4D3/LuaSnip", version = "v2.*" },
		},

		-- use a release tag to download pre-built binaries
		version = "*",
		-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
		-- build = "cargo build --release",

		opts = function(_, opts)
			-- 'default' for mappings similar to built-in completion
			-- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
			-- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
			-- See the full "keymap" documentation for information on defining your own keymap.
			opts.keymap = { preset = "default" }

			opts.appearance = {
				-- Sets the fallback highlight groups to nvim-cmp's highlight groups
				-- Useful for when your theme doesn't support blink.cmp
				-- Will be removed in a future release
				use_nvim_cmp_as_default = true,
				kind_icons = {
					Copilot = " ",
					Text = "󰉿 ",
					Method = "󰊕 ",
					Function = "󰊕 ",
					Constructor = "󰒓 ",

					Field = "󰜢 ",
					Variable = "󰆦 ",
					Property = "󰖷 ",

					Class = "󱡠 ",
					Interface = "󱡠 ",
					Struct = "󱡠 ",
					Module = "󰅩 ",

					Unit = "󰪚 ",
					Value = "󰦨 ",
					Enum = "󰦨 ",
					EnumMember = "󰦨 ",

					Keyword = "󰻾 ",
					Constant = "󰏿 ",

					Snippet = "󱄽 ",
					Color = "󰏘 ",
					File = "󰈔 ",
					Reference = "󰬲 ",
					Folder = "󰉋 ",
					Event = "󱐋 ",
					Operator = "󰪚 ",
					TypeParameter = "󰬛 ",
				},
			}

			-- Default list of enabled providers defined so that you can extend it
			-- elsewhere in your config, without redefining it, due to `opts_extend`
			opts.sources = vim.tbl_deep_extend("force", opts.sources or {}, {
				default = function(ctx)
					local _ = ctx
					local success, node = pcall(vim.treesitter.get_node)
					if
						success
						and node
						and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type())
					then
						return { "buffer" }
					else
						return {
							"lsp",
							"path",
							"snippets",
							"buffer",
							-- "dadbod",
							-- "copilot"
						}
					end
				end,
				per_filetype = {
					lua = { "lsp", "path", "snippets", "buffer" },
				},
				providers = {
					lsp = {
						name = "LSP",
						module = "blink.cmp.sources.lsp",
						-- Filter text items from the LSP provider, since we have the buffer provider for that
						transform_items = function(_, items)
							for _, item in ipairs(items) do
								if item.kind == require("blink.cmp.types").CompletionItemKind.Snippet then
									item.score_offset = item.score_offset - 3
								end
							end

							return vim.tbl_filter(function(item)
								return item.kind ~= require("blink.cmp.types").CompletionItemKind.Text
							end, items)
						end,
						score_offset = 90,
					},
					path = {
						name = "Path",
						module = "blink.cmp.sources.path",
						score_offset = 25,
						-- When typing a path, I would get snippets and text in the
						-- suggestions, I want those to show only if there are no path suggestions
						fallbacks = { "snippets", "buffer" },
						opts = {
							trailing_slash = false,
							label_trailing_slash = true,
							get_cwd = function(context)
								return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
							end,
							show_hidden_files_by_default = true,
						},
					},
					buffer = {
						name = "Buffer",
						enabled = true,
						max_items = 3,
						module = "blink.cmp.sources.buffer",
						min_keyword_length = 4,
						score_offset = 15,
					},
					snippets = {
						name = "snippets",
						max_items = 8,
						min_keyword_length = 2,
						module = "blink.cmp.sources.snippets",
						score_offset = 85,
						opts = {
							friendly_snippets = true,
							global_snippets = { "all" },
							extended_filetypes = {
								php = {
									"html",
									-- "css",
									-- "javascript"
								},
							},
							ignored_filetypes = {},
							get_filetype = function(ctx)
								local _ = ctx
								return vim.bo.filetype
							end,
						},
					},
					-- dadbod = {
					-- 	name = "Dadbod",
					-- 	module = "vim_dadbod_completion.blink",
					-- 	score_offset = 85,
					-- },
					-- copilot = {
					-- 	name = "copilot",
					-- 	module = "blink-cmp-copilot",
					-- 	score_offset = 100,
					-- 	async = true,
					-- },
				},
				cmdline = function()
					local type = vim.fn.getcmdtype()
					if type == "/" or type == "?" then
						return { "buffer" }
					end
					if type == ":" then
						return { "cmdline" }
					end
					return {}
				end,
			})

			opts.snippets = {
				preset = "default",
				-- Function to use when expanding LSP provided snippets
				expand = function(snippet)
					-- vim.snippet.expand(snippet)
					require("luasnip").lsp_expand(snippet)
				end,
				-- Function to use when checking if a snippet is active
				active = function(filter)
					-- return vim.snippet.active(filter)
					-- if filter and filter.direction then
					-- 	return require("luasnip").jumpable(filter)
					-- end
					-- return require("luasnip").in_snippet()
					return require("luasnip").jumpable(filter)
				end,
				-- Function to use when jumping between tab stops in a snippet, where direction can be negative or positive
				jump = function(direction)
					-- vim.snippet.jump(direction)
					require("luasnip").jump(direction)
				end,
			}

			-- Style
			opts.completion = {
				-- accept = {
				-- 	auto_brackets = {
				-- 		enabled = true,
				-- 	},
				-- },
				menu = {
					border = "rounded",
					draw = {
						treesitter = { "lsp" },
						components = {
							kind_icon = {
								ellipsis = false,
								text = function(ctx)
									local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
									return kind_icon
								end,
								-- Optionally, you may also use the highlights from mini.icons
								highlight = function(ctx)
									local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
									return hl
								end,
							},
						},
						columns = {
							{ "label", "label_description", gap = 1 },
							{ "kind_icon", "kind" },
						},
					},
				},
				-- Show documentation when selecting a completion item
				documentation = {
					window = {
						border = "single",
					},
					auto_show = true,
					auto_show_delay_ms = 500,
				},

				-- Display a preview of the selected item on the current line
				-- ghost_text = { enabled = true },
			}

			-- Experimental signature help support
			opts.signature = {
				enabled = true,
				window = {
					border = "rounded",
				},
			}
		end,
		opts_extend = { "sources.default" },
	},
}
