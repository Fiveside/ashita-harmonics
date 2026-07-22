local imgui = require('imgui');
local Utils = require('utils');
local BattleAction = require('battle_action');
local Constants = require('constants');

local Export = {};

-- This is a standin for the actual target data for testing and design purposes.
local targetData = T{
    start = 0,
    history = T{},
}

function Export.resetData()
    local now = Utils.getPerformanceStampMilliseconds();
    targetData = T{
        start = Utils.getPerformanceStampMilliseconds(),
        history = T{
            start = now,
            {
                stamp = now,
                event = {
                    actor = {
                        id = 5,
                        name = "Bozo",
                        defaultName = "{Unknown Bozo}",
                    },
                    action = {
                        recordName = {
                            en = "DBSkill",
                            ja = "JA_DBSkill",
                        },
                        name = "MemorySkill",
                        resonance = {"Distortion"},
                    },
                    effect = {
                        id = 7,
                        name = "Doodleboy",
                        defaultName = "{Unknown Doodleboy}",
                        damage = 140,
                        kind = BattleAction.Miss.Hit
                    }
                },
            },
            {
                stamp = now + 4500,
                event = {
                    actor = {
                        id = 12,
                        name = "Fleabag",
                        defaultName = "{Unknown Fleabag}",
                        owner = nil,
                        defaultOwner = "{Unknown Owner}",
                    },
                    action = {
                        recordName = {
                            en = "DBSkill2",
                            ja = "JA_DBSkill2",
                        },
                        name = "MemorySkill2",
                        resonance = {"Gravitation"},
                    },
                    effect = {
                        id = 7,
                        name = "Doodleboy",
                        defaultName = "{Unknown Doodleboy}",
                        damage = 140,
                        kind = BattleAction.Miss.Hit
                    },
                    chain = {
                        damage = 1000,
                        chain = "Darkness",
                        elements = {"Reverberation"},
                    }
                }
            }
        }
    }
end

local openState = {true};

function getTimers(start)
    local now = tonumber(Utils.getPerformanceStampMilliseconds());
    local scWindowOpen = start + 3000; -- Opens after 3 seconds
    local scWindowClose = start + 10000; -- Closes 7 seconds later.
    local scWindowDuration = 7000;
    local burstWindowOpen = start; -- Burst window opens immediately.
    local burstWindowClose = scWindowClose; -- Burst window closes after 10 seconds;
    local burstWindowDuration = 10000;
    return {
        scWindowOpen = scWindowOpen,
        -- Percent of the duration that has passed since start until window open
        scWindowOpenPct = start/scWindowOpen,
        scWindowClose = scWindowClose,
        scWindowClosePct = (now - scWindowOpen)/scWindowDuration,

        burstWindowOpen = burstWindowOpen,
        burstWindowClose = burstWindowClose,
        burstWindowPct = burstWindowOpen/burstWindowClose,
    }
end

function Export.drawGui()
    -- weeeee
    local now = Utils.getPerformanceStampMilliseconds();
    local startDelta = now - targetData.start;
    local windowBegin = targetData.start + 3000;
    local windowEnd = targetData.start + 10000;
    local beginPct = tonumber(startDelta)/3000;
    local endPct = tonumber(startDelta-3000)/7000;

    imgui.SetNextWindowSize({ 350, 0 }, ImGuiCond_Always);
    imgui.Begin("Harmonics##main", openState);
    imgui.Text("Hello World");

    local flags = bit.bor(ImGuiTableFlags_NoBordersInBody, ImGuiTableFlags_SizingStretchProp);
    imgui.BeginTable("progress_table", 2, flags);
    
    imgui.TableSetupColumn("progress_table_labels");
    imgui.TableSetupColumn("progress_table_bars");
    
    -- imgui.TableHeadersRow();
    imgui.TableNextRow();
    imgui.TableNextColumn();

    imgui.Text("WS Window:")
    imgui.TableNextColumn();
    -- imgui.SameLine(90)
    
    imgui.PushItemWidth(-1);
    if beginPct < 1 then
        imgui.PushStyleColor(ImGuiCol_PlotHistogram, { 0.921, 0.921, 0.203, 1.0 }) -- Yellow
        imgui.ProgressBar(beginPct, { -1, 18 }, string.format("%.1fs", tonumber((3000-startDelta))/1000))
    else
        -- Switch progress bar to green and swap foreground and background to simulate
        -- it draining left to right.
        imgui.PushStyleColor(ImGuiCol_PlotHistogram, { 0.203, 0.921, 0.203, 1.0 }) -- Green
        
        local frameR, frameG, frameB, frameA = imgui.GetStyleColorVec4(ImGuiCol_FrameBg);
        local fillR, fillG, fillB, fillA = imgui.GetStyleColorVec4(ImGuiCol_PlotHistogram);
        imgui.PushStyleColor(ImGuiCol_PlotHistogram, {frameR, frameG, frameB, frameA});
        imgui.PushStyleColor(ImGuiCol_FrameBg, {fillR, fillG, fillB, fillA});
        
        imgui.ProgressBar(endPct, { -1, 18 }, string.format("%.1fs", tonumber((10000-startDelta))/1000))
        
        imgui.PopStyleColor(2);
    end
    imgui.PopStyleColor()

    imgui.TableNextRow();
    imgui.TableNextColumn();
    imgui.Text("Magic Burst Window:");
    imgui.TableNextColumn();
    imgui.ProgressBar(0.5, {-1, 18}, "EEEEEE");

    imgui.EndTable();

    imgui.End();
end

return Export;