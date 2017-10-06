local menu = require "src.menu"

local results = {}

function results:init()
	self.timer = Timer.new()
end

function results:entered()
	self.timer:add(2, function() Venus.switch(menu) end)
end

function results:update(dt)
	self.timer:update(dt)	
end

function results:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(Game.result, 10, 10)
end

return results
