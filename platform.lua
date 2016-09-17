Platform = {}
Platform.__index = Platform

BASIC_PLATFORM = 1
DISAPPEARING_PLATFORM = 2
GOAL_PLATFORM = 3

function createPlatform(world, x, y, width, height, density, platformType)
	local block = {}
	setmetatable(block, Platform)
	
	if density == nil then
		density = 5
	end
	
	block.toDelete = false
	--variable to count down to deletion once a platform has been marked for deletion
	block.deleteCountdown = -1
	--amount of time after being stepped on until block disappears
	block.deleteDuration = 1.5
	block.platformType = platformType
	block.body = love.physics.newBody(world, x, y, "static")
	block.shape = love.physics.newRectangleShape(width, height)
	-- A higher density gives it more mass.
	block.fixture = love.physics.newFixture(block.body, block.shape, density)
	return block
end

function Platform:activate()
	if self.platformType == BASIC_PLATFORM then
		--print("doing nothing, it's a basic platform")
	elseif self.platformType == DISAPPEARING_PLATFORM then
		if self.deleteCountdown == -1 and self.toDelete ~= true then
			print("make the platform DISAPPEAR!")
			self.deleteCountdown = self.deleteDuration
		end
	end
end

function Platform:update(dt)
	if self.deleteCountdown ~= -1  and self.deleteCountdown >= 0 then
		self.deleteCountdown = self.deleteCountdown - dt
	elseif self.deleteCountdown ~= -1 and self.deleteCountdown <= 0 then
		self.deleteCountdown = -1
		self.toDelete = true
		self.body:destroy()
	end
end