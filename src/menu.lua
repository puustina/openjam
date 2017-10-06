local menu = {}

function menu:init()
	local minigameNames = {
		"DiamondHeist",
		"CavePainting",
		"WalkTheDog"
	}

	self.minigames = {}
	for i, j in ipairs(minigameNames) do
		self.minigames[j] = require ("src.minigame"..j)
	end
end

function menu:keypressed(key, scancode, isRepeat)
	if (key == "return") then
		Venus.switch(self.minigames["DiamondHeist"])
	end
end

function menu:update(dt)
end

function menu:draw()
	local counter = 0
	for i, j in pairs(self.minigames) do
		love.graphics.print(j.name .. ": " .. j.description, 10, 10 + 35 * counter)
		love.graphics.print(j.controls, 20, 25 + 35 * counter)
		counter = counter + 1
	end
end

return menu
