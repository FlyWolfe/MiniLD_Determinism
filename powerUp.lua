Powerup = {}
Powerup.__index = Powerup

function Powerup.create(world, x, y, width, height, powerupType, imageFile)
	local powerup = {}
	setmetatable(powerup, Powerup)
	powerup.width = width
	powerup.height = height
	powerup.powerupType = powerupType
	powerup.image = love.graphics.newImage(imageFile)
	
	powerup.maxSpeed = 200
	powerup.x = x
	powerup.y = y
	powerup.floatLeniency = 1
	
	return powerup
end

function Powerup:withinRange(n1, n2)
	local result = false
	if n1 and n2 then
		result = n1 + self.floatLeniency > n2 and n1 - self.floatLeniency < n2
	end
	return result
end

function Powerup:isColliding(x, y, width, height)
	if x - width / 2 < self.x + self.width / 2 and y - height / 2 < self.y + self.width / 2 and x + width / 2 > self.x - self.width / 2 and y + height / 2 > self.y - self.width / 2 then
		print("collided!!!")
		return true
	else
		return false
	end
end

function Powerup:grabbed()
	self.width = 0
	self.height = 0
end

function Powerup:update(dt)

end

function Powerup:draw(dt)
	love.graphics.draw(self.image, self.x - (self.width / 2), self.y - (self.height / 2))
end
