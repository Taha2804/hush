import json

# FIXED 010_sports.json - 29 records from fix_010_sports.txt
data_010 = [
  {
    "word": "Muay thai",
    "category": "sports_games",
    "subcategory": "Combat sports",
    "difficulty": "medium",
    "description": "A Thai combat sport using fists elbows knees and shins as striking tools.",
    "tags": ["combat", "thailand", "striking"],
    "hints": {
      "easy": ["Bangkok", "Ring", "Shin guards", "Wai kru", "Clinch work", "Eight limbs"],
      "medium": ["Elbow strike", "Knee strike", "Lumpinee", "Rajadamnern", "Ram muay", "Nak muay"],
      "hard": ["Teep kick", "Plum clinch", "Mongkol", "Sok klap", "Muay boran", "Kru muay"]
    },
    "imposters": {
      "easy": ["Kickboxing", "Boxing", "Karate"],
      "medium": ["Lethwei", "Savate", "Krav maga"],
      "hard": ["Dutch kickboxing", "Muay boran"]
    }
  },
  {
    "word": "Kung fu",
    "category": "sports_games",
    "subcategory": "Combat sports",
    "difficulty": "easy",
    "description": "A Chinese martial art encompassing many fighting styles and traditions.",
    "tags": ["martial-arts", "china", "tradition"],
    "hints": {
      "easy": ["Shaolin", "Bruce Lee", "Sifu", "Wing Chun", "Training hall", "Robe and sash"],
      "medium": ["Forms", "Qi", "Stances", "Northern style", "Southern fist", "Weapons forms"],
      "hard": ["Internal power", "Meridian", "Chin na", "Liuhebafa", "Wushu style", "San shou"]
    },
    "imposters": {
      "easy": ["Karate", "Taekwondo", "Judo"],
      "medium": ["Pencak silat", "Muay thai", "Wushu style"],
      "hard": ["Sanshou", "Qinna"]
    }
  },
  {
    "word": "Pilates",
    "category": "sports_games",
    "subcategory": "Fitness",
    "difficulty": "easy",
    "description": "A low-impact exercise system focused on core strength flexibility and posture.",
    "tags": ["fitness", "core", "exercise"],
    "hints": {
      "easy": ["Reformer", "Mat work", "Core strength", "Studio class", "Controlled breathing", "Apparatus"],
      "medium": ["Hundred", "Roll up", "Teaser", "Magic circle", "Neutral pelvis", "Spine stretch"],
      "hard": ["Cadillac", "Wunda chair", "Ladder barrel", "Imprint", "Scoop", "Breath pattern"]
    },
    "imposters": {
      "easy": ["Yoga", "Aerobics", "Stretching"],
      "medium": ["Barre", "Gyrotonic", "Calisthenics"],
      "hard": ["Clinical method", "Mat sequence"]
    }
  },
  {
    "word": "Aerobics",
    "category": "sports_games",
    "subcategory": "Fitness",
    "difficulty": "easy",
    "description": "Rhythmic physical exercise performed to music improving cardiovascular fitness.",
    "tags": ["fitness", "cardio", "music"],
    "hints": {
      "easy": ["Step class", "Leotard", "Eighties workout", "Instructor", "Group exercise", "High energy"],
      "medium": ["Choreography", "Heart rate", "Cool down", "Warm up", "Impact level", "Dance moves"],
      "hard": ["Anaerobic threshold", "Interval training", "Step height", "Jacki Sorensen", "Kenneth Cooper", "Fitness test"]
    },
    "imposters": {
      "easy": ["Pilates", "Zumba", "Yoga"],
      "medium": ["Step class variant", "Water workout", "Dance class"],
      "hard": ["HIIT", "Cardio dance"]
    }
  },
  {
    "word": "Zumba",
    "category": "sports_games",
    "subcategory": "Fitness",
    "difficulty": "easy",
    "description": "A dance fitness program blending Latin rhythms with aerobic movements.",
    "tags": ["fitness", "dance", "latin"],
    "hints": {
      "easy": ["Latin music", "Dance party", "Salsa steps", "Fitness class", "Instructor", "Hip movements"],
      "medium": ["Merengue", "Cumbia", "Reggaeton", "Bet Perez", "Party atmosphere", "Rhythm"],
      "hard": ["Beto shuffle", "Arm styling", "Footwork patterns", "ZIN", "Master class", "Rumba rhythm"]
    },
    "imposters": {
      "easy": ["Aerobics", "Salsa", "Pilates"],
      "medium": ["Bachata class", "Cardio party", "Latin workout"],
      "hard": ["Toning version", "Aqua version"]
    }
  },
  {
    "word": "Bodybuilding",
    "category": "sports_games",
    "subcategory": "Strength sports",
    "difficulty": "easy",
    "description": "A sport developing muscle size and symmetry through progressive resistance training.",
    "tags": ["strength", "muscle", "gym"],
    "hints": {
      "easy": ["Dumbbells", "Gym", "Protein shake", "Arnold Schwarzenegger", "Mirror posing", "Bulking"],
      "medium": ["Hypertrophy", "Compound lifts", "Cutting phase", "Macros", "Symmetry", "Stage tan"],
      "hard": ["Mr Olympia", "Peak week", "Carb loading", "Pump", "Vascularity", "Prejudging"]
    },
    "imposters": {
      "easy": ["Weightlifting", "Powerlifting", "Wrestling"],
      "medium": ["Strongman", "Physique", "Calisthenics"],
      "hard": ["Classic physique", "Natural division"]
    }
  },
  {
    "word": "Powerlifting",
    "category": "sports_games",
    "subcategory": "Strength sports",
    "difficulty": "medium",
    "description": "A strength sport testing maximal force in three lifts: squat bench press and deadlift.",
    "tags": ["strength", "barbell", "competition"],
    "hints": {
      "easy": ["Squat rack", "Heavy plates", "Chalk dust", "Belt", "Spotter", "Three attempts"],
      "medium": ["Bench press", "Deadlift", "Lockout", "Depth", "Commands", "Wilks score"],
      "hard": ["Pause bench", "Sumo stance", "Raw division", "Flight", "Bomb out", "Singlet"]
    },
    "imposters": {
      "easy": ["Weightlifting", "Bodybuilding", "Strongman"],
      "medium": ["Olympic style", "Stone lifting", "Grip sport"],
      "hard": ["Push pull", "Bench only meet"]
    }
  },
  {
    "word": "Arm wrestling",
    "category": "sports_games",
    "subcategory": "Strength sports",
    "difficulty": "easy",
    "description": "A contest where two opponents pin each other's arm to a table surface.",
    "tags": ["strength", "grip", "table"],
    "hints": {
      "easy": ["Table", "Grip", "Pin", "Forearm strength", "Bar setting", "Side pressure"],
      "medium": ["Hook technique", "Toproll", "Wrist control", "Elbow pad", "Strap match", "King move"],
      "hard": ["Pronation", "Supination", "Rising", "Slip out", "Referee grip", "Peg board"]
    },
    "imposters": {
      "easy": ["Judo", "Sumo", "Boxing"],
      "medium": ["Finger pull", "Thumb war", "Hand grip"],
      "hard": ["Devon Larratt", "John Brzenk"]
    }
  },
  {
    "word": "Hopscotch",
    "category": "sports_games",
    "subcategory": "Playground games",
    "difficulty": "easy",
    "description": "A children's game of hopping through numbered squares drawn on the ground.",
    "tags": ["playground", "children", "jumping"],
    "hints": {
      "easy": ["Chalk squares", "Playground", "Stone marker", "One foot", "Turn taking", "Sidewalk game"],
      "medium": ["Numbered grid", "Rest square", "Toss marker", "Retrieve", "Balance", "Skip square"],
      "hard": ["Pattern hop", "Potsy", "Hop score", "Line hop", "Spiral pattern", "Kick the stone"]
    },
    "imposters": {
      "easy": ["Jump rope", "Tag", "Marbles"],
      "medium": ["Four corner game", "Skipping", "Elastics"],
      "hard": ["Rayuela", "Playground hop"]
    }
  },
  {
    "word": "Dodgeball",
    "category": "sports_games",
    "subcategory": "Ball games",
    "difficulty": "easy",
    "description": "A team game where players throw balls to hit opponents while avoiding being hit.",
    "tags": ["team", "ball", "throwing"],
    "hints": {
      "easy": ["Gym class", "Red spheres", "Elimination", "Court lines", "Catch", "Last player"],
      "medium": ["Five D's", "Opening rush", "Dead sphere", "Headshot rule", "Blocking", "Sudden death"],
      "hard": ["Court geometry", "Counter throw", "Sacrifice play", "Pinching", "Cloth sphere", "Foam sphere"]
    },
    "imposters": {
      "easy": ["Handball", "Tag", "Volleyball"],
      "medium": ["Ga-ga", "Prison ball", "Bombardment"],
      "hard": ["Circle version", "Doctor version"]
    }
  },
  {
    "word": "Netball",
    "category": "sports_games",
    "subcategory": "Ball games",
    "difficulty": "easy",
    "description": "A team court game where players pass a ball and shoot through a raised hoop.",
    "tags": ["team", "ball", "court"],
    "hints": {
      "easy": ["No dribbling", "Seven players", "Goal shooter", "Centre pass", "Bib positions", "Pivot foot"],
      "medium": ["Goal circle", "Three seconds", "Contact rule", "Obstruction", "Centre third", "Wing attack"],
      "hard": ["Short pass", "Rebound", "Intercept", "Feed", "Transverse line", "Held sphere"]
    },
    "imposters": {
      "easy": ["Basketball", "Volleyball", "Handball"],
      "medium": ["Korfball", "Ringball", "Fast five"],
      "hard": ["Indoor version", "Mixed version"]
    }
  },
  {
    "word": "Frisbee",
    "category": "sports_games",
    "subcategory": "Disc sports",
    "difficulty": "easy",
    "description": "A flying disc thrown and caught for recreation or competitive play.",
    "tags": ["disc", "throwing", "outdoor"],
    "hints": {
      "easy": ["Beach throw", "Park game", "Catch", "Spin", "Plastic disc", "Backhand"],
      "medium": ["Forehand", "Hammer throw", "Flight path", "Wind reading", "Dog catch", "Golf variant"],
      "hard": ["Turnover", "Pull", "Layout", "Callahan", "Greatest", "Spirit of the game"]
    },
    "imposters": {
      "easy": ["Boomerang", "Kite", "Ball"],
      "medium": ["Golf variant", "Freestyle", "Ultimate"],
      "hard": ["Guts", "DDC"]
    }
  },
  {
    "word": "Ultimate",
    "category": "sports_games",
    "subcategory": "Disc sports",
    "difficulty": "medium",
    "description": "A team sport played with a flying disc scoring by catching in an end zone.",
    "tags": ["team", "disc", "field"],
    "hints": {
      "easy": ["End zone", "Pull", "Stack", "Handler", "Cutter", "Turnover"],
      "medium": ["Force", "Break side", "Huck", "Layout", "Callahan", "Spirit circle"],
      "hard": ["Horizontal stack", "Vertical stack", "Zone defence", "Poach", "Swing pass", "Dump"]
    },
    "imposters": {
      "easy": ["Rugby", "Football", "Netball"],
      "medium": ["Guts", "Freestyle", "Golf variant"],
      "hard": ["Beach version", "Indoor version"]
    }
  },
  {
    "word": "Pickleball",
    "category": "sports_games",
    "subcategory": "Racket sports",
    "difficulty": "easy",
    "description": "A paddle sport on a small court combining elements of tennis badminton and table tennis.",
    "tags": ["racket", "paddle", "court"],
    "hints": {
      "easy": ["Paddle", "Kitchen", "Dink", "Double bounce", "Senior sport", "Paddle sport"],
      "medium": ["Non-volley zone", "Third shot drop", "Ernie", "ATP", "Stacking", "Banger"],
      "hard": ["Two-bounce rule", "Side out", "Rally scoring", "Transition zone", "Reset", "Pickle point"]
    },
    "imposters": {
      "easy": ["Tennis", "Badminton", "Table tennis"],
      "medium": ["Padel", "Platform tennis", "Squash"],
      "hard": ["Mini version", "Short version"]
    }
  },
  {
    "word": "Croquet",
    "category": "sports_games",
    "subcategory": "Lawn games",
    "difficulty": "easy",
    "description": "A lawn game where players hit balls through hoops using wooden mallets.",
    "tags": ["lawn", "mallet", "ball"],
    "hints": {
      "easy": ["Hoops", "Mallet", "Lawn", "White clothes", "Garden party", "Stake"],
      "medium": ["Continuation", "Wicket", "Dead ball", "Peg out", "Rush", "Take-off"],
      "hard": ["Split shot", "Peel", "Triple peel", "Sextuple peel", "Roquet shot", "Croquet stroke"]
    },
    "imposters": {
      "easy": ["Golf", "Polo", "Bowls"],
      "medium": ["Gateball", "Woodball", "Beach variant"],
      "hard": ["Golf variant", "Association variant"]
    }
  },
  {
    "word": "Mini golf",
    "category": "sports_games",
    "subcategory": "Golf variants",
    "difficulty": "easy",
    "description": "A putting game on artificial courses with obstacles tunnels and themed holes.",
    "tags": ["golf", "putting", "family"],
    "hints": {
      "easy": ["Windmill", "Putt putt", "Obstacles", "Score card", "Pencil", "Hole in one"],
      "medium": ["Bank shot", "Carpet green", "Themed hole", "Par two", "Mulligan", "Clown mouth"],
      "hard": ["Competitive putt", "USPMGA", "Concrete course", "Felt surface", "Bank angle", "Trick shot"]
    },
    "imposters": {
      "easy": ["Snooker", "Bowling", "Croquet"],
      "medium": ["Adventure golf", "Crazy golf", "Pitch variant"],
      "hard": ["Short game", "Green putting"]
    }
  },
  {
    "word": "Go karting",
    "category": "sports_games",
    "subcategory": "Motor sports",
    "difficulty": "easy",
    "description": "Racing small open-wheel vehicles on a paved circuit for recreation or competition.",
    "tags": ["motorsport", "racing", "kart"],
    "hints": {
      "easy": ["Track", "Helmet", "Steering wheel", "Pedals", "Lap time", "Vehicle rental"],
      "medium": ["Racing line", "Apex", "Slipstream", "Hairpin", "Chicane", "Slick tyres"],
      "hard": ["Two-stroke", "Shifter vehicle", "Rotax", "Cadet class", "Weight distribution", "Tyre pressure"]
    },
    "imposters": {
      "easy": ["Formula one", "Bumper cars", "Motocross"],
      "medium": ["Indoor karting", "Outdoor karting", "Enduro karting"],
      "hard": ["Superkart", "Gearbox kart"]
    }
  },
  {
    "word": "Esports",
    "category": "sports_games",
    "subcategory": "Competitive gaming",
    "difficulty": "easy",
    "description": "Organized competitive video gaming with professional players teams and tournaments.",
    "tags": ["gaming", "competitive", "digital"],
    "hints": {
      "easy": ["Tournament", "Pro player", "Streaming", "Headset", "Mouse", "Keyboard"],
      "medium": ["LAN event", "Prize pool", "Meta", "Patch notes", "Scrim", "Coach"],
      "hard": ["APM", "KDA", "Draft phase", "Ban pick", "Stage fright", "Crowd chant"]
    },
    "imposters": {
      "easy": ["Chess", "Poker", "Arcade"],
      "medium": ["Speedrunning", "Fighting games", "MOBA"],
      "hard": ["Sim racing", "Online chess"]
    }
  },
  {
    "word": "Channel swim",
    "category": "sports_games",
    "subcategory": "Open water swimming",
    "difficulty": "hard",
    "description": "A long-distance swim across the English Channel between England and France.",
    "tags": ["swimming", "endurance", "channel"],
    "hints": {
      "easy": ["Dover", "Calais", "Cold water", "Pilot boat", "Feeding stops", "Tide"],
      "medium": ["Tide charts", "Jellyfish", "Shipping lanes", "Spring tides", "Neap tides", "Observer"],
      "hard": ["Captain Webb", "Trent Grimsey", "Ratios", "Ratification", "Anti-doping", "CS PF"]
    },
    "imposters": {
      "easy": ["Triathlon", "Rowing", "Diving"],
      "medium": ["Marathon swim", "Lake swim", "Ice swimming"],
      "hard": ["North Channel", "Catalina Channel"]
    }
  },
  {
    "word": "Steeplechase",
    "category": "sports_games",
    "subcategory": "Athletics",
    "difficulty": "medium",
    "description": "A track race with barriers and a water jump that athletes must clear each lap.",
    "tags": ["athletics", "track", "barriers"],
    "hints": {
      "easy": ["Water jump", "Barriers", "Track", "Splash", "Olympics", "Laps"],
      "medium": ["Barrier clearance", "Lead leg", "Trail leg", "Water pit", "Kenyan dominance", "Fall recovery"],
      "hard": ["Three thousand metres", "Hurdle rhythm", "Soggy shoes", "Fosbury technique", "Obstacle", "Steeple"]
    },
    "imposters": {
      "easy": ["Hurdles", "Marathon", "Relay"],
      "medium": ["Cross country", "Mud run", "Obstacle course"],
      "hard": ["Chase event", "Horse chase"]
    }
  },
  {
    "word": "Biathlon",
    "category": "sports_games",
    "subcategory": "Winter sports",
    "difficulty": "medium",
    "description": "A winter sport combining cross-country skiing with rifle target shooting.",
    "tags": ["winter", "skiing", "shooting"],
    "hints": {
      "easy": ["Rifle", "Skiing", "Shooting", "Targets", "Olympics", "Snow"],
      "medium": ["Prone position", "Standing shoot", "Penalty loop", "Zeroing", "Clip", "Heart rate"],
      "hard": ["Fortner action", "Anschutz", "Split times", "Range time", "Ski wax", "Vasaloppet"]
    },
    "imposters": {
      "easy": ["Triathlon", "Skiing", "Archery"],
      "medium": ["Duathlon", "Ski archery", "Winter duathlon"],
      "hard": ["Mass start", "Sprint event"]
    }
  },
  {
    "word": "Bobsleigh",
    "category": "sports_games",
    "subcategory": "Winter sports",
    "difficulty": "medium",
    "description": "A winter sport where teams race down an ice track in a steerable sled.",
    "tags": ["winter", "ice", "sled"],
    "hints": {
      "easy": ["Ice track", "Push start", "Helmet", "Team", "Four man", "Two man"],
      "medium": ["Brakeman", "Pilot", "Sled runners", "Ice crystals", "G-force", "Kreisel"],
      "hard": ["Cowling", "Pod", "Runners", "Articulated", "FIBT", "St Moritz"]
    },
    "imposters": {
      "easy": ["Luge", "Skeleton", "Sledding"],
      "medium": ["Monobob", "Four-person", "Two-person"],
      "hard": ["Bobsled", "Ice vehicle"]
    }
  },
  {
    "word": "Luge",
    "category": "sports_games",
    "subcategory": "Winter sports",
    "difficulty": "medium",
    "description": "A winter sport where a rider slides feet-first down an ice track on a small sled.",
    "tags": ["winter", "ice", "sled"],
    "hints": {
      "easy": ["Feet first", "Ice track", "Helmet", "Speed", "Olympics", "Sled"],
      "medium": ["Steering", "Calf pressure", "Shoulder shift", "Start handles", "Ice friction", "Doubles"],
      "hard": ["Kufen", "Pod position", "Aerodynamic", "Natural track", "Artificial track", "FIL"]
    },
    "imposters": {
      "easy": ["Bobsleigh", "Skeleton", "Sledding"],
      "medium": ["Natural variant", "Street variant", "Summer variant"],
      "hard": ["Skeleton push", "Start technique"]
    }
  },
  {
    "word": "Sledding",
    "category": "sports_games",
    "subcategory": "Winter recreation",
    "difficulty": "easy",
    "description": "Sliding down snowy slopes on a sled toboggan or similar device.",
    "tags": ["winter", "snow", "recreation"],
    "hints": {
      "easy": ["Snow hill", "Toboggan", "Saucer", "Family fun", "Winter day", "Pull rope"],
      "medium": ["Steering", "Braking", "Snow conditions", "Hill gradient", "Runner wax", "Drifting"],
      "hard": ["Toboggan run", "Bob run", "Natural track", "Artificial track", "Skeleton sled", "Luge sled"]
    },
    "imposters": {
      "easy": ["Skiing", "Luge", "Snowboarding"],
      "medium": ["Tobogganing", "Snow tubing", "Inner tube"],
      "hard": ["Recreational luge", "Backyard sled"]
    }
  },
  {
    "word": "Rollerblading",
    "category": "sports_games",
    "subcategory": "Wheel sports",
    "difficulty": "easy",
    "description": "Skating on inline wheels attached to boots for recreation fitness or sport.",
    "tags": ["wheels", "inline", "skating"],
    "hints": {
      "easy": ["Inline skates", "Park trail", "Helmet", "Knee pads", "Wrist guards", "Heel brake"],
      "medium": ["Cross training", "Aggressive skating", "Urban skating", "Frame", "Wheel rotation", "Freestyle slalom"],
      "hard": ["Rockered setup", "Flat setup", "Hi-lo", "Powerslide", "T-stop", "Soul grind"]
    },
    "imposters": {
      "easy": ["Skateboarding", "Ice skating", "Cycling"],
      "medium": ["Roller hockey", "Inline racing", "Aggressive inline"],
      "hard": ["Inline speed", "Artistic inline"]
    }
  },
  {
    "word": "Parkour",
    "category": "sports_games",
    "subcategory": "Urban sports",
    "difficulty": "medium",
    "description": "A discipline of moving efficiently through environments by running jumping and climbing.",
    "tags": ["movement", "urban", "freerunning"],
    "hints": {
      "easy": ["Urban", "Roof jumps", "Wall run", "Vault", "Precision landing", "Traceur"],
      "medium": ["Flow", "Kong vault", "Cat leap", "Tic tac", "Roll", "Quadrupedal"],
      "hard": ["Lache", "Stride", "Dyno", "Arm jump", "Drop", "PK"]
    },
    "imposters": {
      "easy": ["Gymnastics", "Skateboarding", "Climbing"],
      "medium": ["Freerunning", "Tricking", "Obstacle racing"],
      "hard": ["Art du deplacement", "Yamakasi"]
    }
  },
  {
    "word": "Bouldering",
    "category": "sports_games",
    "subcategory": "Climbing",
    "difficulty": "medium",
    "description": "Rock climbing on small formations without ropes using crash pads for protection.",
    "tags": ["climbing", "rock", "gym"],
    "hints": {
      "easy": ["Crash pad", "Chalk bag", "Climbing gym", "Problem", "Send", "Spotter"],
      "medium": ["V-grade", "Crux", "Mantel", "Dyno", "Heel hook", "Toe hook"],
      "hard": ["Fontainebleau", "Hueco Tanks", "Project", "Flash", "Onsight", "Redpoint"]
    },
    "imposters": {
      "easy": ["Rock climbing", "Parkour", "Hiking"],
      "medium": ["Indoor bouldering", "Outdoor bouldering", "Deep water solo"],
      "hard": ["Highball", "Traverse"]
    }
  },
  {
    "word": "Ice hockey",
    "category": "sports_games",
    "subcategory": "Team sports",
    "difficulty": "easy",
    "description": "A fast team game on ice where players use sticks to shoot a puck into a net.",
    "tags": ["ice", "team", "puck"],
    "hints": {
      "easy": ["Puck", "Skates", "Stick", "Rink", "Goalie", "Penalty box"],
      "medium": ["Face-off", "Power play", "Icing", "Offside", "Slapshot", "Hat trick"],
      "hard": ["Forecheck", "Backcheck", "Neutral zone", "Dump and chase", "Cycle", "Gretzky"]
    },
    "imposters": {
      "easy": ["Field hockey", "Curling", "Lacrosse"],
      "medium": ["Roller hockey", "Bandy", "Ringette"],
      "hard": ["Inline hockey", "Ball hockey"]
    }
  },
  {
    "word": "Field hockey",
    "category": "sports_games",
    "subcategory": "Team sports",
    "difficulty": "medium",
    "description": "A team game on grass or turf where players use curved sticks to hit a ball into a goal.",
    "tags": ["team", "stick", "ball"],
    "hints": {
      "easy": ["Stick", "Ball", "Turf", "Shin guards", "Goalkeeper", "Pitch"],
      "medium": ["Penalty corner", "Drag flick", "Indian dribble", "Reverse stick", "Obstruction", "Long corner"],
      "hard": ["Aerial", "Tomahawk", "Jab tackle", "Channel", "Press", "FIH"]
    },
    "imposters": {
      "easy": ["Ice hockey", "Lacrosse", "Polo"],
      "medium": ["Indoor hockey", "Bandy", "Floorball"],
      "hard": ["Hockey five", "Masters hockey"]
    }
  },
  {
    "word": "Beach volleyball",
    "category": "sports_games",
    "subcategory": "Beach sports",
    "difficulty": "easy",
    "description": "A team sport on sand where two players per side hit a ball over a high net.",
    "tags": ["beach", "sand", "volleyball"],
    "hints": {
      "easy": ["Sand", "Two players", "Bikini", "Sun", "Ocean", "Olympics"],
      "medium": ["Side out", "Block", "Dig", "Set", "Spike", "Wind"],
      "hard": ["Peel", "Pull", "Signal", "Husband and wife", "Deep court", "Float serve"]
    },
    "imposters": {
      "easy": ["Netball", "Badminton", "Handball"],
      "medium": ["Indoor volleyball", "Snow volleyball", "Footvolley"],
      "hard": ["Beach doubles", "King of the court"]
    }
  },
  {
    "word": "Bowls",
    "category": "sports_games",
    "subcategory": "Lawn games",
    "difficulty": "easy",
    "description": "A precision game where players roll biased balls toward a smaller target ball.",
    "tags": ["lawn", "precision", "ball"],
    "hints": {
      "easy": ["Green", "Jack", "Bias", "Mat", "Rink", "White shoes"],
      "medium": ["Draw shot", "Drive", "Block", "Wick", "Measure", "End"],
      "hard": ["Grass line", "Weight control", "Head", "Shot", "Toucher", "Dead end"]
    },
    "imposters": {
      "easy": ["Bocce", "Croquet", "Curling"],
      "medium": ["Lawn bowls", "Indoor bowls", "Short mat"],
      "hard": ["Crown green", "Flat green"]
    }
  },
  {
    "word": "Bocce",
    "category": "sports_games",
    "subcategory": "Lawn games",
    "difficulty": "easy",
    "description": "An Italian lawn game where players toss balls to land closest to a target ball.",
    "tags": ["lawn", "italian", "ball"],
    "hints": {
      "easy": ["Pallino", "Court", "Toss", "Underhand", "Italian", "Backyard"],
      "medium": ["Volo", "Raffa", "Pointing", "Shooting", "Measure", "Frame"],
      "hard": ["Boccia", "Petanque", "Boules", "Carreau", "Fanny", "Terrain"]
    },
    "imposters": {
      "easy": ["Bowls", "Croquet", "Curling"],
      "medium": ["Petanque", "Boules", "Lawn bowling"],
      "hard": ["Bocce volo", "Bocce raffa"]
    }
  },
  {
    "word": "Gymkhana",
    "category": "sports_games",
    "subcategory": "Equestrian",
    "difficulty": "hard",
    "description": "An equestrian event with timed games testing horse and rider skill and speed.",
    "tags": ["equestrian", "horse", "games"],
    "hints": {
      "easy": ["Horse", "Games", "Speed", "Pony club", "Timed", "Bending poles"],
      "medium": ["Barrel racing", "Pole bending", "Keyhole", "Flag race", "Sack race", "Musical chairs"],
      "hard": ["O-Mok-See", "Rescue race", "Boot race", "Egg and spoon", "Dismount", "Mount"]
    },
    "imposters": {
      "easy": ["Rodeo", "Polo", "Show jumping"],
      "medium": ["Mounted games", "Pony games", "Horse agility"],
      "hard": ["Tent pegging", "Skill at arms"]
    }
  },
  {
    "word": "Show jumping",
    "category": "sports_games",
    "subcategory": "Equestrian",
    "difficulty": "medium",
    "description": "An equestrian sport where horse and rider jump a course of fences within a time limit.",
    "tags": ["equestrian", "horse", "jumping"],
    "hints": {
      "easy": ["Fences", "Horse", "Rider", "Clear round", "Knock down", "Time fault"],
      "medium": ["Oxer", "Vertical", "Combination", "Stride", "Approach", "Landing"],
      "hard": ["Liverpool", "Triple bar", "Water jump", "Related distance", "Jump-off", "FEI"]
    },
    "imposters": {
      "easy": ["Dressage", "Polo", "Horse racing"],
      "medium": ["Eventing", "Hunter", "Equitation"],
      "hard": ["Prix St-Georges", "Grand prix jumping"]
    }
  },
  {
    "word": "Dressage",
    "category": "sports_games",
    "subcategory": "Equestrian",
    "difficulty": "medium",
    "description": "An equestrian discipline where horse and rider perform a set sequence of precise movements.",
    "tags": ["equestrian", "horse", "precision"],
    "hints": {
      "easy": ["Horse", "Dance", "Arena", "Movements", "Judges", "Tailcoat"],
      "medium": ["Piaffe", "Passage", "Half-pass", "Flying change", "Extended trot", "Collection"],
      "hard": ["Grand prix", "Freestyle", "Pirouette", "Tempi changes", "Harmony", "FEI"]
    },
    "imposters": {
      "easy": ["Show jumping", "Polo", "Rodeo"],
      "medium": ["Eventing", "Western dressage", "Prix caprilli"],
      "hard": ["Intermediaire", "Grand prix special"]
    }
  },
  {
    "word": "Pentathlon",
    "category": "sports_games",
    "subcategory": "Multi-sport",
    "difficulty": "medium",
    "description": "A contest of five events testing diverse athletic skills in a single competition.",
    "tags": ["multisport", "five", "olympic"],
    "hints": {
      "easy": ["Five events", "Olympics", "Fencing", "Swimming", "Riding", "Running"],
      "medium": ["Shooting", "Laser pistol", "Modern pentathlon", "Points", "Handicap start", "Final event"],
      "hard": ["Coubertin", "Ancient pentathlon", "Discus", "Javelin", "Wrestling", "Stadion"]
    },
    "imposters": {
      "easy": ["Decathlon", "Triathlon", "Biathlon"],
      "medium": ["Heptathlon", "Tetrathlon", "Quadrathlon"],
      "hard": ["Modern pentathlon", "Ancient pentathlon"]
    }
  },
  {
    "word": "Racquetball",
    "category": "sports_games",
    "subcategory": "Racket sports",
    "difficulty": "medium",
    "description": "An indoor racket sport played with a hollow rubber ball on a four-walled court.",
    "tags": ["racket", "indoor", "court"],
    "hints": {
      "easy": ["Racket", "Ball", "Court", "Wall", "Serve", "Goggles"],
      "medium": ["Ceiling shot", "Kill shot", "Z-serve", "Drive serve", "Lob serve", "Hinder"],
      "hard": ["Pinch shot", "Splat", "Around the world", "Three wall", "Cutthroat", "Doubles"]
    },
    "imposters": {
      "easy": ["Squash", "Tennis", "Handball"],
      "medium": ["Padel", "Frontenis", "One wall"],
      "hard": ["American handball", "Racketball UK"]
    }
  },
  {
    "word": "Sepak takraw",
    "category": "sports_games",
    "subcategory": "Southeast Asian sports",
    "difficulty": "hard",
    "description": "A Southeast Asian sport where teams kick a rattan ball over a net using feet and head.",
    "tags": ["southeast-asia", "kick", "net"],
    "hints": {
      "easy": ["Rattan ball", "Kick", "Net", "Thailand", "Malaysia", "Bicycle kick"],
      "medium": ["Three players", "Regu", "Spike", "Service", "Inside kick", "Head"],
      "hard": ["Tekong", "Feeder", "Killer", "Roll spike", "Sunback", "ISTAF"]
    },
    "imposters": {
      "easy": ["Volleyball", "Football", "Badminton"],
      "medium": ["Footvolley", "Jianzi", "Sipa"],
      "hard": ["Sepak raga", "Chinlone"]
    }
  },
  {
    "word": "Hurling",
    "category": "sports_games",
    "subcategory": "Gaelic games",
    "difficulty": "hard",
    "description": "An Irish field game where players use a wooden stick to hit a small ball between goals.",
    "tags": ["irish", "stick", "field"],
    "hints": {
      "easy": ["Ireland", "Stick", "Ball", "Helmet", "Goals", "Fast"],
      "medium": ["Camán", "Sliotar", "County", "All-Ireland", "Croke Park", "Ash wood"],
      "hard": ["Puck", "Solo", "Hand pass", "Shoulder charge", "Square ball", "GAA"]
    },
    "imposters": {
      "easy": ["Hockey", "Lacrosse", "Cricket"],
      "medium": ["Shinty", "Camogie", "Field hockey"],
      "hard": ["Hurling stick", "Ground hurling"]
    }
  },
  {
    "word": "Gaelic football",
    "category": "sports_games",
    "subcategory": "Gaelic games",
    "difficulty": "medium",
    "description": "An Irish team sport combining carrying kicking and hand-passing a ball to score.",
    "tags": ["irish", "team", "ball"],
    "hints": {
      "easy": ["Ireland", "Ball", "County", "Goals", "Points", "Croke Park"],
      "medium": ["Solo", "Hand pass", "Fist pass", "Pick up", "Shoulder charge", "Mark"],
      "hard": ["Sam Maguire", "All-Ireland", "GAA", "Inter-county", "Club", "Provincial"]
    },
    "imposters": {
      "easy": ["Rugby", "Lacrosse", "Hurling"],
      "medium": ["Aussie rules", "International rules", "Soccer"],
      "hard": ["Gaelic", "Peil ghaelach"]
    }
  },
  {
    "word": "Kho kho",
    "category": "sports_games",
    "subcategory": "Traditional games",
    "difficulty": "hard",
    "description": "A South Asian tag game where chasers pursue defenders around poles in a rectangular court.",
    "tags": ["india", "tag", "traditional"],
    "hints": {
      "easy": ["India", "Tag", "Poles", "Chaser", "Runner", "Kho"],
      "medium": ["Active chaser", "Defender", "Pole dive", "Chain", "Batch", "Innings"],
      "hard": ["Cross lane", "Central lane", "Post", "Kho call", "Early kho", "Late kho"]
    },
    "imposters": {
      "easy": ["Kabaddi", "Tag", "Dodgeball"],
      "medium": ["Atya patya", "Langdi", "Nadi"],
      "hard": ["Kho kho federation", "Ultimate kho kho"]
    }
  },
  {
    "word": "Gilli danda",
    "category": "sports_games",
    "subcategory": "Traditional games",
    "difficulty": "hard",
    "description": "A South Asian stick game where a small wooden piece is struck and hit in the air.",
    "tags": ["india", "stick", "traditional"],
    "hints": {
      "easy": ["India", "Stick", "Wood", "Hit", "Air", "Field"],
      "medium": ["Gilli", "Danda", "Striker", "Fielder", "Catch", "Distance"],
      "hard": ["Tipcat", "Lippa", "Kuttiyum kolum", "Dandi biyo", "Guti", "Gullach"]
    },
    "imposters": {
      "easy": ["Cricket", "Baseball", "Hockey"],
      "medium": ["Tip-cat", "Knurr and spell", "Cat and dog"],
      "hard": ["Gilli piece", "Danda stick"]
    }
  },
  {
    "word": "Carrom",
    "category": "sports_games",
    "subcategory": "Tabletop games",
    "difficulty": "medium",
    "description": "A tabletop game where players flick discs into corner pockets using a striker.",
    "tags": ["tabletop", "disc", "flick"],
    "hints": {
      "easy": ["Board", "Striker", "Pockets", "Discs", "Queen", "Powder"],
      "medium": ["Flick", "Cover", "Due", "Foul", "Break", "Turn"],
      "hard": ["Carrom men", "Queen cover", "Double due", "Bank shot", "Cut shot", "ICF"]
    },
    "imposters": {
      "easy": ["Billiards", "Chess", "Ludo"],
      "medium": ["Novuss", "Crokinole", "Pichenotte"],
      "hard": ["Carrom board", "Striker shot"]
    }
  },
  {
    "word": "Ludo",
    "category": "sports_games",
    "subcategory": "Board games",
    "difficulty": "easy",
    "description": "A board game where players race four tokens from start to finish according to dice rolls.",
    "tags": ["board-game", "dice", "race"],
    "hints": {
      "easy": ["Dice", "Tokens", "Board", "Home", "Six", "Family game"],
      "medium": ["Safe square", "Capture", "Block", "Star", "Double", "Strategy"],
      "hard": ["Pachisi", "Chaupar", "Parcheesi", "Sorry", "Trouble", "Mensch"]
    },
    "imposters": {
      "easy": ["Backgammon", "Carrom", "Chess"],
      "medium": ["Pachisi", "Chaupar", "Uckers"],
      "hard": ["Ludo star", "Royal ludo"]
    }
  },
  {
    "word": "Rummy",
    "category": "sports_games",
    "subcategory": "Card games",
    "difficulty": "easy",
    "description": "A card game where players form matching sets and runs to be the first to discard all cards.",
    "tags": ["card-game", "sets", "runs"],
    "hints": {
      "easy": ["Cards", "Sets", "Runs", "Discard", "Draw", "Meld"],
      "medium": ["Pure sequence", "Impure sequence", "Joker", "Drop", "Points", "Declare"],
      "hard": ["Gin rummy", "Indian rummy", "Canasta", "Kalooki", "Contract rummy", "500 rum"]
    },
    "imposters": {
      "easy": ["Poker", "Bridge", "Solitaire"],
      "medium": ["Gin", "Canasta", "Conquian"],
      "hard": ["Rummy 500", "Oklahoma gin"]
    }
  },
  {
    "word": "Boomerang",
    "category": "sports_games",
    "subcategory": "Throwing sports",
    "difficulty": "medium",
    "description": "A curved throwing stick designed to return to the thrower when launched correctly.",
    "tags": ["throwing", "australian", "return"],
    "hints": {
      "easy": ["Return", "Aboriginal", "Throw", "Curve", "Catch", "Hunting"],
      "medium": ["Aerofoil", "Gyroscopic", "Wind", "Tuning", "Flight path", "Left handed"],
      "hard": ["MTA", "Trick catch", "Aussie round", "Fast catch", "Endurance", "Accuracy"]
    },
    "imposters": {
      "easy": ["Frisbee", "Javelin", "Kite"],
      "medium": ["Throwing stick", "Kylie", "Non-returning"],
      "hard": ["Boomerang throw", "Competition boomerang"]
    }
  },
  {
    "word": "Jump rope",
    "category": "sports_games",
    "subcategory": "Playground games",
    "difficulty": "easy",
    "description": "A game or exercise of jumping over a rope swung under the feet and over the head.",
    "tags": ["jumping", "rope", "fitness"],
    "hints": {
      "easy": ["Rope", "Skip", "Playground", "Handles", "Rhythm", "Double dutch"],
      "medium": ["Single unders", "Cross overs", "Speed", "Freestyle", "Beaded rope", "Wire rope"],
      "hard": ["Triple unders", "Side swing", "Criss cross", "Toad", "EB", "IJRU"]
    },
    "imposters": {
      "easy": ["Hopscotch", "Trampoline", "Hula hoop"],
      "medium": ["Skipping", "Double dutch", "Chinese wheel"],
      "hard": ["Speed rope", "Freestyle rope"]
    }
  },
  {
    "word": "Hula hoop",
    "category": "sports_games",
    "subcategory": "Playground games",
    "difficulty": "easy",
    "description": "A plastic ring twirled around the waist hips or limbs by rotating the body.",
    "tags": ["hoop", "waist", "twirl"],
    "hints": {
      "easy": ["Waist", "Circle", "Spin", "Plastic", "Colourful", "Childhood"],
      "medium": ["Hooping", "Tricks", "Isolations", "Flow", "LED hoop", "Polypro"],
      "hard": ["Off-body", "On-body", "Toss", "Roll", "Wedgie", "Escalator"]
    },
    "imposters": {
      "easy": ["Jump rope", "Frisbee", "Yo yo"],
      "medium": ["Hoop dance", "Circus hoop", "Fitness hoop"],
      "hard": ["Hoop trick", "Hoop spinning"]
    }
  },
  {
    "word": "Trampoline",
    "category": "sports_games",
    "subcategory": "Gymnastics",
    "difficulty": "easy",
    "description": "A springy fabric sheet on a frame used for jumping and performing aerial acrobatics.",
    "tags": ["gymnastics", "jumping", "acrobatics"],
    "hints": {
      "easy": ["Bounce", "Spring", "Backyard", "Somersault", "Safety net", "Fun"],
      "medium": ["Bed", "Frame", "Springs", "Routine", "Difficulty", "Execution"],
      "hard": ["Double mini", "Synchronised", "Time of flight", "Horizontal displacement", "Difficulty score", "FIG"]
    },
    "imposters": {
      "easy": ["Gymnastics", "Bouncy castle", "Diving"],
      "medium": ["Tumbling", "Power tumbling", "Double mini tramp"],
      "hard": ["Trampoline park", "Competitive trampoline"]
    }
  },
  {
    "word": "Obstacle race",
    "category": "sports_games",
    "subcategory": "Endurance events",
    "difficulty": "medium",
    "description": "A running event featuring walls mud ropes and other physical challenges along the course.",
    "tags": ["running", "obstacles", "mud"],
    "hints": {
      "easy": ["Mud", "Walls", "Rope climb", "Barbed wire", "Fire", "Team"],
      "medium": ["Spartan", "Tough Mudder", "Warrior Dash", "Burpee penalty", "Spear throw", "Bucket carry"],
      "hard": ["OCR", "Age group", "Elite heat", "Obstacle proficiency", "Mandatory obstacle", "Trifecta"]
    },
    "imposters": {
      "easy": ["Marathon", "Triathlon", "Steeplechase"],
      "medium": ["Mud run", "Adventure race", "Ninja warrior"],
      "hard": ["Spartan race", "Obstacle course racing"]
    }
  }
]

with open('tool/words/replies/010_sports.json', 'w') as f:
    json.dump(data_010, f, indent=2)
print('Wrote 010_sports.json with', len(data_010), 'records')

# FIXED 011_sports.json - 22 records from fix_011_sports.txt
data_011 = [
  {
    "word": "Rally",
    "category": "sports_games",
    "subcategory": "Motor sports",
    "difficulty": "medium",
    "description": "Automobile racing on public or private roads with production-derived cars and co-drivers.",
    "tags": ["motorsport", "racing", "car"],
    "hints": {
      "easy": ["Dirt roads", "Co-driver", "Notes", "Stage", "Service park", "Drifting"],
      "medium": ["Pace notes", "Gravel", "Snow bank", "Jump", "Tyre choice", "Recce"],
      "hard": ["Time control", "Road section", "Flat out", "Handbrake turn", "Ditch", "Service"]
    },
    "imposters": {
      "easy": ["Formula one", "Motocross", "Karting"],
      "medium": ["Rallycross", "Hillclimb", "Enduro"],
      "hard": ["Raid event", "Championship"]
    }
  },
  {
    "word": "Drag racing",
    "category": "sports_games",
    "subcategory": "Motor sports",
    "difficulty": "easy",
    "description": "A race over a short straight track between two vehicles from a standing start.",
    "tags": ["motorsport", "racing", "speed"],
    "hints": {
      "easy": ["Quarter mile", "Christmas tree", "Burnout", "Top fuel", "Speed", "Finish line"],
      "medium": ["Reaction time", "Parachute", "Strip", "Funny car", "Pro stock", "Elapsed time"],
      "hard": ["Staging beams", "Nitromethane", "Wheelie bars", "Launch", "Trap speed", "Dial in"]
    },
    "imposters": {
      "easy": ["Rally", "Formula one", "Karting"],
      "medium": ["Street racing", "Grudge racing", "Bracket racing"],
      "hard": ["Pro modified", "Funny car class"]
    }
  },
  {
    "word": "Jet skiing",
    "category": "sports_games",
    "subcategory": "Water sports",
    "difficulty": "easy",
    "description": "Riding a small personal watercraft across water while seated or standing.",
    "tags": ["water", "motor", "speed"],
    "hints": {
      "easy": ["Water", "Waves", "Throttle", "Life jacket", "Handlebars", "Personal craft"],
      "medium": ["Buoy", "Slalom", "Stand-up", "Sit-down", "Wake", "Spray"],
      "hard": ["PWC", "Kawasaki", "Yamaha", "BRP", "Freestyle", "Competition"]
    },
    "imposters": {
      "easy": ["Kayaking", "Waterskiing", "Surfing"],
      "medium": ["Powerboating", "Wakeboarding", "Seadoo"],
      "hard": ["Ski racing", "Freestyle event"]
    }
  },
  {
    "word": "Waterskiing",
    "category": "sports_games",
    "subcategory": "Water sports",
    "difficulty": "easy",
    "description": "Being pulled across water by a boat while gliding on skis.",
    "tags": ["water", "boat", "skiing"],
    "hints": {
      "easy": ["Boat", "Tow rope", "Lake", "Speed", "Standing", "Tow"],
      "medium": ["Slalom ski", "Trick ski", "Jump ramp", "Wake", "Cross", "Start"],
      "hard": ["Binding", "Handle", "Pylon", "Speedometer", "Course", "Buoy"]
    },
    "imposters": {
      "easy": ["Wakeboarding", "Jet skiing", "Surfing"],
      "medium": ["Barefoot variant", "Kneeboarding", "Wake surfing"],
      "hard": ["Trick variant", "Slalom variant"]
    }
  },
  {
    "word": "Wakeboarding",
    "category": "sports_games",
    "subcategory": "Water sports",
    "difficulty": "easy",
    "description": "Riding a board while being towed by a motorboat on the water's surface.",
    "tags": ["water", "board", "extreme"],
    "hints": {
      "easy": ["Boat", "Tow rope", "Wake", "Jump", "Extreme", "Tow"],
      "medium": ["Bindings", "Edge", "Ollie", "Grab", "Surface trick", "Handle pass"],
      "hard": ["Invert", "Backroll", "Railey", "Slider", "Kicker", "Cable park"]
    },
    "imposters": {
      "easy": ["Waterskiing", "Snowboarding", "Surfing"],
      "medium": ["Wakeskating", "Wakesurfing", "Kneeboarding"],
      "hard": ["Cable variant", "Boat variant"]
    }
  },
  {
    "word": "Cliff diving",
    "category": "sports_games",
    "subcategory": "Extreme sports",
    "difficulty": "medium",
    "description": "Jumping from a very high natural cliff into water below.",
    "tags": ["water", "extreme", "diving"],
    "hints": {
      "easy": ["Height", "Water", "Jump", "Adrenaline", "Splash", "Rock face"],
      "medium": ["Vertical", "Entry", "Trajectory", "Deep water", "Safety", "Skill"],
      "hard": ["Platform", "Tuck", "Pike", "Impact", "Acclimatisation", "Competition"]
    },
    "imposters": {
      "easy": ["Snorkeling", "Bungee jumping", "Skydiving"],
      "medium": ["High diving", "Platform diving", "Waterfall jumping"],
      "hard": ["Extreme diving", "Rock jumping"]
    }
  },
  {
    "word": "Speed skating",
    "category": "sports_games",
    "subcategory": "Winter sports",
    "difficulty": "medium",
    "description": "Racing on ice using long blades to achieve high speeds on a rink.",
    "tags": ["winter", "ice", "skating"],
    "hints": {
      "easy": ["Ice", "Skates", "Track", "Oval", "Race", "Blades"],
      "medium": ["Lap", "Straight", "Turn", "Clap skate", "Skin suit", "Arm swing"],
      "hard": ["Inner lane", "Outer lane", "Crossover", "Time", "Glide", "Push"]
    },
    "imposters": {
      "easy": ["Figure skating", "Cycling", "Skiing"],
      "medium": ["Inline variant", "Ice derby", "Derby"],
      "hard": ["Short track", "Long track"]
    }
  },
  {
    "word": "Cross country",
    "category": "sports_games",
    "subcategory": "Athletics",
    "difficulty": "easy",
    "description": "A footrace run over outdoor natural terrain like grass fields and dirt paths.",
    "tags": ["running", "terrain", "outdoor"],
    "hints": {
      "easy": ["Fields", "Mud", "Outdoors", "Course", "Race", "Running"],
      "medium": ["Spikes", "Hills", "Weather", "Pack", "Start", "Finish"],
      "hard": ["National", "Regional", "Terrain", "Off-road", "Distance", "Championship"]
    },
    "imposters": {
      "easy": ["Marathon", "Steeplechase", "Orienteering"],
      "medium": ["Trail running", "Fell running", "Road running"],
      "hard": ["XC race", "Cross-country"]
    }
  },
  {
    "word": "Golf putt",
    "category": "sports_games",
    "subcategory": "Golf",
    "difficulty": "easy",
    "description": "A gentle stroke on the green to roll a ball into the hole.",
    "tags": ["golf", "precision", "putting"],
    "hints": {
      "easy": ["Green", "Hole", "Ball", "Gentle", "Line", "Cup"],
      "medium": ["Read", "Speed", "Break", "Club", "Stance", "Grip"],
      "hard": ["Follow-through", "Fringe", "Apron", "Grain", "Touch", "Feel"]
    },
    "imposters": {
      "easy": ["Drive", "Chip", "Swing"],
      "medium": ["Lag putt", "Short putt", "Long putt"],
      "hard": ["Stroke", "Reading green"]
    }
  },
  {
    "word": "Penalty kick",
    "category": "sports_games",
    "subcategory": "Ball sports",
    "difficulty": "easy",
    "description": "A direct free kick taken from a spot inside the box against the goalkeeper.",
    "tags": ["football", "kick", "goal"],
    "hints": {
      "easy": ["Spot", "Goalie", "Goal", "Foul", "Referee", "Pressure"],
      "medium": ["Box", "Tension", "Run-up", "Target", "Score", "Save"],
      "hard": ["Stutter", "Fake", "Placement", "Crossbar", "Post", "Nerves"]
    },
    "imposters": {
      "easy": ["Free kick", "Corner", "Header"],
      "medium": ["Shootout", "Spot kick", "Direct kick"],
      "hard": ["PK", "Penalty shot"]
    }
  },
  {
    "word": "Slam dunk",
    "category": "sports_games",
    "subcategory": "Basketball",
    "difficulty": "easy",
    "description": "A powerful basketball move where a player jumps and forces the ball through the hoop.",
    "tags": ["basketball", "move", "score"],
    "hints": {
      "easy": ["Basketball", "Hoop", "Jump", "Force", "Score", "Power"],
      "medium": ["Rim", "Backboard", "Contest", "All-star", "Two points", "Height"],
      "hard": ["Alley-oop", "Reverse", "Tomahawk", "Windmill", "Posterize", "Hang"]
    },
    "imposters": {
      "easy": ["Layup", "Three pointer", "Rebound"],
      "medium": ["Jam", "Flush", "Dunk"],
      "hard": ["Poster dunk", "In-game dunk"]
    }
  },
  {
    "word": "Home run",
    "category": "sports_games",
    "subcategory": "Baseball",
    "difficulty": "easy",
    "description": "A hit in baseball allowing the batter to run all bases and score a run.",
    "tags": ["baseball", "hit", "score"],
    "hints": {
      "easy": ["Baseball", "Hit", "Bases", "Score", "Outfield", "Fence"],
      "medium": ["Batter", "Pitch", "Diamond", "Bat", "Runner", "Cycle"],
      "hard": ["Grand slam", "Walk-off", "Inside the park", "Wall", "Ballpark", "Stats"]
    },
    "imposters": {
      "easy": ["Strikeout", "Touchdown", "Goal"],
      "medium": ["Homer", "Four-bagger", "Run"],
      "hard": ["Grand slam", "Walk-off"]
    }
  },
  {
    "word": "Touchdown",
    "category": "sports_games",
    "subcategory": "American football",
    "difficulty": "easy",
    "description": "A score in American football achieved by carrying or catching the ball in the end zone.",
    "tags": ["football", "score", "field"],
    "hints": {
      "easy": ["End zone", "Score", "Ball", "Six points", "Celebration", "Field"],
      "medium": ["Catch", "Carry", "Line", "Goal", "Game", "Action"],
      "hard": ["Spike", "Dance", "Review", "Referee", "Clock", "Quarterback"]
    },
    "imposters": {
      "easy": ["Home run", "Goal", "Try"],
      "medium": ["Score play", "TD", "End zone play"],
      "hard": ["Catch score", "Rush score"]
    }
  },
  {
    "word": "Hat trick",
    "category": "sports_games",
    "subcategory": "Sporting moments",
    "difficulty": "easy",
    "description": "Three goals or successes by one player in a single match.",
    "tags": ["score", "achievement", "goals"],
    "hints": {
      "easy": ["Three", "Goals", "Success", "Player", "Match", "Score"],
      "medium": ["Game", "Record", "Ball", "Fans", "Celebration", "Performance"],
      "hard": ["Consecutive", "Period", "Stoppage", "Magic", "Legend", "Cap"]
    },
    "imposters": {
      "easy": ["Brace", "Double", "Treble"],
      "medium": ["Three goals", "Triple", "Three-peat"],
      "hard": ["Hat trick", "Treble"]
    }
  },
  {
    "word": "Knockout",
    "category": "sports_games",
    "subcategory": "Combat sports",
    "difficulty": "easy",
    "description": "A victory in fighting sports when an opponent is unable to continue.",
    "tags": ["fight", "victory", "combat"],
    "hints": {
      "easy": ["Fighter", "Down", "Victory", "Count", "Referee", "End"],
      "medium": ["Punch", "Kick", "Ring", "Canvas", "Win", "Unable"],
      "hard": ["Stoppage", "Decision", "Bell", "Corner", "Recovery", "Technical"]
    },
    "imposters": {
      "easy": ["Submission", "Tapout", "Decision"],
      "medium": ["TKO", "Win", "Stop"],
      "hard": ["Victory", "Technical stoppage"]
    }
  },
  {
    "word": "Olympics",
    "category": "sports_games",
    "subcategory": "Events",
    "difficulty": "easy",
    "description": "A major international multi-sport event held every four years.",
    "tags": ["event", "international", "sports"],
    "hints": {
      "easy": ["International", "Four years", "Gold medal", "Opening ceremony", "Athletes", "Games"],
      "medium": ["Rings", "Torch", "Host city", "Summer", "Winter", "Medals"],
      "hard": ["IOC", "Coubertin", "Paralympics", "Opening", "Closing", "Competition"]
    },
    "imposters": {
      "easy": ["World cup", "Paralympics", "Asian games"],
      "medium": ["Olympiad", "Sporting event", "Summer games"],
      "hard": ["World Games", "Pan Am Games"]
    }
  },
  {
    "word": "World cup",
    "category": "sports_games",
    "subcategory": "Events",
    "difficulty": "easy",
    "description": "A major international sporting championship held periodically.",
    "tags": ["event", "international", "championship"],
    "hints": {
      "easy": ["International", "Tournament", "Match", "Fans", "Trophy", "Winner"],
      "medium": ["Sport", "Teams", "Final", "Host", "Periodically", "Qualifier"],
      "hard": ["FIFA", "Rugby", "Cricket", "Group stage", "Knockout", "Champion"]
    },
    "imposters": {
      "easy": ["Olympics", "Champions league", "Super bowl"],
      "medium": ["Final", "Winner", "Champion"],
      "hard": ["World Championship", "Major event"]
    }
  },
  {
    "word": "Super bowl",
    "category": "sports_games",
    "subcategory": "Events",
    "difficulty": "easy",
    "description": "The annual championship game of the American National Football League.",
    "tags": ["event", "football", "championship"],
    "hints": {
      "easy": ["American football", "Annual", "Championship", "NFL", "Game", "Teams"],
      "medium": ["Final", "Winner", "Halftime", "Show", "Trophy", "Ring"],
      "hard": ["Tom Brady", "Commercials", "Sunday", "Viewers", "Stadium", "History"]
    },
    "imposters": {
      "easy": ["World cup", "Grand final", "Olympics"],
      "medium": ["NFL final", "Championship game", "Big game"],
      "hard": ["Pro Bowl", "Playoffs"]
    }
  },
  {
    "word": "Trophy",
    "category": "sports_games",
    "subcategory": "Sporting equipment",
    "difficulty": "easy",
    "description": "An object awarded to a winner of a competition as a prize.",
    "tags": ["award", "winner", "prize"],
    "hints": {
      "easy": ["Winner", "Prize", "Competition", "Winning", "Metal", "Cup"],
      "medium": ["Ceremony", "Display", "Victory", "Achievement", "Plinth", "Engraved"],
      "hard": ["Holding", "Champagne", "Medal", "Ribbon", "Reward", "Recognition"]
    },
    "imposters": {
      "easy": ["Medal", "Ribbon", "Plaque"],
      "medium": ["Award", "Prize", "Cup"],
      "hard": ["Reward", "Recognition"]
    }
  }
]

with open('tool/words/replies/011_sports.json', 'w') as f:
    json.dump(data_011, f, indent=2)
print('Wrote 011_sports.json with', len(data_011), 'records')