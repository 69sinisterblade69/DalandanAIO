local champs = {
--   Lux = true;
--   Malphite = true;
--   Ryze = true;
  TwistedFate = true;
  Xerath = true;
}

return { id = "Dalandan_AIO", name = "Dalandan AIO - " .. player.charName, 
author = "Dalandan_dev",
description = "Free DalandanAIO",
shard = {
    'main','header','common','menu',
    -- 'Lux',
    -- 'Malphite',
    -- 'Ryze',
    'TwistedFate',
    'Xerath'
},
flag = {
  text = "Dalandan AIO",
  color = {    
    text = 0xFF001ADB ,
    background1 = 0xFF001ADB,
    background2 = 0xFFDBCF1F,      
  },
},
  load = function()
    return champs[player.charName]; 
  end
}

