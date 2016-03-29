-- Copyright (C) Charles Leasure, Mark Dietzer, and Michael Johnson d.b.a SpaceAge - All Rights Reserved
-- See LICENSE file for more information.

-- cache global variables
local FrameTime = FrameTime
local MsgC = MsgC
local MsgN = MsgN
local SysTime = SysTime

-- attempt to use gmsv_fps
local betterFrameTime = false
do
	local requireSuccess = pcall(require, "fps")
	if requireSuccess then
		if engine and engine.RealFrameTime then
			FrameTime = engine.RealFrameTime
			betterFrameTime = true
		elseif game and game.GetFrameTimeReal then
			FrameTime = game.GetFrameTimeReal
			betterFrameTime = true
		end
	end
end

-- configuration
local slowFrameTime = 1 / 8 -- 8 FPS
local neededHysteresisFrames = 3

local successColor = Color(80, 220, 100)
local warningColor = Color(232, 118, 0)
local errorColor = Color(206, 32, 41)

-- state
local isLagging = false
local hysteresisFrames = 0

local function checkForLag()
	local frameTime = FrameTime()

	if isLagging then
		-- we're presently lagging
		if frameTime >= slowFrameTime then
			hysteresisFrames = 0 -- reset hysteresis
			return -- we're still lagging, no change
		end

		-- we're not lagging anymore, increment hysteresis state
		hysteresisFrames = hysteresisFrames + 1

		-- we're not lagging on this frame
		if hysteresisFrames >= neededHysteresisFrames then
			-- we're no longer lagging and have met the required number of hysteresis frames
			isLagging = false
			hook.Run("StoppedLagging")
			MsgC(successColor, "[LagDetect] Lag ended\n")
			return
		end

		return
	end

	-- we're not presently lagging
	if frameTime >= slowFrameTime then
		-- this frame was above our threshold, increment hysteresis state
		hysteresisFrames = hysteresisFrames + 1

		if hysteresisFrames >= neededHysteresisFrames then
			-- we've been lagging for the required number of frames
			isLagging = true
			MsgC(errorColor, "[LagDetect] Severe lag detected\n")
			hook.Run("StartedLagging")
			return
		end

		-- we haven't yet met the required number of hysteresis frames
		--MsgC(warningColor, "[LagDetect] Long frame detected\n")
		return
	end

	-- our frame time wasn't long enough, reset hysteresis
	hysteresisFrames = 0
end

timer.Simple(5, function()
	-- wait until we've spawned everything
	lastFrame = SysTime() -- update lastFrame to now so that we don't get an initial long frame warning
	hook.Add("Think", "LagDetect", checkForLag)
	MsgC(successColor, "[LagDetect] Started\n")
end)

if betterFrameTime then
	MsgC(successColor, "[LagDetect] Loaded (with high quality FPS detection)\n")
else
	MsgC(warningColor, "[LagDetect] Loaded (with poor quality FPS detection)\n")
end
