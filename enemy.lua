Enemy = {}
Enemy.__index = Enemy

BIRD_ENEMY = 1
DINO_ENEMY = 2
WOLF_ENEMY = 3

function Enemy.create(world, x, y, width, height, density, enemyType, imageFile)
	local enemy = {}
	setmetatable(enemy, Enemy)
	enemy.width = width
	enemy.height = height
	enemy.enemyType = enemyType
	enemy.image = love.graphics.newImage(imageFile)
	
	enemy.dangerous = false
	
	if enemyType == DINO_ENEMY or enemyType == WOLF_ENEMY then
		enemy.dangerous = true
	end
	
	enemy.maxSpeed = 200
	enemy.prevX = x
	enemy.prevY = y
	enemy.floatLeniency = 1
	enemy.count = 1

	--place the body in the center of the world and make it dynamic, so it can move around
	enemy.body = love.physics.newBody(world, x, y, "static")
	enemy.body:setFixedRotation(true)
	enemy.body:setGravityScale(0)
	enemy.shape = love.physics.newRectangleShape(width, height)
	-- Attach fixture to body and give it a density of 1.
	enemy.fixture = love.physics.newFixture(enemy.body, enemy.shape, density)
	--No bounce for you
	enemy.fixture:setRestitution(0)
	return enemy
end

function Enemy:withinRange(n1, n2)
	local result = false
	if n1 and n2 then
		result = n1 + self.floatLeniency > n2 and n1 - self.floatLeniency < n2
	end
	return result
end

function Enemy:isStandingOn(contact)
	x1,y1,x2,y2 = contact:getPositions()
	if self:withinRange(y1, self.body:getY() + (self.height / 2)) and self:withinRange(y2, self.body:getY() + (self.height / 2)) and not self:withinRange(x1, x2) then 
		return true
	end
	return false
end

function Enemy:isGrounded()
	local result = false
	local bodyList = self.body:getContactList()
	if bodyList ~= nil then
		for i=1, #bodyList do
			if self:isStandingOn(bodyList[i]) then
				result = true
				break
			end
		end
	end
	
	return result
end

--gets all platforms that the enemy is standing on
function Enemy:getGroundedBodies()
	local result = {}
	local bodyList = self.body:getContactList()
	if bodyList ~= nil then
		for i=1, #bodyList do
			if self:isStandingOn(bodyList[i]) then
				local f1, f2 = bodyList[i]:getFixtures()
				if f1 == self.fixture then
					table.insert(result, f2)
				else
					table.insert(result, f1)
				end
			end
		end
	end
	
	return result
end

function Enemy:update(dt)
	if self.enemyType == BIRD_ENEMY then
		if self.count < 30 then
			self.body:setX(self.body:getX() + 2)
		elseif self.count > 40 and self.count < 70 then
			self.body:setX(self.body:getX() - 2)
		elseif self.count >= 70 then
			self.count = 0
		end
	elseif self.enemyType == DINO_ENEMY then
		
	elseif self.enemyType == WOLF_ENEMY then
	
	end

	self.count = self.count + 1
end

function Enemy:draw(dt)
	love.graphics.draw(self.image, self.body:getX() - (self.width / 2), self.body:getY() - (self.height / 2))
end
