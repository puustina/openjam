local menu = require "src.menu"
local results = {}

function results:init()
	self.timer = Timer.new()
end

function results:entered()
	self.timer:add(2, function() Venus.switch(menu) end)
end

function results:left()
	Game.result = ""
end

function results:update(dt)
	if Game.paused then return end
	self.timer:update(dt)	
end

function results:draw()
	preDraw()
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(Game.result, 10, 10)
	postDraw()
end

return results
