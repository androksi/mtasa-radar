-- Tiny optimisations
local min = math.min
local max = math.max

-- Local variables
local screenX, screenY = guiGetScreenSize()
local radarScale = max(0.80, screenY / 900)
local radarSize = 200 * radarScale
local radarMarginX = 10
local radarMarginY = 20
local radarX = screenX - (radarSize + radarMarginX)
local radarY = screenY - (radarSize + radarMarginY)
local radarOpacity = 1

local renderMargin = 4
local renderWidth = radarSize - renderMargin * 2
local renderHeight = radarSize - renderMargin * 2
local renderTargetX = radarX + renderMargin
local renderTargetY = radarY + renderMargin
local renderTarget
local centerWidth = renderWidth / 2

local locationSize = 24
local locationX = renderWidth / 2 - locationSize / 2
local locationY = renderHeight / 2 - locationSize / 2
local locationImage

local clicksAvailable = true

-- Local tables
local clicksOffset = {}
local fonts = {}

local menu = {
    visible = false,
    selected = {},
    items = {
        showPlayers = {status = true, label = "Show all players", description = "High CPU Usage"},
        showBlips = {status = true, label = "Show blips", description = "High CPU Usage"},
        performanceMode = {status = false, label = "Optimised Mode", description = "Force low rendering", tick = {0, 0}},
    }
}

-- Functions
function createFonts()
    fonts.default = dxCreateFont("assets/fonts/Roboto-Medium.ttf", 9 * radarScale, false, "antialiased")
    for index, font in pairs(fonts) do
        if not isElement(font) then
            fonts[index] = "default-bold"
        end
    end
end

function destroyFonts()
    for index, font in pairs(fonts) do
        if isElement(font) then
            destroyElement(font)
            fonts[index] = nil
        end
    end
end

function renderRadar()
    dxDrawRoundedRectangle(radarX, radarY, radarSize, radarSize, 4, tocolor(20, 21, 22, 200 * radarOpacity), false, false)

    if getTickCount() > menu.items["performanceMode"].tick[1] + menu.items["performanceMode"].tick[2] then
        dxSetRenderTarget(renderTarget, true)
            local playerX, playerY, playerZ = getElementPosition(localPlayer)
            local rotation = getPedCameraRotation(localPlayer)
            local mapX = (playerX + 3000) / 6000
            local mapY = (3000 - playerY) / 6000
            
            dxDrawImage(-((mapX * 6000) - centerWidth), -((mapY * 6000) - centerWidth), 6000, 6000, "assets/images/map.jpg", 0, 0, 0, tocolor(255, 255, 255, 255 * radarOpacity))
            if menu.items["showPlayers"].status then
                local players = getElementsByType("player", root, true)
                for i = 1, #players do
                    local player = players[i]
                    if player ~= localPlayer then
                        local pX, pY, pZ = getElementPosition(player)
                        local ppX = (pX + 3000) / 6000
                        local ppY = (3000 - pY) / 6000
                        
                        dxDrawImage(-((mapX * 6000) - centerWidth) + ppX * 6000 - 8, -((mapY * 6000) - centerWidth) + ppY * 6000 - 8, 16, 16, "assets/images/location.png", 0, 0, 0, tocolor(55, 255, 55, 255 * radarOpacity))
                    end
                end
            end
            if menu.items["showBlips"].status then
                local blips = getElementsByType("blip")
                for i = 1, #blips do
                    local blip = blips[i]
                    local blipId = getBlipIcon(blip)
		    if blidId ~= 0 then
			local blipX, blipY, blipZ = getElementPosition(blip)
			local bpX = (blipX + 3000) / 6000
			local bpY = (3000 - blipY) / 6000
						
			if fileExists("assets/images/blips/" .. blipId .. ".png") then
			    dxDrawImage(-((mapX * 6000) - centerWidth) + bpX * 6000 - 12, -((mapY * 6000) - centerWidth) + bpY * 6000 - 12, 24, 24, "assets/images/blips/" .. blipId .. ".png", 0, 0, 0, tocolor(255, 255, 255, 255 * radarOpacity))
			end
		    end
                end
            end
            dxDrawImage(locationX, locationY, locationSize, locationSize, locationImage, rotation + 180, 0, 0, tocolor(255, 255, 255, 255 * radarOpacity))
        dxSetRenderTarget()
        menu.items["performanceMode"].tick[1] = getTickCount()
    end
    dxDrawImage(renderTargetX, renderTargetY, renderWidth, renderHeight, renderTarget, 0, 0, 0, tocolor(255, 255, 255, 255 * radarOpacity))

    if getKeyState("tab") then
        radarOpacity = max(0, radarOpacity - 0.2)
    else
        radarOpacity = min(1, radarOpacity + 0.2)
    end

    if clicksOffset[1] and clicksOffset[1] == true then
        local cursorX, cursorY = getCursorPosition()
        cursorX, cursorY = screenX * cursorX, screenY * cursorY

        radarX = min(screenX - (radarSize + radarMarginX), max(radarMarginX, cursorX - clicksOffset[2]))
        radarY = min(screenY - (radarSize + radarMarginY), max(radarMarginY / 2, cursorY - clicksOffset[3]))
        renderTargetX = radarX + renderMargin
        renderTargetY = radarY + renderMargin
    end

    if menu.visible then
        local offset = menu.y
        for index, item in pairs(menu.items) do
            dxDrawRectangle(menu.x, offset, menu.width, menu.itemHeight, tocolor(20, 21, 22, 180 * radarOpacity), false)
            dxDrawText(item.label, menu.x + 10 * radarScale, offset + 8 * radarScale, menu.x + menu.width, offset + menu.itemHeight, tocolor(255, 255, 255, 255 * radarOpacity), 1, fonts.default, "left", "top")
            dxDrawText(item.description, menu.x + 10, offset, menu.x + menu.width, offset + menu.itemHeight - 8 * radarScale, tocolor(255, 255, 255, 255 * radarOpacity), 0.85, fonts.default, "left", "bottom")
            dxDrawText(item.status and "✔" or "", menu.x, offset, menu.x + menu.width - 10 * radarScale, offset + menu.itemHeight, tocolor(255, 255, 255, 255 * radarOpacity), 1, fonts.default, "right", "center")

            if isCursorInZone(radarX, offset, menu.width, menu.itemHeight) then
                menu.selected = {x = radarX, y = offset, width = menu.width, height = menu.itemHeight, option = index}
            end

            offset = offset + menu.itemHeight
        end

        local textY = radarY + radarSize
        local textHeight = 15

        dxDrawText("Click outside the radar to close the menu", radarX + 1, textY + 1, radarX + radarSize + 1, textY + textHeight + 1, tocolor(0, 0, 0, 255 * radarOpacity), 1, fonts.default, "center", "center")
        dxDrawText("Click outside the radar to close the menu", radarX, textY, radarX + radarSize, textY + textHeight, tocolor(255, 255, 255, 255 * radarOpacity), 1, fonts.default, "center", "center")
    end
end

function createRender()
    clicksAvailable = true
    renderTarget = dxCreateRenderTarget(renderWidth, renderHeight, true)
    locationImage = dxCreateTexture("assets/images/location.png", "dxt5", false, "clamp")
end

function freeMemory()
    if isElement(renderTarget) then
        destroyElement(renderTarget)
        renderTarget = nil
    end
    if isElement(locationImage) then
        destroyElement(locationImage)
        locationImage = nil
    end
end

function dxClicks(button, state, absoluteX, absoluteY)
    local isLeft = button == "left"
    local isUp = state == "up"

    if clicksAvailable then
        if isLeft and not isUp and getKeyState("lalt") == false then
            if isCursorInZone(radarX, radarY, radarSize, radarSize) then
                clicksOffset = {true, absoluteX - radarX, absoluteY - radarY}
            end
        elseif isLeft and isUp and getKeyState("lalt") then
            if isCursorInZone(radarX, radarY, radarSize, radarSize) then
                toggleMenu(true)
            end
        elseif isLeft and isUp and clicksOffset[1] then
            cancelMove()
        elseif not isLeft and isUp and clicksOffset[1] == false then
            if isCursorInZone(radarX, radarY, radarSize, radarSize) then
                resetRadar()
            end
        end
	elseif menu.visible then
		if isLeft and isUp then
            if not isCursorInZone(radarX, radarY, radarSize, radarSize) then
                toggleMenu(false)
                cancelMove()
            else
                local click = menu.selected
                if not click.x then
                    return false
                end

                if isCursorInZone(click.x, click.y, click.width, click.height) then
                    menu.items[click.option].status = not menu.items[click.option].status

                    if click.option == "performanceMode" then
                        menu.items[click.option].tick[1] = getTickCount()
                        menu.items[click.option].tick[2] = menu.items[click.option].status and 1000 or 0
                    end
                end
            end
        end
    end
end

function toggleMenu(bool)
    if type(bool) ~= "boolean" then
        return false
    end

    menu.visible = bool
    menu.width = renderWidth
    menu.itemHeight = 45 * radarScale
    menu.x = renderTargetX
    menu.y = renderTargetY

    clicksAvailable = not clicksAvailable
end

function resetRadar()
    radarX = screenX - (radarSize + radarMarginX)
    radarY = screenY - (radarSize + radarMarginY)
    renderTargetX = radarX + renderMargin
    renderTargetY = radarY + renderMargin
end

function cancelMove()
    clicksOffset = {false}
end

function toggleRadar(bool)
    if type(bool) ~= "boolean" then
        return false
    end

    if bool then
        createFonts()
        createRender()
        addEventHandler("onClientRender", root, renderRadar)
        addEventHandler("onClientClick", root, dxClicks)
    else
        removeEventHandler("onClientRender", root, renderRadar)
        removeEventHandler("onClientClick", root, dxClicks)
        freeMemory()
        cancelMove()
        toggleMenu(false)
        destroyFonts()
    end
end
toggleRadar(true)
