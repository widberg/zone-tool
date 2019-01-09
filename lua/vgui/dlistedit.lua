local PANEL = {}

AccessorFunc( PANEL, "m_bTable", "Table" )
AccessorFunc( PANEL, "m_bLabel", "Label" )
AccessorFunc( PANEL, "m_bTextEntry", "TextEntry" )
AccessorFunc( PANEL, "m_bListView", "ListView" )

Derma_Install_Convar_Functions( PANEL )

function PANEL:Init()

	self:SetLabel( "" )
	
	local list = vgui.Create( "DListView", self )
	list:AddColumn( "" )
	
	local text = vgui.Create( "DTextEntry", self )
	text.OnEnter = function( panel )
		list:AddLine( panel:GetValue() )
		self:SetTable( list:GetLines() )
		self:UpdateConvarValue()
	end
	
	list.OnRowSelected = function( panel, rowIndex, row )
		panel:RemoveLine( rowIndex )
		self:SetTable( panel:GetLines() )
		self:UpdateConvarValue()
	end
	
	self:SetTextEntry( text )
	self:SetListView( list )
	self:Add( text )
	self:Add( list )

end

function PANEL:Think()

	self:ConVarStringThink()

end

function PANEL:UpdateConvarValue()

	self:ConVarChanged( util.TableToJSON( self:GetTable() ) )

end

function PANEL:GetValue()

	return util.TableToJSON( self:GetTable() )

end

function PANEL:SetValue( stringValue )

	self:SetTable( util.JSONToTable( stringValue ) )

end

derma.DefineControl( "DListEdit", "A simple ListEdit control", PANEL, "Panel" )