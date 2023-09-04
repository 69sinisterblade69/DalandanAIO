return { id = "Dalandan_AIO", name = "Dalandan AIO - " .. player.charName, 
author = "Dalandan_dev",
description = "Free DalandanAIO",
shard = {
    'main','common','menu',
    'Utility/reloader','Utility/pings',
    -- 'Lux',
    -- 'Malphite',
    -- 'Ryze',
    'TwistedFate/TwistedFate',
    'Xerath/Xerath',
    'Yasuo/Yasuo2',
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
  
  'TwistedFate/TwistedFate.png',
  'Yasuo/Yasuo.png',
  'Xerath/Xerath.png',
},
  load = function()
    return true; 
  end
}

