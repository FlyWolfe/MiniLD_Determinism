require ("platform")
require ("player")
function love.load()
  --initial graphics setup
  love.graphics.setBackgroundColor(104, 136, 248) --set the background color to a nice blue
  love.window.setMode(650, 650) --set the window dimensions to 650 by 650
  
  
  love.physics.setMeter(64) --the height of a meter our worlds will be 64px
  world = love.physics.newWorld(0, 9.81*64, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
 
  objects = {} -- table to hold all our physical objects
 
 
  --Create Platforms
  objects.block1 = createPlatform(world, 200, 550, 50, 75, 5)
  objects.block2 = createPlatform(world, 200, 400, 100, 50, 2)
  objects.ground = createPlatform(world, love.graphics.getWidth() / 2, love.graphics.getHeight() - 25, love.graphics.getWidth(), 50, 10)
 
  objects.player = Player.create(world, 325, 325, 20, 20)
 
end
 
 
function love.update(dt)
  world:update(dt) --this puts the world into motion
  objects.player:update(dt)
end
 
function love.draw()
  love.graphics.setColor(72, 160, 14) -- set the drawing color to green for the ground
  love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates
 
  love.graphics.setColor(193, 47, 14) --set the drawing color to red for the ball
  love.graphics.polygon("fill", objects.player.body:getWorldPoints(objects.player.shape:getPoints()))
 
  love.graphics.setColor(50, 50, 50) -- set the drawing color to grey for the blocks
  love.graphics.polygon("fill", objects.block1.body:getWorldPoints(objects.block1.shape:getPoints()))
  love.graphics.polygon("fill", objects.block2.body:getWorldPoints(objects.block2.shape:getPoints()))
end