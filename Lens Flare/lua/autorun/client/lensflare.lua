CreateClientConVar("snfl_enable", "1", true, false)

--Floats
CreateClientConVar("snfl_transparency", "1.2", true, false)
CreateClientConVar("snfl_flareSize", "360", true, false)
CreateClientConVar("snfl_spaceing", "1.2", true, false)
CreateClientConVar("snfl_area", "0.2", true, false)
--Bools
CreateClientConVar("snfl_rotate", "1", true, false)
CreateClientConVar("snfl_fast", "1", true, false)
CreateClientConVar("snfl_obstruction", "1", true, false)
--Strings
CreateClientConVar("snfl_sprites", "sprites/glow04_noz sprites/blueflare1_noz_gmod sprites/orangecore1_gmod sprites/light_ignorez", true, false)
CreateClientConVar("snfl_sprites_angles", "0 0 0", true, false)
CreateClientConVar("snfl_sprites_scales", "1 1 1", true, false)
--Ints
CreateClientConVar("snfl_color_r", "255", true, false)
CreateClientConVar("snfl_color_g", "255", true, false)
CreateClientConVar("snfl_color_b", "255", true, false)

local convarstring = GetConVar("snfl_sprites"):GetString()
local convarangles = GetConVar("snfl_sprites_angles"):GetString()
local convarscales = GetConVar("snfl_sprites_scales"):GetString()


local spritetbl = string.Explode( " ", convarstring )
local anglestbl = string.Explode( " ", convarangles )
local scalestbl = string.Explode( " ", convarscales )
local FlareSprites = spritetbl
local FlareAngle = anglestbl
local FlareScales = scalestbl
local AppList = nil
		cvars.AddChangeCallback("snfl_sprites", function(convar_name, value_old, value_new)
    spritetbl = string.Explode( " ", value_new )
    FlareSprites = spritetbl
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
function loadSNFLpreset( filePath )
	local openFile = file.Read( filePath, "GAME" )
	if !openFile then return end
	local jtt = util.JSONToTable(openFile)
	RunConsoleCommand("snfl_transparency", jtt[1])
	RunConsoleCommand("snfl_flareSize", jtt[2])
	RunConsoleCommand("snfl_spaceing", jtt[3])
	RunConsoleCommand("snfl_area", jtt[4])
	RunConsoleCommand("snfl_rotate", jtt[5])
	RunConsoleCommand("snfl_fast", jtt[6])
	RunConsoleCommand("snfl_obstruction", jtt[7])
	RunConsoleCommand("snfl_color_r", jtt[8])
	RunConsoleCommand("snfl_color_g", jtt[9])
	RunConsoleCommand("snfl_color_b", jtt[10])
	RunConsoleCommand("snfl_sprites", jtt[11])
	RunConsoleCommand("snfl_sprites_angles", jtt[12])
	RunConsoleCommand("snfl_sprites_scales", jtt[13])

	surface.PlaySound( "garrysmod/content_downloaded.wav" )
	chat.AddText( filePath .. ".json loaded" )
end

function deleteSNFLpreset( filePath )
	local delfile = string.Replace(filePath, "data/", "")
	file.Delete( delfile, "DATA" )
	print(file.Exists( filePath, "GAME" ))
	if file.Exists( filePath, "GAME" )then
		surface.PlaySound( "common/wpn_denyselect.wav" )
	else
		surface.PlaySound( "common/wpn_hudoff.wav" )
		chat.AddText( filePath .. ".json deleted" )
	end
end


concommand.Add( "snfl_load", function( ply, cmd, args, str )
	loadSNFLpreset( "data/" .. str )
end, function(cmd, args)
	local tbl = {}
	local files, directories = file.Find( "data/snfl/*", "GAME" )
	for k, v in ipairs(files) do
		table.insert(tbl, "snfl_load snfl/" .. files[k])
	end
	return tbl
end)

hook.Add("PreDrawEffects", "PreDrawExample", function()
	if !GetConVar("snfl_enable"):GetBool() then return end
	if GetConVar("snfl_flareSize"):GetFloat() <= 0 then return end
	if GetConVar("snfl_transparency"):GetFloat() <= 0 then return end
	local fastCalc = GetConVar("snfl_flareSize"):GetBool()
	local cone = GetConVar("snfl_area"):GetFloat()
	local obstruction = GetConVar("snfl_obstruction"):GetBool()
	local SunTable = util.GetSunInfo()
	if !SunTable then return end
	local SunBrightness = 1

	if obstruction then
		if SunTable.obstruction == 0 then return end
		obstruction = SunTable.obstruction
	else
		obstruction = 1
	end
	local SunToCenter = Vector(0.5, 0.5, 0)
	local point = EyePos() + (SunTable.direction * 100)
	local data2D = point:ToScreen()
	if ( !data2D.visible ) then return end
	local SunCoords = Vector(data2D.x / ScrW(), data2D.y / ScrH(), 0)
	SunToCenter = SunToCenter - Vector(data2D.x / ScrW(), data2D.y / ScrH(), 0)

	if fastCalc then
		SunBrightness = 1 - (SunToCenter:Length2DSqr() / cone)
	else
		SunBrightness = 1 - (SunToCenter:Length2D() / cone)
	end

	SunBrightness = math.Clamp(SunBrightness, 0, 1) * obstruction

	if ((SunBrightness < 1 && fastCalc) || (SunBrightness > 0 && !fastCalc)) then
		for k, v in ipairs(FlareSprites) do
			local FlareMat = Material(v)
			if FlareMat:IsError() then
				cam.Start2D()
						surface.SetDrawColor( 255, 255, 255, 255 )
						surface.SetMaterial( Material( "icon16/error.png", "noclamp smooth" ) )
						surface.DrawTexturedRect( 10, 10, 50 + math.sin(CurTime() * 5) * 2, 50 + math.sin(CurTime() * 5) * 2)

						surface.SetFont( "Trebuchet24" )
						surface.SetTextColor( 255, 255, 255 )
						surface.SetTextPos( 80, 30 ) 
						surface.DrawText( "One or more sun flare materials NOT found" )
				cam.End2D()
			 return end
			FlareMat:SetInt( "$additive", 1 )
			local spaceing = GetConVar("snfl_spaceing"):GetFloat()
			local flareSize = GetConVar("snfl_flareSize"):GetFloat()
			local direction = SunToCenter * (k * spaceing)
			local flarePos = SunCoords + direction
			flarePos = Vector(flarePos.x * ScrW(), flarePos.y * ScrH(), 0)
			local clr = Color( GetConVar("snfl_color_r"):GetInt(), GetConVar("snfl_color_g"):GetInt(), GetConVar("snfl_color_b"):GetInt(), GetConVar("snfl_transparency"):GetFloat() * SunBrightness )
			local angle = 0

			if GetConVar("snfl_rotate"):GetBool() then
				if FlareAngle[k] then
					angle = -SunToCenter:Angle().y - tonumber(FlareAngle[k])
				else
					angle = -SunToCenter:Angle().y
				end
			else
				if FlareAngle[k] then
					angle = tonumber(FlareAngle[k])
				end
			end

			if FlareScales[k] then
				flareSize = flareSize * tonumber(FlareScales[k])
			end
			cam.Start2D()
				surface.SetDrawColor( clr )
				surface.SetMaterial( Material(v) )
				surface.DrawTexturedRectRotated( flarePos.x, flarePos.y, flareSize, flareSize, angle )
			cam.End2D()
		end
	end
end)

function SFAddControls()
	spawnmenu.AddToolMenuOption( "Options", "Lens Flares", "FlareOptions", "#Sun Flares Settings", "", "", function( panel )
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
			surface.PlaySound( "buttons/button24.wav" )
			chat.AddText( "snfl/" .. TextEntry:GetValue() .. ".json saved" )
			file.Write( "snfl/" .. TextEntry:GetValue() .. ".json", tab)
			browser:SetCurrentFolder( "" )
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
	spawnmenu.AddToolCategory( "Options", "Lens Flares", "#Lens Flares" )
end )

hook.Add( "PopulateToolMenu", "CustomMenuSettings", SFAddControls)