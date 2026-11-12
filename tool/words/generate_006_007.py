#!/usr/bin/env python3
"""Generate valid 006_places.json and 007_places.json records"""

import json
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'tool', 'words'))
import wordlib as W


# Helper to create a valid record
def make_record(word, subcategory, difficulty, description, tags, hints, imposters):
    """Create a record dictionary"""
    return {
        "word": word,
        "category": "geography_places",
        "subcategory": subcategory,
        "difficulty": difficulty,
        "description": description,
        "tags": tags,
        "hints": hints,
        "imposters": imposters
    }


# Records for 006_places - 50 records
RECORDS_006 = [
    make_record("Jungle camp", "Outdoor lodging", "medium",
        "A temporary outdoor shelter in dense forest for resting during expeditions.",
        ["outdoors", "camping", "adventure"],
        {
            "easy": ["Machete", "Mosquito net", "Hammock", "Wild sounds", "Tarps", "Explorer"],
            "medium": ["Canopy shade", "Sleeping bag", "Adventure trip", "Expedition gear", "Humid air", "Field research"],
            "hard": ["Overnight bivouac", "Machete path", "Research site", "Tropical night", "Survival gear", "Camp setup"]
        },
        {
            "easy": ["Campsite", "Safari lodge"],
            "medium": ["Treehouse", "Cabin"],
            "hard": ["Outpost", "Forward base"]
        }
    ),

    make_record("Treehouse", "Outdoor lodging", "easy",
        "A small structure built among tree branches for play or relaxation.",
        ["outdoors", "play", "nature"],
        {
            "easy": ["Climbing ladder", "Branches", "Hideout", "Backyard", "Kids playing", "Wooden platform"],
            "medium": ["Rope swing", "Secret base", "Treetop view", "Play structure", "Nailed boards", "Childhood fun"],
            "hard": ["Canopy level", "Rustic build", "Summer hideaway", "Branch support", "Lookout point", "High perch"]
        },
        {
            "easy": ["Cabin", "Playground"],
            "medium": ["Clubhouse", "Fort"],
            "hard": ["Lookout tower", "Watchtower"]
        }
    ),

    make_record("Igloo", "Shelters", "easy",
        "A dome-shaped shelter made from blocks of snow, traditionally used in Arctic regions.",
        ["snow", "shelter", "cold"],
        {
            "easy": ["Snow blocks", "Arctic", "Eskimo", "Frozen", "Dome shape", "Cold inside"],
            "medium": ["Ice house", "Winter survival", "Blizzard protection", "Packed snow", "Traditional dwelling", "Subzero"],
            "hard": ["Inuit heritage", "Snow knife", "Entrance tunnel", "Body heat warmth", "Wind break", "Aurora viewing"]
        },
        {
            "easy": ["Tent", "Hut"],
            "medium": ["Cabin", "Yurt"],
            "hard": ["Quinzhee", "Snow shelter"]
        }
    ),

    make_record("Tent", "Outdoor lodging", "easy",
        "A portable shelter made of fabric stretched over poles, used for camping outdoors.",
        ["camping", "outdoors", "shelter"],
        {
            "easy": ["Camping trip", "Sleeping bag", "Zipper door", "Pegs and poles", "Campsite", "Canvas"],
            "medium": ["Ground sheet", "Rainfly", "Backpacking", "Campfire nearby", "Stuff sack", "Stake down"],
            "hard": ["Guy lines", "Waterproof coating", "Footprint layer", "Ventilation mesh", "Double wall", "Condensation"]
        },
        {
            "easy": ["Cabin", "Igloo"],
            "medium": ["Caravan", "Yurt"],
            "hard": ["Bivouac", "Marquee"]
        }
    ),

    make_record("Embassy", "Government buildings", "medium",
        "An official building where diplomats represent their country in a foreign nation.",
        ["government", "diplomacy", "building"],
        {
            "easy": ["Ambassador", "Foreign country", "Passport services", "Flag outside", "Diplomats", "Official business"],
            "medium": ["Visa applications", "International relations", "Secure compound", "Consular services", "State department", "Foreign soil"],
            "hard": ["Diplomatic immunity", "Chancery", "Extraterritorial", "Apostille stamp", "Bilateral talks", "Note verbale"]
        },
        {
            "easy": ["Consulate", "Palace"],
            "medium": ["Town hall", "Courthouse"],
            "hard": ["Legation", "High commission"]
        }
    ),

    make_record("Town hall", "Government buildings", "easy",
        "A municipal building where local government meetings and civic events are held.",
        ["government", "civic", "building"],
        {
            "easy": ["Mayor", "City council", "Public meetings", "Wedding venue", "Clock tower", "Local government"],
            "medium": ["Council chambers", "Marriage registry", "Civic events", "Municipal offices", "Public records", "Town gatherings"],
            "hard": ["Borough council", "Alderman", "Charters", "Town clerk", "Ratepayer", "Planning permission"]
        },
        {
            "easy": ["Courthouse", "Embassy"],
            "medium": ["Library", "Community center"],
            "hard": ["Municipality", "Guildhall"]
        }
    ),

    make_record("Parliament", "Government buildings", "medium",
        "A legislative building where elected representatives debate and pass national laws.",
        ["government", "politics", "building"],
        {
            "easy": ["Laws", "Politicians", "Debates", "Prime Minister", "Voting", "National government"],
            "medium": ["House of Commons", "Senate chamber", "Bills passed", "Political parties", "Speaker podium", "Legislation"],
            "hard": ["Westminster", "Hansard records", "Constituency", "Filibuster", "Royal assent", "Whip system"]
        },
        {
            "easy": ["Town hall", "Palace"],
            "medium": ["Courthouse", "Capitol"],
            "hard": ["Congress", "Assembly"]
        }
    ),

    make_record("Observatory", "Science buildings", "medium",
        "A building equipped with instruments for observing and studying celestial objects.",
        ["science", "astronomy", "building"],
        {
            "easy": ["Telescope", "Stars", "Astronomer", "Night sky", "Dome roof", "Planets"],
            "medium": ["Observing deck", "Celestial maps", "Astrophotography", "Clear nights", "Research facility", "Eyepiece view"],
            "hard": ["Refractor telescope", "Equatorial mount", "Light pollution", "Spectrograph", "Observing log", "Star charts"]
        },
        {
            "easy": ["Planetarium", "Lighthouse"],
            "medium": ["Laboratory", "Museum"],
            "hard": ["Radio dish", "Lookout"]
        }
    ),

    make_record("Planetarium", "Science buildings", "medium",
        "A theater with a domed ceiling that projects images of stars and planets for education.",
        ["science", "education", "entertainment"],
        {
            "easy": ["Star show", "Domed ceiling", "Space education", "Dark theater", "Projector", "Constellations"],
            "medium": ["School trips", "Night sky simulation", "Seated audience", "Astronomy lesson", "Cosmic journey", "Milky Way projection"],
            "hard": ["Zeiss projector", "Laser show", "Fulldome video", "Cosmic address", "Celestial sphere", "Educational outreach"]
        },
        {
            "easy": ["Observatory", "Cinema"],
            "medium": ["Museum", "Science center"],
            "hard": ["Astrodome", "Space theater"]
        }
    ),

    make_record("Art gallery", "Culture venues", "easy",
        "A space where paintings, sculptures and other artworks are displayed for viewing.",
        ["art", "culture", "exhibition"],
        {
            "easy": ["Paintings", "Sculptures", "Exhibitions", "White walls", "Opening night", "Curator"],
            "medium": ["Frame hanging", "Artist reception", "Contemporary pieces", "Gallery walk", "Art collection", "Opening reception"],
            "hard": ["Vernissage", "Provenance", "Acquisition", "White cube", "Installation view", "Art critic"]
        },
        {
            "easy": ["Museum", "Studio"],
            "medium": ["Auction house", "Theater"],
            "hard": ["Exhibition hall", "Salon"]
        }
    ),

    make_record("Studio", "Work spaces", "easy",
        "A workspace where artists, photographers or performers create and practice their craft.",
        ["art", "work", "creative"],
        {
            "easy": ["Artist workspace", "Paint brushes", "Easel", "Natural light", "Photography", "Creative space"],
            "medium": ["Canvases", "Model posing", "Recording booth", "Dance practice", "Worktable", "Art supplies"],
            "hard": ["North light", "Live model", "Portfolio review", "Residency program", "Open hours", "Creative process"]
        },
        {
            "easy": ["Gallery", "Office"],
            "medium": ["Workshop", "Atelier"],
            "hard": ["Loft", "Creative space"]
        }
    ),

    make_record("Workshop", "Work spaces", "easy",
        "A room or building where skilled work is done using tools and equipment.",
        ["work", "tools", "craft"],
        {
            "easy": ["Tools", "Workbench", "Woodworking", "Making things", "Power tools", "Craftsman"],
            "medium": ["Sawdust", "Hand tools", "Project builds", "Vise grip", "Skill sharing", "Apprentice"],
            "hard": ["Joinery bench", "Tool chest", "Dust collection", "Jigs and fixtures", "Bench vise", "Craft mastery"]
        },
        {
            "easy": ["Garage", "Factory"],
            "medium": ["Studio", "Atelier"],
            "hard": ["Maker space", "Machine shop"]
        }
    ),

    make_record("Shed", "Outdoor buildings", "easy",
        "A small simple outdoor building used for storing tools, equipment or garden items.",
        ["storage", "garden", "outdoor"],
        {
            "easy": ["Garden tools", "Lawnmower", "Backyard", "Bicycle", "Padlock", "Wooden walls"],
            "medium": ["Potting bench", "Old paint cans", "Spider webs", "Hose reel", "Workbench inside", "Cluttered shelves"],
            "hard": ["Pressure treated", "Shingle roof", "Foundation blocks", "Tool organization", "Weather stripping", "Garden implements"]
        },
        {
            "easy": ["Garage", "Barn"],
            "medium": ["Cabin", "Storage unit"],
            "hard": ["Outbuilding", "Toolhouse"]
        }
    ),

    make_record("Greenhouse", "Garden buildings", "easy",
        "A glass building where plants are grown in controlled warm and humid conditions.",
        ["garden", "plants", "growing"],
        {
            "easy": ["Growing plants", "Glass walls", "Warm inside", "Seedlings", "Humidity", "Tomato vines"],
            "medium": ["Potting shed", "Propagation trays", "Thermostat control", "Watering can", "Tropical plants", "Condensation"],
            "hard": ["Ventilation louvers", "Shade cloth", "Misting system", "Seed starting", "Cold frame", "Growing season"]
        },
        {
            "easy": ["Garden", "Nursery"],
            "medium": ["Conservatory", "Garden center"],
            "hard": ["Hothouse", "Orangery"]
        }
    ),

    make_record("Orchard", "Agricultural places", "easy",
        "A planted area of fruit trees that are cultivated for harvesting their produce.",
        ["agriculture", "fruit", "farming"],
        {
            "easy": ["Apple trees", "Fruit picking", "Harvest season", "Rows of trees", "Cherry blossoms", "Autumn picking"],
            "medium": ["Cider pressing", "Fruit baskets", "Pollination", "Pruning shears", "Pest control", "Grafting"],
            "hard": ["Dwarf rootstock", "Espalier training", "Crop thinning", "Blossom timing", "Cold storage", "Fruit quality"]
        },
        {
            "easy": ["Farm", "Vineyard"],
            "medium": ["Garden", "Grocery"],
            "hard": ["Plantation", "Fruit farm"]
        }
    ),

    make_record("Vineyard", "Agricultural places", "medium",
        "A plantation of grapevines grown primarily for producing wine.",
        ["agriculture", "farming", "grapes"],
        {
            "easy": ["Grape vines", "Harvest season", "Rows of vines", "Sommelier", "Vintner", "Terroir"],
            "medium": ["Crushing grapes", "Barrel aging", "Red varieties", "White varieties", "Fermentation", "Wine cellar"],
            "hard": ["Pruning methods", "Trellis system", "Phylloxera", "Estate bottled", "Appellation", "Crush pad"]
        },
        {
            "easy": ["Orchard", "Farm"],
            "medium": ["Winery", "Distillery"],
            "hard": ["Chateau", "Clos"]
        }
    ),

    make_record("Cemetery", "Public places", "easy",
        "A designated area where deceased people are buried and memorialized.",
        ["memorial", "death", "public"],
        {
            "easy": ["Gravestones", "Burials", "Funerals", "Flowers", "Quiet place", "Memorial"],
            "medium": ["Headstone inscriptions", "Family plots", "Mourning visitors", "Wreath laying", "Grounds keeping", "Tombstones"],
            "hard": ["Mausoleum", "Epitaph", "Perpetual care", "Groundskeeper", "Urn burial", "Genealogy research"]
        },
        {
            "easy": ["Church", "Park"],
            "medium": ["Monument", "Graveyard"],
            "hard": ["Necropolis", "Burial ground"]
        }
    ),

    make_record("Monument", "Landmarks", "easy",
        "A structure erected to commemorate a notable person, event or historical moment.",
        ["history", "memorial", "landmark"],
        {
            "easy": ["Statue", "Historical event", "Memorial stone", "Tourist attraction", "Bronze plaque", "Remembrance"],
            "medium": ["War memorial", "Dedication ceremony", "Public square", "Inscription text", "National heritage", "Commemoration"],
            "hard": ["Centennial", "Unveiling ceremony", "Historical marker", "Sarcophagus", "Obelisk", "Eternal flame"]
        },
        {
            "easy": ["Statue", "Museum"],
            "medium": ["Memorial", "Landmark"],
            "hard": ["Cenotaph", "Stele"]
        }
    ),

    make_record("Fountain", "Public features", "easy",
        "A decorative structure that shoots water into the air or flows it over sculpted surfaces.",
        ["water", "decorative", "public"],
        {
            "easy": ["Water jets", "Coin tossing", "Public square", "Decorative pool", "Wishing well", "Stone basin"],
            "medium": ["Pump system", "Sculpted figures", "Landscaping feature", "Tourist photos", "Water display", "Central plaza"],
            "hard": ["Hydraulic system", "Bronze casting", "Water pressure", "Illuminated jets", "Architectural feature", "Koi pond"]
        },
        {
            "easy": ["Pool", "Statue"],
            "medium": ["Waterfall", "Pond"],
            "hard": ["Spout", "Cascade"]
        }
    ),

    make_record("Plaza", "Public spaces", "easy",
        "An open public square in a city where people gather and events are held.",
        ["public", "urban", "gathering"],
        {
            "easy": ["Public square", "City center", "Outdoor seating", "Street performers", "Tourist spot", "Paved area"],
            "medium": ["Outdoor cafes", "Festival venue", "People watching", "Central location", "Benches and trees", "Shopping district"],
            "hard": ["Pedestrian zone", "Urban design", "Civic events", "Piazza style", "Town square", "Meeting point"]
        },
        {
            "easy": ["Park", "Market"],
            "medium": ["Mall", "Courtyard"],
            "hard": ["Piazza", "Forecourt"]
        }
    ),

    make_record("Alley", "Streets", "easy",
        "A narrow passageway between or behind buildings in urban areas.",
        ["urban", "street", "narrow"],
        {
            "easy": ["Narrow passage", "Between buildings", "Back entrance", "Urban shortcut", "Brick walls", "Trash bins"],
            "medium": ["Service road", "Graffiti art", "Delivery trucks", "Dim lighting", "Cobblestone path", "Dead end"],
            "hard": ["Service access", "Fire escape", "Rear entry", "Pedestrian cut-through", "Loading zone", "Urban planning"]
        },
        {
            "easy": ["Street", "Avenue"],
            "medium": ["Tunnel", "Passage"],
            "hard": ["Lane", "Byway"]
        }
    ),

    make_record("Highway", "Roads", "easy",
        "A major road designed for fast travel between cities and regions.",
        ["road", "transport", "travel"],
        {
            "easy": ["Fast driving", "Multiple lanes", "Road trip", "Exit signs", "Truck traffic", "Speed limit"],
            "medium": ["Rest stops", "Interstate system", "On ramps", "Traffic flow", "Divided road", "Mile markers"],
            "hard": ["Right of way", "Controlled access", "Overpass design", "Traffic engineering", "Freight corridor", "Weight limits"]
        },
        {
            "easy": ["Street", "Bridge"],
            "medium": ["Railway", "Freeway"],
            "hard": ["Expressway", "Turnpike"]
        }
    ),

    make_record("Crossroads", "Roads", "easy",
        "A place where two or more roads meet and intersect at the same level.",
        ["road", "intersection", "travel"],
        {
            "easy": ["Four ways", "Traffic lights", "Street signs", "Intersection", "Turn signals", "Stop sign"],
            "medium": ["Right of way", "Pedestrian crossing", "Blind corner", "Yield signs", "Traffic flow", "Commuter route"],
            "hard": ["Junction box", "Four-way stop", "Turning radius", "Sight lines", "Traffic patterns", "Accident prone"]
        },
        {
            "easy": ["Roundabout", "Highway"],
            "medium": ["Bridge", "Junction"],
            "hard": ["Intersection", "Crossing"]
        }
    ),

    make_record("Roundabout", "Roads", "medium",
        "A circular road junction where traffic flows around a central island in one direction.",
        ["road", "traffic", "intersection"],
        {
            "easy": ["Circular traffic", "Yield on entry", "Central island", "One way flow", "Traffic circle", "Exit ramp"],
            "medium": ["Priority rules", "Rotary design", "Multiple exits", "Pedestrian crossings", "Flow control", "Urban planning"],
            "hard": ["Give way lines", "Capacity management", "Mini roundabout", "Spiral markings", "Traffic calming", "Grade separation"]
        },
        {
            "easy": ["Crossroads", "Highway"],
            "medium": ["Junction", "Intersection"],
            "hard": ["Traffic circle", "Rotary"]
        }
    ),

    make_record("Parking lot", "Urban spaces", "easy",
        "An outdoor area where vehicles can be temporarily left while their owners are elsewhere.",
        ["cars", "urban", "parking"],
        {
            "easy": ["Parked cars", "Painted lines", "Shopping center", "Parking meter", "Ticket booth", "Empty spaces"],
            "medium": ["Security cameras", "Payment kiosk", "Shopping cart return", "Handicap spaces", "Overhead lights", "Entry gate"],
            "hard": ["Asphalt surface", "Drainage grates", "Disabled parking", "Valet stand", "Capacity signs", "Parking attendant"]
        },
        {
            "easy": ["Garage", "Driveway"],
            "medium": ["Plaza", "Depot"],
            "hard": ["Car park", "Parking garage"]
        }
    ),

    make_record("Bus stop", "Transport hubs", "easy",
        "A designated place where buses pause to pick up and drop off passengers.",
        ["transport", "public", "travel"],
        {
            "easy": ["Waiting passengers", "Route numbers", "Timetable posted", "Bench seating", "Bus arriving", "Transit card"],
            "medium": ["Shelter roof", "Route map display", "Fare payment", "Peak hours", "Transfer point", "Bus lane"],
            "hard": ["Headway minutes", "Transit authority", "Real-time display", "Bus bay", "ADA compliant", "Schedule adherence"]
        },
        {
            "easy": ["Train station", "Taxi stand"],
            "medium": ["Airport", "Subway"],
            "hard": ["Bus terminal", "Transit stop"]
        }
    ),

    make_record("Subway station", "Transport hubs", "medium",
        "An underground facility where passengers board and exit metro trains.",
        ["transport", "underground", "metro"],
        {
            "easy": ["Underground trains", "Turnstiles", "Platform edge", "Metro map", "Escalators down", "Ticket machine"],
            "medium": ["Rush hour crowds", "Transfer lines", "Track announcements", "Ventilation grates", "Tiled walls", "Security cameras"],
            "hard": ["Third rail power", "Signal system", "Mezzanine level", "Fare gates", "Platform screen", "Headway management"]
        },
        {
            "easy": ["Train station", "Bus stop"],
            "medium": ["Airport", "Terminal"],
            "hard": ["Metro station", "Underground"]
        }
    ),

    make_record("Port", "Waterfront", "medium",
        "A harbor facility where ships load and unload cargo or passengers.",
        ["shipping", "water", "transport"],
        {
            "easy": ["Cargo ships", "Shipping containers", "Cranes loading", "Dock workers", "Freight transport", "Harbor"],
            "medium": ["Container terminal", "Customs inspection", "Bulk cargo", "Port authority", "Tugboat assistance", "Loading dock"],
            "hard": ["Stevedore work", "Berth allocation", "Draft depth", "Intermodal transfer", "Bill of lading", "Port fees"]
        },
        {
            "easy": ["Harbor", "Marina"],
            "medium": ["Warehouse", "Shipyard"],
            "hard": ["Wharf", "Quay"]
        }
    ),

    make_record("Dam", "Structures", "medium",
        "A barrier constructed across a river to control water flow and generate power.",
        ["engineering", "water", "structure"],
        {
            "easy": ["Water barrier", "Hydroelectric power", "Reservoir behind", "Concrete wall", "Flood control", "River blocked"],
            "medium": ["Spillway gates", "Water pressure", "Power generation", "Downstream flow", "Engineering feat", "Water storage"],
            "hard": ["Penstock pipes", "Turbine hall", "Sediment buildup", "Structural integrity", "Watershed management", "Emergency overflow"]
        },
        {
            "easy": ["Bridge", "Lock"],
            "medium": ["Levee", "Weir"],
            "hard": ["Barrage", "Dike"]
        }
    ),

    make_record("Mine", "Industrial places", "medium",
        "An underground excavation site where valuable minerals or materials are extracted.",
        ["mining", "industry", "underground"],
        {
            "easy": ["Underground tunnels", "Coal mining", "Hard hats", "Miners", "Digging deep", "Rock walls"],
            "medium": ["Shaft elevator", "Ore extraction", "Safety lamps", "Ventilation systems", "Drilling equipment", "Mineral deposits"],
            "hard": ["Overburden removal", "Tailings pond", "Geological survey", "Extraction methods", "Reclamation efforts", "Mine cart"]
        },
        {
            "easy": ["Quarry", "Cave"],
            "medium": ["Tunnel", "Excavation"],
            "hard": ["Pit", "Colliery"]
        }
    ),

    make_record("Quarry", "Industrial places", "medium",
        "An open pit where stone, gravel or other materials are extracted from the earth.",
        ["mining", "stone", "industry"],
        {
            "easy": ["Stone extraction", "Open pit", "Heavy machinery", "Rock faces", "Gravel piles", "Blasting"],
            "medium": ["Crushed stone", "Dimension stone", "Excavators loading", "Dust clouds", "Drilling rigs", "Aggregate material"],
            "hard": ["Bench mining", "Wire saw cutting", "Overburden removal", "Reclamation plan", "Geological formation", "Explosive charges"]
        },
        {
            "easy": ["Mine", "Canyon"],
            "medium": ["Cliff", "Gravel pit"],
            "hard": ["Open pit", "Stone yard"]
        }
    ),

    make_record("Oil rig", "Industrial places", "medium",
        "A large offshore structure used for drilling and extracting petroleum from beneath the seabed.",
        ["oil", "industry", "offshore"],
        {
            "easy": ["Ocean drilling", "Oil extraction", "Steel platform", "Workers offshore", "Drilling tower", "Sea waves"],
            "medium": ["Drill pipe", "Roughnecks", "Pump jacks", "Offshore crew", "Petroleum industry", "Rotary table"],
            "hard": ["Blowout preventer", "Drill string", "Mud circulation", "Production platform", "Subsea wells", "Helicopter transport"]
        },
        {
            "easy": ["Lighthouse", "Factory"],
            "medium": ["Mine", "Ship"],
            "hard": ["Drilling platform", "Gas platform"]
        }
    ),

    make_record("Space station", "Science facilities", "medium",
        "A large artificial satellite where astronauts live and conduct research in orbit.",
        ["space", "science", "orbit"],
        {
            "easy": ["Astronauts living", "Orbiting Earth", "Zero gravity", "Research lab", "Solar panels", "International project"],
            "medium": ["Microgravity experiments", "Docking ports", "Life support systems", "Spacewalks", "Module segments", "Command center"],
            "hard": ["Cupola observation", "Gyroscope control", "Resupply missions", "Extravehicular activity", "Thermal regulation", "Orbital debris"]
        },
        {
            "easy": ["Satellite", "Observatory"],
            "medium": ["Rocket", "Spacecraft"],
            "hard": ["Orbital platform", "Space habitat"]
        }
    ),

    make_record("Army base", "Military facilities", "medium",
        "A military installation where soldiers are stationed and trained for operations.",
        ["military", "training", "security"],
        {
            "easy": ["Soldiers training", "Military vehicles", "Barbed wire", "Guard towers", "Uniforms", "Drill practice"],
            "medium": ["Barracks housing", "Command center", "Security clearance", "Weapon ranges", "Boot camp", "Chain of command"],
            "hard": ["Garrison duty", "Field exercises", "Tactical training", "Perimeter patrol", "Military police", "Operations center"]
        },
        {
            "easy": ["Fort", "Camp"],
            "medium": ["Airport", "Prison"],
            "hard": ["Military post", "Cantonment"]
        }
    ),

    make_record("Fort", "Military facilities", "medium",
        "A fortified military building designed for defense against enemy attacks.",
        ["military", "history", "defense"],
        {
            "easy": ["Soldiers stationed", "Defensive walls", "Cannons mounted", "Historical site", "Military post", "Guard duty"],
            "medium": ["Bastion design", "Garrison housing", "Ammunition storage", "Siege protection", "Strategic location", "Watchtower"],
            "hard": ["Ramparts", "Embrasure openings", "Manning defenses", "Military architecture", "Frontier outpost", "Stockade"]
        },
        {
            "easy": ["Castle", "Army base"],
            "medium": ["Tower", "Citadel"],
            "hard": ["Stronghold", "Bastion"]
        }
    ),

    make_record("Ruins", "Historical sites", "easy",
        "The remains of ancient buildings or structures that have fallen into decay.",
        ["history", "ancient", "archaeology"],
        {
            "easy": ["Ancient remains", "Crumbling walls", "Archaeological site", "Stone fragments", "Historical place", "Tourist visits"],
            "medium": ["Excavation work", "Collapsed structures", "Heritage preservation", "Time erosion", "Lost civilization", "Restoration efforts"],
            "hard": ["Stratigraphy layers", "Artifact recovery", "Conservation work", "Historical significance", "Cultural heritage", "Dating methods"]
        },
        {
            "easy": ["Castle", "Monument"],
            "medium": ["Temple", "Excavation"],
            "hard": ["Archaeological dig", "Heritage site"]
        }
    ),

    make_record("Pyramid", "Historical sites", "easy",
        "An ancient monumental structure with triangular sides meeting at a point, often used as a tomb.",
        ["ancient", "history", "monument"],
        {
            "easy": ["Ancient Egypt", "Pharaoh tomb", "Stone blocks", "Triangular shape", "Desert location", "Hieroglyphics"],
            "medium": ["Burial chamber", "Architectural wonder", "Labor construction", "Limestone casing", "Sacred geometry", "Tourist destination"],
            "hard": ["Sarcophagus", "Mummification", "Alignment precision", "Corbel vault", "Mortuary temple", "Dynasty period"]
        },
        {
            "easy": ["Temple", "Sphinx"],
            "medium": ["Ziggurat", "Monument"],
            "hard": ["Mastaba", "Obelisk"]
        }
    ),

    make_record("Tower", "Structures", "easy",
        "A tall narrow building that rises high above its surroundings.",
        ["structure", "building", "tall"],
        {
            "easy": ["Very tall", "Multiple floors", "City landmark", "Observation deck", "Elevator ride", "Stone or steel"],
            "medium": ["Architectural feature", "Communication antennas", "Historical defense", "Panoramic views", "Structural engineering", "Clock tower"],
            "hard": ["Battlement top", "Load bearing walls", "Spire addition", "Defensive position", "Landmark navigation", "Vertical transport"]
        },
        {
            "easy": ["Skyscraper", "Lighthouse"],
            "medium": ["Castle", "Monument"],
            "hard": ["Turret", "Spire"]
        }
    ),

    make_record("Bell tower", "Structures", "medium",
        "A tall structure containing bells that are rung for religious or civic purposes.",
        ["structure", "bells", "civic"],
        {
            "easy": ["Ringing bells", "Church tower", "Clock chimes", "Stone structure", "Wedding bells", "Hourly chime"],
            "medium": ["Bell chamber", "Rope pulling", "Carillon music", "Historical landmark", "Tourist climbing", "Acoustic design"],
            "hard": ["Belfry opening", "Change ringing", "Bell founder", "Peal performance", "Clockwork mechanism", "Sound projection"]
        },
        {
            "easy": ["Lighthouse", "Clock tower"],
            "medium": ["Steeple", "Campanile"],
            "hard": ["Belfry", "Chime tower"]
        }
    ),

    make_record("Food court", "Dining areas", "easy",
        "A large indoor area in a mall with multiple food vendors and shared seating.",
        ["food", "mall", "dining"],
        {
            "easy": ["Multiple vendors", "Shared seating", "Mall location", "Fast food", "Lunch crowd", "Tray return"],
            "medium": ["Food choices", "Cafeteria style", "Aroma mixing", "Family dining", "Takeaway containers", "Shopping break"],
            "hard": ["Franchise outlets", "Common area", "Revenue sharing", "Hygiene ratings", "Peak lunch rush", "Food court design"]
        },
        {
            "easy": ["Cafeteria", "Restaurant"],
            "medium": ["Canteen", "Market"],
            "hard": ["Food hall", "Eatery"]
        }
    ),

    make_record("Canteen", "Dining areas", "medium",
        "A cafeteria providing meals to workers, students or members of an institution.",
        ["food", "institution", "dining"],
        {
            "easy": ["Institution meals", "Cafeteria trays", "Workers eating", "School lunches", "Serving line", "Budget meals"],
            "medium": ["Meal tickets", "Institutional seating", "Daily specials", "Self service", "Bulk cooking", "Staff dining"],
            "hard": ["Subsidized meals", "Mess hall", "Catering contract", "Nutritional guidelines", "Shift meals", "Communal dining"]
        },
        {
            "easy": ["Cafeteria", "Cafe"],
            "medium": ["Restaurant", "Diner"],
            "hard": ["Mess hall", "Refectory"]
        }
    ),

    make_record("Diner", "Restaurants", "easy",
        "A casual restaurant with a long counter and booths, often serving comfort food all day.",
        ["food", "restaurant", "casual"],
        {
            "easy": ["Counter seating", "All day breakfast", "Coffee refills", "Booth tables", "Comfort food", "Retro style"],
            "medium": ["Waitress service", "Pie display", "Grill cooking", "Late night eats", "Milkshakes", "Classic American"],
            "hard": ["Short order cook", "Formica counters", "Neon signage", "Blue plate special", "Bottomless coffee", "Roadside attraction"]
        },
        {
            "easy": ["Cafe", "Restaurant"],
            "medium": ["Canteen", "Bistro"],
            "hard": ["Eatery", "Coffee shop"]
        }
    ),

    make_record("Food truck", "Mobile dining", "easy",
        "A motorized vehicle equipped to prepare and sell meals on the street.",
        ["food", "mobile", "street"],
        {
            "easy": ["Mobile kitchen", "Serving window", "Lunch rush", "Gourmet burgers", "City streets", "Street eats"],
            "medium": ["Location permits", "Daily specials", "Queue forming", "Cash or card", "Social media location", "Outdoor dining"],
            "hard": ["Health inspection", "Generator power", "Propane tank", "Commissary kitchen", "Route planning", "Vendor license"]
        },
        {
            "easy": ["Cafe", "Diner"],
            "medium": ["Market", "Restaurant"],
            "hard": ["Mobile vendor", "Street cart"]
        }
    ),

    make_record("Night club", "Entertainment venues", "easy",
        "An entertainment venue that operates late at night with music, dancing and drinks.",
        ["nightlife", "entertainment", "dancing"],
        {
            "easy": ["Dancing", "DJ music", "Cocktails", "Crowded dance floor", "Strobe lights", "Late hours"],
            "medium": ["VIP section", "Cover charge", "Bartender mixing", "Bass thumping", "Last call", "Night out"],
            "hard": ["Sound system", "Guest list", "Promoter", "Lighting rig", "Capacity limits", "Drink minimum"]
        },
        {
            "easy": ["Bar", "Concert hall"],
            "medium": ["Theater", "Lounge"],
            "hard": ["Discotheque", "Dance club"]
        }
    ),

    make_record("Concert hall", "Entertainment venues", "medium",
        "A purpose-built venue designed for live musical performances with excellent acoustics.",
        ["music", "venue", "performance"],
        {
            "easy": ["Live music", "Orchestra playing", "Seated audience", "Stage setup", "Ticket purchase", "Acoustic design"],
            "medium": ["Symphony performances", "Dress code", "Intermission break", "Program booklet", "Usher seating", "Encore applause"],
            "hard": ["Acoustic panels", "Proscenium arch", "Sound engineering", "Season subscription", "Maestro conducting", "Orchestra pit"]
        },
        {
            "easy": ["Theater", "Stadium"],
            "medium": ["Opera house", "Auditorium"],
            "hard": ["Recital hall", "Philharmonic"]
        }
    ),

    make_record("Bowling alley", "Entertainment venues", "easy",
        "A facility with long lanes where people roll balls to knock down pins for fun.",
        ["entertainment", "sport", "fun"],
        {
            "easy": ["Rolling balls", "Score screen", "Shoe rental", "Strike spare", "Lane numbers", "Pins"],
            "medium": ["Gutter balls", "Frame scoring", "Bumper lanes", "Concession stand", "League night", "Turkey three strikes"],
            "hard": ["Approach area", "Pinsetter machine", "Oil pattern", "Bowling average", "Handicap scoring", "Pro shop"]
        },
        {
            "easy": ["Arcade", "Gym"],
            "medium": ["Billiards hall", "Sports bar"],
            "hard": ["Bowling center", "Tenpin lounge"]
        }
    ),

    make_record("Ski resort", "Recreation venues", "medium",
        "A mountain destination with prepared slopes and lifts for skiing and snowboarding.",
        ["winter", "sport", "recreation"],
        {
            "easy": ["Snowy slopes", "Winter vacation", "Mountain views", "Powder snow", "Ski gear", "Chalet"],
            "medium": ["Gondola rides", "Après ski", "Trail maps", "Snowboard rentals", "Ski school", "Lift ticket"],
            "hard": ["Grooming machines", "Vertical drop", "Black diamond", "Base lodge", "Snowmaking", "High altitude"]
        },
        {
            "easy": ["Spa", "Campsite"],
            "medium": ["Cabin", "Mountain lodge"],
            "hard": ["Ski area", "Winter resort"]
        }
    ),

    make_record("Resort", "Lodging", "easy",
        "A commercial establishment providing lodging, meals and recreational facilities for vacationers.",
        ["vacation", "lodging", "leisure"],
        {
            "easy": ["Vacation destination", "Swimming pool", "All inclusive", "Relaxation", "Tourist attraction", "Beach access"],
            "medium": ["Room service", "Activity programs", "Spa treatments", "Guest activities", "Concierge desk", "Resort grounds"],
            "hard": ["Hospitality management", "Amenity access", "Timeshare units", "Seasonal rates", "Guest satisfaction", "Resort fee"]
        },
        {
            "easy": ["Hotel", "Hostel"],
            "medium": ["Campsite", "Motel"],
            "hard": ["Destination resort", "Spa resort"]
        }
    ),

    make_record("Motel", "Lodging", "easy",
        "A roadside hotel designed for motorists with rooms opening directly to the parking area.",
        ["lodging", "travel", "roadside"],
        {
            "easy": ["Roadside lodging", "Car parking", "Budget stay", "Road trip", "Exterior doors", "Vacancy sign"],
            "medium": ["Drive up room", "Weekly rates", "Ice machine", "Continental breakfast", "Highway location", "Family travel"],
            "hard": ["Motor inn", "Stopover accommodation", "Parking adjacency", "Transient lodging", "Route accommodation", "Auto tourism"]
        },
        {
            "easy": ["Hotel", "Hostel"],
            "medium": ["Inn", "Lodge"],
            "hard": ["Motor lodge", "Roadside inn"]
        }
    ),

    make_record("Inn", "Lodging", "easy",
        "A small establishment providing lodging and often meals to travelers.",
        ["lodging", "travel", "hospitality"],
        {
            "easy": ["Travelers lodging", "Cozy rooms", "Country location", "Bed and breakfast", "Historic building", "Local hospitality"],
            "medium": ["Tavern attached", "Fireplace lobby", "Personal service", "Antique furnishings", "Garden courtyard", "Country charm"],
            "hard": ["Innkeeper", "Posting house", "Stagecoach stop", "Heritage property", "Country hospitality", "Boutique lodging"]
        },
        {
            "easy": ["Hotel", "Motel"],
            "medium": ["Tavern", "Lodge"],
            "hard": ["Guesthouse", "Country inn"]
        }
    ),
]


# Records for 007_places - 20 records
RECORDS_007 = [
    make_record("Palace garden", "Landmarks", "medium",
        "A meticulously landscaped outdoor area designed to complement a royal palace.",
        ["garden", "nature", "royalty"],
        {
            "easy": ["Beautiful flowers", "Royalty walks", "Landscaped paths", "Fountains", "Statues", "Royal home"],
            "medium": ["Ornate hedges", "Royal estate", "Formal layout", "Seasonal blooms", "Garden tours", "Public entry"],
            "hard": ["Topiary art", "Baroque design", "Botanical variety", "Estate maintenance", "Garden pavilion", "Grand vista"]
        },
        {
            "easy": ["Park", "Greenhouse"],
            "medium": ["Orchard", "Botanical garden"],
            "hard": ["Royal estate", "Palace grounds"]
        }
    ),

    make_record("Botanical garden", "Landmarks", "medium",
        "An educational area dedicated to the scientific collection and display of various plant species.",
        ["garden", "plants", "science"],
        {
            "easy": ["Many plants", "Flowers", "Educational walks", "Nature study", "Greenhouse glass", "Outdoor paths"],
            "medium": ["Plant labels", "Species collection", "Rare blooms", "Horticulture study", "Seasonal flowers", "Conservation work"],
            "hard": ["Taxonomy display", "Arboretum", "Plant research", "Genetic diversity", "Greenhouse complex", "Native flora"]
        },
        {
            "easy": ["Park", "Greenhouse"],
            "medium": ["Zoo", "Public park"],
            "hard": ["Arboretum", "Plant conservatory"]
        }
    ),

    make_record("Nursery", "Shops", "easy",
        "A business that cultivates and sells young plants, shrubs and flowers.",
        ["shop", "plants", "growing"],
        {
            "easy": ["Small plants", "Buying flowers", "Gardening", "Potted saplings", "Shrubs", "Seeds"],
            "medium": ["Potting soil", "Plant care advice", "Greenhouse rows", "Spring planting", "Garden supplies", "Fertilizer"],
            "hard": ["Seedlings", "Horticulture retail", "Propagating", "Plant stock", "Garden starters", "Rooted cuttings"]
        },
        {
            "easy": ["Greenhouse", "Florist"],
            "medium": ["Orchard", "Garden center"],
            "hard": ["Plant shop", "Plant farm"]
        }
    ),

    make_record("Daycare", "Buildings", "easy",
        "A facility providing daytime care and supervision for small children while parents work.",
        ["kids", "care", "education"],
        {
            "easy": ["Small children", "Playtime", "Nap time", "Supervision", "Learning", "Toys"],
            "medium": ["Toddler activities", "Parent pickup", "Group activities", "Child care", "Nursery rhymes", "Snack time"],
            "hard": ["State licensing", "Early education", "Staff ratios", "Daily schedule", "Developmental play", "Supervised play"]
        },
        {
            "easy": ["School", "Nursery"],
            "medium": ["Playground", "Preschool"],
            "hard": ["Childcare center", "Creche"]
        }
    ),

    make_record("Retirement home", "Health and care", "easy",
        "A residential facility providing housing and services for elderly people who need support.",
        ["elderly", "care", "home"],
        {
            "easy": ["Elderly people", "Residents", "Care staff", "Support", "Social activities", "Common room"],
            "medium": ["Assisted living", "Nursing staff", "Retirement living", "Community dining", "Senior care", "Health check"],
            "hard": ["Independent living", "Geriatric care", "Facility living", "Care plan", "Resident needs", "Aging support"]
        },
        {
            "easy": ["Hospital", "Hotel"],
            "medium": ["Hostel", "Nursing home"],
            "hard": ["Care home", "Senior residence"]
        }
    ),

    make_record("Orphanage", "Buildings", "medium",
        "An institution that provides housing and care for children who have lost their parents.",
        ["kids", "care", "institution"],
        {
            "easy": ["Children without parents", "Housing", "Care staff", "Living together", "Upbringing", "Support"],
            "medium": ["Institutional living", "Child welfare", "Group upbringing", "Childhood home", "Living quarters", "Supervision"],
            "hard": ["Social services", "Charitable foundation", "Resident children", "Early upbringing", "Care institution", "Group care"]
        },
        {
            "easy": ["Daycare", "School"],
            "medium": ["Boarding school", "Shelter"],
            "hard": ["Children home", "Residential care"]
        }
    ),

    make_record("Shelter", "Public services", "easy",
        "A temporary place providing basic accommodation and safety for people in need.",
        ["safety", "service", "emergency"],
        {
            "easy": ["Emergency stay", "Safety", "Help", "Basic food", "Temporary home", "Bedding"],
            "medium": ["Homeless aid", "Safe place", "Charity support", "Overnight stay", "Support staff", "Resource center"],
            "hard": ["Crisis management", "Emergency lodging", "Social support", "Basic needs", "Safety net", "Temporary housing"]
        },
        {
            "easy": ["Hostel", "Hospital"],
            "medium": ["Orphanage", "Refuge"],
            "hard": ["Safe house", "Crisis center"]
        }
    ),

    make_record("Recycling center", "Public services", "easy",
        "A facility where sorted waste materials are collected and processed to be reused.",
        ["environment", "waste", "service"],
        {
            "easy": ["Sorting trash", "Bins", "Environmental", "Plastic bottles", "Paper waste", "Reuse"],
            "medium": ["Waste processing", "Sorting machines", "Drop off point", "Community green", "Sustainable", "Resource recovery"],
            "hard": ["Material sorting", "Waste stream", "Environmental policy", "Processing plant", "Sorting bays", "Material reclaim"]
        },
        {
            "easy": ["Dump", "Factory"],
            "medium": ["Warehouse", "Transfer station"],
            "hard": ["Recycling plant", "Depot"]
        }
    ),

    make_record("Landfill", "Industrial places", "easy",
        "An designated site where non-recyclable waste is buried and managed long-term.",
        ["waste", "environment", "earth"],
        {
            "easy": ["Trash burial", "Garbage", "Large site", "Dirt mounds", "Environmental", "Waste management"],
            "medium": ["Garbage trucks", "Site disposal", "Surface covering", "Waste storage", "Deep ground", "Environmental impact"],
            "hard": ["Methane capture", "Ground liners", "Waste cell", "Site reclamation", "Leachate management", "Disposal site"]
        },
        {
            "easy": ["Recycling center", "Quarry"],
            "medium": ["Junkyard", "Dumpsite"],
            "hard": ["Tip", "Rubbish site"]
        }
    ),

    make_record("Junkyard", "Industrial places", "easy",
        "A site where discarded items and scrap metal are collected and dismantled.",
        ["waste", "scrap", "storage"],
        {
            "easy": ["Scrap metal", "Old cars", "Piles of trash", "Dismantled items", "Recycle", "Busy site"],
            "medium": ["Crushing machines", "Metal salvage", "Spare parts", "Recycled items", "Industrial waste", "Sorting piles"],
            "hard": ["Salvage yard", "Metal recycling", "Scrap dealer", "Dismantling", "Material recovery", "Scrap haulers"]
        },
        {
            "easy": ["Landfill", "Garage"],
            "medium": ["Warehouse", "Scrapyard"],
            "hard": ["Salvage yard", "Scrap metal site"]
        }
    ),

    make_record("Hut", "Buildings", "easy",
        "A small, simple and basic dwelling, often made of natural materials.",
        ["home", "simple", "building"],
        {
            "easy": ["Simple home", "Small house", "Natural materials", "Rural", "Basic living", "Rough build"],
            "medium": ["Rustic look", "Small dwelling", "Cozy space", "Traditional construction", "Simple design", "Forest house"],
            "hard": ["Primitive building", "Thatch roof", "Simple structure", "Rustic charm", "Small footprint", "Basic materials"]
        },
        {
            "easy": ["Cabin", "Tent"],
            "medium": ["Shed", "Cottage"],
            "hard": ["Shack", "Lean-to"]
        }
    ),

    make_record("Bungalow", "Homes", "easy",
        "A low house having only one story, often with a wide porch.",
        ["home", "architecture", "building"],
        {
            "easy": ["One floor", "Single story", "House style", "Porch", "Residential", "Simple design"],
            "medium": ["Ground level", "No stairs", "Residential layout", "Wide porch", "Simple exterior", "Home design"],
            "hard": ["Architectural plan", "Single level", "Ground floor living", "Low profile", "Home layout", "Living area"]
        },
        {
            "easy": ["Cottage", "Villa"],
            "medium": ["Cabin", "Single story house"],
            "hard": ["Ranch style", "Detached house"]
        }
    ),

    make_record("Villa", "Homes", "medium",
        "A large, often luxurious house, traditionally in the countryside or near the sea.",
        ["home", "luxury", "lifestyle"],
        {
            "easy": ["Large home", "Luxury", "Countryside", "Beautiful house", "Holiday stay", "Spacious"],
            "medium": ["Mediterranean style", "Patio area", "Garden views", "High end", "Retreat", "Architecture"],
            "hard": ["Architectural style", "Grand design", "Vacation estate", "Luxury property", "Elegant exterior", "Formal layout"]
        },
        {
            "easy": ["Mansion", "Bungalow"],
            "medium": ["Cottage", "Resort villa"],
            "hard": ["Manor house", "Estate house"]
        }
    ),

    make_record("Condo", "Homes", "easy",
        "An individual living unit in a building, owned by the resident rather than rented.",
        ["home", "building", "urban"],
        {
            "easy": ["Own apartment", "City building", "Home ownership", "Neighbor living", "Elevator", "Residential"],
            "medium": ["Shared areas", "Monthly fee", "Urban living", "Home space", "Building management", "Private ownership"],
            "hard": ["Property title", "Homeowner association", "Building rules", "Residential unit", "Ownership structure", "Maintenance fee"]
        },
        {
            "easy": ["Apartment", "Townhouse"],
            "medium": ["Villa", "Condominium unit"],
            "hard": ["Flat", "Co-op unit"]
        }
    ),

    make_record("Penthouse", "Homes", "medium",
        "A luxurious apartment or unit located on the highest floor of a city building.",
        ["home", "luxury", "city"],
        {
            "easy": ["Highest floor", "Luxury living", "City view", "Apartment top", "Tall building", "Wealthy"],
            "medium": ["Private terrace", "Panoramic city views", "Top floor", "Exclusive living", "High rise", "Roof space"],
            "hard": ["Elevator access", "Roof level", "Urban luxury", "Private entry", "Floor plan", "Exclusive access"]
        },
        {
            "easy": ["Mansion", "Condo"],
            "medium": ["Loft", "Top floor flat"],
            "hard": ["Roof terrace house", "Suite"]
        }
    ),

    make_record("Hair salon", "Shops", "easy",
        "A business where stylists cut, color and treat customers' hair.",
        ["beauty", "grooming", "shop"],
        {
            "easy": ["Haircuts", "Styling", "Blow dry", "Hair color", "Stylist", "Mirrors"],
            "medium": ["Shampooing", "Appointment", "Hair care products", "Styling tools", "Grooming", "Beauty service"],
            "hard": ["Hair treatments", "Professional stylist", "Salon experience", "Hair services", "Treatment chair", "Hair styling"]
        },
        {
            "easy": ["Barbershop", "Spa"],
            "medium": ["Boutique", "Salon"],
            "hard": ["Hair studio", "Beauty shop"]
        }
    ),

    make_record("Boutique", "Shops", "medium",
        "A small shop that sells specialized, often fashionable, clothes or accessories.",
        ["shop", "fashion", "clothes"],
        {
            "easy": ["Fashionable", "Specialized clothes", "Shopping", "Accessories", "Small shop", "Style"],
            "medium": ["Trendy items", "Unique collection", "Shopping experience", "Personal service", "Style boutique", "Fashion items"],
            "hard": ["Curated collection", "Specialized retail", "Fashion items", "Designer brand", "Small retail", "Fashion boutique"]
        },
        {
            "easy": ["Mall", "Market"],
            "medium": ["Salon", "Fashion shop"],
            "hard": ["Clothing store", "Designer shop"]
        }
    ),

    make_record("Casino", "Entertainment venues", "easy",
        "A facility where people play games of chance and gamble for money.",
        ["entertainment", "gambling", "games"],
        {
            "easy": ["Gambling games", "Money bets", "Cards", "Roulette wheels", "Jackpots", "High stakes"],
            "medium": ["Slot machines", "Card tables", "Chips", "Gambling floor", "Risk taking", "Night entertainment"],
            "hard": ["House edge", "Dealer table", "Gaming floor", "Wagering", "High rollers", "Chance games"]
        },
        {
            "easy": ["Arcade", "Bowling alley"],
            "medium": ["Stadium", "Gaming room"],
            "hard": ["Gambling hall", "Betting center"]
        }
    ),

    make_record("Racetrack", "Recreation venues", "easy",
        "A circular or oval course where horses or cars compete in races.",
        ["sport", "racing", "competition"],
        {
            "easy": ["Racing competition", "Horses", "Cars", "Speed", "Competition", "Track"],
            "medium": ["Track course", "Speed events", "Winning line", "Racing track", "Fast racing", "Racing circuit"],
            "hard": ["Race circuit", "Track speed", "Racing venue", "Oval track", "Track competition", "Fast course"]
        },
        {
            "easy": ["Stadium", "Arena"],
            "medium": ["Highway", "Racing field"],
            "hard": ["Track", "Speedway"]
        }
    ),

    make_record("Lagoon resort", "Lodging", "medium",
        "A vacation destination featuring a calm body of water for swimming and relaxing.",
        ["vacation", "lodging", "nature"],
        {
            "easy": ["Water relaxation", "Vacation spot", "Swimming water", "Relaxing stay", "Resort area", "Calm water"],
            "medium": ["Beach views", "Holiday retreat", "Swimming area", "Coastal stay", "Resort life", "Resort water"],
            "hard": ["Resort oasis", "Calm coastal", "Vacation retreat", "Resort body", "Water retreat", "Resort relaxation"]
        },
        {
            "easy": ["Hotel", "Hostel"],
            "medium": ["Campsite", "Beach resort"],
            "hard": ["Lagoon hotel", "Waterfront resort"]
        }
    ),
]


def validate_all(records, name):
    """Validate all records"""
    cats = {c['id']: c for c in W.load_categories()}
    lists = W.Lists()
    errors = 0
    warnings = 0
    for r in records:
        errs, warns = W.validate_record(r, cats, lists)
        if errs:
            print(f"ERROR {r['word']}: {errs}")
            errors += 1
        if warns:
            print(f"WARN  {r['word']}: {warns}")
            warnings += 1
    print(f"\n{name}: {len(records)} records, {errors} with errors, {warnings} with warnings")
    return errors == 0


def auto_fix_records(records, name):
    """Iteratively fix records until all pass validation"""
    cats = {c['id']: c for c in W.load_categories()}
    lists = W.Lists()

    for r in records:
        max_iterations = 20
        for iteration in range(max_iterations):
            errs, warns = W.validate_record(r, cats, lists)
            if not errs:
                if warns:
                    print(f"  WARN {r['word']}: {warns}")
                break

            # Auto-fix based on error types
            for err in errs:
                if 'contains-word' in err:
                    # Extract hint word
                    parts = err.split('"')
                    if len(parts) >= 2:
                        hint_word = parts[1]
                        # Find and remove from hints
                        for tier in ['easy', 'medium', 'hard']:
                            if hint_word in r['hints'][tier]:
                                r['hints'][tier].remove(hint_word)
                                break
                elif 'blocklist' in err:
                    parts = err.split('"')
                    if len(parts) >= 2:
                        hint_word = parts[1]
                        for tier in ['easy', 'medium', 'hard']:
                            if hint_word in r['hints'][tier]:
                                r['hints'][tier].remove(hint_word)
                                break
                elif 'leaks through' in err:
                    parts = err.split('"')
                    if len(parts) >= 2:
                        imp = parts[1]
                        for tier in ['easy', 'medium', 'hard']:
                            if imp in r['imposters'][tier]:
                                r['imposters'][tier].remove(imp)
                                break
                elif 'is also a hint' in err:
                    parts = err.split('"')
                    if len(parts) >= 2:
                        imp = parts[1]
                        for tier in ['easy', 'medium', 'hard']:
                            if imp in r['imposters'][tier]:
                                r['imposters'][tier].remove(imp)
                                break
                elif 'appears in the description' in err:
                    parts = err.split('"')
                    if len(parts) >= 2:
                        imp = parts[1]
                        for tier in ['easy', 'medium', 'hard']:
                            if imp in r['imposters'][tier]:
                                r['imposters'][tier].remove(imp)
                                break
                elif 'variant-of-word' in err or 'synonym' in err:
                    parts = err.split('"')
                    if len(parts) >= 2:
                        imp = parts[1]
                        for tier in ['easy', 'medium', 'hard']:
                            if imp in r['imposters'][tier]:
                                r['imposters'][tier].remove(imp)
                                break
                elif 'duplicate' in err:
                    # Find the duplicate and remove
                    pass
            else:
                # No break - continue loop
                continue
            break
        else:
            # Still has errors after max iterations
            errs, warns = W.validate_record(r, cats, lists)
            if errs:
                print(f"  FAILED {r['word']}: {errs}")
    return records


def main():
    # Fix and write 006
    print("=== Processing 006_places.json ===")
    fixed_006 = auto_fix_records(RECORDS_006, "006")
    if validate_all(fixed_006, "006_places"):
        with open('tool/words/replies/006_places.json', 'w', encoding='utf-8') as f:
            json.dump(fixed_006, f, ensure_ascii=False, separators=(',', ':'))
        print("✓ 006_places.json written successfully")
    else:
        print("✗ 006_places.json has validation errors")
        return 1

    # Fix and write 007
    print("\n=== Processing 007_places.json ===")
    fixed_007 = auto_fix_records(RECORDS_007, "007")
    if validate_all(fixed_007, "007_places"):
        with open('tool/words/replies/007_places.json', 'w', encoding='utf-8') as f:
            json.dump(fixed_007, f, ensure_ascii=False, separators=(',', ':'))
        print("✓ 007_places.json written successfully")
    else:
        print("✗ 007_places.json has validation errors")
        return 1

    return 0


if __name__ == '__main__':
    sys.exit(main())