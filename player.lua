Player = {}
Player.__index = Player

function Player.create(world, x, y, width, height)
	local player = {}
	setmetatable(player, Player)
	player.width = width
	player.height = height
	player.maxSpeed = 200
	player.floatLeniency = 1
	player.recordedPoints = {}
	player.recordedVelocity = {}
	player.isRecording = false
	--place the body in the center of the world and make it dynamic, so it can move around
	player.body = love.physics.newBody(world, x, y, "dynamic")
	player.body:setFixedRotation(true)
	player.shape = love.physics.newRectangleShape(width, height)
	-- Attach fixture to body and give it a density of 1.
	player.fixture = love.physics.newFixture(player.body, player.shape, 1)
	--No bounce for you
	player.fixture:setRestitution(0)
	return player
end

function Player:withinRange(n1, n2)
	local result = false
	if n1 and n2 then
		result = n1 + self.floatLeniency > n2 and n1 - self.floatLeniency < n2
	end
	return result
end

function Player:isStandingOn(contact)
	x1,y1,x2,y2 = contact:getPositions()
	if self:withinRange(y1, self.body:getY() + (self.height / 2)) and self:withinRange(y2, self.body:getY() + (self.height / 2)) then 
		return true
	end
	return false
end

function Player:isGrounded()
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

--gets all platforms that the player is standing on
function Player:getGroundedBodies()
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

function Player:clearRecordedData()
	player.recordedPoints = {}
	player.recordedVelocity = {}
end

function Player:beginRecording()
	self:clearRecordedData()
	self.isRecording = true
end

function Player:endRecording()
	self.isRecording = false
end

function Player:update(dt)
	--press the right arrow key to push the ball to the right
	if love.keyboard.isDown("right") then
		self.body:applyForce(200, 0)
		x, y = self.body:getLinearVelocity()
		if math.abs(x) > self.maxSpeed then
			self.body:setLinearVelocity(self.maxSpeed,y)
		end
	elseif love.keyboard.isDown("left") then --press the left arrow key to push the ball to the left
		self.body:applyForce(-200, 0)
		x, y = self.body:getLinearVelocity()
		if math.abs(x) > self.maxSpeed then
			self.body:setLinearVelocity(-self.maxSpeed,y)
		end
	end
	if love.keyboard.isDown("up") then
		if self:isGrounded() then
		--we must set the velocity to zero to prevent a potentially large velocity generated by the change in position
			self.body:applyForce(0, -2000)
		end
	end
	if love.keyboard.isDown("rctrl") then --set to whatever key you want to use
		debug.debug()
	end
	
	
	--record location and speed if necessary
	if self.isRecording then
		local point = {}
		point.x = self.body:getX()
		point.y = self.body:getY()
		table.insert(self.recordedPoints, point)
		local velocity = {}
		velocity.x, velocity.y = objects.self.body:getLinearVelocity()
		table.insert(self.recordedVelocity, velocity)
	end
  end