include( "autorun/server/sv_zones.lua" )

TOOL.Name = "#tool.zone.name"
TOOL.Category = "Construction"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar[ "id" ] = "Zone"
TOOL.ClientConVar[ "wireframe" ] = "0"
TOOL.ClientConVar[ "player" ] = "0"
TOOL.ClientConVar[ "admin" ] = "0"
TOOL.ClientConVar[ "npc" ] = "0"
TOOL.ClientConVar[ "ent" ] = "0"
TOOL.ClientConVar[ "removeprops" ] = "0"
TOOL.ClientConVar[ "tick" ] = 1
TOOL.ClientConVar[ "amount" ] = 1
TOOL.ClientConVar[ "limit" ] = 0
TOOL.ClientConVar[ "type" ] = TYPE_DAMAGE
TOOL.ClientConVar[ "shape" ] = SHAPE_BOX
TOOL.ClientConVar[ "red" ] = 255
TOOL.ClientConVar[ "green" ] = 255
TOOL.ClientConVar[ "blue" ] = 255
TOOL.ClientConVar[ "alpha" ] = 255

TOOL.Point1 = nil
TOOL.Point2 = nil

TOOL.NextUse = CurTime()

TOOL.Information = {
	{ name = "left_box", stage = 0, op = SHAPE_BOX },
	{ name = "left_box", stage = 1, op = SHAPE_BOX },
	{ name = "right_box", stage = 1, op = SHAPE_BOX },
	{ name = "left_sphere", stage = 0, op = SHAPE_SPHERE },
	{ name = "left_sphere", stage = 1, op = SHAPE_SPHERE },
	{ name = "right_sphere", stage = 1, op = SHAPE_SPHERE },
	{ name = "reload" },
	{ name = "use"}
}

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL:LeftClick( tr )
	-- Zone point marking
	self.Point1 = tr.HitPos
	
	self:SetStage( 1 )

	return true
end
	
function TOOL:RightClick( tr )
	-- Zone point marking
	self.Point2 = tr.HitPos

	return true
end

function TOOL:Reload( tr )
	-- Zone creation
	local identifier = self:GetClientInfo( "id" )
	local owner = self:GetOwner()
	local zone = ZoneManager.Zones[ identifier ]

	if ( self.Point1 == nil ) then
		owner:PrintMessage( HUD_PRINTCENTER, "#zone.error.first" )

		return false
	end

	if ( self.Point2 == nil ) then
		owner:PrintMessage( HUD_PRINTCENTER, "#zone.error.second" )

		return false
	end

	if ( not isstring( identifier ) ) || ( identifier == "" ) || ( string.byte( identifier ) == 32 ) then
		owner:PrintMessage( HUD_PRINTCENTER, "#zone.error.id" )

		return false
	end

	ZoneManager.CreateZone( identifier, {
		id = identifier,
		point1 = self.Point1,
		point2 = self.Point2,
		wireframe = self:GetClientNumber( "wireframe" ),
		player = self:GetClientNumber( "player" ),
		admin = self:GetClientNumber( "admin" ),
		npc = self:GetClientNumber( "npc" ),
		ent = self:GetClientNumber( "ent" ),
		removeprops = self:GetClientNumber( "removeprops" ),
		tick = self:GetClientNumber( "tick" ),
		amount = self:GetClientNumber( "amount" ),
		limit = self:GetClientNumber( "limit" ),
		type = self:GetClientNumber( "type" ),
		shape = self:GetClientNumber( "shape" ),
		r = self:GetClientNumber( "red" ),
		g = self:GetClientNumber( "green" ),
		b = self:GetClientNumber( "blue" ),
		a = self:GetClientNumber( "alpha" )
	} )
	
	if (zone == nil) then
		undo.Create( "ZoneCreate" )
			undo.AddFunction( function( tab, id )
				ZoneManager.RemoveZone( id )
			end, identifier )
			undo.SetPlayer( owner )
		undo.Finish()
	else
		undo.Create( "ZoneCreate" )
			undo.AddFunction( function( tab, zone )
				ZoneManager.CreateZone( zone.id, {
					id = zone.id,
					point1 = zone.point1,
					point2 = zone.point2,
					wireframe = zone.wireframe,
					player = zone.player,
					admin = zone.admin,
					npc = zone.npc,
					ent = zone.ent,
					removeprops = zone.removeprops,
					tick = zone.tick,
					amount = zone.amount,
					limit = zone.limit,
					type = zone.type,
					shape = zone.shape,
					r = zone.r,
					g = zone.g,
					b = zone.b,
					a = zone.a
				} )
			end, zone )
			undo.SetPlayer( owner )
		undo.Finish()
	end

	owner:PrintMessage( HUD_PRINTCENTER, "#zone.success.create" )
	self.Point1 = nil
	self.Point2 = nil
	
	self:SetStage( 0 )

	return true
end

function TOOL:Think()
	-- Existing zone modification
	if ( CLIENT ) then return end
	
	self:SetOperation( self:GetClientNumber( "shape" ) )

	local owner = self:GetOwner()
	local zone = ZoneManager.Zones[self:GetClientInfo( "id" )]

	if ( owner:KeyDown(IN_USE) && self.NextUse <= CurTime() ) then
		if ( zone == nil ) then owner:PrintMessage( HUD_PRINTCENTER, "#zone.error.exist" ) return false end

		ZoneManager.CreateZone( zone.id, {
			id = zone.id,
			point1 = zone.point1,
			point2 = zone.point2,
			wireframe = self:GetClientNumber( "wireframe" ),
			player = self:GetClientNumber( "player" ),
			admin = self:GetClientNumber( "admin" ),
			npc = self:GetClientNumber( "npc" ),
			ent = self:GetClientNumber( "ent" ),
			removeprops = self:GetClientNumber( "removeprops" ),
			tick = self:GetClientNumber( "tick" ),
			amount = self:GetClientNumber( "amount" ),
			limit = self:GetClientNumber( "limit" ),
			type = self:GetClientNumber( "type" ),
			shape = self:GetClientNumber( "shape" ),
			r = self:GetClientNumber( "red" ),
			g = self:GetClientNumber( "green" ),
			b = self:GetClientNumber( "blue" ),
			a = self:GetClientNumber( "alpha" )
		} )
		
		undo.Create( "ZoneEdit" )
			undo.AddFunction( function( tab, zone )
				ZoneManager.CreateZone( zone.id, {
					id = zone.id,
					point1 = zone.point1,
					point2 = zone.point2,
					wireframe = zone.wireframe,
					player = zone.player,
					admin = zone.admin,
					npc = zone.npc,
					ent = zone.ent,
					removeprops = zone.removeprops,
					tick = zone.tick,
					amount = zone.amount,
					limit = zone.limit,
					type = zone.type,
					shape = zone.shape,
					r = zone.r,
					g = zone.g,
					b = zone.b,
					a = zone.a
				} )
			end, zone )
			undo.SetPlayer( owner )
		undo.Finish()

		owner:PrintMessage( HUD_PRINTCENTER, "#zone.success.edit" )

		self.NextUse = CurTime() + 0.25
	end
end

function TOOL:Holster()
	-- Remove data on holster
	self.Point1 = nil
	self.Point2 = nil
	
	self:SetStage( 0 )

	return true
end

if ( CLIENT ) then
	language.Add( "tool.zone.name", "Zone" )
	language.Add( "tool.zone.desc", "Create a Zone" )
	language.Add( "tool.zone.left_box", "Mark the first point of the zone" )
	language.Add( "tool.zone.right_box", "Mark the second point of the zone" )
	language.Add( "tool.zone.left_sphere", "Mark the center of the zone" )
	language.Add( "tool.zone.right_sphere", "Mark the radius of the zone" )
	language.Add( "tool.zone.reload", "Finish zone creation" )
	language.Add( "tool.zone.use", "Replace a zone's properties" )
	
	language.Add( "zone.error.first", "You haven't marked your first point." )
	language.Add( "zone.error.second", "You haven't marked your second point." )
	language.Add( "zone.error.id", "Please type in a valid identifier." )
	language.Add( "zone.error.exist", "The zone that you are trying to modify is non-existent." )
	
	language.Add( "zone.success.create", "Successfully created a zone!" )
	language.Add( "zone.success.edit", "Successfully edited the properties of the zone!" )
	language.Add( "zone.success.remove", "Successfully removed a zone!" )
	
	language.Add( "zone.option.description", "A zone affects the health of entities in it." )
	language.Add( "zone.option.id.label", "Identifier:" )
	language.Add( "zone.option.id.help", "The identifier of your zone, setting this to an already existing identifier will overwrite it." )
	language.Add( "zone.option.type.label", "Type:" )
	language.Add( "zone.option.type.damage", "Damage" )
	language.Add( "zone.option.type.heal", "Heal" )
	language.Add( "zone.option.type.safe", "Safe" )
	language.Add( "zone.option.type.useless", "Useless" )
	language.Add( "zone.option.shape.label", "Shape:" )
	language.Add( "zone.option.shape.box", "Box" )
	language.Add( "zone.option.shape.sphere", "Sphere" )
	language.Add( "zone.option.wireframe", "Wireframe" )
	language.Add( "zone.option.color.label", "Zone Color:" )
	language.Add( "zone.option.tick.label", "Tick Interval:" )
	language.Add( "zone.option.tick.help", "How often the zone will affect health. The tick interval is measured in seconds." )
	language.Add( "zone.option.damage_amount", "Damage Amount:" )
	language.Add( "zone.option.heal_amount", "Heal Amount:" )
	language.Add( "zone.option.min_health", "Min Health:" )
	language.Add( "zone.option.max_health", "Max Health:" )
	language.Add( "zone.option.limit.help", "How much health the entity will have when the zone stops affecting it. Set to 0 for no limit." )
	language.Add( "zone.option.more", "More Options:" )
	language.Add( "zone.option.damage_players", "Damage Players" )
	language.Add( "zone.option.damage_admins", "Damage Admins" )
	language.Add( "zone.option.damage_npcs", "Damage NPCs" )
	language.Add( "zone.option.damage_entities", "Damage Entities" )
	language.Add( "zone.option.heal_players", "Heal Players" )
	language.Add( "zone.option.heal_admins", "Heal Admins" )
	language.Add( "zone.option.heal_npcs", "Heal NPCs" )
	language.Add( "zone.option.heal_entities", "Heal Entities" )
	language.Add( "zone.option.protect_players", "Protect Players" )
	language.Add( "zone.option.protect_admins", "Protect Admins" )
	language.Add( "zone.option.protect_npcs", "Protect NPCs" )
	language.Add( "zone.option.protect_entities", "Protect Entities" )
	language.Add( "zone.option.remove_props", "Remove Props" )
	language.Add( "zone.option.remove", "Remove this zone" )
	
	language.Add( "Undone_ZoneCreate", "Undone Zone Create" )
	language.Add( "Undone_ZoneEdit", "Undone Zone Edit" )
	language.Add( "Undone_ZoneRemove", "Undone Zone Remove" )

	local function AddDefControls( CPanel )
		CPanel:ClearControls()
		
		-- Header
		CPanel:Help( "#zone.option.description" )
		
		-- Preset
		local preset_panel = vgui.Create( "ControlPresets", CPanel )
		preset_panel:SetPreset( "zone" )
		preset_panel:AddOption( "#preset.default", ConVarsDefault )
		for k, v in pairs( ConVarsDefault ) do
			preset_panel:AddConVar( k )
		end
		CPanel:AddPanel( preset_panel )
		
		-- Identifier
		CPanel:TextEntry( "#zone.option.id.label", "zone_id" )
		CPanel:ControlHelp( "#zone.option.id.help" )
		
		-- Type
		local type = LocalPlayer():GetInfoNum( "zone_type", TYPE_DAMAGE )
		local type_combobox = CPanel:ComboBox( "#zone.option.type.label", "zone_type" )
		type_combobox:AddChoice( "#zone.option.type.damage", TYPE_DAMAGE, type == TYPE_DAMAGE )
		type_combobox:AddChoice( "#zone.option.type.heal", TYPE_HEAL, type == TYPE_HEAL )
		type_combobox:AddChoice( "#zone.option.type.safe", TYPE_SAFE, type == TYPE_SAFE )
		type_combobox:AddChoice( "#zone.option.type.useless", TYPE_USELESS, type == TYPE_USELESS )
		
		-- Shape
		local shape = LocalPlayer():GetInfoNum( "zone_shape", SHAPE_BOX )
		local shape_combobox = CPanel:ComboBox( "#zone.option.shape.label", "zone_shape" )
		shape_combobox:AddChoice( "#zone.option.shape.box", SHAPE_BOX, shape == SHAPE_BOX )
		shape_combobox:AddChoice( "#zone.option.shape.sphere", SHAPE_SPHERE, shape == SHAPE_SPHERE )
		
		-- Wireframe
		CPanel:CheckBox( "#zone.option.wireframe", "zone_wireframe" )
		
		-- Color
		local mixer = vgui.Create( "DColorMixer", CPanel )
		mixer:SetLabel( "#zone.option.color.label" )
		mixer:SetConVarR( "zone_red" )
		mixer:SetConVarG( "zone_green" )
		mixer:SetConVarB( "zone_blue" )
		mixer:SetConVarA( "zone_alpha" )
		CPanel:AddItem( mixer )
		
		-- Sliders
		if ( type  == TYPE_DAMAGE || type == TYPE_HEAL ) then
			CPanel:NumSlider( "#zone.option.tick.label", "zone_tick", 1, 60, 0 )
			CPanel:ControlHelp( "#zone.option.tick.help" )
			CPanel:NumSlider( type == TYPE_DAMAGE and "#zone.option.damage_amount" or "#zone.option.heal_amount", "zone_amount", 1, 100, 0 )
			CPanel:NumSlider( type == TYPE_DAMAGE and "#zone.option.min_health" or "#zone.option.max_health", "zone_limit", 0, 200, 0 )
			CPanel:ControlHelp( "#zone.option.limit.help" )
		end
		
		CPanel:Help( "#zone.option.more" )
		
		-- Groups
		if type  == TYPE_DAMAGE then
			CPanel:CheckBox( "#zone.option.damage_players", "zone_player" )
			CPanel:CheckBox( "#zone.option.damage_admins", "zone_admin" )
			CPanel:CheckBox( "#zone.option.damage_npcs", "zone_npc" )
			CPanel:CheckBox( "#zone.option.damage_entities", "zone_ent" )
		elseif type == TYPE_HEAL then
			CPanel:CheckBox( "#zone.option.heal_players", "zone_player" )
			CPanel:CheckBox( "#zone.option.heal_admins", "zone_admin" )
			CPanel:CheckBox( "#zone.option.heal_npcs", "zone_npc" )
			CPanel:CheckBox( "#zone.option.heal_entities", "zone_ent" )
		elseif type == TYPE_SAFE then
			CPanel:CheckBox( "#zone.option.protect_players", "zone_player" )
			CPanel:CheckBox( "#zone.option.protect_admins", "zone_admin" )
			CPanel:CheckBox( "#zone.option.protect_npcs", "zone_npc" )
			CPanel:CheckBox( "#zone.option.protect_entities", "zone_ent" )
		end
		
		-- Remove Props
		CPanel:CheckBox( "#zone.option.remove_props", "zone_removeprops" )
		
		-- Remove Zone
		local remove_button = CPanel:Button( "#zone.option.remove" )
		remove_button.DoClick = function()
			RunConsoleCommand( "zone_remove", LocalPlayer():GetInfo( "zone_id", "Zone" ) )
		end
	end
	
	hook.Add( "InitPostEntity", "ProWolf's Zone Tool Init Post Entity", function()
		cvars.AddChangeCallback( "zone_type", function()
			local CPanel = controlpanel.Get( "zone" )
			if (!CPanel) then return end
			AddDefControls( CPanel )
		end )
	end )
	
	function TOOL.BuildCPanel( CPanel )
		AddDefControls( CPanel )
	end
end