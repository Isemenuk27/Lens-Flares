local CVAREnabled = CreateClientConVar("snfl_enable", "1", true, false)

--Floats
local CVARTranspc = CreateClientConVar("snfl_transparency", "1.2", true, false)
local CVARSize = CreateClientConVar("snfl_flareSize", "360", true, false)
local CVARSpaceing = CreateClientConVar("snfl_spaceing", "1.2", true, false)
local CVARArea = CreateClientConVar("snfl_area", "0.2", true, false)
--Bools
local CVARRotation = CreateClientConVar("snfl_rotate", "1", true, false)
local CVARFastMode = CreateClientConVar("snfl_fast", "0", true, false)
local CVARObstruct = CreateClientConVar("snfl_obstruction", "1", true, false)
--Strings
local CVARSpriteList = CreateClientConVar("snfl_sprites", "sprites/glow04_noz sprites/blueflare1_noz_gmod sprites/orangecore1_gmod sprites/light_ignorez", true, false)
local CVARSpriteAngl = CreateClientConVar("snfl_sprites_angles", "0 0 0", true, false)
local CVARSpriteScls = CreateClientConVar("snfl_sprites_scales", "1 1 1", true, false)
--Ints
local CVARcolorR = CreateClientConVar("snfl_color_r", "255", true, false)
local CVARcolorG = CreateClientConVar("snfl_color_g", "255", true, false)
local CVARcolorB = CreateClientConVar("snfl_color_b", "255", true, false)

local convarstring = CVARSpriteList:GetString()
local convarangles = CVARSpriteAngl:GetString()
local convarscales = CVARSpriteScls:GetString()

local spritetbl = string.Explode( " ", convarstring )
local anglestbl = string.Explode( " ", convarangles )
local scalestbl = string.Explode( " ", convarscales )
local FlareSprites = spritetbl
local FlareMaterials = {}
local FlareAngle = anglestbl
local FlareScales = scalestbl
local AppList = nil

local function RebuildMaterialTable()
	FlareMaterials = {}
    for i,v in ipairs(FlareSprites) do
		local FlareMat = Material(v)
		if FlareMat:IsError() then
			chat.AddText( "Sun Flare material NOT found (" .. v .. ")" )
		end
		FlareMat:SetInt( "$additive", 1 )
		FlareMaterials[i] = FlareMat
    end
end

RebuildMaterialTable()

cvars.AddChangeCallback("snfl_sprites", function(convar_name, value_old, value_new)

    spritetbl = string.Explode( " ", value_new )
    FlareSprites = spritetbl
    RebuildMaterialTable()

    if !IsValid(AppList) then return end
    AppList:Clear()
    for k, v in ipairs (FlareSprites) do
		AppList:AddLine( k, v, FlareAngle[k], FlareScales[k] )
	end
end)
cvars.AddChangeCallback("snfl_sprites_angles", function(convar_name, value_old, value_new)
    anglestbl = string.Explode( " ", value_new )
    FlareAngle = anglestbl
    if !IsValid(AppList) then return end
    AppList:Clear()
    for k, v in ipairs (FlareSprites) do
		AppList:AddLine( k, v, FlareAngle[k], FlareScales[k] )
	end
end)

cvars.AddChangeCallback("snfl_sprites_scales", function(convar_name, value_old, value_new)
    scalestbl = string.Explode( " ", value_new )
    FlareScales = scalestbl
    if !IsValid(AppList) then return end
    AppList:Clear()
    for k, v in ipairs (FlareSprites) do
		AppList:AddLine( k, v, FlareAngle[k], FlareScales[k] )
	end
end)

local cmdstotable = {
	"snfl_transparency",
	"snfl_flareSize",
	"snfl_spaceing",
	"snfl_area",
	"snfl_rotate",
	"snfl_fast",
	"snfl_obstruction",
	"snfl_color_r",
	"snfl_color_g",
	"snfl_color_b",
	"snfl_sprites",
	"snfl_sprites_angles",
	"snfl_sprites_scales"
}

function loadSNFLpreset( filePath )
	local openFile = file.Read( filePath, "GAME" )
	if !openFile then return end
	local jtt = util.JSONToTable(openFile)

	for num,cmd in ipairs(cmdstotable) do
		RunConsoleCommand(cmd, jtt[num])
	end

	surface.PlaySound( "garrysmod/content_downloaded.wav" )
	chat.AddText( filePath .. ".json loaded" )
end

if !file.Exists( "snfl", "DATA" ) then
	file.CreateDir("snfl")
end

if !file.Exists( "snfl/default_gmod.json", "DATA" ) then
	print("snfl/default_gmod.json missing")
	local defsnfl = {
		15,
		299,
		0.439,
		0.15,
		0.0,
		1.0,
		1.0,
		255,
		255,
		255,
		"sprites/glow04_noz sprites/blueflare1_noz_gmod sprites/orangecore1_gmod sprites/light_ignorez",
		"0 0 0 90",
		"1 1 1 2"
	}
	local defwrite = util.TableToJSON( defsnfl )
	file.Write("snfl/default_gmod.json", defwrite)
end

if !file.Exists( "snfl/default_snfl.json", "DATA" ) then
	print("snfl/default_snfl.json missing")
	local defsnfl = {
	8.0,
	235.0,
	0.5,
	0.15,
	1.0,
	1.0,
	1.0,
	255.0,
	255.0,
	255.0,
	"effects/snfl/fx_flare1 effects/snfl/fx_flare2 effects/snfl/fx_flare3 effects/snfl/rainbow",
	"0 0 0 105",
	"1 1 1 2"
	}
	local defwrite = util.TableToJSON( defsnfl )
	file.Write("snfl/default_snfl.json", defwrite)
end

local snflwhitelist = {
	"default_gmod.json",
	"default_snfl.json"
}

local function whiteList( filePath )
	local stipedsnfl = string.GetFileFromFilename(filePath)
	for k, v in ipairs(snflwhitelist)do
		if stipedsnfl == v then
			return false
		end
	end
	return true
end

function deleteSNFLpreset( filePath )
	local delfile = string.Replace(filePath, "data/", "")
	if whiteList( delfile ) then
		file.Delete( delfile, "DATA" )
	end
	if file.Exists( filePath, "GAME" )then
		surface.PlaySound( "common/wpn_denyselect.wav" )
		chat.AddText( filePath .. " cannot be deleted" )
	else
		surface.PlaySound( "common/wpn_hudoff.wav" )
		chat.AddText( filePath .. " has been deleted" )
	end
end

do
	local function cbackfunc( ply, cmd, args, str )
		loadSNFLpreset( "data/" .. str )
	end

	local function AutoComplete(cmd, args)
		local tbl = {}
		local files, directories = file.Find( "data/snfl/*", "GAME" )
		for k, v in ipairs(files) do
			table.insert(tbl, "snfl_load snfl/" .. files[k])
		end
		return tbl
	end

	concommand.Add( "snfl_load", cbackfunc, AutoComplete)
end

local ENABLED = CVAREnabled:GetBool() -- snfl_enable

local snfl_transparency = CVARTranspc:GetFloat() -- snfl_transparency
local snfl_flareSize = CVARSize:GetFloat() -- snfl_flareSize
local snfl_spaceing = CVARSpaceing:GetFloat() -- snfl_spaceing
local snfl_area = CVARArea:GetFloat() -- snfl_area
--Bools
local snfl_rotate = CVARRotation:GetBool() -- snfl_rotate
local snfl_fast = CVARFastMode:GetBool() -- snfl_fast
local snfl_obstruction = CVARObstruct:GetBool() -- snfl_obstruction
--Strings
local snfl_sprites = CVARSpriteList:GetString() -- snfl_sprites
local snfl_sprites_angles = CVARSpriteAngl:GetString() -- snfl_sprites_angles
local snfl_sprites_scales = CVARSpriteScls:GetString() -- snfl_sprites_scales
--Ints
local snfl_color_r = CVARcolorR:GetInt() -- snfl_color_r
local snfl_color_g = CVARcolorG:GetInt() -- snfl_color_g
local snfl_color_b = CVARcolorB:GetInt() -- snfl_color_b

local DrawColor = Color(255, 255, 255)


local GetSunInfo = util.GetSunInfo
local EyePos = EyePos
local Clamp = math.Clamp

local HalfVector = Vector(0.5, 0.5, 0)
local SCRW = ScrW()
local SCRH = ScrH()
local ipairs = ipairs
local errormat = Material( "icon16/error.png", "noclamp smooth" )

local VectorMeta = FindMetaTable("Vector")

local Length2DSqr = VectorMeta.Length2DSqr
local Length2D = VectorMeta.Length2D
local ToScreen = VectorMeta.ToScreen
local VectorToAngle = VectorMeta.Angle

hook.Add( "OnScreenSizeChanged", "LENSFLARE.SCR", function()
	SCRW = ScrW()
	SCRH = ScrH()
end)

local function DrawFunc()
	if snfl_flareSize <= 0 then return end
	if snfl_transparency <= 0 then return end

	local obstruction = 1

	local SunTable = GetSunInfo()
	if !SunTable then return end

	local SunBrightness = 1

	if snfl_obstruction then
		if SunTable.obstruction == 0 then return end
		obstruction = SunTable.obstruction
	end

	local point = EyePos() + SunTable.direction

	local data2D = ToScreen(point)
	if ( !data2D.visible ) then return end

	local SunCoords = Vector(data2D.x / SCRW, data2D.y / SCRH, 0)

	local SunToCenter = HalfVector - SunCoords

	if snfl_fast then
		SunBrightness = 1 - (Length2DSqr(SunToCenter) / snfl_area)
	else
		SunBrightness = 1 - (Length2D(SunToCenter) / snfl_area)
	end

	SunBrightness = Clamp(SunBrightness, 0, 1) * obstruction

	if SunBrightness > 0 then
		for k, FlareMat in ipairs(FlareMaterials) do
			local flarePos = SunCoords + SunToCenter * (k * snfl_spaceing)
			flarePos = Vector(flarePos.x * SCRW, flarePos.y * SCRH, 0)
			local angle = 0

			if snfl_rotate then
				if FlareAngle[k] then
					angle = -VectorToAngle(SunToCenter).y - FlareAngle[k]
				else
					angle = -VectorToAngle(SunToCenter).y
				end
			else
				if FlareAngle[k] then
					angle = FlareAngle[k]
				end
			end
			local flareSize = snfl_flareSize
			if FlareScales[k] then
				flareSize = snfl_flareSize * FlareScales[k]
			end

			DrawColor.a = snfl_transparency * SunBrightness

			surface.SetDrawColor( DrawColor )
			surface.SetMaterial( FlareMat )
			surface.DrawTexturedRectRotated( flarePos.x, flarePos.y, flareSize, flareSize, angle )
		end
	end
end

local function DisableLensFlares()
	hook.Remove("RenderScreenspaceEffects", "CUSTOMIZABLELENSFL")
end

local function EnableLensFlares()
	hook.Add("RenderScreenspaceEffects", "CUSTOMIZABLELENSFL", DrawFunc)
end

--[[-------------------------------------------------------------------------
								Floats
---------------------------------------------------------------------------]]
cvars.AddChangeCallback("snfl_transparency", function(cname, old, new)
	snfl_transparency = tonumber(new)
end)
cvars.AddChangeCallback("snfl_flareSize", function(cname, old, new)
	snfl_flareSize = tonumber(new)
end)
cvars.AddChangeCallback("snfl_spaceing", function(cname, old, new)
	snfl_spaceing = tonumber(new)
end)
cvars.AddChangeCallback("snfl_area", function(cname, old, new)
	snfl_area = tonumber(new)
end)
--[[-------------------------------------------------------------------------
								Bools
---------------------------------------------------------------------------]]
cvars.AddChangeCallback("snfl_rotate", function(cname, old, new)
	snfl_rotate = tobool(new)
end)

cvars.AddChangeCallback("snfl_fast", function(cname, old, new)
	snfl_fast = tobool(new)
end)

cvars.AddChangeCallback("snfl_obstruction", function(cname, old, new)
	snfl_obstruction = tobool(new)
end)
--[[-------------------------------------------------------------------------
								Strings
---------------------------------------------------------------------------]]
cvars.AddChangeCallback("snfl_sprites_angles", function(cname, old, new)
	snfl_sprites_angles = tostring(new)
end)

cvars.AddChangeCallback("snfl_sprites_scales", function(cname, old, new)
	snfl_sprites_scales = tostring(new)
end)
--[[-------------------------------------------------------------------------
								Colors
---------------------------------------------------------------------------]]
cvars.AddChangeCallback("snfl_color_r", function(cname, old, new)
	snfl_color_r = tonumber(new)
	DrawColor.r = snfl_color_r
end)

cvars.AddChangeCallback("snfl_color_g", function(cname, old, new)
	snfl_color_g = tonumber(new)
	DrawColor.g = snfl_color_g
end)

cvars.AddChangeCallback("snfl_color_b", function(cname, old, new)
	snfl_color_b = tonumber(new)
	DrawColor.b = snfl_color_b
end)
--[[-------------------------------------------------------------------------
								Enable/Disable
---------------------------------------------------------------------------]]

local function SwitchLF( bl )
    ENABLED = bl
    if ENABLED then
    	EnableLensFlares()
    	return
    end
    DisableLensFlares()
end

cvars.AddChangeCallback("snfl_enable", function(cname, old, new)
	SwitchLF( tobool(new) )
end)

SwitchLF( ENABLED )

function SFAddControls()
	spawnmenu.AddToolMenuOption( "Options", "postprocessing", "SunFlares", "#Sun Flares", "", "", function( panel )
		panel:ClearControls()

		panel:CheckBox( "Enable Sun Flares", "snfl_enable")

		local browser = vgui.Create( "DFileBrowser", panel )
		browser:Dock( FILL )
		browser:SetHeight(100)
		browser:SetPath( "GAME" ) -- The access path i.e. GAME, LUA, DATA etc.
		browser:SetBaseFolder( "data/snfl" )
		browser:SetOpen( false )
		browser:SetCurrentFolder( "data/snfl" )

		panel:AddItem(browser)


		local TextEntry = vgui.Create( "DTextEntry", panel )
		TextEntry:Dock( TOP )
		TextEntry.OnEnter = function( self )
		end
		panel:AddItem(TextEntry)

		local SaveButton = vgui.Create( "DButton", panel )
		SaveButton:SetText( "Save preset" )
		panel:AddItem(SaveButton)

		panel:NumSlider( "Density", "snfl_spaceing", 0.1, 3 )
		panel:ControlHelp("Distance between the flares.")
		panel:NumSlider( "Base transparency", "snfl_transparency", 0, 255 )
		panel:NumSlider( "Flare Sizes", "snfl_flareSize", 0.1, 1000 )
		panel:NumSlider( "Flare Cone", "snfl_area", 0.001, 1 )
		panel:ControlHelp("Area around the sun in which the flares becomes visible.")
		panel:CheckBox( "Fast Calculation", "snfl_fast")
		panel:ControlHelp("Use Length2DSqr() instead Length2D().")
		panel:CheckBox( "Sun obstruction", "snfl_obstruction")
		panel:ControlHelp("Sun flares can be seen through the walls, or beyond the FOV.")
		panel:CheckBox( "Flare rotation", "snfl_rotate")
		panel:ControlHelp("Flares always look at sun.")

		local Mixer = vgui.Create("DColorMixer", panel)
		Mixer:Dock(FILL)
		Mixer:SetPalette(true)
		Mixer:SetAlphaBar(false)
		Mixer:SetWangs(true)
		Mixer:SetColor(Color(255,255,255))
		Mixer:SetConVarR("snfl_color_r")
		Mixer:SetConVarG("snfl_color_g")
		Mixer:SetConVarB("snfl_color_b")
		panel:AddItem(Mixer)
/*
		AppList = vgui.Create( "DListView", panel )
		AppList:Dock( FILL )
		AppList:SetMultiSelect( false )
		AppList:SetHeight(100)
		AppList:AddColumn( "№" ):SetWidth(2)
		AppList:AddColumn( "Material" )
		AppList:AddColumn( "Angle" ):SetWidth(5)
		AppList:AddColumn( "Scale" ):SetWidth(4)

		panel:AddItem(AppList)

		panel:ControlHelp("snfl_sprites - list of materials")
		panel:ControlHelp("Example: snfl_sprites effects/fx_flare1 effects/fx_flare2 effects/fx_flare3 effects/rainbow")
		panel:ControlHelp("")
		panel:ControlHelp("snfl_sprites_angles - list of angle offsets")
		panel:ControlHelp("Example: snfl_sprites_angles 0 0 0 90")
		panel:ControlHelp("")
		panel:ControlHelp("snfl_sprites_scales - list of angle offsets")
		panel:ControlHelp("Example: snfl_sprites_scales 1 1 1 2")
		panel:ControlHelp("")

		AppList:Clear()
		for k, v in ipairs (FlareSprites) do
			AppList:AddLine( k, v, FlareAngle[k], FlareScales[k] )
		end
*/
		browser.OnDoubleClick = function( panel, filePath )
			loadSNFLpreset( filePath )
		end
		browser.OnRightClick = function( panel, filePath )
			deleteSNFLpreset( filePath )
			browser:SetCurrentFolder( browser:GetCurrentFolder() )
		end
		SaveButton.DoClick = function()
			local snfl_r = GetConVar("snfl_color_r"):GetInt()
			local snfl_g = GetConVar("snfl_color_g"):GetInt()
			local snfl_b = GetConVar("snfl_color_b"):GetInt()
			local Vars = {
				GetConVar("snfl_transparency"):GetFloat(),
				GetConVar("snfl_flareSize"):GetFloat(),
				GetConVar("snfl_spaceing"):GetFloat(),
				GetConVar("snfl_area"):GetFloat(),
				GetConVar("snfl_rotate"):GetInt(),
				GetConVar("snfl_fast"):GetInt(),
				GetConVar("snfl_obstruction"):GetInt(),
				snfl_r,
				snfl_g,
				snfl_b,
				GetConVar("snfl_sprites"):GetString(),
				GetConVar("snfl_sprites_angles"):GetString(),
				GetConVar("snfl_sprites_scales"):GetString()
			}

			local tab = util.TableToJSON( Vars )
			if !file.Exists( "snfl", "DATA" ) then
				file.CreateDir("snfl")
			end

			if whiteList( "snfl/" .. TextEntry:GetValue() .. ".json" ) then
				file.Write( "snfl/" .. TextEntry:GetValue() .. ".json", tab)
				surface.PlaySound( "buttons/button24.wav" )
				chat.AddText( "snfl/" .. TextEntry:GetValue() .. ".json saved" )
			else
				surface.PlaySound( "common/wpn_denyselect.wav" )
				chat.AddText( "snfl/" .. TextEntry:GetValue() .. ".json cannot be saved" )
			end

			browser:SetCurrentFolder( browser:GetCurrentFolder() )
		end

		browser.OnSelect = function( panel, filePath)
			local sendtext = string.GetFileFromFilename(filePath)
			sendtext = string.StripExtension(sendtext)
			TextEntry:SetValue(sendtext)
			surface.PlaySound( "garrysmod/ui_hover.wav" )
		end
	end )
end
hook.Add( "AddToolMenuCategories", "CustomCategory", function()
	spawnmenu.AddToolCategory( "Options", "postprocessing", "#spawnmenu.category.postprocess" )
end )

hook.Add( "PopulateToolMenu", "CustomMenuSettings", SFAddControls)