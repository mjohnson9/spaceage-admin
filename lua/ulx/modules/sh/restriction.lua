local cvarName = "sa_bypass_restrictions"
local permissionName = "sa bypassrestrictions"

if CLIENT then
	CreateClientConVar(cvarName, "0", false, true)
end
if SERVER then
	ULib.ucl.registerAccess(permissionName, ULib.ACCESS_ADMIN, "Ability to bypass gamemode restrictions", "Other")
end

local PLAYER = FindMetaTable("Player")

function PLAYER:IsRestricted()
	local hasAccess = ULib.ucl.query(self, permissionName)
	if not hasAccess then
		return false
	end

	-- if it's any value other than zero, the player isn't restricted
	return self:GetInfoNum(cvarName, 0) == 0
end
