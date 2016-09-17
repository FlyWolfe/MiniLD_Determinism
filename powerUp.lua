Powerup = {}
Powerup.__index = Powerup

DOUBLEJUMP_POWERUP = 1
FORECEFIELD_POWERUP = 2
SPEED_POWERUP = 3

function Powerup.create(world, x, y, width, height, powerupType)
	local powerup = {}
	setmetatable(powerup, Powerup)
	powerup.width = width
	powerup.height = height
	powerup.powerupType = powerupType
	
	powerup.maxSpeed = 200
	powerup.prevX = x
	powerup.prevY = y
	powerup.floatLeniency = 1

	--place the body in the center of the world and make it dynamic, so it can move around
	powerup.body = love.physics.newBody(world, x, y, "dynamic")
	powerup.body:setFixedRotation(true)
	powerup.shape = love.physics.newRectangleShape(width, height)
	-- Attach fixture to body and give it a density of 1.
	powerup.fixture = love.physics.newFixture(powerup.body, powerup.shape, 1)
	--No bounce for you
	powerup.fixture:setRestitution(0)
	return powerup
end

function Powerup:withinRange(n1, n2)
	local result = false
	if n1 and n2 then
		result = n1 + self.floatLeniency > n2 and n1 - self.floatLeniency < n2
	end
	return result
end

function Powerup:grabbed()
	self.width = 0
	self.height = 0
end

function Powerup:update(dt)

end