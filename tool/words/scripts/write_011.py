import json

data = [
  {
    "word": "Rally",
    "category": "sports_games",
    "subcategory": "Motor sports",
    "difficulty": "medium",
    "description": "Automobile racing on public or private roads with production-derived cars and co-drivers.",
    "tags": ["motorsport", "racing", "car"],
    "hints": {
      "easy": ["Dirt roads", "Co-driver", "Notes", "Stage", "Service park", "Drifting"],
      "medium": ["Pace notes", "WRC", "Gravel", "Snow bank", "Jump", "Tyre choice"],
      "hard": ["Recce", "Time control", "Road section", "Flat out", "Handbrake turn", "Ditch"]
    },
    "imposters": {
      "easy": ["Formula one", "Motocross", "Karting"],
      "medium": ["Rallycross", "Hillclimb", "Enduro"],
      "hard": ["Rally raid", "WRC"]
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
      "hard": ["Staging beams", "Nitromethane", "60-foot", "Drag slick", "Wheelie bars", "Launch"]
    },
    "imposters": {
      "easy": ["Rally", "Formula one", "Karting"],
      "medium": ["Street racing", "Grudge racing", "Bracket racing"],
      "hard": ["Pro mod", "Funny car"]
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
      "easy": ["Water", "Speed", "Personal watercraft", "Waves", "Throttle", "Life jacket"],
      "medium": ["Buoy", "Slalom", "Stand-up", "Sit-down", "Wake", "Spray"],
      "hard": ["PWC", "Kawasaki", "Yamaha", "BRP", "Freestyle", "Racing"]
    },
    "imposters": {
      "easy": ["Kayaking", "Waterskiing", "Surfing"],
      "medium": ["Powerboating", "Wakeboarding", "Seadoo"],
      "hard": ["Ski racing", "Freestyle PWC"]
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
      "easy": ["Boat", "Tow rope", "Skis", "Lake", "Speed", "Standing"],
      "medium": ["Slalom ski", "Trick ski", "Jump ramp", "Deep water start", "Wake", "Cross"],
      "hard": ["Binding", "Handle", "Pylon", "Speedometer", "Course", "Buoy"]
    },
    "imposters": {
      "easy": ["Wakeboarding", "Jet skiing", "Surfing"],
      "medium": ["Barefoot skiing", "Kneeboarding", "Wake surfing"],
      "hard": ["Trick skiing", "Slalom skiing"]
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
      "easy": ["Boat", "Tow rope", "Board", "Wake", "Jump", "Extreme"],
      "medium": ["Bindings", "Edge", "Ollie", "Grab", "Surface trick", "Handle pass"],
      "hard": ["Invert", "Backroll", "Railey", "Slider", "Kicker", "Cable park"]
    },
    "imposters": {
      "easy": ["Waterskiing", "Snowboarding", "Surfing"],
      "medium": ["Wakeskating", "Wakesurfing", "Kneeboarding"],
      "hard": ["Cable wakeboarding", "Boat wakeboarding"]
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
      "easy": ["Height", "Cliff", "Water", "Jump", "Adrenaline", "Splash"],
      "medium": ["Vertical", "Entry", "Trajectory", "Deep water", "Safety", "Skill"],
      "hard": ["Red Bull", "Platform", "Tuck", "Pike", "Impact", "Acclimatisation"]
    },
    "imposters": {
      "easy": ["Snorkeling", "Bungee jumping", "Skydiving"],
      "medium": ["High diving", "Platform diving", "Waterfall jumping"],
      "hard": ["Extreme diving", "Cliff jumping"]
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
      "easy": ["Ice", "Skates", "Speed", "Track", "Oval", "Race"],
      "medium": ["Lap", "Straight", "Turn", "Clap skate", "Skin suit", "Arm swing"],
      "hard": ["Short track", "Long track", "Inner lane", "Outer lane", "Crossover", "Time"]
    },
    "imposters": {
      "easy": ["Figure skating", "Cycling", "Skiing"],
      "medium": ["Inline speed skating", "Ice racing", "Derby"],
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
      "easy": ["Running", "Fields", "Mud", "Outdoors", "Course", "Race"],
      "medium": ["Spikes", "Hills", "Weather", "Pack", "Start", "Finish"],
      "hard": ["National", "Regional", "Terrain", "Off-road", "Distance", "Championship"]
    },
    "imposters": {
      "easy": ["Marathon", "Steeplechase", "Orienteering"],
      "medium": ["Trail running", "Fell running", "Road running"],
      "hard": ["XC", "Cross-country race"]
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
      "easy": ["Green", "Hole", "Putter", "Ball", "Stroke", "Gentle"],
      "medium": ["Read", "Line", "Speed", "Break", "Cup", "Club"],
      "hard": ["Stance", "Grip", "Follow-through", "Fringe", "Apron", "Grain"]
    },
    "imposters": {
      "easy": ["Drive", "Chip", "Swing"],
      "medium": ["Putting", "Lag putt", "Short putt"],
      "hard": ["Stroke", "Green reading"]
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
      "medium": ["Box", "Shootout", "Tension", "Run-up", "Target", "Score"],
      "hard": ["Stutter", "Fake", "Placement", "Crossbar", "Post", "Nerves"]
    },
    "imposters": {
      "easy": ["Free kick", "Corner", "Header"],
      "medium": ["Shootout", "Spot kick", "Direct free kick"],
      "hard": ["Penalty", "PK"]
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
      "medium": ["Dunk", "Jam", "Flush"],
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
      "medium": ["Batter", "Pitch", "Diamond", "Over", "Bat", "Run"],
      "hard": ["Grand slam", "Walk-off", "Inside the park", "Wall", "Ballpark", "Stats"]
    },
    "imposters": {
      "easy": ["Strikeout", "Touchdown", "Goal"],
      "medium": ["Run", "Homer", "Four-bagger"],
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
      "medium": ["Score", "TD", "End zone score"],
      "hard": ["Catch", "Rush"]
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
      "hard": ["Consecutive", "Period", "Stoppage", "Hat", "Magic", "Legend"]
    },
    "imposters": {
      "easy": ["Brace", "Double", "Treble"],
      "medium": ["Three goals", "Triple", "Three-peat"],
      "hard": ["Hat-trick", "Hat trick"]
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
      "hard": ["Technical", "Stoppage", "Decision", "Bell", "Corner", "Recovery"]
    },
    "imposters": {
      "easy": ["Submission", "Tapout", "Decision"],
      "medium": ["KO", "TKO", "Win"],
      "hard": ["Victory", "Technical knockout"]
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
      "medium": ["Games", "Olympiad", "Sporting event"],
      "hard": ["World Games", "Pan American Games"]
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
      "easy": ["International", "Championship", "Tournament", "Match", "Fans", "Trophy"],
      "medium": ["Sport", "Teams", "Final", "Host", "Winner", "Periodically"],
      "hard": ["FIFA", "Rugby", "Cricket", "Qualifier", "Group stage", "Knockout"]
    },
    "imposters": {
      "easy": ["Olympics", "Champions league", "Super bowl"],
      "medium": ["Championship", "Tournament", "Final"],
      "hard": ["World Championship", "Major"]
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
      "medium": ["NFL Championship", "Championship game", "Big game"],
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
      "easy": ["Award", "Winner", "Prize", "Competition", "Winning", "Object"],
      "medium": ["Metal", "Cup", "Ceremony", "Display", "Victory", "Achievement"],
      "hard": ["Plinth", "Engraved", "Holding", "Champagne", "Medal", "Ribbon"]
    },
    "imposters": {
      "easy": ["Medal", "Ribbon", "Plaque"],
      "medium": ["Award", "Prize", "Cup"],
      "hard": ["Reward", "Recognition"]
    }
  }
]

with open('tool/words/replies/011_sports.json', 'w') as f:
    json.dump(data, f, indent=2)

print(f'Wrote 011_sports.json with {len(data)} records')