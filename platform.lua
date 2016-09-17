function createPlatform(world, x, y, width, height, density)
	if density == nil then
		density = 5
	end
	local block = {}
	block.body = love.physics.newBody(world, x, y, "static")
	block.shape = love.physics.newRectangleShape(width, height)
	block.fixture = love.physics.newFixture(block.body, block.shape, density) -- A higher density gives it more mass.
	return block
end