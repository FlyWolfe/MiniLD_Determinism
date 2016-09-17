require ("platform")
require ("player")
function love.load()
	--initial graphics setup
	love.graphics.setBackgroundColor(104, 136, 248) --set the background color to a nice blue
	love.window.setMode(650, 650) --set the window dimensions to 650 by 650

	love.physics.setMeter(64) --the height of a meter our worlds will be 64px
	world = love.physics.newWorld(0, 9.81*64, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81

	objects = {} -- table to hold all our physical objects
	objects.platforms = {} --table to hold all platforms

	--Create Platforms
	table.insert(objects.platforms, createPlatform(world, love.graphics.getWidth() / 2, love.graphics.getHeight() - 25, love.graphics.getWidth(), 50, 10, BASIC_PLATFORM))
	table.insert(objects.platforms, createPlatform(world, 200, 550, 50, 75, 5, DISAPPEARING_PLATFORM))
	table.insert(objects.platforms, createPlatform(world, 200, 400, 100, 50, 2, DISAPPEARING_PLATFORM))

	objects.player = Player.create(world, 325, 325, 20, 20)
 
end

function love.update(dt)
	world:update(dt) --this puts the world into motion
	objects.player:update(dt)
	local colliders = objects.player:getGroundedBodies()

	for i = #objects.platforms, 1, -1 do
		objects.platforms[i]:update(dt)
		--if we are colliding with the current platform, then activate it
		for j = 1, #colliders, 1 do
			if colliders[j] == objects.platforms[i].fixture then
				objects.platforms[i]:activate()
			end
		end
		if objects.platforms[i].toDelete then
			table.remove(objects.platforms, i)
		end
	end
end
 
function love.draw()

	love.graphics.setColor(193, 47, 14) --set the drawing color to red for the ball
	love.graphics.polygon("fill", objects.player.body:getWorldPoints(objects.player.shape:getPoints()))
	
	love.graphics.setColor(50, 50, 50) -- set the drawing color to grey for the blocks
	for i = 1, #objects.platforms do
		love.graphics.polygon("fill", objects.platforms[i].body:getWorldPoints(objects.platforms[i].shape:getPoints()))
	end
	
end