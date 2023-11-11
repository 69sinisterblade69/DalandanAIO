return { id = "Dalandan_AIO", name = "Dalandan AIO - " .. player.charName, 
author = "Dalandan_dev",
description = "Free DalandanAIO",
shard = {
    'main','common','menu','prediction',
    'Utility/reloader','Utility/pings','Utility/trollChat','Utility/trollPing','Utility/trollEmote','Utility/aa',
    -- 'Lux',
    -- 'Malphite',
    -- 'Ryze',
    'TwistedFate/TwistedFate',
    'Xerath/Xerath',
    'Yasuo/Yasuo',
    'Yone/Yone',
    'Caitlyn/Caitlyn',
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

  'TwistedFate/TwistedFate.png',
  'Yasuo/Yasuo.png',
  'Xerath/Xerath.png',
  'Yone/Yone.png',
  'Caitlyn/Caitlyn.png',
},
  load = function()
    return true; 
  end
}
