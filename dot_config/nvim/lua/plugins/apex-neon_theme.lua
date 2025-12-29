return {
	-- 1. Keep the palette definition (for syntax highlighting)
	{
		"AstroNvim/astrotheme",
		opts = {
			palette = {
				astrodark = {
					bg = "#050505",
					fg = "#ededed",
					ui = {
						base = "#050505",
						bg_gutter = "#050505",
						bg_p1 = "#141414",
						bg_p2 = "#262626",
						border = "#ff0044",
					},
					syntax = {
						red = "#ff0044",
						orange = "#ffb700",
						yellow = "#ffb700",
						green = "#00ff99",
						cyan = "#00eaff",
						blue = "#00eaff",
						purple = "#9d00ff",
						magenta = "#ff80bf",
						comment = "#404040",
					},
				},
			},
		},
	},

	-- 2. THE IMPORTANT PART: Brute force the UI background
	{
		"AstroNvim/astroui",
		opts = {
			colorscheme = "astrodark",
			highlights = {
				-- This 'init' table runs on startup and overwrites everything
				init = {
					-- FORCE THE MAIN EDITOR BACKGROUND BLACK
					Normal = { bg = "#050505", fg = "#ededed" },
					NormalNC = { bg = "#050505" }, -- Non-current windows

					-- VISUAL SELECTION: TARGET ACQUIRED
					Visual = { bg = "#00eaff", fg = "#050505", bold = true },
					VisualNOS = { bg = "#00eaff", fg = "#050505" },

					-- Force the gutters (line numbers) to blend in
					SignColumn = { bg = "#050505" },
					FoldColumn = { bg = "#050505" },

					-- Aggressive UI Tweaks
					WinSeparator = { fg = "#ff0044" },
					NeoTreeNormal = { bg = "#050505" },
					NeoTreeNormalNC = { bg = "#050505" },

					-- Hide the "~" characters at the end of the buffer
					EndOfBuffer = { fg = "#050505" },

					-- Line numbers
					LineNr = { fg = "#404040" },
					CursorLineNr = { fg = "#00eaff", bold = true },
				},
			},
		},
	},
}
