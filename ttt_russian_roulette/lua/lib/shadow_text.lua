AddCSLuaFile()

if CLIENT then
	surface.CreateFont( "CustomFont", {
			font = "coolvetica",
			size = 100,
			weight = 500,
			blursize = 0,
			scanlines = 0,
			antialias = true,
			underline = false,
			italic = false,
			strikeout = true,
			symbol = false,
			rotary = false,
			shadow = true,
			additive = false,
			outline = false,
	})
end

local text_white = Color( 255, 255, 255, 255 )
local text_black = Color(   0,   0,   0, 255 )

function ShadowText(text, font, x, y, dist, xalign, yalign)
	draw.SimpleText(text, font, x + dist, y + dist, text_black, xalign, yalign)
	draw.SimpleText(text, font, x, y, text_white, xalign, yalign)
end