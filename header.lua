return { id = "Dalandan_AIO", name = "Dalandan AIO - " .. player.charName, 
author = "Dalandan_dev",
description = "Free DalandanAIO",
shard = {
    'main','common','menu','prediction',
    'Utility/reloader','Utility/pings','Utility/trollChat','Utility/trollPing','Utility/trollEmote',
    'Awareness/aa','Awareness/cooldown','Awareness/hud',
    -- 'Lux',
    -- 'Malphite',
    -- 'Ryze',
    'TwistedFate/TwistedFate',
    'Xerath/Xerath',
    'Yasuo/Yasuo',
    'Yone/Yone',
    'Caitlyn/Caitlyn',
    'Jinx/Jinx',
},
flag = {
  text = "Dalandan AIO",
  color = {    
    text = 0xFF001ADB ,
    background1 = 0xFF001ADB,
    background2 = 0xFFDBCF1F,      
  },
},
resources = {
  'Sprites/Combo.png', 
  'Sprites/Draw.png', 
  'Sprites/Harass.png', 
  'Sprites/Misc.png', 
  'Sprites/icon minions dark.png',
  'Sprites/icon minions light.png',
  'Sprites/Yone.png',

  'Sprites/items/2420.png','Sprites/items/3139.png','Sprites/items/3140.png','Sprites/items/3193.png','Sprites/items/3222.png','Sprites/items/6029.png','Sprites/items/6035.png',
},
  load = function()
    return true; 
  end
}
