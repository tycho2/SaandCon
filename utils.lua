function find_user(uid)
    for n,e in pairs(g2.search("user")) do
        if e.user_uid == uid then return e end
    end
end
function radiusToProd(radius)
    local prod = (radius*17 - 168)*5/12
    return prod
end

function prodToRadius(p)
    return (p * 12 / 5 + 168) / 17
end

function searchString(string, pattern)
    local words = {}
    for word in string:gmatch(pattern) do
        table.insert(words, word)
    end
    return words
end

function getEventUid(e)
    if e.type == "net:message" then
        return e.uid
    else
        -- any unintended consequences?
        return g2.uid
    end
end

function isNetMessageOrButton(e)
    return e.type == "net:message" or e.type == "onclick"
end

function sendMessageGroup(group, message)
    --group is a list of uids
    for r=0, #group do
        net_send(group[r], "message", message)
    end
end

function string.fromhex(str)
    return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end

function checkNoSpecialChars(str)
    --Allow - . _ ~ but not other non-alphanumeric chars
    local safe = true
    local safeChars = {"-", "~", ".","_"}
    local nonNumeric = string.find(str, "%W")
    if nonNumeric ~= nil then
        for r=1, #str do
            local piece = string.sub(str, r,r)
            if string.find(piece, "%W") ~= nil and has_value(safeChars, piece) == false or string.find(piece, " ") ~= nil then
                safe = false
            end
        end
    end
    return safe
end

function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

--NO NEED FOR THIS I JUST WANTED TO MAKE MY OWN
-- function hexToDecimalAphid(str)
--     local converted = 0
--     local r = 0
--     local length = string.len(str)
--     for r=0, length-1 do
--         local exponent = (length-1) - r
--         local multiple = 16 ^ exponent
--         local actual = multiple * stringToNumber(string.sub(str, r+1, r+1))
--         converted = converted + actual
--     end
--     return converted
-- end

function toNumberExtended(str)
    local finishedVal = 0
    for i = 1, string.len(str) do
        local byt = str.byte(str, i)
        finishedVal = finishedVal * 7
        finishedVal = finishedVal + byt
    end
    return finishedVal
end

function stringToNumber(str)
    local hexVal = {['0'] = 0, ['1'] = 1, ['2'] = 2, ['3'] = 3, ['4'] = 4, ['5'] = 5, ['6'] = 6, ['7'] = 7, 
    ['8'] = 8, ['9'] = 9, ['a'] = 10, ['b'] = 11, ['c'] = 12, ['d'] = 13, ['e'] = 14, ['f'] = 15}
    return hexVal[string.lower(str)]
end

function getDistance(x1, y1, x2, y2)
    local distx = x1 - x2
    local disty = y1 - y2

    local a = distx^2
    local b = disty^2

    local c = a + b
    local dist = math.sqrt(c)
    return dist
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

function count_ships()
    local r = {}
    local items = g2.search("planet -neutral")
    for _i, o in ipairs(items) do
        local team = o:owner():team()
        r[team] = (r[team] or 0) + o.ships_value
    end

    local fleets = g2.search("fleet")
    for _i, o in ipairs(fleets) do
        local team = o:owner():team()
        r[team] = (r[team] or 0) + o.fleet_ships
    end
    return r
end

function count_production()
    local r = {}
    local items = g2.search("planet -neutral")
    for _i,o in ipairs(items) do
        if g2.item(o:owner().n).title_value ~= "neutral" then 
            local team = o:owner():team()
            r[team] = (r[team] or 0) + o.ships_production
        end
    end
    return r
end

function most_ships()
    local r = count_ships()
    local best_o = nil
    local best_v = 0
    for o,v in pairs(r) do
        if v > best_v then
            best_v = v
            best_o = o
        end
    end
    return best_o
end

function most_ships_tie_check()
    local r = count_ships()
    local best_o = nil
    local best_v = 0
    local tie = false
    for o,v in pairs(r) do
        if v > best_v then
            best_v = v
            best_o = o
            tie = false
        elseif v == best_v then
            tie = true
        elseif v < best_v then
            tie = false
        end
    end
    if tie then
        return "tie"
    else
        return best_o
    end
end

function most_production()
    local r = count_production()
    local best_o = nil
    local best_v = 0
    for o,v in pairs(r) do
        if v > best_v then
            best_v = v
            best_o = o
        end
    end
    return best_o
end

function most_production_tie_check()
    local r = count_production()
    local best_o = nil
    local best_v = 0
    local tie = false
    for o,v in pairs(r) do
        if v > best_v then
            best_v = v
            best_o = o
            tie = false
        elseif v == best_v then
            tie = true
        elseif v < best_v then
            tie = false
        end
    end
    if tie then
        return "tie"
    else
        return best_o
    end
end

function find_enemy(uid)
    for n, e in pairs(g2.search("user")) do
        -- user_neutral is not strictly necessary
        if e.user_uid ~= uid and not e.user_neutral and e.title_value ~= "neutral" then
            return e
        end
    end
end

function getUserItems(uid)
    print("Uid in: " .. uid)
    local planets = {}
    local items = g2.search("planet -neutral")
    for _i,o in ipairs(items) do
        print(g2.item(o:owner().n).user_uid)
        local id = g2.item(o:owner().n).user_uid
        if id == uid then
            print("Found")
            table.insert(planets, o)
        end
    end
    print(#planets)
    return planets
end

function hostUidFix(e)
    if e.uid == nil then 
       return g2.uid
    else
       return e.uid
    end
end

function botUidFix(e)
    if(tonumber(e.uid) < 0) then
        return GAME.clients[tonumber(e.uid)].botName
    else
        return e.uid
    end
end

function rollRandColor()
    local r = 0
    local g = 0
    local b = 0
    local brightPick = math.random(1,3) --Pick one of 3 to guarantee bright enough
    if brightPick == 1 then
        r = 170
        g = math.random(0, 255)
        b = math.random(0, 255)
    elseif brightPick == 2 then
        r = math.random(0, 255)
        g = 170
        b = math.random(0, 255)
    else
        r = math.random(0, 255)
        g = math.random(0, 255)
        b = 170
    end
    r = string.format("%x", r)
    g = string.format("%x", g)
    b = string.format("%x", b)

    if(tonumber(r, 16) < 16) then 
        r = "0"..r
    end
    if(tonumber(g, 16) < 16) then 
        g = "0"..g
    end
    if(tonumber(b, 16) < 16) then 
        b = "0"..b
    end
    return "0x"..r..g..b
end

function handlePlayerMatchUpdate(uid, isWin, mode)
    if uid == nil then return end
    if(tonumber(uid) < 0) then
        uid = GAME.clients[tonumber(uid)].botName
        handleBotMatchUpdate(uid, isWin, mode)
    else
        if(string.lower(mode) ~= 'float') then
            if(isWin) then
                GAME.clients[uid].stats['total'].wins = GAME.clients[uid].stats['total'].wins + 1
                GAME.clients[uid].stats[string.lower(mode)].wins = GAME.clients[uid].stats[string.lower(mode)].wins + 1
            else
                GAME.clients[uid].stats['total'].losses = GAME.clients[uid].stats['total'].losses + 1
                GAME.clients[uid].stats[string.lower(mode)].losses = GAME.clients[uid].stats[string.lower(mode)].losses + 1
            end
        end
        GAME.clients[uid].stats['total'].matches = GAME.clients[uid].stats['total'].matches + 1
        GAME.clients[uid].stats[string.lower(mode)].matches = GAME.clients[uid].stats[string.lower(mode)].matches + 1
        editPlayerData("stats", uid, GAME.clients[uid].stats)
    end
end

function handleBotMatchUpdate(uid, isWin, mode)
    local botData = playerData.getUserData(uid)
    if(string.lower(mode) ~= 'float') then
        if(isWin) then
            botData.stats['total'].wins = botData.stats['total'].wins + 1
            botData.stats[string.lower(mode)].wins = botData.stats[string.lower(mode)].wins + 1
        else
            botData.stats['total'].losses = botData.stats['total'].losses + 1
            botData.stats[string.lower(mode)].losses = botData.stats[string.lower(mode)].losses + 1
        end
    end
    botData.stats['total'].matches = botData.stats['total'].matches + 1
    botData.stats[string.lower(mode)].matches = botData.stats[string.lower(mode)].matches + 1
    editPlayerData("stats", uid, botData.stats)
end

function getLvlXpCap(level)
    return math.pow((level)*5, 2) * 2
end

function handlePrestige(uid)
    local player = playerData.getUserData(uid)
    player.level = 0
    player.xp = 0
    player.prestige = player.prestige + 1
    net_send("", "message", player.displayName.." prestiged to level "..player.prestige.." and was born again!")
    editPlayerData("level", uid, player.level)
    editPlayerData("xp", uid, player.xp)
    editPlayerData("prestige", uid, player.prestige)
end

function handlePlayerXpUpdate(uid, isWin)
    --formula ((lvl*5) ^ 2) * 2
    local isbot = false
    if(tonumber(uid) < 0) then
        uid = GAME.clients[tonumber(uid)].botName
        isbot = true
    end
    local player = playerData.getUserData(uid)
    local levelXpCap = getLvlXpCap(player.level+1)
    local incomingXp = GAME.galcon.global.matchXp
    local maxLevel = GAME.galcon.global.CONFIGS.maxPlayerLevel
    if(not isWin) then
        incomingXp = math.floor(incomingXp * .3)
    end
    if player.level < maxLevel then
        if levelXpCap - player.xp < incomingXp then
            incomingXp = incomingXp - (levelXpCap - player.xp)
            player.level = player.level + 1
            player.xp = 0
            net_send("", "message", player.displayName.." reached level "..player.level.."!")
        end
        if player.level < maxLevel then
            while(incomingXp >= levelXpCap) do
                incomingXp = incomingXp - levelXpCap
                player.level = player.level + 1
                levelXpCap = getLvlXpCap(player.level + 1)
                net_send("", "message", player.displayName.." reached level "..player.level.."!")
                if player.level == maxLevel then
                    break
                end
            end
        end
        editPlayerData("level", uid, player.level)
    end
    player.xp = player.xp + incomingXp
    editPlayerData("xp", uid, player.xp)
    if isbot and player.level == maxLevel then
        handlePrestige(uid)
    end
end

function keywords_refreshKeywords()
    local EncodedKeywords = json.encode(GAME.galcon.global.CONFIGS.chat_keywords)
    g2.chat_keywords(EncodedKeywords)
    net_send("", "keywords", EncodedKeywords)
end

function keywords_addKeyword(keyword)
    local keywords = GAME.galcon.global.CONFIGS.chat_keywords
    
    local found = false
    for i, word in pairs(keywords) do
        if word == keyword then
            found = true
        end
    end
    if not found then
        table.insert(keywords, keyword)
    end

    keywords_refreshKeywords()
end

function keywords_removeKeyword(keyword)
    local keywords = GAME.galcon.global.CONFIGS.chat_keywords
    local removedKeywords = 0

    for i, word in pairs(keywords) do
        if word == keyword then
            table.remove(keywords, i)
            removedKeywords = removedKeywords + 1
        end
    end

    if not removedKeywords then
        print("ERROR: " .. keyword " wasn't found.")
    end

    keywords_refreshKeywords()
end