function widget:GetInfo()
    return {
        name      = "Anti-Trollmando v1",
        desc      = "Shows warnings when enemy commando is detected",
        author    = "[teh]decay aka [teh]undertaker aka [DoR]Saruman",
        date      = "10 jan 2015",
        license   = "The BSD License",
        layer     = 0,
        version   = 1,
        enabled   = true  -- loaded by default
    }
end

-- project page on github: https://github.com/SpringWidgets/anti-trollmando

--Changelog
-- v2

local myTeamID             = Spring.GetMyTeamID()

local spGetUnitPosition    = Spring.GetUnitPosition
local spGetUnitDefID       = Spring.GetUnitDefID
local spAreTeamsAllied     = Spring.AreTeamsAllied
local spGetUnitTeam        = Spring.GetUnitTeam
local spMarkerAddPoint     = Spring.MarkerAddPoint
local spGetMyPlayerID      = Spring.GetMyPlayerID
local spIsUnitVisible      = Spring.IsUnitVisible
local spGetPlayerInfo      = Spring.GetPlayerInfo

local coreCommando = UnitDefNames["commando"]
local coreCommandoId = coreCommando.id

local enemyTrollmandosList = {}


function isEnemyCommando(unitID, unitDefID)
    if unitDefID == coreCommandoId then
        local unitTeam = spGetUnitTeam(unitID)
        if unitTeam ~= myTeamID and not spAreTeamsAllied(myTeamID, unitTeam) then
            return true
        end
    end
    return false
end

function widget:PlayerChanged()
    checkSpecState()
    refreshCommandosInfo()
end

local function checkSpecState()
    local playerID = spGetMyPlayerID()
    local _, _, spec, _, _, _, _, _ = spGetPlayerInfo(playerID)

    if ( spec == true ) then
        widgetHandler:RemoveWidget()
    end
end


function widget:GameFrame(frameNum)
    if (frameNum % 64) == 0 then
        checkSpecState()

        for unitID in pairs(enemyTrollmandosList) do
            if spIsUnitVisible(unitID) then
                local x, y, z = spGetUnitPosition(unitID)
                spMarkerAddPoint(x, y, z, "Enemy commando!", true)
            end
        end
    end
end

function refreshCommandosInfo()
    enemyTrollmandosList = {}

    local visibleUnits = spGetAllUnits()
    if visibleUnits ~= nil then
        for _, unitID in ipairs(visibleUnits) do
            local udefId = GetUnitDefID(unitID)
            if udefId ~= nil then
                if isEnemyCommando(unitID, udefId) then
                    enemyTrollmandosList[unitID] = true
                end
            end
        end
    end
end

function widget:UnitFinished(unitID, unitDefID, unitTeam)
    if isEnemyCommando(unitID, unitDefID) then
        enemyTrollmandosList[unitID] = true
    end
end

function widget:UnitDestroyed(unitID, unitDefID, unitTeam)
    if enemyTrollmandosList[unitID] then
        enemyTrollmandosList[unitID] = nil
    end
end

function widget:UnitEnteredLos(unitID, unitTeam)
    local unitDefID = spGetUnitDefID(unitID)
    if isEnemyCommando(unitID, unitDefID) then
        enemyTrollmandosList[unitID] = true
    end
end

function widget:UnitCreated(unitID, unitDefID, teamID, builderID)
    if isEnemyCommando(unitID, unitDefID) then
        enemyTrollmandosList[unitID] = true
    end
end

function widget:UnitTaken(unitID, unitDefID, unitTeam, newTeam)
    if isEnemyCommando(unitID, unitDefID) then
        enemyTrollmandosList[unitID] = true
    end
end

function widget:UnitGiven(unitID, unitDefID, unitTeam, oldTeam)
    if isEnemyCommando(unitID, unitDefID) then
        enemyTrollmandosList[unitID] = true
    end
end

function widget:UnitLeftLos(unitID, unitDefID, unitTeam)
    if enemyTrollmandosList[unitID] then
        enemyTrollmandosList[unitID] = nil
    end
end

function widget:Initialize()
    checkSpecState()
end

