import json
import sys
import os

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

recs = [
  {
    "word": "Kuwait",
    "category": "geography_places",
    "subcategory": "Middle East",
    "difficulty": "medium",
    "description": "A small oil-rich monarchy on the Persian Gulf coast with a modern capital city.",
    "tags": ["geography", "middle-east", "country"],
    "hints": {
      "easy": ["Oil wealth", "Gulf state", "Desert nation", "Pearl diving", "Modern skyline", "Towers landmark"],
      "medium": ["Constitutional emirate", "Oil reserves", "Pearl history", "Gulf war site", "Arab league member", "Landmark towers"],
      "hard": ["Sheikhdom rule", "Petroleum economy", "Failaka island", "Subhan region", "Non-OPEC exporter", "Diplomatic mediator"]
    },
    "imposters": {
      "easy": ["Qatar", "Bahrain"],
      "medium": ["Oman", "UAE"],
      "hard": ["Jordan", "Lebanon"]
    }
  },
  {
    "word": "Tunisia",
    "category": "geography_places",
    "subcategory": "North Africa",
    "difficulty": "medium",
    "description": "A Mediterranean nation in North Africa known for ancient Carthage ruins and coastal towns.",
    "tags": ["geography", "africa", "mediterranean"],
    "hints": {
      "easy": ["Carthage ruins", "Mediterranean coast", "Olive oil", "Jasmine flower", "North Africa", "Desert south"],
      "medium": ["Arab spring birth", "Phoenician colony", "Roman amphitheater", "Sahara gateway", "Capital city", "Blue white towns"],
      "hard": ["Hannibal barca", "Byrsa hill", "El jem colosseum", "Medina quarters", "Kairouan mosque", "Berber culture"]
    },
    "imposters": {
      "easy": ["Morocco", "Algeria"],
      "medium": ["Libya", "Egypt"],
      "hard": ["Malta", "Sicily"]
    }
  },
  {
    "word": "Sudan",
    "category": "geography_places",
    "subcategory": "North Africa",
    "difficulty": "medium",
    "description": "A vast Northeast African nation where the Blue and White Nile rivers meet at its capital.",
    "tags": ["geography", "africa", "nile"],
    "hints": {
      "easy": ["Nile confluence", "Khartoum capital", "Pyramids ancient", "Desert land", "Red Sea coast", "Arabic speaking"],
      "medium": ["Nubian kingdom", "Meroe pyramids", "Gum arabic", "Western region", "Two Nile rivers", "Islamic culture"],
      "hard": ["Kerma culture", "Kushite rulers", "Sennar dam", "Gezeira scheme", "Hajj route", "Red sea hills"]
    },
    "imposters": {
      "easy": ["Egypt", "Chad"],
      "medium": ["Ethiopia", "Libya"],
      "hard": ["Eritrea", "Darfur"]
    }
  },
  {
    "word": "Rwanda",
    "category": "geography_places",
    "subcategory": "East Africa",
    "difficulty": "medium",
    "description": "A small landlocked East African nation known for mountain gorillas and rolling green hills.",
    "tags": ["geography", "africa", "wildlife"],
    "hints": {
      "easy": ["Mountain gorillas", "Thousand hills", "Kigali capital", "Tea coffee", "Clean streets", "Safe tourism"],
      "medium": ["Volcanoes park", "Lake Kivu", "Gorilla trekking", "Banana farms", "Community cleaning", "Wildlife recovery"],
      "hard": ["Bisoke volcano", "Akagera park", "Nyungwe forest", "Intore dancers", "Imigongo art", "Native tongue"]
    },
    "imposters": {
      "easy": ["Uganda", "Burundi"],
      "medium": ["Kenya", "Tanzania"],
      "hard": ["Congo", "Malawi"]
    }
  },
  {
    "word": "Zimbabwe",
    "category": "geography_places",
    "subcategory": "Southern Africa",
    "difficulty": "medium",
    "description": "A landlocked southern African nation with ancient stone ruins and dramatic waterfalls.",
    "tags": ["geography", "africa", "ruins"],
    "hints": {
      "easy": ["Victoria Falls", "Ancient ruins", "Harare capital", "Wildlife parks", "Shona people", "Stone walls"],
      "medium": ["Mana pools", "Matobo hills", "Crop export", "Mugabe era", "Lake Kariba", "Eastern highlands"],
      "hard": ["Monomotapa empire", "Zambezi river", "Balancing rocks", "Hwange park", "Chimanimani", "Soapstone birds"]
    },
    "imposters": {
      "easy": ["Zambia", "Botswana"],
      "medium": ["Mozambique", "South Africa"],
      "hard": ["Namibia", "Malawi"]
    }
  },
  {
    "word": "Botswana",
    "category": "geography_places",
    "subcategory": "Southern Africa",
    "difficulty": "medium",
    "description": "A stable southern African democracy with vast wilderness and diamond wealth.",
    "tags": ["geography", "africa", "diamonds"],
    "hints": {
      "easy": ["Okavango delta", "Diamond mines", "Gaborone capital", "Elephant herds", "Kalahari desert", "Stable democracy"],
      "medium": ["Chobe river", "Makgadikgadi pans", "Tsodilo hills", "Cattle ranching", "Bushmen culture", "Wildlife tourism"],
      "hard": ["Moremi reserve", "Mopane worms", "Kgalagadi park", "Tswana people", "Pula currency", "Mining partner"]
    },
    "imposters": {
      "easy": ["Namibia", "Zimbabwe"],
      "medium": ["Zambia", "South Africa"],
      "hard": ["Angola", "Lesotho"]
    }
  },
  {
    "word": "Namibia",
    "category": "geography_places",
    "subcategory": "Southern Africa",
    "difficulty": "medium",
    "description": "A sparsely populated southwestern African nation with towering sand dunes and rugged coast.",
    "tags": ["geography", "africa", "desert"],
    "hints": {
      "easy": ["Sossusvlei dunes", "Skeleton coast", "Etosha pan", "Windhoek capital", "German colonial", "Diamond mining"],
      "medium": ["Desert sands", "Fish river canyon", "Himba people", "Swakopmund town", "Uranium mines", "Cheetah conservation"],
      "hard": ["Kolmanskop ghost", "Welwitschia plant", "Spitzkoppe peaks", "Epupa falls", "Damaraland rock", "Ovambo culture"]
    },
    "imposters": {
      "easy": ["Botswana", "Angola"],
      "medium": ["South Africa", "Zambia"],
      "hard": ["Zimbabwe", "Mozambique"]
    }
  },
  {
    "word": "Senegal",
    "category": "geography_places",
    "subcategory": "West Africa",
    "difficulty": "medium",
    "description": "A West African coastal nation known for vibrant music scene and historic Goree Island.",
    "tags": ["geography", "africa", "music"],
    "hints": {
      "easy": ["Dakar capital", "Goree island", "West Africa", "Music scene", "Peanut farming", "Ocean coast"],
      "medium": ["Wolof language", "Saint Louis", "Pink lake", "Baobab trees", "Mbalax rhythm", "Teranga hospitality"],
      "hard": ["Touba holy city", "Casamance river", "Djoudj birds", "Lebou people", "Thieboudienne dish", "River basin"]
    },
    "imposters": {
      "easy": ["Gambia", "Mali"],
      "medium": ["Ghana", "Guinea"],
      "hard": ["Mauritania", "Cote d'Ivoire"]
    }
  },
  {
    "word": "Cameroon",
    "category": "geography_places",
    "subcategory": "Central Africa",
    "difficulty": "medium",
    "description": "A central African nation with diverse landscapes from rainforest to savanna and volcanic peaks.",
    "tags": ["geography", "africa", "volcanoes"],
    "hints": {
      "easy": ["Active volcano", "Yaounde capital", "Douala port", "Rainforest wildlife", "Bilingual nation", "Mountain peak"],
      "medium": ["Waza park", "Bamenda highlands", "Lake Nyos", "Foumban palace", "Cocoa coffee", "Pygmy forests"],
      "hard": ["Bakossi mountains", "Korup forest", "Dja reserve", "Bamileke chiefs", "Fulani herders", "Limbe gardens"]
    },
    "imposters": {
      "easy": ["Nigeria", "Gabon"],
      "medium": ["Chad", "Congo"],
      "hard": ["CAR", "Equatorial Guinea"]
    }
  },
  {
    "word": "Ecuador",
    "category": "geography_places",
    "subcategory": "South America",
    "difficulty": "medium",
    "description": "A South American nation straddling the equator with Andes peaks and Galapagos islands.",
    "tags": ["geography", "south-america", "equator"],
    "hints": {
      "easy": ["Galapagos islands", "Equator line", "Quito capital", "Andes mountains", "Amazon basin", "Banana export"],
      "medium": ["Cotopaxi volcano", "Cuenca colonial", "Pacific coast", "Cloud forest", "Inca ruins", "Straw hats"],
      "hard": ["Yasuni park", "Mitad del mundo", "Quilotoa lake", "Shuar people", "Oil reserves", "Dollar currency"]
    },
    "imposters": {
      "easy": ["Peru", "Colombia"],
      "medium": ["Bolivia", "Chile"],
      "hard": ["Venezuela", "Costa Rica"]
    }
  },
  {
    "word": "Uruguay",
    "category": "geography_places",
    "subcategory": "South America",
    "difficulty": "medium",
    "description": "A small South American nation known for progressive policies and Atlantic beaches.",
    "tags": ["geography", "south-america", "progressive"],
    "hints": {
      "easy": ["Montevideo capital", "Punta del este", "Beef export", "Mate drinking", "Atlantic coast", "Stable democracy"],
      "medium": ["Colonia del sacramento", "Gaucho culture", "Tango music", "Carnival parade", "Renewable energy", "Literacy rate"],
      "hard": ["Cerro Arequita", "Cabo Polonio", "Quebrada de los cuervos", "Red drink", "Chivito sandwich", "Candombe drums"]
    },
    "imposters": {
      "easy": ["Argentina", "Paraguay"],
      "medium": ["Brazil", "Chile"],
      "hard": ["Bolivia", "Suriname"]
    }
  },
  {
    "word": "Paraguay",
    "category": "geography_places",
    "subcategory": "South America",
    "difficulty": "medium",
    "description": "A landlocked South American nation with Guarani culture and massive hydroelectric dams.",
    "tags": ["geography", "south-america", "landlocked"],
    "hints": {
      "easy": ["Asuncion capital", "Guarani language", "Itaipu dam", "Landlocked nation", "Yerba mate", "Chaco region"],
      "medium": ["Parana river", "Jesuit missions", "Cerro Cora park", "Mennonite colonies", "Terere drink", "Guarani aquifer"],
      "hard": ["Ybyturuzu hills", "Pantanal wetlands", "Chaco war site", "Nanduti lace", "Corn cake", "Ache people"]
    },
    "imposters": {
      "easy": ["Uruguay", "Bolivia"],
      "medium": ["Argentina", "Brazil"],
      "hard": ["Peru", "Chile"]
    }
  },
  {
    "word": "Panama",
    "category": "geography_places",
    "subcategory": "Central America",
    "difficulty": "medium",
    "description": "A Central American isthmus nation famous for its canal connecting two oceans.",
    "tags": ["geography", "central-america", "canal"],
    "hints": {
      "easy": ["Famous canal", "Capital city", "Two oceans", "Straw hat", "Darien gap", "Dollar economy"],
      "medium": ["Miraflores locks", "Casco Viejo", "Bocas del toro", "San Blas islands", "Kuna people", "Rainforest bridge"],
      "hard": ["Canal expansion", "Coiba park", "Volcan Baru", "Embera villages", "Golden frog", "Trans-isthmian railroad"]
    },
    "imposters": {
      "easy": ["Costa Rica", "Colombia"],
      "medium": ["Nicaragua", "Guatemala"],
      "hard": ["Honduras", "El Salvador"]
    }
  },
  {
    "word": "Costa Rica",
    "category": "geography_places",
    "subcategory": "Central America",
    "difficulty": "medium",
    "description": "A peaceful Central American nation with no army and incredible biodiversity in cloud forests.",
    "tags": ["geography", "central-america", "nature"],
    "hints": {
      "easy": ["No military", "Cloud forests", "San Jose capital", "Biodiversity", "Volcanoes", "Pacific Caribbean"],
      "medium": ["Arenal volcano", "Monteverde reserve", "Tortuguero turtles", "Pura vida", "Coffee export", "Ecotourism leader"],
      "hard": ["Corcovado park", "Poas crater", "Bribri people", "Oxcart tradition", "Stone spheres", "Renewable energy"]
    },
    "imposters": {
      "easy": ["Panama", "Nicaragua"],
      "medium": ["Guatemala", "Honduras"],
      "hard": ["El Salvador", "Belize"]
    }
  },
  {
    "word": "Guatemala",
    "category": "geography_places",
    "subcategory": "Central America",
    "difficulty": "medium",
    "description": "A Central American nation with ancient Mayan ruins and towering volcanoes near colonial cities.",
    "tags": ["geography", "central-america", "mayan"],
    "hints": {
      "easy": ["Tikal ruins", "Active volcanoes", "Antigua colonial", "Mayan culture", "Lake Atitlan", "Colorful textiles"],
      "medium": ["Pacaya volcano", "Chichicastenango", "Quetzal bird", "Coffee highlands", "Livingston garifuna", "Semuc champey"],
      "hard": ["El Mirador", "Iximche ruins", "Maximon saint", "Jade museum", "Kaqchikel language", "Pacific slope"]
    },
    "imposters": {
      "easy": ["Honduras", "Mexico"],
      "medium": ["Belize", "El Salvador"],
      "hard": ["Nicaragua", "Costa Rica"]
    }
  },
  {
    "word": "Honduras",
    "category": "geography_places",
    "subcategory": "Central America",
    "difficulty": "medium",
    "description": "A Central American nation with Caribbean coral reefs and ancient Mayan ceremonial centers.",
    "tags": ["geography", "central-america", "reefs"],
    "hints": {
      "easy": ["Copan ruins", "Bay Islands", "Caribbean reef", "Tegucigalpa capital", "Banana history", "Mosquito coast"],
      "medium": ["Roatan diving", "Pico Bonito", "Lenca people", "Coffee mountains", "Garifuna culture", "Rio Platano"],
      "hard": ["Comayagua clocks", "Celaque peak", "Miskito coast", "Yojoa lake", "Talanga valley", "Paya ruins"]
    },
    "imposters": {
      "easy": ["Guatemala", "Nicaragua"],
      "medium": ["Belize", "El Salvador"],
      "hard": ["Costa Rica", "Mexico"]
    }
  },
  {
    "word": "Haiti",
    "category": "geography_places",
    "subcategory": "Caribbean",
    "difficulty": "medium",
    "description": "A Caribbean nation sharing Hispaniola island with vibrant Creole culture and mountain terrain.",
    "tags": ["geography", "caribbean", "creole"],
    "hints": {
      "easy": ["Port-au-Prince", "Hispaniola island", "Voodoo culture", "Mountainous land", "French Creole", "Art naive style"],
      "medium": ["Citadelle fortress", "Jacmel carnival", "Bassin bleu", "Kreyol language", "Iron market", "Coffee export"],
      "hard": ["Sans Souci palace", "Pic la Selle", "Gonave island", "Rara festival", "Local art", "Dessalines leader"]
    },
    "imposters": {
      "easy": ["Cuba", "Jamaica"],
      "medium": ["Dominican Republic", "Bahamas"],
      "hard": ["Puerto Rico", "Turks Caicos"]
    }
  },
  {
    "word": "Bahamas",
    "category": "geography_places",
    "subcategory": "Caribbean",
    "difficulty": "easy",
    "description": "An Atlantic archipelago of over seven hundred islands known for pink sand and clear waters.",
    "tags": ["geography", "caribbean", "islands"],
    "hints": {
      "easy": ["Nassau capital", "Pink sand", "Crystal water", "Island chain", "Tourism hub", "Pirate history"],
      "medium": ["Exuma pigs", "Blue holes", "Andros barrier", "Junkanoo festival", "Conch salad", "Loyalist heritage"],
      "hard": ["Lucayan parks", "Dean's blue hole", "Inagua flamingos", "Cat Island", "Ragged islands", "Acklins crooked"]
    },
    "imposters": {
      "easy": ["Jamaica", "Bermuda"],
      "medium": ["Cuba", "Turks Caicos"],
      "hard": ["Haiti", "Dominican Republic"]
    }
  },
  {
    "word": "Barbados",
    "category": "geography_places",
    "subcategory": "Caribbean",
    "difficulty": "easy",
    "description": "An eastern Caribbean island nation with British heritage and world-class rum distilleries.",
    "tags": ["geography", "caribbean", "british"],
    "hints": {
      "easy": ["Bridgetown capital", "Flying fish", "Cricket sport", "British colony", "Coral limestone", "Sugar cane"],
      "medium": ["Harrison cave", "Oistins fry", "Crop over festival", "Green monkey", "St Nicholas abbey", "East coast surf"],
      "hard": ["Morgan Lewis mill", "Animal flower", "Bathsheba soup", "Chattel houses", "Cou cou dish", "Historic brand"]
    },
    "imposters": {
      "easy": ["Jamaica", "Trinidad"],
      "medium": ["Bahamas", "Grenada"],
      "hard": ["St Lucia", "Antigua"]
    }
  },
  {
    "word": "Lithuania",
    "category": "geography_places",
    "subcategory": "Europe",
    "difficulty": "medium",
    "description": "A Baltic nation with medieval castles and amber coast that regained independence in 1990.",
    "tags": ["geography", "europe", "baltic"],
    "hints": {
      "easy": ["Vilnius capital", "Baltic state", "Amber coast", "Hill of crosses", "Trakai castle", "Euro currency"],
      "medium": ["Curonian spit", "Klaipeda port", "Basketball passion", "Cepelinai dumplings", "Soviet resistance", "Medieval old town"],
      "hard": ["Aukstaitija lakes", "Zemaitija culture", "Kernave mounds", "Rumsiskes museum", "Native tongue", "Singing revolution"]
    },
    "imposters": {
      "easy": ["Latvia", "Estonia"],
      "medium": ["Poland", "Belarus"],
      "hard": ["Finland", "Sweden"]
    }
  },
  {
    "word": "Latvia",
    "category": "geography_places",
    "subcategory": "Europe",
    "difficulty": "medium",
    "description": "A Baltic nation with Art Nouveau architecture and dense forests covering half its territory.",
    "tags": ["geography", "europe", "baltic"],
    "hints": {
      "easy": ["Riga capital", "Art nouveau", "Baltic coast", "Amber jewelry", "Medieval guilds", "Song festival"],
      "medium": ["Gauja park", "Jurmala beach", "Rundale palace", "Daugava river", "Livonian coast", "Black balsam"],
      "hard": ["Kuldiga ventas", "Cesis castle", "Latgale ceramics", "Koknese ruins", "Dainas folk songs", "Sigulda bobsleigh"]
    },
    "imposters": {
      "easy": ["Lithuania", "Estonia"],
      "medium": ["Finland", "Russia"],
      "hard": ["Poland", "Sweden"]
    }
  },
  {
    "word": "Estonia",
    "category": "geography_places",
    "subcategory": "Europe",
    "difficulty": "medium",
    "description": "A digital-savvy Baltic nation with medieval Tallinn and thousands of islands in the Baltic Sea.",
    "tags": ["geography", "europe", "digital"],
    "hints": {
      "easy": ["Tallinn medieval", "Digital nation", "Baltic islands", "Skype birthplace", "Sauna culture", "Euro adopter"],
      "medium": ["Lahemaa park", "Saaremaa island", "Song grounds", "E-residency", "Viru bog", "Krenholm textile"],
      "hard": ["Seto polyphony", "Võru dialect", "Kihnu skirts", "Muhu patterns", "Hiiumaa lighthouse", "Narva fortress"]
    },
    "imposters": {
      "easy": ["Latvia", "Finland"],
      "medium": ["Lithuania", "Russia"],
      "hard": ["Poland", "Sweden"]
    }
  },
  {
    "word": "Slovakia",
    "category": "geography_places",
    "subcategory": "Europe",
    "difficulty": "medium",
    "description": "A central European nation with High Tatra peaks and medieval towns preserving folk traditions.",
    "tags": ["geography", "europe", "mountains"],
    "hints": {
      "easy": ["Bratislava capital", "High Tatras", "Castles hilltops", "Folk costumes", "Euro currency", "Danube river"],
      "medium": ["Spis castle", "Slovak paradise", "Orava castle", "Wooden churches", "Sheep cheese", "Caves dripstone"],
      "hard": ["Gerlachovsky peak", "Vlkolinec village", "Dobsinska ice", "Wine region", "Fujara flute", "Cyril methodius"]
    },
    "imposters": {
      "easy": ["Czechia", "Hungary"],
      "medium": ["Slovenia", "Austria"],
      "hard": ["Poland", "Ukraine"]
    }
  },
  {
    "word": "Slovenia",
    "category": "geography_places",
    "subcategory": "Europe",
    "difficulty": "medium",
    "description": "A small Alpine nation with emerald lakes and limestone caves at the crossroads of Europe.",
    "tags": ["geography", "europe", "alpine"],
    "hints": {
      "easy": ["Lake Bled", "Ljubljana capital", "Julian Alps", "Postojna cave", "Green destination", "Bee keeping"],
      "medium": ["Triglav peak", "Piran coastal", "Skocjan caves", "Lipica horses", "Potica cake", "Vineyard areas"],
      "hard": ["Soča river", "Kranjska klobasa", "Idrija mercury", "Ptuj oldest", "Kurent carnival", "Predjama castle"]
    },
    "imposters": {
      "easy": ["Croatia", "Slovakia"],
      "medium": ["Austria", "Italy"],
      "hard": ["Hungary", "Czechia"]
    }
  },
  {
    "word": "Serbia",
    "category": "geography_places",
    "subcategory": "Europe",
    "difficulty": "medium",
    "description": "A Balkan nation with vibrant Belgrade nightlife and medieval monasteries dotting its hills.",
    "tags": ["geography", "europe", "balkan"],
    "hints": {
      "easy": ["Belgrade fortress", "Danube Sava", "Orthodox faith", "Fruit brandy", "Medieval monasteries", "Exit festival"],
      "medium": ["Novi Sad", "Derdap gorge", "Tara mountain", "Zlatibor resort", "Viminacium ruins", "Kafana culture"],
      "hard": ["Studenica fresco", "Golubac fortress", "Uvac meanders", "Vojvodina plains", "Morava valley", "Nemanjic dynasty"]
    },
    "imposters": {
      "easy": ["Croatia", "Bosnia"],
      "medium": ["Bulgaria", "Montenegro"],
      "hard": ["Romania", "Hungary"]
    }
  },
  {
    "word": "Bulgaria",
    "category": "geography_places",
    "subcategory": "Europe",
    "difficulty": "medium",
    "description": "A Balkan nation with Black Sea coast and ancient Thracian gold treasures in mountain valleys.",
    "tags": ["geography", "europe", "balkan"],
    "hints": {
      "easy": ["Sofia capital", "Rose valleys", "Yogurt origin", "Cyrillic script", "Thracian gold", "Sea coast"],
      "medium": ["Rila monastery", "Plovdiv ancient", "Pirin peaks", "Nessebar peninsula", "Kazanluk roses", "Banitsa pastry"],
      "hard": ["Belogradchik rocks", "Srebarna pelicans", "Madara rider", "Shipka pass", "Tryavna woodcarving", "Koprivshtitsa revival"]
    },
    "imposters": {
      "easy": ["Romania", "Serbia"],
      "medium": ["Greece", "Turkey"],
      "hard": ["North Macedonia", "Moldova"]
    }
  },
  {
    "word": "Albania",
    "category": "geography_places",
    "subcategory": "Europe",
    "difficulty": "medium",
    "description": "A Balkan nation with Adriatic beaches and Ottoman-era towns rising from communist isolation.",
    "tags": ["geography", "europe", "balkan"],
    "hints": {
      "easy": ["Tirana capital", "Adriatic coast", "Bunkers everywhere", "Eagle flag", "Skanderbeg hero", "Riviera beaches"],
      "medium": ["Berat windows", "Gjirokaster stone", "Butrint ruins", "High mountains", "Besa honor code", "Raki spirit"],
      "hard": ["Kruja castle", "Valbona valley", "Theth village", "Ohrid lake share", "Iso polyphony", "Enver Hoxha pyramid"]
    },
    "imposters": {
      "easy": ["Greece", "Kosovo"],
      "medium": ["Montenegro", "North Macedonia"],
      "hard": ["Italy", "Croatia"]
    }
  },
  {
    "word": "Montenegro",
    "category": "geography_places",
    "subcategory": "Europe",
    "difficulty": "medium",
    "description": "A tiny Adriatic nation with fjord-like bay and rugged mountains rising from the sea.",
    "tags": ["geography", "europe", "adriatic"],
    "hints": {
      "easy": ["Kotor bay", "Podgorica capital", "Black mountain", "Adriatic coast", "Durmitor peaks", "Euro user"],
      "medium": ["Sveti Stefan", "Tara canyon", "Ostrog monastery", "Lovcen mausoleum", "Skadar lake", "Njegos poet"],
      "hard": ["Prokletije range", "Biogradska forest", "Perast islands", "Cetinje royal", "Plav gusinje", "Boka kotorska"]
    },
    "imposters": {
      "easy": ["Albania", "Croatia"],
      "medium": ["Serbia", "Bosnia"],
      "hard": ["Italy", "Slovenia"]
    }
  },
  {
    "word": "Cyprus",
    "category": "geography_places",
    "subcategory": "Europe",
    "difficulty": "medium",
    "description": "An eastern Mediterranean island divided between Greek south and Turkish north since 1974.",
    "tags": ["geography", "europe", "mediterranean"],
    "hints": {
      "easy": ["Nicosia divided", "Aphrodite birthplace", "Halloumi cheese", "Mediterranean island", "Troodos mountains", "Ancient ruins"],
      "medium": ["Kyrenia harbor", "Paphos mosaics", "Famagusta ghost", "Larnaca salt", "Sweet wine", "Lefkara lace"],
      "hard": ["Akamas peninsula", "Choirokoitia neolithic", "Kourion theater", "Stavrovouni monastery", "Omodos village", "Avakas gorge"]
    },
    "imposters": {
      "easy": ["Greece", "Malta"],
      "medium": ["Turkey", "Lebanon"],
      "hard": ["Israel", "Syria"]
    }
  },
  {
    "word": "Malta",
    "category": "geography_places",
    "subcategory": "Europe",
    "difficulty": "medium",
    "description": "A tiny Mediterranean archipelago with megalithic temples older than Egyptian pyramids.",
    "tags": ["geography", "europe", "temples"],
    "hints": {
      "easy": ["Valletta capital", "Megalithic temples", "Blue lagoon", "Knights hospitaller", "Mediterranean islands", "Maltese cross"],
      "medium": ["Mdina silent city", "Gozo island", "Hypogeum underground", "Marsaxlokk luzzu", "Festa fireworks", "Pastizzi snack"],
      "hard": ["Ggantija temples", "Hagar Qim", "Mnajdra aligned", "Dingli cliffs", "Comino blue", "Xewkija rotunda"]
    },
    "imposters": {
      "easy": ["Cyprus", "Sicily"],
      "medium": ["Greece", "Italy"],
      "hard": ["Tunisia", "Spain"]
    }
  },
  {
    "word": "Luxembourg",
    "category": "geography_places",
    "subcategory": "Europe",
    "difficulty": "medium",
    "description": "A tiny wealthy duchy nestled between France Germany and Belgium with medieval fortifications.",
    "tags": ["geography", "europe", "duchy"],
    "hints": {
      "easy": ["Grand duchy", "Three borders", "Banking center", "Medieval casemates", "Vianden castle", "Mullerthal trails"],
      "medium": ["Capital city", "Schengen village", "Steel industry", "Euro founder", "Trilingual nation", "River valley"],
      "hard": ["Bock casemates", "Grund district", "Echternach abbey", "Clervaux castle", "Red lion symbol", "G.D. Charlotte"]
    },
    "imposters": {
      "easy": ["Belgium", "Monaco"],
      "medium": ["Liechtenstein", "Netherlands"],
      "hard": ["Switzerland", "Andorra"]
    }
  },
  {
    "word": "Monaco",
    "category": "geography_places",
    "subcategory": "Europe",
    "difficulty": "easy",
    "description": "A glamorous city-state on the French Riviera famous for its casino and Formula One race.",
    "tags": ["geography", "europe", "city-state"],
    "hints": {
      "easy": ["Monte Carlo", "Casino famous", "Formula One", "Prince palace", "Tax haven", "Mediterranean coast"],
      "medium": ["Grimaldi family", "Oceanographic museum", "Exotic garden", "Larvotto beach", "Yacht harbor", "National day"],
      "hard": ["Port Hercules", "Fontvieille land", "Opera Garnier", "Rose ball", "Carabiniers guard", "Saint Devote"]
    },
    "imposters": {
      "easy": ["Luxembourg", "Andorra"],
      "medium": ["San Marino", "Liechtenstein"],
      "hard": ["Vatican", "Malta"]
    }
  },
  {
    "word": "Vatican",
    "category": "geography_places",
    "subcategory": "Europe",
    "difficulty": "easy",
    "description": "The world's smallest sovereign state serving as spiritual center of the Catholic Church.",
    "tags": ["geography", "europe", "religion"],
    "hints": {
      "easy": ["Pope residence", "St Peter's", "Sistine Chapel", "Tiny state", "Swiss Guards", "Holy See"],
      "medium": ["Museums art", "Raphael rooms", "Bernini colonnade", "Castel Gandolfo", "Latin language", "Pontifical academy"],
      "hard": ["Apostolic palace", "Library archives", "Lateran treaty", "Obelisk square", "Gregorian chant", "Secret archives"]
    },
    "imposters": {
      "easy": ["Monaco", "Malta"],
      "medium": ["San Marino", "Liechtenstein"],
      "hard": ["Luxembourg", "Andorra"]
    }
  },
  {
    "word": "Andorra",
    "category": "geography_places",
    "subcategory": "Europe",
    "difficulty": "medium",
    "description": "A Pyrenean principality between France and Spain known for ski resorts and duty-free shopping.",
    "tags": ["geography", "europe", "pyrenees"],
    "hints": {
      "easy": ["Capital city", "Pyrenees mountains", "Ski resorts", "Duty free", "Co-princes rule", "Catalan speaking"],
      "medium": ["Vallnord slopes", "Caldea spa", "Romanesque churches", "Tobacco history", "Hiking trails", "Euro user"],
      "hard": ["Madriu valley", "Ordino valley", "Sant Joan de caselles", "Roc del quer", "Encamp parish", "La Massana"]
    },
    "imposters": {
      "easy": ["Monaco", "Liechtenstein"],
      "medium": ["Luxembourg", "San Marino"],
      "hard": ["Switzerland", "Malta"]
    }
  },
  {
    "word": "Georgia",
    "category": "geography_places",
    "subcategory": "Europe",
    "difficulty": "medium",
    "description": "A Caucasus nation with ancient wine culture and dramatic mountain scenery at Europe's edge.",
    "tags": ["geography", "europe", "caucasus"],
    "hints": {
      "easy": ["Tbilisi capital", "Caucasus mountains", "Ancient wine", "Ancient alphabet", "Khinkali dumplings", "Black Sea coast"],
      "medium": ["Kazbegi peak", "Svaneti towers", "Uplistsikhe cave", "Mtskheta ancient", "Polyphonic singing", "Borjomi water"],
      "hard": ["Vardzia monastery", "Gergeti church", "Tusheti remote", "Kakheti vineyards", "Sighnaghi walls", "Dmanisi fossils"]
    },
    "imposters": {
      "easy": ["Armenia", "Azerbaijan"],
      "medium": ["Turkey", "Russia"],
      "hard": ["Iran", "Ukraine"]
    }
  },
  {
    "word": "Azerbaijan",
    "category": "geography_places",
    "subcategory": "Europe",
    "difficulty": "medium",
    "description": "A Caspian Sea nation with mud volcanoes and modern flame towers lighting its capital.",
    "tags": ["geography", "europe", "caspian"],
    "hints": {
      "easy": ["Baku flames", "Caspian shore", "Mud volcanoes", "Oil wealth", "Silk road", "Carpet weaving"],
      "medium": ["Gobustan petroglyphs", "Shirvanshah palace", "Yanar dag fire", "Absheron peninsula", "Mugham music", "Pomegranate festival"],
      "hard": ["Icheri sheher", "Ateshgah temple", "Khinalug village", "Lahij copper", "Naftalan oil", "Sheki khan palace"]
    },
    "imposters": {
      "easy": ["Georgia", "Armenia"],
      "medium": ["Turkey", "Iran"],
      "hard": ["Russia", "Kazakhstan"]
    }
  },
  {
    "word": "Uzbekistan",
    "category": "geography_places",
    "subcategory": "Central Asia",
    "difficulty": "medium",
    "description": "A Central Asian nation with Silk Road cities showcasing dazzling Islamic architecture in turquoise tiles.",
    "tags": ["geography", "central-asia", "silk-road"],
    "hints": {
      "easy": ["Samarkand Registan", "Bukhara old", "Silk Road", "Blue tiles", "Tashkent capital", "Plov rice dish"],
      "medium": ["Khiva walled", "Shah-i-Zinda", "Bibi Khanym", "Ulugbek observatory", "Chorsu bazaar", "Fergana valley"],
      "hard": ["Itchan kala", "Kalyan minaret", "Bolo hauz mosque", "Sitorai mokhi", "Aral sea tragedy", "Navoi theater"]
    },
    "imposters": {
      "easy": ["Kazakhstan", "Tajikistan"],
      "medium": ["Turkmenistan", "Kyrgyzstan"],
      "hard": ["Afghanistan", "Iran"]
    }
  },
  {
    "word": "Kyrgyzstan",
    "category": "geography_places",
    "subcategory": "Central Asia",
    "difficulty": "hard",
    "description": "A mountainous Central Asian nation where nomadic traditions thrive among Tian Shan peaks.",
    "tags": ["geography", "central-asia", "mountains"],
    "hints": {
      "easy": ["Bishkek capital", "Tian Shan", "Nomadic yurts", "Issyk Kul lake", "Horse culture", "Eagle hunters"],
      "medium": ["Song Kol pasture", "Ala Archa park", "Kochkor village", "Kumis drink", "Felt carpets", "Manas epic"],
      "hard": ["Lenin peak", "Jeti Oguz", "Tash Rabat", "Sary Chelek", "Kyzyl Oi", "Chong Kemin"]
    },
    "imposters": {
      "easy": ["Kazakhstan", "Tajikistan"],
      "medium": ["Uzbekistan", "Mongolia"],
      "hard": ["China", "Afghanistan"]
    }
  },
  {
    "word": "Brunei",
    "category": "geography_places",
    "subcategory": "Southeast Asia",
    "difficulty": "medium",
    "description": "A tiny oil-rich sultanate on Borneo island with pristine rainforest and golden mosques.",
    "tags": ["geography", "southeast-asia", "sultanate"],
    "hints": {
      "easy": ["Bandar Seri Begawan", "Oil sultanate", "Golden mosques", "No tax", "Rainforest intact", "Borneo island"],
      "medium": ["Omar Ali Mosque", "Kampong Ayer", "Ulu Temburong", "Royal regalia", "Water village", "Sharia law"],
      "hard": ["Jame Asr Hassanil", "Tasek Merimbun", "Wasai Wong Kadir", "Bukit Shahbandar", "Mentiri Park", "Tutong district"]
    },
    "imposters": {
      "easy": ["Malaysia", "Singapore"],
      "medium": ["Qatar", "Oman"],
      "hard": ["Indonesia", "Philippines"]
    }
  },
  {
    "word": "Samoa",
    "category": "geography_places",
    "subcategory": "Oceania",
    "difficulty": "medium",
    "description": "A Polynesian island nation with traditional fa'a Samoa culture and volcanic landscapes.",
    "tags": ["geography", "oceania", "polynesian"],
    "hints": {
      "easy": ["Apia capital", "Polynesian culture", "Volcanic islands", "Tattoo tradition", "Coconut cream", "Lava lava cloth"],
      "medium": ["To Sua trench", "Robert Louis Stevenson", "Traditional ways", "Fale houses", "Kava ceremony", "Lalomanu beach"],
      "hard": ["Piula cave pool", "Saleaula lava", "Falealupo canopy", "Native tongue", "Siva afi dance", "Umu earth oven"]
    },
    "imposters": {
      "easy": ["Tonga", "Fiji"],
      "medium": ["Tahiti", "Niue"],
      "hard": ["Tokelau", "Wallis Futuna"]
    }
  },
  {
    "word": "Tonga",
    "category": "geography_places",
    "subcategory": "Oceania",
    "difficulty": "medium",
    "description": "A Polynesian kingdom of 170 islands where ancient monarchy meets tropical paradise.",
    "tags": ["geography", "oceania", "kingdom"],
    "hints": {
      "easy": ["Nuku'alofa capital", "Polynesian kingdom", "Blowholes coast", "Whale watching", "Kava root", "Tapa cloth"],
      "medium": ["Ha'amonga trilithon", "Vava'u sailing", "Eua caves", "Royal palace", "Feast celebrations", "Humpback whales"],
      "hard": ["Niuafo'ou volcano", "Tofua caldera", "Lifuka island", "Southern group", "Central group", "Northern remote"]
    },
    "imposters": {
      "easy": ["Samoa", "Fiji"],
      "medium": ["Vanuatu", "Niue"],
      "hard": ["Tokelau", "Wallis Futuna"]
    }
  },
  {
    "word": "Vanuatu",
    "category": "geography_places",
    "subcategory": "Oceania",
    "difficulty": "medium",
    "description": "A Melanesian archipelago with active volcanoes and unique land-diving ritual on Pentecost.",
    "tags": ["geography", "oceania", "volcanoes"],
    "hints": {
      "easy": ["Port Vila capital", "Active volcanoes", "Land diving", "Melanesian culture", "Y-shape islands", "Blue holes"],
      "medium": ["Yasur volcano", "Espiritu Santo", "Pentecost jump", "Kastom villages", "Kava nakamal", "Champagne beach"],
      "hard": ["Ambrym lava lakes", "Lopevi eruptions", "Malekula masks", "Torba province", "Aneityum mystery", "Efate ring road"]
    },
    "imposters": {
      "easy": ["Fiji", "Samoa"],
      "medium": ["Tonga", "Solomon"],
      "hard": ["New Caledonia", "Papua Guinea"]
    }
  },
  {
    "word": "Greenland",
    "category": "geography_places",
    "subcategory": "North America",
    "difficulty": "medium",
    "description": "The world's largest island covered mostly by ice sheet with Inuit culture under Danish realm.",
    "tags": ["geography", "north-america", "arctic"],
    "hints": {
      "easy": ["Nuuk capital", "Ice sheet", "Inuit culture", "Midnight sun", "Northern lights", "Danish territory"],
      "medium": ["Ilulissat icefjord", "Dog sledding", "Kayak origin", "Musox reindeer", "Thule air base", "Viking ruins"],
      "hard": ["Kangerlussuaq", "Qaqortoq town", "Disko bay", "Eqi glacier", "Narsaq valley", "Uunartoq springs"]
    },
    "imposters": {
      "easy": ["Iceland", "Canada"],
      "medium": ["Norway", "Faroe"],
      "hard": ["Svalbard", "Alaska"]
    }
  },
  {
    "word": "Mauritius",
    "category": "geography_places",
    "subcategory": "Africa",
    "difficulty": "medium",
    "description": "An Indian Ocean island nation with multicultural society and extinct dodo bird legacy.",
    "tags": ["geography", "africa", "indian-ocean"],
    "hints": {
      "easy": ["Port Louis", "Dodo extinct", "Coral reefs", "Sugar cane", "Multicultural", "Tropical beaches"],
      "medium": ["Le Morne mountain", "Black river gorges", "Seven colored earth", "Chamarel waterfall", "Sega dance", "Rum export"],
      "hard": ["Ile aux cerfs", "Ganga Talao", "Pamplemousses garden", "Rodrigues island", "Agalega remote", "Chagos dispute"]
    },
    "imposters": {
      "easy": ["Maldives", "Seychelles"],
      "medium": ["Madagascar", "Reunion"],
      "hard": ["Comoros", "Sri Lanka"]
    }
  },
  {
    "word": "Seychelles",
    "category": "geography_places",
    "subcategory": "Africa",
    "difficulty": "medium",
    "description": "A granitic Indian Ocean archipelago with rare coco de mer palms and giant tortoises.",
    "tags": ["geography", "africa", "granitic"],
    "hints": {
      "easy": ["Victoria capital", "Coco de mer", "Giant tortoises", "Granite islands", "Coral atolls", "Praslin valley"],
      "medium": ["Vallee de mai", "La Digue bicycles", "Aldabra atoll", "Bird island", "Marine parks", "Creole cuisine"],
      "hard": ["Silhouette mountain", "Curieuse tortoises", "Aride seabirds", "Fregate private", "Denis island", "Cosmoledo remote"]
    },
    "imposters": {
      "easy": ["Maldives", "Mauritius"],
      "medium": ["Comoros", "Madagascar"],
      "hard": ["Reunion", "Zanzibar"]
    }
  },
  {
    "word": "United States",
    "category": "geography_places",
    "subcategory": "North America",
    "difficulty": "easy",
    "description": "A vast North American federation of fifty states spanning from Atlantic to Pacific oceans.",
    "tags": ["geography", "north-america", "federation"],
    "hints": {
      "easy": ["Washington DC", "Fifty states", "Statue Liberty", "Grand Canyon", "Hollywood", "NASA space"],
      "medium": ["Yellowstone park", "Mississippi river", "Historic highway", "Silicon Valley", "Broadway shows", "Thanksgiving turkey"],
      "hard": ["Death valley", "Denali peak", "Everglades swamp", "Badlands formations", "Outer banks", "Appalachian trail"]
    },
    "imposters": {
      "easy": ["Canada", "Mexico"],
      "medium": ["Brazil", "Argentina"],
      "hard": ["England", "Australia"]
    }
  },
  {
    "word": "Chad",
    "category": "geography_places",
    "subcategory": "Central Africa",
    "difficulty": "hard",
    "description": "A landlocked Sahel nation with shrinking lake and ancient rock art in Sahara.",
    "tags": ["geography", "africa", "sahel"],
    "hints": {
      "easy": ["N'Djamena capital", "Lake shrinking", "Saharan north", "Sahel zone", "Cotton export", "Camel caravans"],
      "medium": ["Ennedi plateau", "Zakouma park", "Saharan rock art", "Arab nomads", "Chari river", "Oil pipeline"],
      "hard": ["Tibesti mountains", "Emi Koussi", "Guelta Archei", "Wadai sultanate", "Kanem Bornu", "Borkou region"]
    },
    "imposters": {
      "easy": ["Niger", "Sudan"],
      "medium": ["Libya", "Cameroon"],
      "hard": ["Nigeria", "CAR"]
    }
  },
  {
    "word": "Mali",
    "category": "geography_places",
    "subcategory": "West Africa",
    "difficulty": "hard",
    "description": "A West African nation with legendary Timbuktu and river lifeline through Sahel.",
    "tags": ["geography", "africa", "sahel"],
    "hints": {
      "easy": ["Bamako capital", "Timbuktu ancient", "River lifeline", "Salt gold trade", "Djenné mosque", "Desert festivals"],
      "medium": ["Dogon cliffs", "Mopti port", "Saharan salt", "Griot singers", "Bogolan cloth", "Festival desert"],
      "hard": ["Bandiagara escarpment", "Gao ancient", "Kidal region", "Taoudenni salt", "Inland delta", "Songhai empire"]
    },
    "imposters": {
      "easy": ["Niger", "Senegal"],
      "medium": ["Burkina Faso", "Mauritania"],
      "hard": ["Guinea", "Algeria"]
    }
  },
  {
    "word": "Niger",
    "category": "geography_places",
    "subcategory": "West Africa",
    "difficulty": "hard",
    "description": "A vast West African nation mostly covered by Sahara desert with uranium riches beneath.",
    "tags": ["geography", "africa", "sahara"],
    "hints": {
      "easy": ["Niamey capital", "Saharan desert", "Uranium mines", "River basin", "Tuareg nomads", "Hottest nations"],
      "medium": ["Agadez gateway", "W park wildlife", "Air mountains", "Salt caravans", "Hausa culture", "Zinder sultanate"],
      "hard": ["Termit tin toumma", "Gadoufaoua dinosaurs", "Koure giraffes", "Bilma oasis", "Diffa region", "Maradi trade"]
    },
    "imposters": {
      "easy": ["Mali", "Chad"],
      "medium": ["Nigeria", "Burkina Faso"],
      "hard": ["Algeria", "Libya"]
    }
  },
  {
    "word": "Angola",
    "category": "geography_places",
    "subcategory": "Southern Africa",
    "difficulty": "medium",
    "description": "A southern African nation with oil wealth and Portuguese heritage rebuilding from civil war.",
    "tags": ["geography", "africa", "oil"],
    "hints": {
      "easy": ["Luanda capital", "Oil diamonds", "Portuguese speaking", "Kalandula falls", "Kissama park", "Atlantic coast"],
      "medium": ["Namib desert north", "Okavango source", "Tundavala gap", "Cuanza river", "Muxima sanctuary", "Cabinda exclave"],
      "hard": ["Serra da Leba", "Iona desert", "Cameia park", "Lunda norte", "Cuando cubango", "Huambo highlands"]
    },
    "imposters": {
      "easy": ["Namibia", "Zambia"],
      "medium": ["DRC", "Congo"],
      "hard": ["Botswana", "Zimbabwe"]
    }
  }
]

any_err = False
for r in recs:
    errs, warns = W.validate_record(r, cats, lists)
    if errs:
        print('FAIL:', r['word'], 'errs:', errs, 'warns:', warns)
        any_err = True
    elif warns:
        print('WARN:', r['word'], 'warns:', warns)

if not any_err:
    print('ALL PASSED!')
    out_dir = r'C:\Users\badam\Desktop\hush\tool\words\replies'
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, '002_countries.json')
    with open(out_path, 'w', encoding='utf8') as f:
        json.dump(recs, f, indent=2, ensure_ascii=False)
    print('Wrote', out_path)
else:
    print('ERRORS - file not written')