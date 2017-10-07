local gameRoulette = {
	timer = Timer.new(),
	propabilities = {},
	gameIndex = nil
}

function gameRoulette:init()
	for i = 1, #Game.minigameNames do
		self.propabilities[i] = 1/#Game.minigameNames
	end
end

function gameRoulette:entering()
	local rand = math.random()
	local index = -1
	local distribute = 0
	for i = 1, #self.propabilities do
		rand = rand - self.propabilities[i]
		if rand <= 0 then
			index = i
			distribute = self.propabilities[i]/2
			self.propabilities[i] = self.propabilities[i]/2
			break
		end
	end

	local sum = 0
	for i = 1, #self.propabilities do
		if i ~= index then
			self.propabilities[i] = (self.propabilities[i] + distribute/(#self.propabilities - 1))
		end
		sum = sum + self.propabilities[i]
	end

	self.gameIndex = index
end

function gameRoulette:entered()
	self.timer:add(1, function() Venus.switch(Game.minigames[Game.minigameNames[self.gameIndex] ]) end)
end

function gameRoulette:update(dt)
	self.timer:update(dt)
end

function gameRoulette:draw()
	drawMinigameInfo(Game.minigames[Game.minigameNames[self.gameIndex] ])
end

return gameRoulette
