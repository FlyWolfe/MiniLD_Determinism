  Player = {}
  Player.__index = Player
  
  function Player.create(world, x, y, width, height)
	local player = {}
	setmetatable(player, Player)
	player.width = width
	player.height = height
	player.maxSpeed = 200
	player.floatLeniency = 1
	player.body = love.physics.newBody(world, x, y, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
	player.body:setFixedRotation(true)
	player.shape = love.physics.newRectangleShape(width, height)
	player.fixture = love.physics.newFixture(player.body, player.shape, 1) -- Attach fixture to body and give it a density of 1.
	player.fixture:setRestitution(0) --No bounce for you
	return player
  end
  
  function Player:withinRange(n1, n2)
	local result = false
	if n1 and n2 then
		result = n1 + self.floatLeniency > n2 and n1 - self.floatLeniency < n2
	end
	return result
  end
  
  function Player:isGrounded()
	local result = false
	local bodyList = self.body:getContactList()
	if bodyList ~= nil then
		for i=1, #bodyList do
			x1,y1,x2,y2 = bodyList[i]:getPositions()
			if self:withinRange(y1, self.body:getY() + (self.height / 2)) and self:withinRange(y2, self.body:getY() + (self.height / 2)) then 
				result = true
				break
			end
		
		end
	end
	return result
  end
  
  function Player:update(dt)
	  --here we are going to create some keyboard events
	  if love.keyboard.isDown("right") then --press the right arrow key to push the ball to the right
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
			self.body:applyForce(0, -2000) --we must set the velocity to zero to prevent a potentially large velocity generated by the change in position
		end
	  end
	  if love.keyboard.isDown("rctrl") then --set to whatever key you want to use
		debug.debug()
	  end
  end