Ghost = {}
Ghost.__index = Ghost

function Ghost.create(pointArray, velocityArray, platformActivations, width, height)
	local ghost = {}
	setmetatable(ghost, Ghost)
	ghost.width = width
	ghost.height = height
	ghost.pointArrray = pointArray
	ghost.velocityArray = velocityArray
	ghost.platformActivations = platformActivations
	ghost.playbackIndex = 1
	ghost.doPlayback = false
	ghost.x = -1
	ghost.y = -1
	return ghost
end

function Ghost:setPlaybackData(pointArray, velocityArray, platformActivations)
	ghost.pointArrray = pointArray
	ghost.velocityArray = velocityArray
	ghost.platformActivations = platformActivations
end

function Ghost:beginPlayback()
	self.doPlayback = true
end

function Ghost:update(dt)
	if self.doPlayback then
		--set the x and y appropriately
		local point = self.pointArray[self.playbackIndex]
		self.x = point.x
		self.y = point.y
		self.playbackIndex = self.playbackIndex + 1
	end
end

function Ghost:draw()
	love.graphics.setColor(25, 25, 25)
	love.graphics.rectangle('fill', self.x - (self.width / 2), self.y - (self.height / 2), self.width, self.height)
end