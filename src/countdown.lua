local countdown = {
	index = 1,
	items = { "3", "2", "1", "GO!" },
	timerMax = 0.5,
	timerCur = 0.5,
	count = false
}

function countdown:reset()
	self.index = 1
	self.timerCur = self.timerMax
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
	love.graphics.setFont(Game.font70)
	local text = self.items[self.index]
	local fH = Game.font70:getHeight()
	local fW = Game.font70:getWidth(text)
	love.graphics.setColor(50, 50, 50)
	love.graphics.rectangle("fill", 0, Game.original.h/2 - fH/2, Game.original.w, fH)
	love.graphics.setColor(200, 200, 200)
	love.graphics.print(text, math.floor(Game.original.w/2 - fW/2), math.floor(Game.original.h/2 - fH/2))
	love.graphics.setFont(Game.font14)
end

return countdown
