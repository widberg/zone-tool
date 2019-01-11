local PANEL = {}

Derma_Install_Convar_Functions( PANEL )

function PANEL:Init()
	
	self:SetTall( 100 )
	self:SetPaintBackground( false )
	
	local Panel = vgui.Create( "DSizeToContents", self )
	Panel:SetSizeX( false )
	Panel:Dock( TOP )
	
	self.Text = vgui.Create( "DTextEntry", Panel )
	self.Text:Dock( FILL )
	
	self.Button = vgui.Create( "DImageButton", Panel )
	self.Button:Dock( RIGHT )
	self.Button:SetMaterial( "icon16/add.png" )
	self.Button:SetStretchToFit( false )
	self.Button:SetSize( 20, 20 )
	self.Button:DockMargin( 2, 0, 0, 0 )
	self.Button.DoClick = function()
		if ( !IsValid( self ) ) then return end
		self.Text:OnEnter()
	end
	
	self.List = vgui.Create( "DListView", self )
	self.Column = self.List:AddColumn( "" )
	self.List:SetMultiSelect( false )
	self.List:SetSortable ( true )
	self.List:Dock( FILL )
	
	self.Text.OnEnter = function()
		if ( !IsValid( self ) ) then return end
		local textValue = self.Text:GetValue()
		if ( string.len( textValue ) > 0 && not string.match(textValue, "[\"|']") && not table.HasValue( self:GetList(), textValue ) ) then
			self.List:AddLine( textValue )
			self:UpdateConvarValue()
			self.Text:SetText( "" )
		end
	end
	
	self.List.OnRowSelected = function( panel, rowIndex, row )
		if ( !IsValid( self ) ) then return end
		self.List:RemoveLine( rowIndex )
		self:UpdateConvarValue()
	end
	
	self.Value = "[]"

end

function PANEL:Think()

	self:ConVarStringThink()

end

function PANEL:UpdateConvarValue()

	self:ConVarChanged( util.TableToJSON( self:GetList() ) )

end

function PANEL:GetList( value )
	
	if self.List:GetLines() == nil then return {} end
	local list = {}
	for k, line in pairs( self.List:GetLines() ) do
		list[k] = tostring( line:GetValue( 1 ) )
	end
	return list
	
end

function PANEL:SetValue( stringValue )

	local list = util.JSONToTable( stringValue:gsub("'", "\"") )
	if ( list && self.Value ~= stringValue ) then
		self.List:Clear()
		for _, v in pairs( list ) do
			self.List:AddLine( v )
		end
		self.Value = stringValue
	end

end

function PANEL:GetLabel()

	return self.Column:GetName()

end

function PANEL:SetLabel( labelText )

	self.Column:SetName( labelText )

end

derma.DefineControl( "DListEdit", "A simple DListEdit control", PANEL, "DPanel" )