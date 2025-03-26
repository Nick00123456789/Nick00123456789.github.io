__cloud_db = {}

local grp_id = 1
local n = 1

function cloud_loc(path, file)

	if clouds__use_smaller_textures and clouds__use_smaller_textures == true and file_exists(path.."\\"..file.."_eco.png") ==  true then

		return path.."\\"..file.."_eco.dds"
	else

		return path.."\\"..file..".dds"
	end
end


grp_id = 0

grp_id = grp_id+1 -- distant hazy
__cloud_db[grp_id] = {}           --  n   alti  radius   a     b
__cloud_db[grp_id]["info"]        = { 7,  3500, 12000,   0.05, 0.14 }
__cloud_db[grp_id]["info"]["rnd"] = { 3,   200,     0,   0,    0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file			          size, ratio, opac  FL     FLDC  BLM  BLE  BLOM BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("hazy","hazy1")},   10000,  2.5,   0.10, 0.14,  0.0, 0.10, 20,  5.0, 10.0, 0.5, 2.5,  1.0   } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                        		  500,  0.5,  0.05,  0.0,   0.10, 0.0,  0,  0.0, 0.0,  0.0, 0.0,  0.0 }

grp_id = grp_id+1 -- distant hazy
__cloud_db[grp_id] = {}           --  n   alti   radius    a     b
__cloud_db[grp_id]["info"]        = { 10, 3800,   12000,   0.15, 0.64 }
__cloud_db[grp_id]["info"]["rnd"] = { 1,   200,       0,   0,    0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file			          size, ratio, opac  FL     FLDC  BLM  BLE  BLOM BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("hazy","hazy1")},   12000,  3.0,   0.30, 0.06,  0.2, 0.55, 20,  1.0, 10.0, 0.5, 1.0,  1.0   } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                        		  500,  0.5,   0.3,  0.0,   0.10, 0.0,  0,  0.0, 0.0,  0.0, 0.0,  0.0 }


grp_id = grp_id+1 -- distant hazy
__cloud_db[grp_id] = {}           --  n   alti  radius   a     b
__cloud_db[grp_id]["info"]        = { 8,  3800, 12000,   0.65, 0.75 }
__cloud_db[grp_id]["info"]["rnd"] = { 4,   200,     0,   0,    0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file			          size, ratio, opac  FL     FLDC  BLM  BLE  BLOM BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("hazy","hazy1")},   12000,  3.5,   0.1,  0.06,  0.1, 0.45, 20,  1.0, 10.0, 1.0, 2.5,  1.00   } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                        		  500,  0.5,   0.2,  0.0,   0.10, 0.0,  0,  0.0, 0.0,  0.0, 0.0,  0.0 }




grp_id = grp_id+1 -- small single fluffy
__cloud_db[grp_id] = {}            --  n  alti radius  a     b
__cloud_db[grp_id]["info"]        = { 15,1000, 6500,   0.10, 0.14 }
__cloud_db[grp_id]["info"]["rnd"] = {  5, 400, 1400,   0,    0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --          file			   		     size, ratio, opac  FL     FLDC   BLM  BLE  BLOM BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("single","021")},        500,   1.1,   0.75, 0.04, 0.45,  0.7, 10,  1.0, 1.0,  0.7, 2.5,  1.0 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("single","031")},        300,   1.1,   0.75, 0.04, 0.45,  0.7, 10,  1.0, 1.0,  0.7, 2.5,  1.0 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("single","051")},        650,   1.1,   0.75, 0.04, 0.45,  0.7, 10,  1.0, 1.0,  0.7, 2.5,  1.0 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("single","061")},        300,   1.1,   0.75, 0.04, 0.45,  0.7, 10,  1.0, 1.0,  0.7, 2.5,  1.0 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("single","071")},        300,   1.1,   0.75, 0.04, 0.45,  0.7, 10,  1.0, 1.0,  0.7, 2.5,  1.0 } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                       		      75,   0.2,   0.05, 0.0,   0.05,  0.0,  0,  0.0, 0.0,  0.0, 0.0,  0.0 }



grp_id = grp_id+1 -- distant width
__cloud_db[grp_id] = {}           --  n  alti   radius  a    b
__cloud_db[grp_id]["info"]        = { 6, 1300,  8000,   0.10, 0.14 }
__cloud_db[grp_id]["info"]["rnd"] = { 1,  100,     0,   0,   0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file			          size, ratio, opac  FL     FLDC  BLM  BLE  BLOM BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("horizon","h1")},    3500,  4.5,   0.3,  0.08,  1.10, 0.1, 10,  1.0, 10.0, 0.5, 1.0,  1.0   } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                        		  500,  0.5,   0.0,  0.0,   0.10, 0.0,  0,  0.0, 0.0,  0.0, 0.0,  0.0 }


grp_id = grp_id+1 -- scattered
__cloud_db[grp_id] = {}           --  n  alti radius   a    b
__cloud_db[grp_id]["info"]        = { 3, 4000,  6000,  0.15, 0.40 }
__cloud_db[grp_id]["info"]["rnd"] = { 1,  500,  3000,  0,   0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file			  		  size, ratio, opac  FL    FLDC  BLM  BLE  BLOM BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("strato","s1")},     8000,   2.0,  0.30, 0.10, 0.05,  2.5, 20,  0.5, 10.0, 1.5, 1.0,  1.1 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("strato","s2")},    16000,   1.0,  0.35, 0.10, 0.05,  2.0, 20,  1.0, 10.0, 0.7, 1.0,  1.1 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("strato","s3")},    12000,   1.5,  0.25, 0.10, 0.05,  2.0, 20,  0.5, 10.0, 0.5, 1.0,  1.1 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("strato","s1")},     8000,   2.2,  0.30, 0.10, 0.05,  2.5, 20,  0.5, 10.0, 1.2, 1.0,  1.1 } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                         		    2,   0.0,   0.0,  0.0, 0.0,   0.0,  0,  0.0, 0.0,  0.0, 0.0,  0.0 }


grp_id = grp_id+1 --scattered
__cloud_db[grp_id] = {}            --  n  alti radius  a    b
__cloud_db[grp_id]["info"]        = {  2, 3000,  1.0,  0.3, 0.38 }
__cloud_db[grp_id]["info"]["rnd"] = {  0,  500,    0,  0,   0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file			  		   size, ratio,  opac  FL    FLDC   BLM  BLE  BLOM BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("ceiling","c2")},      8000,   1.0,   0.1, 0.10, 0.05,  1.2, 15,  0.00,1.0,  1.5, 2.5,  2.5 } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                          		  1,   0.0,   0.05,  0.0, 0.0,   0.0,  0,  0.0, 0.0,  0.0, 0.0,  0.0 }


grp_id = grp_id+1 --scattered
__cloud_db[grp_id] = {}            --  n  alti   radius   a    b
__cloud_db[grp_id]["info"]        = {  3, 2000,  3000.0,  0.3, 0.38 }
__cloud_db[grp_id]["info"]["rnd"] = {  1,  100,  500,     0,   0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file			 		   size, ratio, opac  FL     FLDC   BLM  BLE  BLOM BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("strato","s5")},       5000, 3.0,   0.1,  0.05,  0.4,   4.0, 25,  1.00,5.0,  0.5, 1.0,  3.0 } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                        		    1,   0.0,   0.05,  0.0,  0.0,   0.0,  0,  0.0, 0.0,  0.0, 0.0,  0.0 }




grp_id = grp_id+1 -- distant detailed clouds
__cloud_db[grp_id] = {}           --  n   alti   radius    a     b
__cloud_db[grp_id]["info"]        = { 35,  500,   10000,   0.15, 0.2999 }
__cloud_db[grp_id]["info"]["rnd"] = { 10,  100,    5000,   0,    0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file			          size, ratio, opac  FL     FLDC  BLM  BLE  BLOM BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far01")},       500, 3.75,  0.6, 0.40,  0.50,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far02")},       580, 5.90,  0.6, 0.40,  0.50,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far03")},       250, 5.84,  0.6, 0.40,  0.50,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far04")},       200, 3.40,  0.6, 0.40,  0.50,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far05")},       280, 5.42,  0.6, 0.40,  0.50,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far06")},       750, 6.30,  0.6, 0.40,  0.50,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far07")},       460, 6.65,  0.6, 0.40,  0.50,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far08")},       320, 3.78,  0.6, 0.40,  0.50,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far09")},       375, 4.16,  0.6, 0.40,  0.50,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far10")},       220, 2.95,  0.6, 0.40,  0.50,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far11")},       125, 1.77,  0.6, 0.40,  0.50,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far12")},       580, 5.61,  0.6, 0.40,  0.50,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far13")},       420, 2.29,  0.6, 0.40,  0.50,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far14")},       330, 2.65,  0.6, 0.40,  0.50,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far15")},       375, 3.10,  0.6, 0.40,  0.50,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                        		   100,  0.5,  0.0,  0.05,   0.1,  0.0,  0,  0.0, 0.0,  0.0, 0.0,  0.1 }


grp_id = grp_id+1 -- distant detailed clouds
__cloud_db[grp_id] = {}           --  n   alti   radius    a     b
__cloud_db[grp_id]["info"]        = { 65,  500,   10000,   0.3,  1.00 }
__cloud_db[grp_id]["info"]["rnd"] = { 10,  100,    5000,   0,    0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file			          size, ratio, opac  FL     FLDC  BLM  BLE  BLOM BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far01")},       500, 3.75,  0.6, 0.60,  0.90,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far02")},       580, 5.90,  0.6, 0.60,  0.90,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far03")},       250, 5.84,  0.6, 0.60,  0.90,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far04")},       200, 3.40,  0.6, 0.60,  0.90,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far05")},       280, 5.42,  0.6, 0.60,  0.90,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far06")},       750, 6.30,  0.6, 0.60,  0.90,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far07")},       460, 6.65,  0.6, 0.60,  0.90,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far08")},       320, 3.78,  0.6, 0.60,  0.90,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far09")},       375, 4.16,  0.6, 0.60,  0.90,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far10")},       220, 2.95,  0.6, 0.60,  0.90,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far11")},       125, 1.77,  0.6, 0.60,  0.90,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far12")},       580, 5.61,  0.6, 0.60,  0.90,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far13")},       420, 2.29,  0.6, 0.60,  0.90,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far14")},       330, 2.65,  0.6, 0.60,  0.90,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("far","far15")},       375, 3.10,  0.6, 0.60,  0.90,  0.0, 20,  1.0, 10.0, 0.1, 1.0,  0.9   } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                        		   100,  0.5,  0.0,  0.05,   0.1,  0.0,  0,  0.0, 0.0,  0.0, 0.0,  0.1 }





grp_id = grp_id+1 -- big front
__cloud_db[grp_id] = {}            --  n  alti radius  a    b
__cloud_db[grp_id]["info"]        = {  3,  150, 9000,  0.55, 0.8 }
__cloud_db[grp_id]["info"]["rnd"] = {  2,  100,  300,  0,    0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file					  size, ratio,  opac  FL     FLDC    BLM  BLE  BLOM  BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("near","n3")},       12000,   2.5,  0.4,  0.52,  0.85,   1.0, 10,  1.09, 0.4,  0.7, 1.0,  1.0 } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                       		  1000,   0.0,  0.1,  0.1,   0.2,    0.0,  0,  0.0,  0.0,  0.0, 0.0,  0.0 }



grp_id = grp_id+1 -- distant width
__cloud_db[grp_id] = {}           --  n  alti   radius  a    b
__cloud_db[grp_id]["info"]        = { 6, 1400,  8000,   0.5, 0.8 }
__cloud_db[grp_id]["info"]["rnd"] = { 1,  100,     0,   0,   0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file			          size, ratio, opac   FL     FLDC  BLM  BLE  BLOM BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("horizon","h1")},    4000,   4.0,  0.60,  0.20,  0.50, 0.1, 20,  1.0, 10.0, 0.1, 1.0,  1.0   } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                        		    2,   0.5,  0.35,  0.1,   0.20, 0.0,  0,  0.0, 0.0,  0.0, 0.0,  0.0 }


grp_id = grp_id+1 -- horizon fluffy
__cloud_db[grp_id] = {}            --  n  alti  radius  a    b
__cloud_db[grp_id]["info"]        = {  6,  850,  5250,  0.15, 0.34 }
__cloud_db[grp_id]["info"]["rnd"] = {  1,  100,  1500,  0,   0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file					   size, ratio, opac  FL     FLDC   BLM  BLE  BLOM  BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("horizon","h21")},     750.0, 5.8,  0.65, 0.10,  0.45,  0.3, 10,  1.02, 1.0, 0.35, 1.0,  1.0 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("horizon","h31")},     750.0, 5.8,  0.65, 0.10,  0.45,  0.3, 10,  1.02, 1.0, 0.35, 1.0,  1.0 } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                      		     100, 0.5,   0.0,  0.05,  0.03,  0.0,  0,  0.0, 0.0, 0.05, 0.0,  0.0 }





grp_id = grp_id+1 --big dark 
__cloud_db[grp_id] = {}            --  n  alti  radius  a    b
__cloud_db[grp_id]["info"]        = {  4, 1400, 2200,   0.5, 0.7499 }
__cloud_db[grp_id]["info"]["rnd"] = {  2,  300,  500,     0,   0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file					   size, ratio, opac  FL     FLDC   BLM  BLE  BLOM BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("near","n81")},        5500,  1.3,  0.90, 0.10,  0.30, 0.80, 20,  1.00,0.4,  0.1, 2.5,  1.10 } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                         		    500,  0.0,   0.05, 0.0,  0.0,   0.0,  0,  0.0, 0.0,  0.0, 0.0,  0.0 }


grp_id = grp_id+1 --big dark 
__cloud_db[grp_id] = {}            --  n  alti  radius  a    b
__cloud_db[grp_id]["info"]        = { 13, 1200, 3500,   0.75, 0.7999 }
__cloud_db[grp_id]["info"]["rnd"] = {  2,  300, 3200,     0,   0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file					   size, ratio, opac  FL     FLDC   BLM  BLE  BLOM BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("near","n81")},        5500,  1.3,  0.70, 0.10,  0.55, 0.00, 20,  1.01,0.4,  0.5, 2.5,  0.50 } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                         		    500,  0.0,   0.05, 0.0,  0.0,   0.0,  0,  0.0, 0.0,  0.0, 0.0,  0.0 }


grp_id = grp_id+1 --big dark 
__cloud_db[grp_id] = {}            --  n  alti  radius  a    b
__cloud_db[grp_id]["info"]        = { 21, 1200, 3500,   0.91, 1.0 }
__cloud_db[grp_id]["info"]["rnd"] = {  2,  300, 3200,     0,   0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file					   size, ratio, opac  FL     FLDC   BLM  BLE  BLOM BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("near","n81")},        5500,  1.3,  0.90, 0.10,  0.85, 0.00, 20,  1.01,0.4,  0.2, 2.5,  0.50 } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                         		    500,  0.0,   0.05, 0.0,  0.0,   0.0,  0,  0.0, 0.0,  0.0, 0.0,  0.0 }



grp_id = grp_id+1 --big dark 
__cloud_db[grp_id] = {}            --  n  alti  radius  a    b
__cloud_db[grp_id]["info"]        = { 13, 1400, 2200,   0.8, 0.9 }
__cloud_db[grp_id]["info"]["rnd"] = {  2,  300,  500,     0,   0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file					   size, ratio, opac  FL     FLDC   BLM  BLE  BLOM BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("near","n81")},        5500,  1.3,  0.90, 0.10,  0.55, 3.50, 20,  1.01,0.4,  0.5, 2.5,  1.10 } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                         		    500,  0.0,   0.05, 0.0,  0.0,   0.0,  0,  0.0, 0.0,  0.0, 0.0,  0.0 }



grp_id = grp_id+1 -- small single fluffy
__cloud_db[grp_id] = {}            --  n  alti radius  a    b
__cloud_db[grp_id]["info"]        = { 60, 900, 4000,   0.20, 0.3399 }
__cloud_db[grp_id]["info"]["rnd"] = {  5, 100, 2500,   0,   0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --          file			   		     size, ratio, opac  FL     FLDC   BLM  BLE  BLOM BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("single","011")},        750,   1.5,   0.80, 0.19, 0.51,  0.5, 20,  1.05, 1.02,  0.7, 2.5,  1.0 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("single","021")},        600,   1.1,   0.80, 0.19, 0.51,  0.5, 20,  1.05, 1.02,  0.7, 2.5,  1.0 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("single","031")},        400,   1.1,   0.80, 0.19, 0.51,  0.5, 20,  1.05, 1.02,  0.7, 2.5,  1.0 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("single","041")},        750,   1.1,   0.80, 0.19, 0.51,  0.5, 20,  1.05, 1.02,  0.7, 2.5,  1.0 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("single","051")},        750,   1.1,   0.80, 0.19, 0.51,  0.5, 20,  1.05, 1.02,  0.7, 2.5,  1.0 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("single","061")},        400,   1.1,   0.80, 0.19, 0.51,  0.5, 20,  1.05, 1.02,  0.7, 2.5,  1.0 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("single","071")},        400,   1.1,   0.80, 0.19, 0.51,  0.5, 20,  1.05, 1.02,  0.7, 2.5,  1.0 } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                       		     100,   0.2,   0.05, 0.0,   0.05,  0.0,  0,  0.0, 0.0,  0.0, 0.0,  0.0 }

--[[
grp_id = grp_id+1 -- few fluffy 1
__cloud_db[grp_id] = {}            --  n  alti  radius  a     b
__cloud_db[grp_id]["info"]        = { 15,  800, 3000,   0.34, 0.4 }
__cloud_db[grp_id]["info"]["rnd"] = {  0,  0,   1300,   0,    0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file			  		  size, ratio, opac  FL     FLDC   BLM  BLE  BLOM BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("near","n4")},         1000, 1.5,   0.70, 0.07,  0.55,  1.0, 20,  1.0, 1.0,  1.0, 2.5,  1.0 } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                        		    300, 0.1,   0.0,  0.0,   0.0,   0.0,  0,  0.0, 0.0,  0.0, 0.0,  0.0 }
]]

grp_id = grp_id+1 -- few fluffy 2
__cloud_db[grp_id] = {}            --  n  alti  radius  a     b
__cloud_db[grp_id]["info"]        = { 15,  950, 3000,   0.34, 0.4 }
__cloud_db[grp_id]["info"]["rnd"] = {  2,  100, 1000,   0,    0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file			  		  size, ratio, opac  FL     FLDC   BLM  BLE  BLOM BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("near","n1")},         3000, 1.2,   0.80, 0.25,  0.60,  1.0, 20,  1.0, 0.9,  0.7, 2.5,  0.95 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("near","n2")},         3000, 1.1,   0.95, 0.28,  0.60,  1.3, 20, 1.02, 0.7,  1.0, 2.5,  1.0 } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                        		    300, 0.1,   0.0,  0.0,   0.0,   0.0,  0,  0.0, 0.0,  0.0, 0.0,  0.0 }



grp_id = grp_id+1 --broken fluffy
__cloud_db[grp_id] = {}            --  n  alti radius  a    b
__cloud_db[grp_id]["info"]        = { 12, 800,  3000,  0.5, 0.7 }
__cloud_db[grp_id]["info"]["rnd"] = {  3, 100,  1000,    0,   0 }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file			  		   size, ratio, opac  FL     FLDC   BLM  BLE  BLOM BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("near","n7")},         800,   3.1,   0.80, 0.10, 0.55,  0.8, 20, 1.00, 1.0,  0.5, 2.5,  0.90 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("near","n71")},        400,   2.1,   0.80, 0.10, 0.55,  0.8, 20, 1.00, 1.0,  0.5, 2.5,  0.90 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("near","n72")},        500,   1.9,   0.80, 0.10, 0.55,  0.8, 20, 1.00, 1.0,  0.5, 2.5,  0.90 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("near","n73")},        400,   2.0,   0.80, 0.10, 0.55,  0.8, 20, 1.00, 1.0,  0.5, 2.5,  0.90 } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                     			    50,  0.50,   0.05,  0.0, 0.0,   0.0,  0,  0.0, 0.0,  0.0, 0.0,  0.0 }


grp_id = grp_id+1 -- small single overcast adds
__cloud_db[grp_id] = {}            --  n  alti radius  a    b
__cloud_db[grp_id]["info"]        = { 40, 500, 3000,   0.71, 0.79 }
__cloud_db[grp_id]["info"]["rnd"] = {  5, 100, 1500,   0,   0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --          file			   			 size, ratio, opac  FL     FLDC   BLM  BLE  BLOM BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("single","011")},        750,   1.7,   1.00, 0.04, 0.45,  0.7, 10,  1.0, 1.0,  0.7, 2.5,  0.9 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("single","021")},        600,   1.4,   1.00, 0.04, 0.45,  0.7, 10,  1.0, 1.0,  0.7, 2.5,  0.9 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("single","031")},        400,   1.4,   1.00, 0.04, 0.45,  0.7, 10,  1.0, 1.0,  0.7, 2.5,  0.9 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("single","041")},        750,   1.4,   1.00, 0.04, 0.45,  0.7, 10,  1.0, 1.0,  0.7, 2.5,  0.9 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("single","051")},        750,   1.4,   1.00, 0.04, 0.45,  0.7, 10,  1.0, 1.0,  0.7, 2.5,  0.9 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("single","061")},        400,   1.4,   1.00, 0.04, 0.45,  0.7, 10,  1.0, 1.0,  0.7, 2.5,  0.9 } n=n+1
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("single","071")},        400,   1.4,   1.00, 0.04, 0.45,  0.7, 10,  1.0, 1.0,  0.7, 2.5,  0.9 } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                       		     100,   0.2,   0.05, 0.0,   0.05,  0.0,  0,  0.0, 0.0,  0.0, 0.0,  0.0 }




grp_id = grp_id+1 -- heavy
__cloud_db[grp_id] = {}            --  n  alti radius  a    b
__cloud_db[grp_id]["info"]        = {  6, 900, 2000,   0.6, 0.7499 }
__cloud_db[grp_id]["info"]["rnd"] = {  2, 100,  500,   0,   0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file					   size, ratio, opac  FL     FLDC   BLM  BLE  BLOM  BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("near","n1")},         3000, 1.1,   0.90, 0.21,  0.60,  1.3, 10,  1.03, 0.1,  0.5, 2.5,  0.95 } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                        		   500,  0.1,   0.0,  0.0,   0.0,   0.0,  0,  0.0,  0.0,  0.0, 0.0,  0.05  }


grp_id = grp_id+1 -- heavy overcast
__cloud_db[grp_id] = {}            --  n  alti radius  a    b
__cloud_db[grp_id]["info"]        = {  2, 900, 2000,   0.75, 0.7999 }
__cloud_db[grp_id]["info"]["rnd"] = {  1, 100,  200,   0,   0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file					   size, ratio, opac  FL     FLDC   BLM  BLE  BLOM  BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("near","n1")},         4000, 1.4,   0.80, 0.20,  0.60,  0.5, 10,  1.02, 0.1,  0.5, 2.5,  0.9 } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                        		   500,  0.3,   0.0,  0.0,   0.0,   0.0,  0,  0.0,  0.0,  0.0, 0.0,  0.05  }


grp_id = grp_id+1 -- heavy overcast
__cloud_db[grp_id] = {}            --  n  alti radius  a    b
__cloud_db[grp_id]["info"]        = {  6, 900, 2000,   0.8, 0.9 }
__cloud_db[grp_id]["info"]["rnd"] = {  2, 100,  200,   0,   0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file					   size, ratio, opac  FL     FLDC   BLM  BLE  BLOM  BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("near","n1")},         4000, 1.3,   0.90, 0.30,  0.50,  1.3, 10,  1.02, 0.1,  1.0, 2.5,  0.6 } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                        		   500,  0.1,   0.0,  0.0,   0.0,   0.0,  0,  0.0,  0.0,  0.0, 0.0,  0.05  }


grp_id = grp_id+1 -- heavy overcast
__cloud_db[grp_id] = {}            --  n  alti radius  a    b
__cloud_db[grp_id]["info"]        = {  6, 900, 2000,   0.91, 1.0 }
__cloud_db[grp_id]["info"]["rnd"] = {  2, 100,  200,   0,   0   }

__cloud_db[grp_id]["clouds"] = {} n=1 --         file					   size, ratio, opac  FL     FLDC   BLM  BLE  BLOM  BLOE  SP   SE
__cloud_db[grp_id]["clouds"][n] = { {file=cloud_loc("near","n1")},         2700, 1.3,   0.80, 0.30,  0.60,  1.3, 10,  1.02, 0.1,  1.0, 2.5,  0.2 } n=n+1

__cloud_db[grp_id]["clouds"]["rnd"] = { 0,                        		   500,  0.1,   0.0,  0.0,   0.0,   0.0,  0,  0.0,  0.0,  0.0, 0.0,  0.05  }








