-- 
-- Abstract: Follow Me (touch event) sample app
-- 
-- Version: 1.1
-- 
-- Copyright (C) 2010 Corona Labs Inc. All Rights Reserved.
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy of 
-- this software and associated documentation files (the "Software"), to deal in the 
-- Software without restriction, including without limitation the rights to use, copy, 
-- modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
-- and to permit persons to whom the Software is furnished to do so, subject to the 
-- following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all copies 
-- or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.

-- Demonstrates how to use create draggable objects. Also shows how to move
-- an object to the top.
local ui = require("ui")

display.setStatusBar(display.HiddenStatusBar)
local backgroundImage = display.newImageRect("bg.png", 320, 480)
backgroundImage.x = 160
backgroundImage.y = 240

local suspendTouchEvent = false

                        
local arguments =
{
    { style=1, x=59*0+6*1, y=330, w=50, h=50, r=10, red=255, green=0,   blue=128 },
    { style=2, x=59*1+5*2, y=330, w=50, h=50, r=10, red=0,   green=128, blue=255 },
    { style=3, x=59*2+5*3, y=330, w=50, h=50, r=10, red=0,   green=255, blue=0 },
    { style=4, x=59*3+5*4, y=330, w=50, h=50, r=10, red=255, green=255, blue=0 },
    { style=5, x=59*4+5*5, y=330, w=50, h=50, r=10, red=113, green=0,   blue=220 }
}

local containers =
{
    { x=59*0+5*1, y=265, w=55, h=55, r=0, red=0, green=0, blue=0, inStore=0 },
    { x=59*1+5*2, y=265, w=55, h=55, r=0, red=0, green=0, blue=0, inStore=0 },
    { x=59*2+5*3, y=265, w=55, h=55, r=0, red=0, green=0, blue=0, inStore=0 },
    { x=59*3+5*4, y=265, w=55, h=55, r=0, red=0, green=0, blue=0, inStore=0 },
    { x=59*4+5*5, y=265, w=55, h=55, r=0, red=0, green=0, blue=0, inStore=0 }
}

local myContainers = 
{
    {inStore=0, C={} },
    {inStore=0, C={} },
    {inStore=0, C={} },
    {inStore=0, C={} },
    {inStore=0, C={} }
}

local hotSpotTable = {}

-- 上方攻擊區 陣列
local topSquareTable = {}

-- 下方準備區 陣列
local buttomSquareTable = {}

-- FULL文字 陣列
local fullTextTable = {}

-- 攻擊 陣列
local attackTable = {}

--rectangle-based collision detection
local function hasCollided( obj1, obj2 )
   if ( obj1 == nil ) then  --make sure the first object exists
      return false
   end
   if ( obj2 == nil ) then  --make sure the other object exists
      return false
   end

   local left = obj1.contentBounds.xMin <= obj2.contentBounds.xMin and obj1.contentBounds.xMax >= obj2.contentBounds.xMin
   local right = obj1.contentBounds.xMin >= obj2.contentBounds.xMin and obj1.contentBounds.xMin <= obj2.contentBounds.xMax
   local up = obj1.contentBounds.yMin <= obj2.contentBounds.yMin and obj1.contentBounds.yMax >= obj2.contentBounds.yMin
   local down = obj1.contentBounds.yMin >= obj2.contentBounds.yMin and obj1.contentBounds.yMin <= obj2.contentBounds.yMax

   return (left or right) and (up or down)
end


local function printTouch( event )
    if event.target then 
        local bounds = event.target.contentBounds
        --print( "event(" .. event.phase .. ") ("..event.x..","..event.y..") bounds: "..bounds.xMin..","..bounds.yMin..","..bounds.xMax..","..bounds.yMax )
    end 
end



local startCountDown = false;
local function onTouch( event )

    if suspendTouchEvent == true then return end

    local t = event.target
    
    -- Print info about the event. For actual production code, you should
    -- not call this function because it wastes CPU resources.
    --printTouch(event)
    
    local phase = event.phase
    if "began" == phase then
        -- Make target the top-most object
        local parent = t.parent
        parent:insert( t )
        display.getCurrentStage():setFocus( t )
        
        -- Spurious events can be sent to the target, e.g. the user presses 
        -- elsewhere on the screen and then moves the finger over the target.
        -- To prevent this, we add this flag. Only when it's true will "move"
        -- events be sent to the target.
        t.isFocus = true
        
        -- Store initial position
        t.x0 = event.x - t.x
        t.y0 = event.y - t.y
    elseif t.isFocus then
        if "moved" == phase then
            -- Make object move (we subtract t.x0,t.y0 so that moves are
            -- relative to initial grab point, rather than object "snapping").
            t.x = event.x - t.x0
            t.y = event.y - t.y0
            
            
            for _,item in ipairs( hotSpotTable ) do
                
                local hotSpot = item;
                
                
                if ( hasCollided( event.target, hotSpot ) ) then
                    --snap in place
                    
                    for _,item2 in ipairs( hotSpotTable ) do
                        item2:setStrokeColor( 0, 0, 0, 0 )
                    end
                    
                    hotSpot:setStrokeColor( 255, 255, 255, 255 )
            
                    break;
                else
                    --move back
                    hotSpot:setStrokeColor( 0, 0, 0, 0 )

                end
            end
            
        elseif "ended" == phase or "cancelled" == phase then
           -- display.getCurrentStage():setFocus( nil )
           -- t.isFocus = false
           
            for i,item in ipairs( myContainers ) do
                
                local hotSpot = hotSpotTable[i];

                display.getCurrentStage():setFocus( nil )
                t.isFocus = false

                if ( hasCollided( event.target, hotSpot ) ) then
                    --snap in place
                    hotSpot:setStrokeColor( 0, 0, 0, 0 )

                    local isNeedCreateNewOne = true
                    local index = myContainers[i].inStore;
                    
                    -- 將方塊移動至容器裡
                    -- 前4個要縮小
                    if index < 4 then
                    
                        -- 縮小
                        event.target.xScale = 0.5;
                        event.target.yScale = 0.5;
                        
                        -- 移動至定位(分別4個角落)
                        local newX = index%2 * 30 - 15
                        local newY = math.floor(index/2) * 30 -15
                        transition.to( event.target, {time=50, x=hotSpot.x + newX, y=hotSpot.y + newY} )
                    -- 第5個要蓋住全部
                    elseif index == 4 then
                    
                        -- 移動至定位
                        transition.to( event.target, {time=50, x=hotSpot.x, y=hotSpot.y} )
                        
                        -- 顯示 FULL 文字
                        local myText = display.newText("FULL", hotSpot.x-27, hotSpot.y-15, native.systemFont, 22)
                        myText:setTextColor(100, 100, 100)
                        myText.rotation = -25
                        
                        table.insert(fullTextTable, myText)
                    -- 超過5個時返回
                    else

                        isNeedCreateNewOne = false
                        
                        --move back
                        local item = arguments[event.target.id]
                        transition.to( event.target, {time=50, x=item.x+30-6, y=item.y+30-5} )
                    end

                    -- 加入容器中
                    if isNeedCreateNewOne == true then
                        
                        startCountDown = true
                    
                        myContainers[i].inStore = index + 1
                        myContainers[i].C[index+1] = event.target.style
                        --print("i("..i..") index("..index..") item.style("..event.target.style..")")
                        
                        
                        table.insert(topSquareTable, event.target)  
                        
                        event.target:removeEventListener( "touch", onTouch )
                        
                        table.remove(buttomSquareTable, event.target.id)
                    end

                    -- 產生新的方塊
                    if isNeedCreateNewOne == true then

                        local item = arguments[event.target.id];
                        local button = display.newRoundedRect( item.x, item.y, item.w, item.h, item.r )
                        local random_num = math.random( 1, 5 )
                        local temp = arguments[random_num]

                        button:setFillColor( temp.red, temp.green, temp.blue )
                        button.strokeWidth = 6
                        button.id = event.target.id
                        button:setStrokeColor( temp.red, temp.green, temp.blue )
                        button.style = temp.style

                        -- Make the button instance respond to touch events
                        button:addEventListener( "touch", onTouch )
                        
                        table.insert(buttomSquareTable, button)
                    end

                    break;
                else
                    --move back
                    local item = arguments[event.target.id];
                    transition.to( event.target, {time=50, x=item.x+30-6, y=item.y+30-5} )
                    hotSpot:setStrokeColor( 0, 0, 0, 0 )
                end
            end
        end
    end
    
    -- Important to return true. This tells the system that the event
    -- should not be propagated to listeners of any objects underneath.
    return true
end


-- 容器
for i,item in ipairs( containers ) do

    local hotSpot = display.newRoundedRect( item.x, item.y, item.w, item.h, item.r )
    hotSpot:setFillColor( 0, 0, 0, 0 )
    hotSpot.strokeWidth = 6
    hotSpot:setStrokeColor( 0, 0, 0, 0 )

    hotSpotTable[i] = hotSpot;
end

-- 方塊
for i,item in ipairs( arguments ) do

    local button = display.newRoundedRect( item.x, item.y, item.w, item.h, item.r )
    button:setFillColor( item.red, item.green, item.blue )
    button.strokeWidth = 6
    button:setStrokeColor( item.red, item.green, item.blue )
    button.id = i
    button.style = item.style
    button:addEventListener( "touch", onTouch )
    
    table.insert(buttomSquareTable, button)
end

local function compare( a, b )
    return a < b
end 

-- 攻擊動畫
local function drawAttack(index)
    
    -- 人物的攻擊動畫
    local img = index.. ".png"
    local object = display.newImageRect(img, 320, 80)
    object.x = 480
    object.y = 280
    transition.to( object, {time=200, x=160, y=280} )
    timer.performWithDelay(300,function() transition.to( object, {time=200, x=160, y=380} ) end)
    timer.performWithDelay(700,function() object:removeSelf(); object = nil; end)
    
    -- 刀光的攻擊動畫
    timer.performWithDelay(300,function()
        local swordImg = "sword.png"
        local swordObject = display.newImageRect(swordImg, 160, 80)
        swordObject.x = 80
        swordObject.y = 80
        swordObject.rotation = 45
        
        timer.performWithDelay(20,function() transition.to( swordObject, {time=100, x=160, y=160} ) end)
        timer.performWithDelay(300,function() swordObject:removeSelf(); swordObject = nil; end)
    end)
end

-- 計算戰鬥次數
local function combatCount() 
    
    for _,item in ipairs( myContainers ) do

        if item.inStore > 0 then
            
            --table.sort( item.C, compare )
            
            --print("item.inStore("..item.inStore..")("..#item.C..")")
            local A1 = 0 
            local A2 = 0
            local A3 = 0
            local A4 = 0
            local A5 = 0
            for _,item2 in ipairs( item.C ) do
                        
                --print("("..item2..")")
                
                if item2 == 1 then A1 = A1 + 1 end
                if item2 == 2 then A2 = A2 + 1 end
                if item2 == 3 then A3 = A3 + 1 end
                if item2 == 4 then A4 = A4 + 1 end
                if item2 == 5 then A5 = A5 + 1 end
            end
            
            if A1 == 5 then A1 = 3 else A1 = math.floor(A1 / 2)    end
            if A2 == 5 then A2 = 3 else A2 = math.floor(A2 / 2)    end
            if A3 == 5 then A3 = 3 else A3 = math.floor(A3 / 2)    end
            if A4 == 5 then A4 = 3 else A4 = math.floor(A4 / 2)    end
            if A5 == 5 then A5 = 3 else A5 = math.floor(A5 / 2)    end

            --print("A1("..A1..")")
            --print("A2("..A2..")")
            --print("A3("..A3..")")
            --print("A4("..A4..")")
            --print("A5("..A5..")")
            
            if A1 > 0 then  for i=1,A1 do   table.insert(attackTable, "A1") end end
            if A2 > 0 then  for i=1,A2 do   table.insert(attackTable, "A2") end end
            if A3 > 0 then  for i=1,A3 do   table.insert(attackTable, "A3") end end
            if A4 > 0 then  for i=1,A4 do   table.insert(attackTable, "A4") end end
            if A5 > 0 then  for i=1,A5 do   table.insert(attackTable, "A5") end end
            
            --print("attackTable("..#attackTable..")")
        end
    end
end

-- 直放戰鬥次數動畫
local function playCombatCount()
    
    for i,index in ipairs( attackTable ) do
        
        local nextTime = i * 500
        
        timer.performWithDelay(nextTime,function() drawAttack(index) end)
    end
    
    local times = table.maxn(attackTable)
    local endTime = times * 500 + 1000
    timer.performWithDelay(endTime,function() suspendTouchEvent = false end)
    
end

-- 戰鬥回合結束，計算得分
local function combatEnd()

    combatCount()       -- 計算戰鬥次數
    playCombatCount()   -- 直放戰鬥次數動畫
end

-- 重置
local function restAll()

    -- 刪除 topSquareTable 裡的 方塊
    for i,item in ipairs( topSquareTable ) do
 
        item:removeSelf()
        item = nil
    end
    topSquareTable = {}

    -- 刪除 FULL 文字
    for i,item in ipairs( fullTextTable ) do

        item:removeSelf()
        item = nil
    end
    fullTextTable = {}

    -- 重置 containers
    myContainers =  {
        {inStore=0, C={} },
        {inStore=0, C={} },
        {inStore=0, C={} },
        {inStore=0, C={} },
        {inStore=0, C={} }
    }
    
    -- 重置 attackTable
    attackTable = {}
end


local onTestTouched = function(event)

    if event.phase == "press" then

        --print("RestAll ")
            
        combatEnd() -- 戰鬥回合結束，計算得分
        restAll()   -- 重置
    end
end

-- 測試用按鈕 (模擬戰鬥回合結束)
--local testButton = ui.newButton{
--    defaultSrc = "End_Turn.png",
--    defaultX=50,
--    defaultY=50,
--    onEvent = onTestTouched,
--}
--testButton.x = 160 
--testButton.y = 25




local countDownTime = 6
local oldTime = 0
local countDownObject = null
local function gameLoop(event)

    if startCountDown == true then
        
        local diffTime = event.time - oldTime
        if diffTime >= 1000 then

            oldTime = event.time
            countDownTime = countDownTime - 1
            
            if countDownTime <= 5 and countDownTime > 0 then 

                -- 顯示倒數記時動畫
                local img = countDownTime..".png"
                if countDownObject ~= null then countDownObject:removeSelf()    end
                countDownObject = display.newImageRect(img, 200, 160)
                countDownObject.x = 160
                countDownObject.y = 150
            elseif countDownTime == 0 then
                
                suspendTouchEvent = true    -- 暫停 touch event

                if countDownObject ~= null then countDownObject:removeSelf()    end
                
                -- 下方準備區 歸位
                print("buttomSquareTable("..#buttomSquareTable..")")
                for _,item in ipairs( buttomSquareTable ) do
                                                                        
                    print("item.id("..item.id..")")
                     --move back
                    local item2 = arguments[item.id]
                    transition.to( item, {time=50, x=item2.x+30-6, y=item2.y+30-5} )
                end
                
                
                -- 初始化 gameloop 資料
                countDownObject = null
                countDownTime = 6
                oldTime = 0
                startCountDown = false

                combatEnd() -- 戰鬥回合結束，計算得分
                restAll()   -- 重置
            end
            
        end

    end
end

Runtime:addEventListener("enterFrame",gameLoop)



-- listener used by Runtime object. This gets called if no other display object
-- intercepts the event.
local function printTouch2( event )
    --print( "event(" .. event.phase .. ") ("..event.x..","..event.y..")" )
end

Runtime:addEventListener( "touch", printTouch2 )