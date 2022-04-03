function loadMap(mapName, destX, destY)

    loadedMap = mapName
    gameMap = sti("maps/" .. mapName .. ".lua")

    if gameMap.layers["Walls"] then
        for i, obj in pairs(gameMap.layers["Walls"].objects) do
            spawnWall(obj.x, obj.y, obj.width, obj.height, obj.name)
        end
    end

    if gameMap.layers["Enemies"] then
        for i, obj in pairs(gameMap.layers["Enemies"].objects) do
            local args = {}
            if obj.properties.form then args.form = obj.properties.form end
            spawnEnemy(obj.x, obj.y, obj.name, args)
        end
    end

    if gameMap.layers["Loot"] then
        for i, obj in pairs(gameMap.layers["Loot"].objects) do
            spawnLoot(obj.x, obj.y, obj.type)
        end
    end

    if gameMap.layers["NPC"] then
        for i, obj in pairs(gameMap.layers["NPC"].objects) do
            spawnNPC(obj.name, obj.x, obj.y)
        end
    end

end