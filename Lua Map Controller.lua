--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    simulator = simulator
    simulator:setScreen(1, "3x3")
    simulator:setProperty("ExampleNumberProperty", 123)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, screenConnection.isTouched)
        simulator:setInputNumber(1, screenConnection.width)
        simulator:setInputNumber(2, screenConnection.height)
        simulator:setInputNumber(3, screenConnection.touchX)
        simulator:setInputNumber(4, screenConnection.touchY)

        -- NEW! button/slider options from the UI
        simulator:setInputBool(31, simulator:getIsClicked(1))       -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        simulator:setInputNumber(31, simulator:getSlider(1))        -- set input 31 to the value of slider 1

        simulator:setInputBool(32, simulator:getIsToggled(2))       -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(32, simulator:getSlider(2) * 50)   -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!


--Lua Map Controller

--color filtering settings
filter = property.getNumber("COLOR FILTERING")
noFilter = filter == 0
greyscale = filter == 1
radar = filter == 2
cyberpunk = filter == 3

--color library
color = {}
red = {245, 10, 10}
white = {245, 245, 245}
lime = {9, 255, 0}
black = {1, 1, 1}
cyan = {10, 245, 245}
yellow = {245, 245, 10}
textbg = {1, 1, 1}

-- color "packer"
function screen.setColorTable(color, alpha)
    alpha = alpha or 255
    screen.setColor(color[1], color[2], color[3], alpha)
end

function onTick()
    throttle = input.getNumber(5)
    owlMod = math.pi*0.85
    zoom = input.getNumber(4)
    waypointX = input.getNumber(5)
    waypointY = input.getNumber(6)

    --ui elements settings
    uiOwl = input.getBool(1)
    uiGPS = input.getBool(2)
    uiHeading = input.getBool(3)
    uiWaypoint = input.getBool(4)
    uiWaypointDistance = input.getBool(5)

    r = 7 -- radius
    r2 = 10 -- bigger radius for owl border

    textHeight = 10
    borderSize = 2

    -- gps info gathering
    x = input.getNumber(1)
    roundX = string.format("%.1f", x)
    y = input.getNumber(3)
    roundY = string.format("%.1f", y)
    gps = "X:" .. roundX .. " " .. "Y:" .. roundY

    --gps info pixel size check
    gpsLength = #gps * 5 - 1
    gpsbgWidth = gpsLength + borderSize

    -- heading conversions
    heading = input.getNumber(17)
    headingDeg = ((-heading - 1) * 360 % 360)
    headingRad = -heading * math.pi * 2

    -- heading ui
    uiHeadingDeg = "Head. :" .. string.format("%.1f", headingDeg)
    headingLength = #uiHeadingDeg * 5 - 1
    headingBgWidth = headingLength + (borderSize * 2)

    --waypoint
    roundWX = string.format("%.1f", waypointX)
    roundWY = string.format("%.1f", waypointY)
    waypoint = "Wayp. X:" .. roundWX .. " Y:" .. roundWY
    waypointLength = #waypoint * 5 - 1
    waypointWidth = waypointLength + borderSize
    wcr1 = 4 -- waypoint background size
    wcr2 = 2 -- waypoint size
    noWaypoint = waypointX == 0 and waypointY == 0

    --waypoint distance
    distance = math.sqrt((waypointX-x) ^2 + (waypointY-y) ^2)
    distRound = string.format("%.1f", distance)
    uiDistance = "Dist.(M): " .. distRound
    distLength = #uiDistance * 5 - 1
    distWidth = distLength + borderSize

    -- rotate the owl
    x1, y1 = r * math.sin(headingRad), r * math.cos(headingRad)
    x2, y2 = r * math.sin(headingRad + owlMod), r * math.cos(headingRad + owlMod)
    x3, y3 = r * math.sin(headingRad - owlMod), r * math.cos(headingRad - owlMod)

    -- rotate the bigger owl
    x1b, y1b = r2 * math.sin(headingRad), r2 * math.cos(headingRad)
    x2b, y2b = r2 * math.sin(headingRad + owlMod), r2 * math.cos(headingRad + owlMod)
    x3b, y3b = r2 * math.sin(headingRad - owlMod), r2 * math.cos(headingRad - owlMod)

    output.setNumber(1, heading)
    output.setNumber(2, headingDeg)
end

function onDraw()

    --map color setting
    if noFilter then
    elseif greyscale then
            screen.setMapColorOcean(25, 25, 25)
            screen.setMapColorShallows(35, 35, 35)
            screen.setMapColorLand(50, 50, 50)
            screen.setMapColorGrass(60, 60, 60)
            screen.setMapColorSand(80, 80, 80)
            screen.setMapColorSnow(140, 140, 140)
    elseif radar then
            screen.setMapColorOcean(1, 8, 1)
            screen.setMapColorShallows(2, 15, 1)
            screen.setMapColorLand(14, 143, 10)
            screen.setMapColorGrass(21, 205, 15)
            screen.setMapColorSand(10, 95, 7)
            screen.setMapColorSnow(23, 228, 17)
    elseif cyberpunk then
            screen.setMapColorOcean(2, 39, 39)
            screen.setMapColorShallows(3, 58, 58)
            screen.setMapColorLand(6, 136, 136)
            screen.setMapColorGrass(7, 157, 157)
            screen.setMapColorSand(8, 196, 196)
            screen.setMapColorSnow(9, 215, 215)
    end

    -- screen information gathering
    w = screen.getWidth()
    h = screen.getHeight()
    cx, cy = w/2, h/2
    hx = borderSize
    hy = h - (textHeight + borderSize)
    wx = borderSize
    wy = borderSize + (borderSize + textHeight)
    wdx = borderSize
    wdy = h - ((2 * textHeight) + (2 * borderSize))


    -- screen drawing
    screen.drawMap(x, y, zoom)

    -- waypoint
    if uiWaypoint then
        screen.setColorTable(textbg, 200)
        screen.drawRectF(wx, wy, (waypointWidth + borderSize), textHeight)
            if noFilter then screen.setColorTable(white)
            elseif greyscale then screen.setColorTable(white)
            elseif radar then screen.setColorTable(lime)
            elseif cyberpunk then screen.setColorTable(yellow)
            end
            screen.drawText((wx + borderSize), (wy + borderSize), waypoint)
            wpX, wpY = map.mapToScreen(x, y, zoom, w, h, waypointX, waypointY)
                if noWaypoint == false then
                    if noFilter then screen.setColorTable(red, 150)
                    elseif greyscale then screen.setColorTable(white, 150)
                    elseif radar then screen.setColorTable(lime, 150)
                    elseif cyberpunk then screen.setColorTable(yellow, 150)
                    end
                screen.drawLine(cx, cy, wpX, wpY)
                else end
            screen.setColorTable(black)
            screen.drawCircleF(wpX, wpY, wcr1)
                if noFilter then screen.setColorTable(red)
                elseif greyscale then screen.setColorTable(white)
                elseif radar then screen.setColorTable(lime)
                elseif cyberpunk then screen.setColorTable(yellow)
                end
            screen.drawCircleF(wpX, wpY, wcr2)
    else end

    -- waypoint distance
    
    if uiWaypointDistance then
        screen.setColorTable(textbg, 200)
        screen.drawRectF(wdx, wdy, (distWidth + borderSize), textHeight)
            if noFilter then screen.setColorTable(white)
            elseif greyscale then screen.setColorTable(white)
            elseif radar then screen.setColorTable(lime)
            elseif cyberpunk then screen.setColorTable(yellow)
            end
            if noWaypoint == false then
            screen.drawText((wdx + borderSize), (wdy + borderSize), uiDistance)
            else screen.drawText((wdx + borderSize), (wdy + borderSize), "Dist.(M): -")
            end
    else end

    -- gps info
    if uiGPS then
        screen.setColorTable(textbg, 200)
        screen.drawRectF(borderSize, borderSize, (gpsbgWidth + borderSize), textHeight)
            if noFilter then screen.setColorTable(white)
            elseif greyscale then screen.setColorTable(white)
            elseif radar then screen.setColorTable(lime)
            elseif cyberpunk then screen.setColorTable(yellow)
            end
            screen.drawText((borderSize + borderSize), (borderSize + borderSize), gps)
    else end

    -- heading info
    if uiHeading then
        screen.setColorTable(textbg, 200)
        screen.drawRectF(hx, hy, headingBgWidth, textHeight)
            if noFilter then screen.setColorTable(white)
            elseif greyscale then screen.setColorTable(white)
            elseif radar then screen.setColorTable(lime)
            elseif cyberpunk then screen.setColorTable(yellow)
            end
            screen.drawText((hx + borderSize), (hy + borderSize), uiHeadingDeg)
    else end

    -- owl 
    if uiOwl then
        screen.setColorTable(black)
        screen.drawTriangleF(cx + x1b, cy - y1b, cx + x2b, cy - y2b, cx + x3b, cy - y3b)
            if noFilter then screen.setColorTable(red)
            elseif greyscale then screen.setColorTable(white)
            elseif radar then screen.setColorTable(lime)
            elseif cyberpunk then screen.setColorTable(yellow)
            end
            screen.drawTriangleF(cx + x1, cy - y1, cx + x2, cy - y2, cx + x3, cy - y3)
    else end

end



