local results = require "src.results"

local walkTheDog = {
	name = "Walk the Dog",
	description = "Mark the fireposts.",
	controls = "ACTION",
	thumbnail = nil
}

function walkTheDog:init()
	self.timer = Timer.new()
end

function walkTheDog:entered()
	Game.result = "WIN"
	self.timer:add(1, function() Venus.switch(results) end)
end

function walkTheDog:update(dt)
	if Game.paused then return end
	self.timer:update(dt)
end

function walkTheDog:draw()
	preDraw()
	love.graphics.print("Walk the Dog - not implemented - You win!", 10, 10)
	postDraw()
end

return walkTheDog
