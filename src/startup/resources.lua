-- All sprites (images)
sprites = {}
sprites.background = love.graphics.newImage('sprites/background.png')
sprites.linkTest = love.graphics.newImage('sprites/linkTest.png')
sprites.linkWalkSheet = love.graphics.newImage('sprites/real-link.png')
sprites.hello = love.graphics.newImage('sprites/hello.png')
sprites.heart_filled = love.graphics.newImage('sprites/heart_filled.png')
sprites.heart_empty = love.graphics.newImage('sprites/heart_empty.png')
sprites.heart_half = love.graphics.newImage('sprites/heart_half.png')

sprites.weapons = {}
sprites.weapons.wooden_sword = love.graphics.newImage('sprites/items/weapons/wooden-sword.png')
sprites.weapons.white_sword = love.graphics.newImage('sprites/items/weapons/white-sword.png')
sprites.weapons.magic_rod = love.graphics.newImage('sprites/items/weapons/magic-rod.png')

-- All fonts
fonts = {}
fonts.title = love.graphics.newFont("fonts/russoone/RussoOne-Regular.ttf", 42)
fonts.debug = love.graphics.newFont("fonts/vt323/VT323-Regular.ttf", 90)
fonts.origin = love.graphics.newFont("fonts/vt323/VT323-Regular.ttf", 78)