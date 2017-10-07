local gameRoulette = {
	timer = Timer.new(),
	lastGame = -1
}

function gameRoulette:entering()
	local newGame = nil
	repeat
		newGame = math.random(#Game.minigameNames)
	until newGame ~= self.lastGame
	self.lastGame = newGame
end

function gameRoulette:entered()
	self.timer:add(1, function() Venus.switch(Game.minigames[Game.minigameNames[self.lastGame] ]) end)
end

function gameRoulette:update(dt)
	self.timer:update(dt)
end

function gameRoulette:draw()
	drawMinigameInfo(Game.minigames[Game.minigameNames[self.lastGame] ])
end

return gameRoulette
