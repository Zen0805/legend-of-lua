player = world:newBSGRectangleCollider(234, 184, 12, 12, 3)
player.x = 0
player.y = 0
player.dir = "down"
player.dirX = 1
player.dirY = 1
player.scaleX = 1
player.speed = 80
player.animSpeed = 0.14
player.walking = false
player.animTimer = 0
player.health = 4
player.stunTimer = 0
player.damagedTimer = 0
player.damagedBool = 1
player.damagedFlashTime = 0.05
player.invincible = 0 -- timer
player.bowRecoveryTime = 0.3
player.holdSprite = sprites.items.heart
player.attackDir = vector(1, 0)
player.comboCount = 0
player.aiming = false
player.arrowOffX = 0
player.arrowOffX = 0
player.bowVec = vector(1, 0)

-- 0 = Normal gameplay
-- 0.5 = Rolling
-- 1 = Sword swing
-- 2 = Use (bomb)
-- 3 = Bow (3: bow drawn, 3.1: recover)
-- 4 = Hookshot (4: armed, 4.1: launching, 4.2: moving)
-- 10 = Damage stun
-- 11 = Hold item
-- 12 = Transition
player.state = -1

player:setCollisionClass("Player")
player:setFixedRotation(true)

player.grid = anim8.newGrid(19, 21, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())

player.animations = {}
player.animations.downRight = anim8.newAnimation(player.grid('1-2', 1), player.animSpeed)
player.animations.downLeft = anim8.newAnimation(player.grid('1-2', 1), player.animSpeed)
player.animations.upRight = anim8.newAnimation(player.grid('1-2', 2), player.animSpeed)
player.animations.upLeft = anim8.newAnimation(player.grid('1-2', 2), player.animSpeed)
player.animations.swordDownRight = anim8.newAnimation(player.grid('1-2', 1), player.animSpeed)
player.animations.swordDownLeft = anim8.newAnimation(player.grid('1-2', 1), player.animSpeed)
player.animations.swordUpRight = anim8.newAnimation(player.grid('1-2', 2), player.animSpeed)
player.animations.swordUpLeft = anim8.newAnimation(player.grid('1-2', 2), player.animSpeed)
player.animations.useDownRight = anim8.newAnimation(player.grid(2, 1), player.animSpeed)
player.animations.useDownLeft = anim8.newAnimation(player.grid(2, 1), player.animSpeed)
player.animations.useUpRight = anim8.newAnimation(player.grid(2, 2), player.animSpeed)
player.animations.useUpLeft = anim8.newAnimation(player.grid(2, 2), player.animSpeed)
player.animations.hold = anim8.newAnimation(player.grid(1, 1), player.animSpeed)
player.animations.roll = anim8.newAnimation(player.grid('1-3', 4), 0.11)

player.anim = player.animations.upLeft

function player:update(dt)
    if player.state == -1 or gamestate == 0 then return end

    if player.stunTimer > 0 then
        player.stunTimer = player.stunTimer - dt
    end
    if player.stunTimer < 0 then
        player.stunTimer = 0
        if player.state == 10 then
            player.state = 0
            player:setLinearVelocity(0, 0)
        end
    end
    
    if player.damagedTimer > 0 then
        player.damagedTimer = player.damagedTimer - dt
        player.damagedFlashTime = player.damagedFlashTime - dt
        if player.damagedFlashTime < 0 then
            player.damagedFlashTime = 0.05
            player.damagedBool = player.damagedBool * -1
        end
    end
    if player.damagedTimer < 0 then
        player.damagedTimer = 0
        --world:collisionClear()
        world:collisionEventsClear()
    end

    if player.state == 0 then
    
        local dirX = 0
        local dirY = 0

        if pause.active then return end

        if love.keyboard.isDown("d") then
            dirX = 1
            player.dirX = 1
            --player.anim = player.animations.right
            player.dir = "right"
        end

        if love.keyboard.isDown("a") then
            dirX = -1
            player.dirX = -1
            --player.anim = player.animations.left
            player.dir = "left"
        end

        if love.keyboard.isDown("s") then
            dirY = 1
            player.dirY = 1
            --player.anim = player.animations.down
            player.dir = "down"
        end

        if love.keyboard.isDown("w") then
            dirY = -1
            player.dirY = -1
            --player.anim = player.animations.up
            player.dir = "up"
        end

        if dirY == 0 and dirX ~= 0 then
            player.dirY = 1
        end

        if player.aiming then
            player:setDirFromVector(player.bowVec)
        end

        if player.dirX == 1 then
            if player.dirY == 1 then
                player.anim = player.animations.downRight
            else
                player.anim = player.animations.upRight
            end
        else
            if player.dirY == 1 then
                player.anim = player.animations.downLeft
            else
                player.anim = player.animations.upLeft
            end
        end

        local vec = vector(dirX, dirY):normalized() * player.speed
        player:setLinearVelocity(vec.x, vec.y)

        if dirX == 0 and dirY == 0 then
            player.walking = false
            player.anim:gotoFrame(1)
        else
            player.walking = true
        end

        if player.walking then
            player.anim:update(dt)
        end

        player:checkDamage()
        player:checkTransition()

        if data.keys and data.keys > 0 then
            if player:enter('Wall') then
                local w = player:getEnterCollisionData('Wall')
                if w.collider.type == "lockedDoor" then
                    w.collider.dead = true
                end
            end
        end

        if player.animTimer > 0 then
            player.animTimer = player.animTimer - dt
            if player.animTimer < 0 then
                player.aiming = false
                player.animTimer = 0
            end
        end

    elseif player.state == 0.5 then

        player.anim:update(dt)

        player.animTimer = player.animTimer - dt
        if player.animTimer < 0 then
            player.state = 0
            player.animTimer = 0
        end

    elseif player.state >= 1 and player.state < 2 then

        player.animTimer = player.animTimer - dt

        if player.state == 1 then
            player:setLinearVelocity((player.attackDir*120):unpack())
        elseif player.state == 1.1 then
            player:setLinearVelocity(0, 0)
        end

        if player.animTimer < 0 then
            if player.state == 1 then
                player.state = 1.1
                player.anim:gotoFrame(2)
                -- animTimer for finished sword swing stance
                player.animTimer = 0.25
                effects:spawn("slice", player:getX(), player:getY()+1, player.attackDir)
                player:swordDamage()
            elseif player.state == 1.1 then
                player.state = 0
                player:resetAnimation(player.dir)
            end
        end

    elseif player.state == 2 or player.state == 3.1 then

        player:setLinearVelocity(0, 0)
        player.animTimer = player.animTimer - dt

        if player.animTimer < 0 then
            player.state = 0
            player:resetAnimation(player.dir)
        end
    
    elseif player.state == 3 then

        -- while drawing the bow back, always 'use' the item
        player:useItem(player.bowRecoveryTime)
    
    elseif player.state == 4 or player.state == 4.1 then

        -- while arming the hookshot, always 'use' the item
        -- player:useItem(1)

        if player.state == 4.1 and hookshot.state == -1 then
            if distanceBetween(player:getX(), player:getY(), hookshot.x, hookshot.y) < 12 then
                hookshot.state = 0
                player.state = 0
                player:resetAnimation(player.dir)
            end
        end

    elseif player.state == 4.2 then

        player:setX( player:getX() + (hookshot.dir.x * hookshot.speed * dt) )
        player:setY( player:getY() + (hookshot.dir.y * hookshot.speed * dt) )

    elseif player.state == 11 then -- got an item

        player.animTimer = player.animTimer - dt

        if player.animTimer < 0 then
            player.state = 0
            player:resetAnimation(player.dir)
        end
    
    elseif player.state == 11.1 then -- got an item (delay)

        player.animTimer = player.animTimer - dt

        if player.animTimer < 0 then
            player:gotItem(player.holdSprite)
        end

    elseif player.state == 12 then -- transition

        player:setLinearVelocity(0, 0)
        player:resetAnimation(player.dir)

    end

end

function player:draw()

    if player.stunTimer > 0 then
        love.graphics.setColor(223/255,106/255,106/255,1)
    elseif player.damagedTimer > 0 then
        local alpha = 0.8
        if player.damagedBool < 0 then alpha = 0.55 end
        love.graphics.setColor(1,1,1,alpha)
    else
        love.graphics.setColor(1,1,1,1)
    end

    -- Sword sprite
    local swSpr = sprites.sword
    local swX = 0
    local swY = 0
    local swLayer = -1
    local arrowSpr = sprites.items.arrow
    local bowSpr = sprites.items.bow1
    --local hookSpr = sprites.items.hookshotArmed
    if player.aiming and (player.animTimer > 0 or data.arrowCount < 1) then bowSpr = sprites.items.bow2 end
    --if player.state == 4.1 or player.state == 4.2 then hookSpr = sprites.items.hookshotHandle end

    local swordRot = 0
    if player.state == 1.1 then
        local tempVec = 0
        if player.comboCount % 2 == 0 then
            tempVec = player.attackDir:rotated(math.pi/2)
        else
            tempVec = player.attackDir:rotated(math.pi/-2)
        end
        swordRot = math.atan2(tempVec.y, tempVec.x)
        swX = tempVec.x * 12
        swY = tempVec.y * 12

        if swY > 0 then
            swLayer = 1
        end
    end

    local px = player:getX()
    local py = player:getY()+1

    local bowLayer = -1
    player.bowVec = toMouseVector(px, py)
    local bowRot = math.atan2(player.bowVec.y, player.bowVec.x)
    local bowOffX = player.bowVec.x*6
    local bowOffY = player.bowVec.y*6
    local hookOffX = player.bowVec.x*6
    local hookOffY = player.bowVec.y*6
    player.arrowOffX = player.bowVec.x*6
    player.arrowOffY = player.bowVec.y*6

    if bowRot > 0 then
        bowLayer = 1
    end

    love.graphics.draw(sprites.playerShadow, px, py+5, nil, nil, nil, sprites.playerShadow:getWidth()/2, sprites.playerShadow:getHeight()/2)

    -- Sword 'down' finished
    if player.dir == "down" and player.state == 1.1 then
        --love.graphics.draw(swSpr, px+12.5, py+7, 0, nil, nil, swSpr:getWidth()/2, swSpr:getHeight()/2)
    end

    -- Sword 'up' windup
    if player.dir == "up" and player.state == 1 then
        --love.graphics.draw(swSpr, px+9.5, py+6.5, 0, nil, nil, swSpr:getWidth()/2, swSpr:getHeight()/2)
    end

    -- Sword 'up' finished
    if player.dir == "up" and player.state == 1.1 then
        --love.graphics.draw(swSpr, px-14, py+7, math.pi, nil, nil, swSpr:getWidth()/2, swSpr:getHeight()/2)
    end

    -- Sword 'right' finished
    if player.dir == "right" and player.state == 1.1 then
        --love.graphics.draw(swSpr, px+1, py-9, math.pi/-2, nil, nil, swSpr:getWidth()/2, swSpr:getHeight()/2)
    end

    -- Sword 'left' finished
    if player.dir == "left" and player.state == 1.1 then
        --love.graphics.draw(swSpr, px-3, py-9, math.pi/-2, nil, nil, swSpr:getWidth()/2, swSpr:getHeight()/2)
    end

    -- Bow 'up'
    if player.dir == "up" and (player.state == 3 or player.state == 3.1) then
        --love.graphics.draw(bowSpr, px-2, py-1, math.pi/-2, nil, nil, bowSpr:getWidth()/2, bowSpr:getHeight()/2)
        if player.state == 3 and data.arrowCount > 0 then love.graphics.draw(arrowSpr, px-1, py-3, math.pi/-2, nil, nil, arrowSpr:getWidth()/2, arrowSpr:getHeight()/2) end
    end

    if player.state == 1.1 and swLayer == -1 then
        love.graphics.draw(swSpr, px+swX, py+swY, swordRot, nil, nil, swSpr:getWidth()/2, swSpr:getHeight()/2)
    end

    if player.aiming and bowLayer == -1 then
        love.graphics.draw(bowSpr, px + bowOffX, py + bowOffY, bowRot, 1.15, nil, bowSpr:getWidth()/2, bowSpr:getHeight()/2)
        if data.arrowCount > 0 and player.animTimer <= 0 then love.graphics.draw(arrowSpr, px + bowOffX, py + bowOffY, bowRot, 0.85, nil, arrowSpr:getWidth()/2, arrowSpr:getHeight()/2) end
        --love.graphics.draw(hookSpr, px + hookOffX, py + hookOffY, bowRot, 1.15, nil, hookSpr:getWidth()/2, hookSpr:getHeight()/2)
    end

    if player.stunTimer > 0 then love.graphics.setShader(shaders.whiteout) end

    player.anim:draw(sprites.playerSheet, player:getX(), player:getY()-2, nil, player.dirX, 1, 9.5, 10.5)

    love.graphics.setShader()

    if player.state == 1.1 and swLayer == 1 then
        love.graphics.draw(swSpr, px+swX, py+swY, swordRot, nil, nil, swSpr:getWidth()/2, swSpr:getHeight()/2)
    end

    if player.aiming and bowLayer == 1 then
        love.graphics.draw(bowSpr, px + bowOffX, py + bowOffY, bowRot, 1.15, nil, bowSpr:getWidth()/2, bowSpr:getHeight()/2)
        if data.arrowCount > 0 and player.animTimer <= 0 then love.graphics.draw(arrowSpr, px + bowOffX, py + bowOffY, bowRot, 0.85, nil, arrowSpr:getWidth()/2, arrowSpr:getHeight()/2) end
        --love.graphics.draw(hookSpr, px + hookOffX, py + hookOffY, bowRot, 1.15, nil, hookSpr:getWidth()/2, hookSpr:getHeight()/2)
    end

    -- Sword 'down' windup
    if player.dir == "down" and player.state == 1 then
        --love.graphics.draw(swSpr, px-7.5, py+6, math.pi, nil, nil, swSpr:getWidth()/2, swSpr:getHeight()/2)
    end

    -- Sword 'right' windup
    if player.dir == "right" and player.state == 1 then
        --love.graphics.draw(swSpr, px+1, py+13.5, math.pi/2, nil, nil, swSpr:getWidth()/2, swSpr:getHeight()/2)
    end

    -- Sword 'left' windup
    if player.dir == "left" and player.state == 1 then
        --love.graphics.draw(swSpr, px-3, py+13.5, math.pi/2, nil, nil, swSpr:getWidth()/2, swSpr:getHeight()/2)
    end

    -- Bow 'right'
    if player.dir == "right" and (player.state == 3 or player.state == 3.1) then
        love.graphics.draw(bowSpr, px+5.5, py+6.5, nil, nil, nil, bowSpr:getWidth()/2, bowSpr:getHeight()/2)
        if player.state == 3 and data.arrowCount > 0 then love.graphics.draw(arrowSpr, px+2.5, py+6.5, nil, nil, nil, arrowSpr:getWidth()/2, arrowSpr:getHeight()/2) end
    end

    -- Bow 'left'
    if player.dir == "left" and (player.state == 3 or player.state == 3.1) then
        love.graphics.draw(bowSpr, px-7.5, py+6.5, nil, -1, 1, bowSpr:getWidth()/2, bowSpr:getHeight()/2)
        if player.state == 3 and data.arrowCount > 0 then love.graphics.draw(arrowSpr, px-4.5, py+6.5, nil, -1, 1, arrowSpr:getWidth()/2, arrowSpr:getHeight()/2) end
    end

    -- Bow 'down'
    if player.dir == "down" and (player.state == 3 or player.state == 3.1) then
        love.graphics.draw(bowSpr, px, py+10.5, math.pi/2, nil, nil, bowSpr:getWidth()/2, bowSpr:getHeight()/2)
        if player.state == 3 and data.arrowCount > 0 then love.graphics.draw(arrowSpr, px, py+11, math.pi/2, nil, nil, arrowSpr:getWidth()/2, arrowSpr:getHeight()/2) end
    end

    if player.state == 11 then
        love.graphics.draw(player.holdSprite, player:getX(), player:getY()-18, nil, nil, nil, player.holdSprite:getWidth()/2, player.holdSprite:getHeight()/2)
    end

end

function player:checkDamage()
    if player.damagedTimer > 0 then return end

    local hitEnemies = world:queryCircleArea(player:getX(), player:getY(), 5, {'Enemy'})
    if #hitEnemies > 0 then
        local e = hitEnemies[1]
        player:hurt(0.5, e:getX(), e:getY())
    end

    if player:enter('Projectile') then
        local e = player:getEnterCollisionData('Projectile')
        e.collider.dead = true
        player:hurt(0.5, e.collider:getX(), e.collider:getY())
    end
end

function player:checkTransition()
    if player:enter('Transition') then
        local t = player:getEnterCollisionData('Transition')
        if t.collider.type == "instant" then
            triggerTransition(t.collider.id, t.collider.destX, t.collider.destY)
        else
            curtain:call(t.collider.id, t.collider.destX, t.collider.destY)
        end
        --triggerTransition(t.collider.id, t.collider.destX, t.collider.destY)
    end
end

function player:hurt(damage, srcX, srcY)
    if player.damagedTimer > 0 then return end
    player.damagedTimer = 2
    shake:start(0.1, 2, 0.03)
    particleEvent("playerHit", player:getX(), player:getY())
    player.health = player.health - damage
    player.state = 10 -- damaged
    player:setLinearVelocity((getFromToVector(srcX, srcY, player:getX(), player:getY()) * 300):unpack())
    player.stunTimer = 0.075
end

function player:swingSword()

    -- The player can only swing their sword if the player.state is 0 (regular gameplay)
    if player.state ~= 0 then return end

    player.comboCount = player.comboCount + 1

    player.attackDir = toMouseVector(player:getX(), player:getY())
    player:setDirFromVector(player.attackDir)

    player.state = 1

    if player.dirX == 1 then
        if player.dirY == 1 then
            player.anim = player.animations.swordDownRight
        else
            player.anim = player.animations.swordUpRight
        end
    else
        if player.dirY == 1 then
            player.anim = player.animations.swordDownLeft
        else
            player.anim = player.animations.swordUpLeft
        end
    end

    --player.anim:gotoFrame(1)
    -- animTimer for sword wind-up
    player.animTimer = 0.1

end

function player:swordDamage()
    -- Query for enemies to hit with the sword
    --local hitEnemies = world:queryCircleArea(player:getX(), player:getY(), 24, {'Enemy'})

    local px, py = player:getPosition()
    local dir = player.attackDir:normalized()
    local rightDir = dir:rotated(math.pi/2)
    local leftDir = dir:rotated(math.pi/-2)
    local polygon = {
        px + dir.x*20,
        py + dir.y*20,
        px + dir:rotated(math.pi/8).x*20,
        py + dir:rotated(math.pi/8).y*20,
        px + dir:rotated(math.pi/4).x*20,
        py + dir:rotated(math.pi/4).y*20,
        px + dir:rotated(3*math.pi/8).x*20,
        py + dir:rotated(3*math.pi/8).y*20,
        px + rightDir.x*22,
        py + rightDir.y*22,
        px + leftDir.x*22,
        py + leftDir.y*22,
        px + dir:rotated(3*math.pi/-8).x*20,
        py + dir:rotated(3*math.pi/-8).y*20,
        px + dir:rotated(math.pi/-4).x*20,
        py + dir:rotated(math.pi/-4).y*20,
        px + dir:rotated(math.pi/-8).x*20,
        py + dir:rotated(math.pi/-8).y*20,
    }

    local hitEnemies = world:queryPolygonArea(polygon, {'Enemy'})

    if #hitEnemies > 0 then shake:start(0.1, 1, 0.02) end
    for _,e in ipairs(hitEnemies) do
        local knockbackDir = getPlayerToSelfVector(e:getX(), e:getY())
        e.parent:hit(1, knockbackDir, 0.1)
    end
end

function player:useItem(duration)

    if player.state ~= 3 and player.state ~= 3.1 and player.state ~= 4 and player.state ~= 4.1 then
        player.state = 2
    end

    --[[if player.dir == "down" then
        player.anim = player.animations.useDown
    elseif player.dir == "up" then
        player.anim = player.animations.useUp
    elseif player.dir == "right" then
        player.anim = player.animations.useRight
    elseif player.dir == "left" then
        player.anim = player.animations.useLeft
    end]]

    if player.dirX == 1 then
        if player.dirY == 1 then
            player.anim = player.animations.useDownRight
        else
            player.anim = player.animations.useUpRight
        end
    else
        if player.dirY == 1 then
            player.anim = player.animations.useDownLeft
        else
            player.anim = player.animations.useUpLeft
        end
    end

    player.anim:gotoFrame(1)
    player.animTimer = duration

end

function player:useBomb()
    player:useItem(0.2)
    spawnBomb()
end

function player:useBoomerang()
    player:useItem(0.2)
    boomerang:throw(player.dir)
end

function player:useBow()
    if player.state == 0 and data.arrowCount > 0 then
        if player.aiming and player.animTimer <= 0 then
            spawnArrow(player:getX() + player.arrowOffX, player:getY()+1+player.arrowOffY)
            player.animTimer = player.bowRecoveryTime
            --player.aiming = false
        else
            player.aiming = true
            player.animTimer = 0
        end
    elseif player.state == 3 then
        player.state = 3.1
    end
end

function player:useHookshot()
    if player.state == 0 then
        player.state = 4.1
        player.attackDir = toMouseVector(player:getX() + player.arrowOffX, player:getY()+1+player.arrowOffY)
        player:useSet()
        hookshot:shoot(player.attackDir)
        player:setLinearVelocity(0, 0)
        player:setDirFromVector(player.attackDir)
    end
end

function player:resetAnimation(direction)
    --player.anim = player.animations[direction]
    if player.dirX == 1 then
        if player.dirY == 1 then
            player.anim = player.animations.downRight
        else
            player.anim = player.animations.upRight
        end
    else
        if player.dirY == 1 then
            player.anim = player.animations.downLeft
        else
            player.anim = player.animations.upLeft
        end
    end
    player.anim:gotoFrame(1)
end

function player:gotItem(spr, delay)
    if delay then
        player.state = 11.1
        player.animTimer = 0.5
        player.holdSprite = spr
        return
    end
    player.holdSprite = spr
    player.state = 11
    player.animTimer = 1
    player.dir = "down"
    player.anim = player.animations.hold
    player:setLinearVelocity(0, 0)
end

function player:interact()
    -- query for interactable walls
    local interactables = world:queryCircleArea(player:getX(), player:getY(), 12, {'Wall'})
    for _,i in ipairs(interactables) do
        if i.parent then
            i.parent:interact()
        end
    end
end

function player:roll()
    player.state = 0.5
    player.animTimer = 0.3
    player.anim = player.animations.roll
    player.anim:gotoFrame(1)

    local dirX = 0
    local dirY = 0

    if love.keyboard.isDown("d") then
        dirX = 1
    end

    if love.keyboard.isDown("a") then
        dirX = -1
    end

    if love.keyboard.isDown("s") then
        dirY = 1
    end

    if love.keyboard.isDown("w") then
        dirY = -1
    end

    local dirVec = vector(dirX, dirY):normalized()*120
    player:setLinearVelocity(dirVec.x, dirVec.y)
end

function player:setDirFromVector(vec)
    local rad = math.atan2(vec.y, vec.x)
    if rad >= 0 and rad < math.pi/2 then
        player.dirX = 1
        player.dirY = 1
    elseif rad >= math.pi/2 and rad < math.pi then
        player.dirX = -1
        player.dirY = 1
    elseif rad < 0 and rad > math.pi/-2 then
        player.dirX = 1
        player.dirY = -1
    else
        player.dirX = -1
        player.dirY = -1
    end
end

function player:useSet()
    local newDir = toMouseVector(player:getX(), player:getY())
    player:setDirFromVector(newDir)

    if player.dirX == 1 then
        if player.dirY == 1 then
            player.anim = player.animations.useDownRight
        else
            player.anim = player.animations.useUpRight
        end
    else
        if player.dirY == 1 then
            player.anim = player.animations.useDownLeft
        else
            player.anim = player.animations.useUpLeft
        end
    end
end