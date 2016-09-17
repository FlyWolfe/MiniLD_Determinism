Ghost = {}
Ghost.__index = Ghost

function Ghost.create(pointArray, velocityArray, platformActivations, width, height, imageFile)
	local ghost = {}
	setmetatable(ghost, Ghost)
	ghost.width = width
	ghost.height = height
	ghost.pointArrray = pointArray
	ghost.velocityArray = velocityArray
	ghost.platformActivations = platformActivations
	ghost.playbackIndex = -1
	ghost.doPlayback = false
	ghost.x = -1
	ghost.y = -1
	ghost.image = love.graphics.newImage(imageFile)
	ghost.dumbCounter = 0
	return ghost
end

function Ghost:setPlaybackData(pointArray, velocityArray, platformActivations)
	self.pointArray = pointArray
	self.velocityArray = velocityArray
	self.platformActivations = platformActivations
end

function Ghost:beginPlayback()
	self.doPlayback = true
	self.dumbCounter = self.dumbCounter + 1
	self.playbackIndex = 1
end

function Ghost:update(dt)
	if self.doPlayback then
		--set the x and y appropriately
		if self.pointArray then
			if self.playbackIndex > #self.pointArray then
				self.playbackIndex = -1
				self.doPlayback = false
			else
				local point = self.pointArray[self.playbackIndex]
				self.x = point.x
				self.y = point.y
				self.playbackIndex = self.playbackIndex + 1
			end
		else
			print("error with playback: no pointArray!")
		end
	end
end

function Ghost:draw()
	love.graphics.draw(self.image, self.x - (self.width / 2), self.y - (self.height / 2))
end