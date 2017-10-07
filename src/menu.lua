local gameRoulette = require "src.gameRoulette"

local LEFT = -Game.original.w
local RIGHT = Game.original.w
local UP = -Game.original.h
local DOWN = Game.original.h
local SHOW = 0
local DELAY = 0.15
local lvl2MenuBG = function()
	love.graphics.setColor(50, 50, 50, 200)
	love.graphics.rectangle("fill", 0, 0, Game.original.w, Game.original.h)
	love.graphics.setColor(100, 100, 100)
	love.graphics.rectangle("fill", 20, 20, Game.original.w - 40, Game.original.h - 40)
end
local lvl1MenuBG = function()
	love.graphics.setColor(50, 50, 50, 200)
	love.graphics.rectangle("fill", 0, 0, Game.original.w, Game.original.h)
	love.graphics.setColor(150, 150, 150)
	love.graphics.rectangle("fill", 10, 10, Game.original.w - 20, Game.original.h - 20)
end
local drawInstructions = function(inst, menuLVL)
	local margin = menuLVL and (menuLVL + 1) * 10 or 0
	for i, j in pairs(inst) do
		local pos = {
			UP = {
				Game.original.w/2 - Game.font14:getWidth(j)/2,
				margin
			},
			DOWN = {
				Game.original.w/2 - Game.font14:getWidth(j)/2,
				Game.original.h - margin - Game.font14:getHeight()
			},
			LEFT = {
				margin,
				Game.original.h/2 - Game.font14:getHeight()/2
			},
			RIGHT = {
				Game.original.w - margin - Game.font14:getWidth(j),
				Game.original.h/2 - Game.font14:getHeight()/2
			}
		}
		love.graphics.setColor(255, 255, 255)
		love.graphics.setFont(Game.font14)
		love.graphics.print(j, math.floor(pos[i][1]), math.floor(pos[i][2]))
	end
end
local menu = {
	structure = {
		[-3] = { -- secret
			origPos = UP,
			pos = UP,
			draw = function(self, menu)
				lvl1MenuBG()
				love.graphics.setFont(Game.font14)
				love.graphics.setColor(255, 255, 255)
				love.graphics.print("secret!", 10, 10)
				drawInstructions({ DOWN = "Back" }, 1)
			end
		},
		[-2] = { -- freeplay game speed
			origPos = LEFT,
			pos = LEFT,
			speed = 1,
			draw = function(self, menu)
				lvl2MenuBG()
				drawInstructions({ LEFT = "Start", RIGHT = "Back", UP = "Speed UP", DOWN = "Speed DOWN" }, 2)
				love.graphics.setFont(Game.font14)
				love.graphics.setColor(255, 255, 255)
				love.graphics.print(self.speed, 10, 30)
			end
		},
		[-1] = { -- freeplay minigame
			origPos = LEFT,
			pos = LEFT,
			index = 1,
			draw = function(self, menu)
				lvl1MenuBG()
				drawInstructions({ LEFT = "Next", RIGHT = "Back", UP = "Select game", DOWN = "Select game" }, 1)
				drawMinigameInfo(Game.minigames[Game.minigameNames[self.index] ])
			end	
		},
		[0] = { -- main screen
			origPos = SHOW,
			pos = SHOW,
			draw = function(self, menu)
				drawInstructions({ LEFT = "Freeplay", RIGHT = "Endurance", DOWN = "Quit" }, 0)
			end
		},
		{ -- endurance initial lives
			origPos = RIGHT,
			pos = RIGHT,
			lives = 3,
			draw = function(self, menu)
				lvl1MenuBG()
				drawInstructions({ LEFT = "Back", RIGHT = "Next", UP = "Lives UP", DOWN = "Lives DOWN" }, 1)
				love.graphics.setFont(Game.font14)
				love.graphics.setColor(255, 255, 255)
				love.graphics.print(self.lives, 10, 30)
			end
		},
		{ -- endurance initial speed
			origPos = RIGHT,
			pos = RIGHT,
			speed = 1,
			draw = function(self, menu)
				lvl2MenuBG()
				drawInstructions({ LEFT = "Back", RIGHT = "Start", UP = "Speed UP", DOWN = "Speed DOWN" }, 2)
				love.graphics.setFont(Game.font14)
				love.graphics.setColor(255, 255, 255)
				love.graphics.print(self.speed, 10, 30)
			end
		},
		{ -- quit confirm
			origPos = DOWN,
			pos = DOWN,
			draw = function(self, menu)
				lvl1MenuBG()
				drawInstructions({ DOWN = "Quit", UP = "Back" }, 1)
			end
		}
	},
	screen = 0,
	timer = Timer.new()
}

local bindingsEvent = {
	LEFT = function(menu)
		if math.abs(menu.screen) == 3 then return end
		if menu.screen - 1 < -2 then 
			Game.mode = "FP"
			Game.speed = menu.structure[-2].speed
			Venus.switch(Game.minigames[Game.minigameNames[menu.structure[-1].index] ])
		else
			if (menu.screen > 0) then
				menu.timer:tween(DELAY, menu.structure[menu.screen], { pos = menu.structure[menu.screen].origPos }, "in-out-quad")
			end
			menu.timer:tween(DELAY, menu.structure[menu.screen - 1], { pos = SHOW }, "in-out-quad")
		end
		menu.screen = math.max(-2, menu.screen - 1)
	end,
	RIGHT = function(menu)
		if math.abs(menu.screen) == 3 then return end
		if menu.screen + 1 > 2 then 
			Game.mode = "END"
			Game.speed = menu.structure[2].speed
			Game.maxLives = menu.structure[1].lives
			Game.curLives = Game.maxLives
			Venus.switch(gameRoulette)
		else
			if (menu.screen < 0) then 
				menu.timer:tween(DELAY, menu.structure[menu.screen], { pos = menu.structure[menu.screen].origPos }, "in-out-quad")
			end
			menu.timer:tween(DELAY, menu.structure[menu.screen + 1], { pos = SHOW }, "in-out-quad")
		end
		menu.screen = math.min(2, menu.screen + 1)
	end,
	UP = function(menu)
		if (menu.screen == 0 or menu.screen == 3) then
			menu.timer:tween(DELAY, menu.structure[menu.screen], { pos = menu.structure[menu.screen].origPos }, "in-out-quad")
			menu.screen = menu.screen - 3
			menu.timer:tween(DELAY, menu.structure[menu.screen], { pos = SHOW }, "in-out-quad")
		elseif (menu.screen == 1) then
			local l = menu.structure[menu.screen].lives
			menu.structure[menu.screen].lives = l + 1
		elseif (menu.screen == -1) then
			local i = menu.structure[menu.screen].index - 1
			if i < 1 then i = i + #Game.minigameNames end
			menu.structure[menu.screen].index = i
		end
	end,
	DOWN = function(menu)
		if (menu.screen == 0 or menu.screen == -3) then
			menu.timer:tween(DELAY, menu.structure[menu.screen], { pos = menu.structure[menu.screen].origPos }, "in-out-quad")
			menu.screen = menu.screen + 3
			menu.timer:tween(DELAY, menu.structure[menu.screen], { pos = SHOW }, "in-out-quad")
		elseif (menu.screen == 3) then
			love.event.quit()
		elseif (menu.screen == 1) then
			local l = menu.structure[menu.screen].lives
			menu.structure[menu.screen].lives = math.max(1, l - 1)
		elseif (menu.screen == -1) then
			local i = menu.structure[menu.screen].index + 1
			if i > #Game.minigameNames then i = i - #Game.minigameNames end
			menu.structure[menu.screen].index = i
		end
	end
}

local bindingsUpdate = {
	UP = function(menu, dt)
		if (math.abs(menu.screen) == 2) then
			local s = menu.structure[menu.screen].speed
			menu.structure[menu.screen].speed = math.min(Game.maxSpeed, s + dt)
		end
	end,
	DOWN = function(menu, dt)
		if (math.abs(menu.screen) == 2) then
			local s = menu.structure[menu.screen].speed
			menu.structure[menu.screen].speed = math.max(Game.minSpeed, s - dt)
		end
	end
}

function menu:init()
end

function menu:entering()
	self.screen = 0
	for i = -3, 3 do
		self.structure[i].pos = self.structure[i].origPos
	end
end

function menu:keypressed(key, scancode, isRepeat)
	if Game.paused then return end
	for i, j in pairs(Controls) do
		if j == key and bindingsEvent[i] then bindingsEvent[i](self) end
	end
end

function menu:update(dt)
	if Game.paused then return end
	self.timer:update(dt)
	for i, j in pairs(bindingsUpdate) do
		if love.keyboard.isDown(Controls[i]) then j(self, dt) end
	end
end

function menu:draw()
	love.graphics.setBackgroundColor(0, 0, 0)
	preDraw()
	local drawScreen = function(scr, trY)
		if (math.abs(scr.pos - scr.origPos) > 0.01) or (scr.origPos == SHOW) then
			love.graphics.push()
			if not trY then
				love.graphics.translate(scr.pos, 0)
			else
				love.graphics.translate(0, scr.pos)
			end
			scr:draw(self)
			love.graphics.pop()
		end
	end
	for i = 0, 2, 1 do
		drawScreen(self.structure[i])
	end
	for i = -1, -2, -1 do
		drawScreen(self.structure[i])
	end
	for i = -3, 3, 6 do
		drawScreen(self.structure[i], true)
	end
	postDraw()
end

return menu
