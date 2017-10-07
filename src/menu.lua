local menu = {
	minigameNames = {
		"DiamondHeist",
		"CavePainting",
		"WalkTheDog",
		"FaceSlap"
	}
}

function menu:init()
	self.minigames = {}
	for i, j in ipairs(self.minigameNames) do
		self.minigames[j] = require ("src.minigame"..j)
	end
end

function menu:keypressed(key, scancode, isRepeat)
	if Game.paused then return end
	if (key == Controls["ACTION"]) then
		local newGame = ""
		repeat 
			newGame = self.minigameNames[math.random(1, #self.minigameNames)] 
		until newGame ~= Game.lastGame
		Game.lastGame = newGame
		--Venus.switch(self.minigames[newGame])
		Venus.switch(self.minigames["CavePainting"])
	end
end

function menu:update(dt)
	if Game.paused then return end
end

function menu:draw()
	love.graphics.setBackgroundColor(0, 0, 0)
	preDraw()
	local counter = 0
	for i, j in pairs(self.minigames) do
		love.graphics.setColor(255, 255, 255)
		love.graphics.print(j.name .. ": " .. j.description, 10, 10 + 35 * counter)
		love.graphics.print(j.controls, 20, 25 + 35 * counter)
		counter = counter + 1
	end
	postDraw()
end

return menu
