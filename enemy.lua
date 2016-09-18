Enemy = {}
Enemy.__index = Enemy

BIRD_ENEMY = 1
DINO_ENEMY = 2
WOLF_ENEMY = 3

function Enemy.create(world, x, y, width, height, enemyType)
	local enemy = {}
	setmetatable(enemy, Enemy)
	enemy.width = width
	enemy.height = height
	enemy.enemyType = enemyType
	
	enemy.maxSpeed = 200
	enemy.prevX = x
	enemy.prevY = y
	enemy.floatLeniency = 1

	--place the body in the center of the world and make it dynamic, so it can move around
	enemy.body = love.physics.newBody(world, x, y, "dynamic")
	enemy.body:setFixedRotation(true)
	enemy.shape = love.physics.newRectangleShape(width, height)
	-- Attach fixture to body and give it a density of 1.
	enemy.fixture = love.physics.newFixture(enemy.body, enemy.shape, 1)
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

end