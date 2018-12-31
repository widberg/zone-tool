include( "autorun/server/sv_zones.lua" )

TOOL.Name = "#Tool.zone.name"
TOOL.Category = "Construction"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar[ "id" ] = "Zone"
TOOL.ClientConVar[ "filled" ] = "0"
TOOL.ClientConVar[ "player" ] = "0"
TOOL.ClientConVar[ "admin" ] = "0"
TOOL.ClientConVar[ "npc" ] = "0"
TOOL.ClientConVar[ "ent" ] = "0"
TOOL.ClientConVar[ "removeprops" ] = "0"
TOOL.ClientConVar[ "tick" ] = 1
TOOL.ClientConVar[ "amount" ] = 1
TOOL.ClientConVar[ "limit" ] = 0
TOOL.ClientConVar[ "type" ] = 1
TOOL.ClientConVar[ "shape" ] = 1
TOOL.ClientConVar[ "red" ] = 255
TOOL.ClientConVar[ "green" ] = 255
TOOL.ClientConVar[ "blue" ] = 255
TOOL.ClientConVar[ "alpha" ] = 255

TOOL.Point1 = nil
TOOL.Point2 = nil

TOOL.NextUse = CurTime()

TOOL.Information = {
	{ name = "left_box", op = 1 },
	{ name = "right_box", op = 1 },
	{ name = "left_sphere", op = 2 },
	{ name = "right_sphere", op = 2 },
	{ name = "reload" },
	{ name = "use"}
}

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL:LeftClick( tr )
    -- Zone point marking
    self.Point1 = tr.HitPos
    self:GetOwner():PrintMessage( HUD_PRINTCENTER, "First point has been marked at: " .. tostring( self.Point1 ) )

    return true
end
	
function TOOL:RightClick( tr )
    -- Zone point marking
    self.Point2 = tr.HitPos
    self:GetOwner():PrintMessage( HUD_PRINTCENTER, "Second point has been marked at: " .. tostring( self.Point2 ) )

    return true
end

function TOOL:Reload( tr )
    -- Zone creation
    local owner = self:GetOwner()
    local zone = ZoneManager.Zones[self:GetClientInfo( "id" )]

    if ( self.Point1 == nil ) then
        owner:PrintMessage( HUD_PRINTCENTER, "You haven't marked your first point." )

        return false
    end

    if ( self.Point2 == nil ) then
        owner:PrintMessage( HUD_PRINTCENTER, "You haven't marked your second point." )

        return false
    end

    if ( not isstring( self:GetClientInfo( "id" ) ) ) || ( self:GetClientInfo( "id" ) == "" ) || ( string.byte(self:GetClientInfo( "id" )) == 32 ) then
        owner:PrintMessage( HUD_PRINTCENTER, "Please type in a valid identifier." )

        return false
    end

	ZoneManager.CreateZone( self:GetClientInfo( "id" ), {
        id = self:GetClientInfo( "id" ),
        point1 = self.Point1,
        point2 = self.Point2,
		filled = self:GetClientNumber( "filled" ),
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
				RunConsoleCommand( "zone_remove", id, "true" )
			end, self:GetClientInfo( "id" ) )
			undo.SetPlayer( owner )
		undo.Finish()
	else
		undo.Create( "ZoneCreate" )
			undo.AddFunction( function( tab, zone )
				ZoneManager.CreateZone( zone.id, {
					id = zone.id,
					point1 = zone.point1,
					point2 = zone.point2,
					filled = zone.filled,
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

    owner:PrintMessage( HUD_PRINTCENTER, "Successfully created a zone!" )
    self.Point1 = nil
    self.Point2 = nil

    return true
end

function TOOL:Think()
    -- Existing zone modification
    if ( CLIENT ) then return end
	
	self:SetOperation( self:GetClientNumber( "shape" ) )

    local owner = self:GetOwner()
    local zone = ZoneManager.Zones[self:GetClientInfo( "id" )]

    if ( owner:KeyDown(IN_USE) && self.NextUse <= CurTime() ) then
        if ( zone == nil ) then owner:PrintMessage( HUD_PRINTCENTER, "The zone that you are trying to modify is non-existent." ) return false end

        ZoneManager.CreateZone( zone.id, {
            id = zone.id,
            point1 = zone.point1,
            point2 = zone.point2,
			filled = self:GetClientNumber( "filled" ),
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
					filled = zone.filled,
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

        owner:PrintMessage( HUD_PRINTCENTER, "Successfully edited the properties of the zone." )

        self.NextUse = CurTime() + 0.25
    end
end

function TOOL:Holster()
    -- Remove data on holster
    self.Point1 = nil
    self.Point2 = nil

    return true
end

if ( CLIENT ) then
	language.Add( "Tool.zone.name", "Zone" )
    language.Add( "Tool.zone.desc", "Create a Zone" )
    language.Add( "Tool.zone.left_box", "Mark the first point of the zone" )
    language.Add( "Tool.zone.right_box", "Mark the second point of the zone" )
	language.Add( "Tool.zone.left_sphere", "Mark the center of the zone" )
    language.Add( "Tool.zone.right_sphere", "Mark the radius of the zone" )
    language.Add( "Tool.zone.reload", "Finish zone creation" )
    language.Add( "Tool.zone.use", "Replace a zone's properties" )
	
	language.Add( "Undone_ZoneCreate", "Undone Zone Create" )
	language.Add( "Undone_ZoneEdit", "Undone Zone Edit" )
	language.Add( "Undone_ZoneRemove", "Undone Zone Remove" )

	local function AddDefControls( CPanel, type )
		CPanel:ClearControls()
		
		CPanel:AddControl( "ComboBox", { MenuButton = 1, Folder = "zone", Options = { [ "#preset.default" ] = ConVarsDefault }, CVars = table.GetKeys( ConVarsDefault ) } )
		
		if type == nil then
			type = LocalPlayer():GetInfoNum( "zone_type", 1 )
		end
		local type_panel = vgui.Create( "DComboBox", CPanel )
		type_panel:AddChoice( "Damage", 1, type == 1 )
		type_panel:AddChoice( "Heal", 2, type == 2 )
		type_panel:AddChoice( "Safe", 3, type == 3 )
		
		type_panel.OnSelect = function( _, _, _, data )
			RunConsoleCommand( "zone_type", data )
			AddDefControls( CPanel, data )
		end
		
		local shape = LocalPlayer():GetInfoNum( "zone_shape", 1 )
		local shape_panel = vgui.Create( "DComboBox", CPanel )
		shape_panel:AddChoice( "Box", 1, shape == 1 )
		shape_panel:AddChoice( "Sphere", 2, shape == 2 )
		
		shape_panel.OnSelect = function( _, _, _, data )
			RunConsoleCommand( "zone_shape", data )
		end

        CPanel:Help( "The identifier of your zone, setting this to an already existing identifier will overwrite it." )
		CPanel:AddControl( "TextBox", { 
            Label = "Zone Identifier:",
            Command = "zone_id" 
        } )
		
		CPanel:Help( "The type of your zone:" )
        CPanel:AddPanel(type_panel)
		
		CPanel:Help( "The shape of your zone:" )
        CPanel:AddPanel(shape_panel)
		
		CPanel:CheckBox( "Filled", "zone_filled" )

        CPanel:AddControl( "Color", {
            Label = "Zone color:",
            Red = "zone_red",
            Green = "zone_green",
            Blue = "zone_blue",
            Alpha = "zone_alpha"
        } )
		
		if ( type  == 1 || type == 2 ) then
			CPanel:AddControl( "slider", { label = "Tick interval (Seconds):", command = "zone_tick", min = 1, max = 60 } )
			CPanel:AddControl( "slider", { label = type == 1 and "Damage Amount:" or "Heal Amount:", command = "zone_amount", min = 1, max = 100 } )
			CPanel:AddControl( "slider", { label = type == 1 and "Min Health:" or "Max health(0 for no limit):", command = "zone_limit", min = 0, max = 200 } )
		end

        CPanel:Help( "More Options:" )
		
		if type  == 1 then
			CPanel:CheckBox( "Damage Players", "zone_player" )
			CPanel:CheckBox( "Damage Admins", "zone_admin" )
			CPanel:CheckBox( "Damage NPCs", "zone_npc" )
			CPanel:CheckBox( "Damage Entities", "zone_ent" )
		elseif type == 2 then
			CPanel:CheckBox( "Heal Players", "zone_player" )
			CPanel:CheckBox( "Heal Admins", "zone_admin" )
			CPanel:CheckBox( "Heal NPCs", "zone_npc" )
			CPanel:CheckBox( "Heal Entities", "zone_ent" )
		elseif type == 3 then
			CPanel:CheckBox( "Protect Players", "zone_player" )
			CPanel:CheckBox( "Protect Admins", "zone_admin" )
			CPanel:CheckBox( "Protect NPCs", "zone_npc" )
			CPanel:CheckBox( "Damage Entities", "zone_ent" )
		end
		
		CPanel:CheckBox( "Remove Props", "zone_removeprops" )
		
		local remove_button = vgui.Create( "DButton", CPanel )
		remove_button:SetText( "Remove this zone" )
		remove_button.DoClick = function()
			RunConsoleCommand( "zone_remove", LocalPlayer():GetInfo( "zone_id" ) )
		end
		
		CPanel:AddPanel(remove_button)
	end
	
	function TOOL.BuildCPanel( CPanel )
        AddDefControls( CPanel )
    end
end