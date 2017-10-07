local LEFT = -Game.original.w
local RIGHT = Game.original.w
local SHOW = 0
local menu = {
	minigameNames = {
		"DiamondHeist",
		"CavePainting",
		"WalkTheDog",
		"FaceSlap"
	},
	structure = {
		[-2] = { -- freeplay game speed
			origPos = LEFT,
			pos = LEFT,
			speed = 1,
			draw = function(self, menu)
				love.graphics.setFont(Game.font14)
				love.graphics.setColor(255, 255, 255)
				love.graphics.print("LEFT = freeplay, RIGHT = fp game sel, UP/DOWN = fp game speed", 10, 10)
				love.graphics.print(self.speed, 10, 30)
			end
		},
		[-1] = { -- freeplay minigame
			origPos = LEFT,
			pos = LEFT,
			index = 1,
			draw = function(self, menu)
				love.graphics.setFont(Game.font14)
				love.graphics.setColor(255, 255, 255)
				love.graphics.print("LEFT = fp game spd, RIGHT = main, UP/DOWN = fp game sel", 10, 10)
				love.graphics.print(menu.minigameNames[self.index], 10, 30)
			end	
		},
		[0] = { -- main screen
			origPos = SHOW,
			pos = SHOW,
			draw = function(self, menu)
				love.graphics.setFont(Game.font14)
				love.graphics.setColor(255, 255, 255)
				love.graphics.print("LEFT = fp, RIGHT = end, DOWN = quit", 10, 10)
			end
		},
		{ -- endurance initial lives
			origPos = RIGHT,
			pos = RIGHT,
			lives = 3,
			draw = function(self, menu)
				love.graphics.setFont(Game.font14)
				love.graphics.setColor(255, 255, 255)
				love.graphics.print("LEFT = main, RIGHT = end speed, UP/DOWN = end lives", 10, 10)
				love.graphics.print(self.lives, 10, 30)
			end
		},
		{ -- endurance initial speed
			origPos = RIGHT,
			pos = RIGHT,
			speed = 1,
			draw = function(self, menu)
				love.graphics.setFont(Game.font14)
				love.graphics.setColor(255, 255, 255)
				love.graphics.print("LEFT = end lives, RIGHT = end start, UP/DOWN = end speed", 10, 10)
				love.graphics.print(self.speed, 10, 30)
			end
		}
	},
	screen = 0,
	timer = Timer.new()
}

local stateSwitch = function(m, s)
	Game.mode = m
	Venus.switch(menu.minigames[s])
end
local bindingsEvent = {
	LEFT = function(menu)
		if menu.screen - 1 < -2 then 
			Game.speed = menu.structure[-2].speed
			stateSwitch("FP", menu.minigameNames[menu.structure[-1].index]) 
		end
		menu.screen = math.max(-2, menu.screen - 1)
	end,
	RIGHT = function(menu)
		if menu.screen + 1 > 2 then 
			Game.speed = menu.structure[2].speed
			stateSwitch("END", menu.minigameNames[menu.structure[-1].index]) 
		end
		menu.screen = math.min(2, menu.screen + 1)
	end,
	UP = function(menu)
		if (menu.screen == 1) then
			local l = menu.structure[menu.screen].lives
			menu.structure[menu.screen].lives = math.min(10, l + 1)
		elseif (menu.screen == -1) then
			local i = menu.structure[menu.screen].index - 1
			if i < 1 then i = i + #menu.minigameNames end
			menu.structure[menu.screen].index = i
		end
	end,
	DOWN = function(menu)
		if (menu.screen == 0) then
			love.event.quit()
		elseif (menu.screen == 1) then
			local l = menu.structure[menu.screen].lives
			menu.structure[menu.screen].lives = math.max(1, l - 1)
		elseif (menu.screen == -1) then
			local i = menu.structure[menu.screen].index + 1
			if i > #menu.minigameNames then i = i - #menu.minigameNames end
			menu.structure[menu.screen].index = i
		end
	end
}

local bindingsUpdate = {
	UP = function(menu, dt)
		if (math.abs(menu.screen) == 2) then
			local s = menu.structure[menu.screen].speed
			menu.structure[menu.screen].speed = math.min(10, s + dt)
		end
	end,
	DOWN = function(menu, dt)
		if (math.abs(menu.screen) == 2) then
			local s = menu.structure[menu.screen].speed
			menu.structure[menu.screen].speed = math.max(0.5, s - dt)
		end
	end
}

function menu:init()
	self.minigames = {}
	for i, j in ipairs(self.minigameNames) do
		self.minigames[j] = require ("src.minigame"..j)
	end
end

function menu:entering()
	self.screen = 0
end

function menu:keypressed(key, scancode, isRepeat)
	if Game.paused then return end
	for i, j in pairs(Controls) do
		if j == key and bindingsEvent[i] then bindingsEvent[i](self) end
	end
	--[[
	if (key == Controls["ACTION"]) then
		local newGame = ""
		repeat 
			newGame = self.minigameNames[math.random(1, #self.minigameNames)] 
		until newGame ~= Game.lastGame
		Game.lastGame = newGame
		--Venus.switch(self.minigames[newGame])
		Venus.switch(self.minigames["CavePainting"])
	end]]--
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
	self.structure[self.screen]:draw(self)
	postDraw()
end

return menu
