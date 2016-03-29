aaaaaaaaaaaaaa&*Y&*F
-- Copyright (C) Charles Leasure, Mark Dietzer, and Michael Johnson d.b.a SpaceAge - All Rights Reserved
-- See LICENSE file for more information.

-- cache global variables
local IsValid = IsValid
local timerCreate = timer.Create
local timerRemove = timer.Remove
local SortedPairsByValue = SortedPairsByValue

-- utility functions
local function isTableEmpty(t)
	return next(t) == nil
end

-- detect function to get prop owner
local getOwner = Entity(0).GetOwner
timer.Simple(2, function() -- wait until everything is loaded
	-- detect getOwner function
	local nullEnt = Entity(0)
	if nullEnt.CPPIGetOwner then
		getOwner = nullEnt.CPPPIGetOwner
	end
end)

-- static configuration (do not change)
local tag = "AntiPenetration" -- Name for hooks

local function antiPenetrationThink()
	local froze = 0
	local owners = {}

	for _, v in ipairs(ents.GetAll()) do
		local thisPenetrating = false

		local physCount = v:GetPhysicsObjectCount()
		for i = 0, physCount do
			-- iterate through all of the entity's physics bodies
			local physObj = v:GetPhysicsObjectNum(i)
			if IsValid(physObj) then
				if physObj:IsPenetrating() and not physObj:IsAsleep() then
					-- if it's actively having penetration issues
					physObj:EnableMotion(false)
					physObj:Sleep()

					thisPenetrating = true
				end
			end
		end

		if thisPenetrating then
			froze = froze + 1
			local owner = getOwner(v)
			if IsValid(owner) then
				owners[owner] = (owners[owner] or 0) + 1
			end
		end
	end

	if froze > 0 then
		MsgN("[AntiPenetration] Froze " .. froze .. " penetrating props")

		if not isTableEmpty(owners) then
			MsgN("[AntiPenetration] Top culprits:")
			local i = 1

			for owner, num in SortedPairsByValue(owners, true) do
				MsgN("\t[" .. owner:SteamID() .. "] " .. owner:Name() .. " - " .. num .. " penetrating props")
				if i >= 3 then
					break
				end
			end
		end
	end
end

hook.Add("StartedLagging", tag, function()
	timerCreate(tag, 0.25, 0, antiPenetrationThink) -- check for penetrating props continuously every 250ms until the lag stops
	antiPenetrationThink() -- go ahead and do the
end)

hook.Add("StoppedLagging", tag, function()
	timerRemove(tag)
end)
