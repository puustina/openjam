local countdown = {
	index = 1,
	items = { "3", "2", "1", "GO" },
	timerMax = 0.25,
	timerCur = 0.25,
	count = false
}

function countdown:reset()
	self.index = 1
	self.timerCur = 0.45
end

function countdown:start()
	self.count = true
end

function countdown:over()
	return not self.count
end

function countdown:update(dt)
	self.timerCur = self.timerCur - dt
	if (self.timerCur < 0) then
		self.timerCur = self.timerMax
		self.index = self.index + 1
		if (self.index > #self.items) then
			self.count = false
		end
	end
end

function countdown:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(self.items[self.index], 100, 100)
end

return countdown
