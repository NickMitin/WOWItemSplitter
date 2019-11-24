local frame, events = CreateFrame("Frame"), {};
local splitBagID = 0
local splitSessionStarted = false

function events:BAG_UPDATE(containerID)
    if containerID == splitBagID and splitSessionStarted then
        ItemSplitter__wait(1, ItemSplitter__splitOnce)
    end
end
frame:SetScript("OnEvent", function(self, event, ...)
    events[event](self, ...); -- call one of the functions above
end);
for k, v in pairs(events) do
    frame:RegisterEvent(k); -- Register all events for which handlers have been defined
end

local waitTable = {};
local waitFrame = nil;

function ItemSplitter__wait(delay, func, ...)
  if(type(delay)~="number" or type(func)~="function") then
    return false;
  end
  if(waitFrame == nil) then
    waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
    waitFrame:SetScript("onUpdate",function (self,elapse)
      local count = #waitTable;
      local i = 1;
      while(i<=count) do
        local waitRecord = tremove(waitTable,i);
        local d = tremove(waitRecord,1);
        local f = tremove(waitRecord,1);
        local p = tremove(waitRecord,1);
        if(d>elapse) then
          tinsert(waitTable,i,{d-elapse,f,p});
          i = i + 1;
        else
          count = count - 1;
          f(unpack(p));
        end
      end
    end);
  end
  tinsert(waitTable,{delay,func,{...}});
  return true;
end

local function MyAddonCommands(msg)
    local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
    if cmd == "split" then
        ItemSplitter__split() 
    end
end
  
SLASH_ITEMSPLITTER1 = '/spltr'
  
SlashCmdList["ITEMSPLITTER"] = MyAddonCommands

function ItemSplitter__split()
    splitSessionStarted = true
    ItemSplitter__splitOnce()
end

function ItemSplitter__splitOnce()
    numberOfSlots = GetContainerNumSlots(splitBagID)
    splitItemSlot = 1
    freeSlot = 0
    for slot = 1,numberOfSlots do
        itemID = GetContainerItemID(splitBagID, slot)
        if itemID == nil and freeSlot == 0 then
            freeSlot = slot 
        end
    end
    if freeSlot> 0 then
        texture, itemCount, locked, quality, readable = GetContainerItemInfo(splitBagID, splitItemSlot)
        if (itemCount > 1) then
            SplitContainerItem(splitBagID, splitItemSlot, 1)
            PickupContainerItem(splitBagID, freeSlot)
            return   
        end
    end
    print("here")
    splitSessionStarted = false
end