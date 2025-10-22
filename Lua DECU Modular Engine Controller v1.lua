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

function run(self, sp, pv)
    local error = sp - pv
    self.integral = math.max(self.min, math.min(self.max, self.integral + error * self.Ki))
    local derivative = (error - self.last_error)
    self.last_error = error
    return self.Kp * error + self.integral + self.Kd * derivative
end

function PID(Kp, Ki, Kd, min, max)
    return {
        Kp = Kp,
        Ki = Ki,
        Kd = Kd,
        min = min or -math.huge,
        max = max or math.huge,
        integral = 0,
        last_error = 0,
        run = run
    }
end

PID_stoich = PID(1, 0, 60, -1, 1) -- PID with integral clamp
PID_afr = PID(1, 0, 60, -1, 1) -- PID with integral clamp
stoich = 1

function onTick()
    throttle = input.getNumber(4)
    airVol = input.getNumber(1)
    fuelVol = input.getNumber(2)
    engTemp = input.getNumber(3)
    stoich = (0.01 - (airVol / fuelVol - 40 / 3) / (engTemp + 200 / 3)) * 100 / 3
    stoich = math.max(0, math.min(stoich, 1))
    stoichTarget = property.getNumber("STOICH TARGET")
    afrTarget = property.getNumber("AFR TARGET")
    afr = -(0.03 * stoichTarget * engTemp + 2 * stoichTarget - 0.01 * engTemp - 14)
    sp1 = stoichTarget
    pv1 = stoich
    sp2 = afrTarget
    pv2 = airVol / fuelVol
    stoichOutput = PID_stoich:run(sp1, pv1)
    fuelMin = throttle * 0.5
    fuel = math.max(fuelMin, math.min(PID_afr:run(sp2, pv2), 1))
    air = throttle
    output.setNumber(1, air)
    output.setNumber(2, fuel)
    output.setNumber(3, stoichOutput)
    output.setNumber(4, stoich)
end

