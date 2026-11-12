import json, os

# Read the source pack file for hints and imposters
with open('assets/packs/movies_entertainment.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

words_data = data.get('words', [])

# Create lookup for words
word_lookup = {}
for w in words_data:
    word_lookup[w['word']] = w

# Define complete records for 008_movies.txt (50 words)
prompt_008_words = [
    'Sword fight', 'Kung fu', 'Samurai film', 'Spy movie', 'Monster movie', 'Pirate movie',
    'Dinosaur movie', 'Space opera', 'Fairy tale', 'Teen movie', 'Sports movie', 'Courtroom drama',
    'Disaster film', 'Martial arts', 'Bollywood', 'Hollywood', 'Anime', 'Cartoon', 'Sitcom',
    'Soap opera', 'Reality show', 'Game show', 'Talk show', 'Binge watch', 'Video streaming',
    'Movie night', 'Movie poster', 'Ticket stub', 'Movie glasses', 'Extended cut', 'Blooper',
    'Box set', 'Costume designer', 'Screenwriter', 'Movie star', 'Award show', 'Indie film',
    'Short film', 'Feature film', 'Horror villain', 'Jump scare', 'Haunted doll', 'Found footage',
    'Slasher', 'Ghost story', 'Love story', 'Tragedy', 'Satire', 'Slapstick', 'Underdog'
]

# Use predefined complete data including proper hints, imposters, descriptions, tags
# This is based on the legacy movies.json and assets/packs/movies_entertainment.json
complete_data = {
    'Sword fight': {
        'description': 'An action scene where opponents duel with bladed weapons.',
        'tags': ['action', 'combat', 'epic'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Fencing moves', 'Sparks fly', 'Clashing steel', 'Duel', 'Swashbuckler', 'Pirate ship', 'Knight armor'],
            'medium': ['Pirates and knights', 'Clashing blades', 'En garde', 'Riposte', 'Lunge', 'Parry', 'Zorro'],
            'hard': ['Action scene', 'Duel choreography', 'Swordsmanship', 'Rapier', 'Fencing master', 'Olympic fencing', 'Historical European martial arts']
        },
        'imposters': {
            'easy': ['Shootout', 'Fist fight', 'Archery', 'Wrestling'],
            'medium': ['Martial arts', 'Boxing match', 'Gunfight', 'Lightsaber duel'],
            'hard': ['Stage combat', 'Fencing bout', 'Kendo match', 'HEMA']
        }
    },
    'Kung fu': {
        'description': 'A Chinese martial art featuring acrobatic kicks and disciplined training.',
        'tags': ['martial-arts', 'action', 'fight'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Dubbed dialogue', 'Bamboo sets', 'Training masters', 'Flying kicks', 'Shaolin temple', 'Monk robe', 'Crane stance'],
            'medium': ['Bruce Lee', 'Jackie Chan', 'Wing Chun', 'Jeet Kune Do', 'Nunchaku', 'Qi gong', 'Iron palm'],
            'hard': ['Action genre', 'Wushu competition', 'Kung fu cinema', 'Shaw Brothers', 'Golden Harvest', 'Five Animals', 'Northern style']
        },
        'imposters': {
            'easy': ['Samurai film', 'Boxing film', 'Western', 'Sumo wrestling'],
            'medium': ['Martial arts', 'Karate film', 'Muay Thai film', 'Capoeira film'],
            'hard': ['Wushu', 'Kung fu comedy', 'Modern wuxia', 'Kung fu panda']
        }
    },
    'Samurai film': {
        'description': 'A Japanese film genre featuring honor-bound warriors and sword battles.',
        'tags': ['japanese', 'action', 'warrior'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Katana duels', 'Feudal villages', 'Ronin master', 'Honor code', 'Bushido way', 'Shogun era', 'Sword master'],
            'medium': ['Honor and duty', 'Masterless warriors', 'Seven Samurai', 'Akira Kurosawa', 'Seppuku ritual', 'Daimyo lord', 'Sengoku period'],
            'hard': ['Japanese genre', 'Sword epic', 'Jidaigeki', 'Chambara', 'Mifune Toshiro', 'Zatoichi', 'Yojimbo']
        },
        'imposters': {
            'easy': ['Kung fu', 'Western', 'War film', 'Ninja movie'],
            'medium': ['Samurai sword', 'Ronin', 'Shogun assassin', 'Lone Wolf and Cub'],
            'hard': ['Period drama', 'Historical epic', 'Bushido film', 'Samurai rebellion']
        }
    },
    'Spy movie': {
        'description': 'A film about secret agents conducting covert operations.',
        'tags': ['action', 'thriller', 'espionage'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Tuxedos and martinis', 'Double agents', 'Secret missions', 'Gadgets galore', 'License to kill', 'Q branch', 'Undercover work'],
            'medium': ['Secret agents', 'Gadgets', 'Cold War', 'James Bond', 'CIA vs KGB', 'Microfilm', 'Dead drop'],
            'hard': ['Film genre', 'Spy thriller', 'Espionage fiction', 'John le Carre', 'Tradecraft', 'Mole hunt', 'Burn notice']
        },
        'imposters': {
            'easy': ['Heist', 'Thriller', 'War', 'Action movie'],
            'medium': ['Secret agent', 'Intelligence officer', 'Covert operative', 'Field agent'],
            'hard': ['Spy thriller', 'Espionage film', 'Bond movie', 'Mission impossible']
        }
    },
    'Monster movie': {
        'description': 'A horror film featuring giant creatures terrorizing cities.',
        'tags': ['horror', 'creature', 'adventure'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Rampaging lizard', 'Screaming crowds', 'Giant beast', 'City destruction', 'Godzilla roar', 'Kaiju attack', 'Military fails'],
            'medium': ['Giant beasts', 'Cities destroyed', 'Radiation mutation', 'Skull Island', 'Mecha Godzilla', 'Mothra wings', 'Rodan flight'],
            'hard': ['Film genre', 'Creature feature', 'Kaiju eiga', 'Toho Studios', 'Special effects', 'Suitmation', 'Daikaiju']
        },
        'imposters': {
            'easy': ['Disaster', 'Horror', 'Alien invasion', 'Dragon film'],
            'medium': ['Kaiju film', 'Giant monster', 'Creature feature', 'Monster mash'],
            'hard': ['Kaiju', 'Daikaiju', 'Monsterverse', 'Toho monster']
        }
    },
    'Pirate movie': {
        'description': 'An adventure film about swashbuckling sea rovers hunting treasure.',
        'tags': ['adventure', 'seas', 'treasure'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Eye patches', 'Skull flags', 'Treasure maps', 'Sword fights', 'Jolly Roger', 'Peg leg', 'Parrot shoulder'],
            'medium': ['Treasure maps', 'Sword fights', 'Caribbean seas', 'Blackbeard', 'Spanish Main', 'Pieces of eight', 'Walking the plank'],
            'hard': ['Film genre', 'Swashbuckler', 'Golden Age of Piracy', 'Privateer', 'Buccaneer', 'Port Royal', 'Tortuga']
        },
        'imposters': {
            'easy': ['Western', 'Adventure', 'Fantasy', 'Sailing movie'],
            'medium': ['Pirate adventure', 'Sea rover', 'Corsair film', 'Privateer story'],
            'hard': ['Pirates of Caribbean', 'Treasure Island', 'Captain Blood', 'Swashbuckler']
        }
    },
    'Dinosaur movie': {
        'description': 'A film featuring prehistoric reptiles brought back to life.',
        'tags': ['prehistoric', 'adventure', 'creature'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Raptors chase', 'Fossils come alive', 'Theme park', 'T-Rex roar', 'Jurassic era', 'Amber DNA', 'Dig site'],
            'medium': ['Roaring beasts', 'Prehistoric park', 'Genetic engineering', 'InGen', 'Isla Nublar', 'Velociraptor', 'Triceratops'],
            'hard': ['Film genre', 'Prehistoric adventure', 'Michael Crichton', 'Steven Spielberg', 'CGI breakthrough', 'Animatronics', 'Paleontology']
        },
        'imposters': {
            'easy': ['Monster movie', 'Disaster', 'Jungle', 'Dragon film'],
            'medium': ['Jurassic Park', 'Lost World', 'Land Before Time', 'Dinosaur adventure'],
            'hard': ['Paleontology film', 'Prehistoric creature', 'Dino thriller', 'Jurassic World']
        }
    },
    'Space opera': {
        'description': 'An epic science fiction saga set among stars and galaxies.',
        'tags': ['science-fiction', 'space', 'adventure'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Rebels and empires', 'Starships', 'Laser swords', 'The Force', 'Galactic empire', 'Princess rescue', 'Death Star'],
            'medium': ['Star empires', 'Laser swords', 'Hyperdrive', 'Jedi Order', 'Sith Lords', 'X-wing fighter', 'Millennium Falcon'],
            'hard': ['Film genre', 'Galactic epic', 'Frank Herbert', 'Isaac Asimov', 'Dune universe', 'Foundation series', 'Space fantasy']
        },
        'imposters': {
            'easy': ['Science fiction', 'Fantasy', 'Western', 'Space western'],
            'medium': ['Star Wars', 'Star Trek', 'Dune', 'Battlestar Galactica'],
            'hard': ['Space fantasy', 'Planetary romance', 'Space adventure', 'Galactic saga']
        }
    },
    'Fairy tale': {
        'description': 'A magical story with enchanted characters and happy endings.',
        'tags': ['fantasy', 'magic', 'story'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Princesses and witches', 'Magic spells', 'Once upon a time', 'Happy ending', 'Enchanted forest', 'Fairy godmother', 'Glass slipper'],
            'medium': ['Once upon a time', 'Bedtime stories', 'Brothers Grimm', 'Hansel and Gretel', 'Little Red Riding Hood', 'Cinderella', 'Sleeping Beauty'],
            'hard': ['Story type', 'Folklore collection', 'Oral tradition', 'Morphology of the tale', 'Propp functions', 'Aarne-Thompson', 'Disney adaptation']
        },
        'imposters': {
            'easy': ['Fable', 'Myth', 'Legend', 'Folk tale'],
            'medium': ['Fairy story', 'Wonder tale', 'Magic tale', 'Enchanted story'],
            'hard': ['Märchen', 'Folklore', 'Oral tradition', 'Literary fairy tale']
        }
    },
    'Teen movie': {
        'description': 'A film about high school life and coming of age.',
        'tags': ['teen', 'drama', 'coming-of-age'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Lockers and cafeterias', 'First crush', 'Prom night', 'Popular cliques', 'High school', 'Yearbook', 'Detention'],
            'medium': ['Prom night', 'Popular cliques', 'John Hughes', 'Molly Ringwald', 'Breakfast Club', 'Ferris Bueller', 'Clueless'],
            'hard': ['Film genre', 'High school story', 'Coming of age', 'Bildungsroman', 'Teen angst', 'Senior year', 'Graduation']
        },
        'imposters': {
            'easy': ['Growing up', 'Rom com', 'Sitcom', 'College movie'],
            'medium': ['High school film', 'Teen drama', 'Youth film', 'Adolescent comedy'],
            'hard': ['Teen comedy', 'High school romance', 'Young adult film', 'Campus movie']
        }
    },
    'Sports movie': {
        'description': 'A drama about athletes striving for victory against odds.',
        'tags': ['sports', 'inspiring', 'drama'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Training scenes', 'Comeback victory', 'Big game', 'Underdog team', 'Coach speech', 'Locker room', 'Championship'],
            'medium': ['Big game finale', 'Locker room speeches', 'Rocky training', 'Miracle on Ice', 'Rudy', 'Hoosiers', 'Remember the Titans'],
            'hard': ['Film genre', 'Underdog story', 'Sports drama', 'Athletic triumph', 'Final buzzer', 'Overtime', 'Hall of Fame']
        },
        'imposters': {
            'easy': ['Biopic', 'Drama', 'Documentary', 'Action movie'],
            'medium': ['Sports drama', 'Athlete story', 'Team movie', 'Coach film'],
            'hard': ['Sports biography', 'Olympic film', 'Championship game', 'Rookie season']
        }
    },
    'Courtroom drama': {
        'description': 'A legal thriller centered on a trial and pursuit of justice.',
        'tags': ['legal', 'drama', 'court'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Judge and jury', 'Closing argument', 'Objection', 'Witness stand', 'Gavel bang', 'Lawyer briefcase', 'Verdict reading'],
            'medium': ['Objection your honor', 'Shocking testimony', 'Perry Mason', 'Cross examination', 'Reasonable doubt', 'Exhibit A', 'Jury deliberation'],
            'hard': ['Film genre', 'Legal story', 'Courtroom thriller', 'Legal procedural', 'Attorney ethics', 'Supreme Court', 'Landmark case']
        },
        'imposters': {
            'easy': ['Crime', 'Mystery', 'Thriller', 'Police procedural'],
            'medium': ['Legal drama', 'Trial movie', 'Lawyer film', 'Justice story'],
            'hard': ['Courtroom thriller', 'Legal thriller', 'Trial film', 'Judicial drama']
        }
    },
    'Disaster film': {
        'description': 'A thriller showing survival during catastrophic natural events.',
        'tags': ['catastrophe', 'thriller', 'survival'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Crumbling cities', 'Heroic scientists', 'Tsunami wave', 'Meteor strike', 'Volcano erupts', 'Earthquake shakes', 'Evacuation'],
            'medium': ['Tsunamis and twisters', 'Survival race', 'Irwin Allen', 'Towering Inferno', 'Poseidon Adventure', 'Airport 77', 'Earthquake'],
            'hard': ['Catastrophe story', 'Disaster epic', 'Roland Emmerich', 'Global destruction', 'Extinction event', 'Survivalist', 'FEMA']
        },
        'imposters': {
            'easy': ['Monster movie', 'Thriller', 'War film', 'Action movie'],
            'medium': ['Disaster epic', 'Catastrophe film', 'Survival story', 'Natural disaster'],
            'hard': ['Disaster movie', 'Apocalypse film', 'End of world', 'Cataclysm']
        }
    },
    'Martial arts': {
        'description': 'Combat disciplines from Asia emphasizing technique and philosophy.',
        'tags': ['combat', 'sport', 'training'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['High kicks', 'Choreographed fights', 'Training dojo', 'Colored belts', 'Sensei master', 'Kata forms', 'Breaking boards'],
            'medium': ['Training dojos', 'Belts and masters', 'Karate tournament', 'Tae Kwon Do', 'Judo throw', 'Aikido wristlock', 'Kung fu stance'],
            'hard': ['Fight style', 'Action genre', 'Martial arts cinema', 'Bruce Lee philosophy', 'Mixed martial arts', 'Combat sport', 'Self defense']
        },
        'imposters': {
            'easy': ['Boxing', 'Wrestling', 'Fencing', 'Sumo'],
            'medium': ['Combat sport', 'Fight choreography', 'Action martial arts', 'Kickboxing'],
            'hard': ['Martial arts film', 'Kung fu movie', 'Karate film', 'Wuxia']
        }
    },
    'Bollywood': {
        'description': 'India\'s Hindi film industry known for musical spectacles.',
        'tags': ['indian', 'musical', 'cinema'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Colorful sets', 'Three hour films', 'Song and dance', 'Big weddings', 'Mumbai studios', 'Item number', 'Intermission'],
            'medium': ['Song and dance', 'Big weddings', 'Shah Rukh Khan', 'Amitabh Bachchan', 'Masala film', 'Playback singer', 'Choreographer'],
            'hard': ['Film industry', 'Indian cinema', 'Hindi cinema', 'Mumbai film industry', 'Bollywood dance', 'Indian musical', 'South Asian cinema']
        },
        'imposters': {
            'easy': ['Hollywood', 'Tollywood', 'Nollywood', 'Kollywood'],
            'medium': ['Indian film industry', 'Hindi cinema', 'Mumbai movies', 'Bollywood musical'],
            'hard': ['Hindi film', 'Indian musical', 'Bollywood star', 'Mumbai cinema']
        }
    },
    'Hollywood': {
        'description': 'The center of American filmmaking and global entertainment.',
        'tags': ['american', 'cinema', 'industry'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Hillside sign', 'Big budgets', 'Movie stars', 'Red carpet', 'Studio lots', 'Oscar night', 'Walk of Fame'],
            'medium': ['Studios and stars', 'Walk of fame', 'Major studios', 'Golden Age', 'Blockbuster factory', 'Dream factory', 'Tinseltown'],
            'hard': ['Film industry', 'Movie capital', 'American cinema', 'Studio system', 'Hollywood sign', 'Los Angeles', 'Entertainment capital']
        },
        'imposters': {
            'easy': ['Bollywood', 'Broadway', 'Nollywood', 'London film'],
            'medium': ['American film industry', 'Movie capital', 'Film capital', 'Studio town'],
            'hard': ['Hollywood studio', 'LA film', 'American cinema', 'Dream factory']
        }
    },
    'Anime': {
        'description': 'Japanese animation with distinctive art style and diverse genres.',
        'tags': ['japanese', 'animation', 'cartoon'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Hand drawn action', 'Dubbed or subbed', 'Big eyes', 'Manga adaptation', 'Otaku culture', 'Cosplay', 'Studio Ghibli'],
            'medium': ['Big expressive eyes', 'Fan conventions', 'Manga source', 'Seinen', 'Shonen', 'Isekai', 'Mecha genre'],
            'hard': ['Animation style', 'Japanese animation', 'Cel animation', 'Key frames', 'In-between', 'Sakuga', 'Production committee']
        },
        'imposters': {
            'easy': ['Cartoon', 'Manga', 'Animation', 'Western animation'],
            'medium': ['Japanese cartoon', 'Anime series', 'Manga adaptation', 'Japanese animation'],
            'hard': ['Anime film', 'OVA', 'Anime movie', 'Japanese anime']
        }
    },
    'Cartoon': {
        'description': 'Animated entertainment with simplified art for humor or adventure.',
        'tags': ['animation', 'kids', 'humor'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Bright colors', 'Slapstick gags', 'Talking animals', 'Saturday morning', 'Looney Tunes', 'Disney classic', 'Hanna Barbera'],
            'medium': ['Saturday mornings', 'Talking animals', 'Cel animation', 'Voice actors', 'Storyboard', 'Key frames', 'Animation cel'],
            'hard': ['Animation', 'Animated series', 'Traditional animation', 'Limited animation', 'Animation studio', 'Cartoon network', 'Animated feature']
        },
        'imposters': {
            'easy': ['Anime', 'Comic', 'Puppet show', 'Claymation'],
            'medium': ['Animated series', 'Cartoon show', 'Children animation', 'Western cartoon'],
            'hard': ['Animated feature', 'Cartoon movie', 'TV cartoon', 'Animated short']
        }
    },
    'Sitcom': {
        'description': 'A comedy series with recurring characters in humorous situations.',
        'tags': ['comedy', 'television', 'laughter'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Episodes', 'Catchphrases', 'Laugh track', 'Studio audience', 'Living room set', 'Three camera', 'Syndication'],
            'medium': ['Laugh track', 'Family living room', 'Friends cast', 'Seinfeld', 'Multi-cam', 'Running gag', 'Bottle episode'],
            'hard': ['Television genre', 'Comedy series', 'Situation comedy', 'Multi-camera', 'Ensemble cast', 'Will they won\'t they', 'Series finale']
        },
        'imposters': {
            'easy': ['Drama', 'Reality show', 'Soap opera', 'Sketch comedy'],
            'medium': ['TV comedy', 'Situation comedy', 'Family sitcom', 'Workplace comedy'],
            'hard': ['Sitcom series', 'Comedy show', 'TV sitcom', 'American sitcom']
        }
    },
    'Soap opera': {
        'description': 'A serialized daytime drama with ongoing emotional storylines.',
        'tags': ['drama', 'television', 'serial'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Long running', 'Cliffhanger episodes', 'Daily episodes', 'Evil twin', 'Amnesia plot', 'Wedding disaster', 'Secret baby'],
            'medium': ['Evil twins', 'Dramatic slap', 'Recasting', 'Super couple', 'Soap opera digest', 'Daytime Emmy', 'General Hospital'],
            'hard': ['Television genre', 'Daytime drama', 'Serial drama', 'Melodrama', 'Telenovela', 'Soap opera network', 'Continuing story']
        },
        'imposters': {
            'easy': ['Sitcom', 'Telenovela', 'Drama', 'Evening soap'],
            'medium': ['Daytime drama', 'Serial drama', 'Melodrama', 'Soap series'],
            'hard': ['Soap', 'Daytime serial', 'Continuing drama', 'TV soap']
        }
    },
    'Reality show': {
        'description': 'Unscripted television featuring real people in contrived situations.',
        'tags': ['television', 'unscripted', 'competition'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Hidden cameras', 'Drama queens', 'Confessionals', 'Tribal council', 'Immunity idol', 'Rose ceremony', 'Elimination'],
            'medium': ['Contestants voted off', 'Confessionals', 'Reunion show', 'After show', 'Reality star', 'Casting call', 'Producer manipulation'],
            'hard': ['Television genre', 'Unscripted series', 'Reality television', 'Format rights', 'Casting director', 'Editing room', 'Story producer']
        },
        'imposters': {
            'easy': ['Game show', 'Sitcom', 'Documentary', 'Talk show'],
            'medium': ['Reality TV', 'Unscripted show', 'Competition show', 'Reality series'],
            'hard': ['Reality television', 'Reality competition', 'Docuseries', 'Reality format']
        }
    },
    'Game show': {
        'description': 'A televised contest where players answer questions for prizes.',
        'tags': ['television', 'quiz', 'prizes'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Buzzers', 'Host with cards', 'Studio audience', 'Big board', 'Daily double', 'Final jeopardy', 'Showcase showdown'],
            'medium': ['Contestants win prizes', 'Studio audience', 'Wheel spin', 'Price is Right', 'Jeopardy', 'Family Feud', 'Who Wants to Be'],
            'hard': ['Television genre', 'Quiz program', 'Game show host', 'Prize budget', 'Sweepstakes', 'Trivia night', 'Game show network']
        },
        'imposters': {
            'easy': ['Reality show', 'Talk show', 'Quiz', 'Lottery'],
            'medium': ['Quiz show', 'TV game', 'Prize show', 'Contest show'],
            'hard': ['Game show format', 'TV quiz', 'Quiz competition', 'Game show host']
        }
    },
    'Talk show': {
        'description': 'A program where hosts interview guests and discuss topics.',
        'tags': ['television', 'interview', 'comedy'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Desk and couch', 'House band', 'Monologue', 'Celebrity guest', 'Audience laughter', 'Sidekick', 'Top ten list'],
            'medium': ['Celebrity guests', 'Late night', 'Johnny Carson', 'David Letterman', 'Conan O\'Brien', 'Stephen Colbert', 'Jimmy Fallon'],
            'hard': ['Television genre', 'Interview program', 'Talk show host', 'Guest booking', 'Green room', 'Pre-interview', 'Band leader']
        },
        'imposters': {
            'easy': ['Game show', 'News', 'Podcast', 'Radio show'],
            'medium': ['Interview show', 'Chat show', 'Late night show', 'Variety show'],
            'hard': ['Talk program', 'Conversation show', 'Host show', 'Interview series']
        }
    },
    'Binge watch': {
        'description': 'Viewing multiple episodes of a series in one extended session.',
        'tags': ['streaming', 'marathon', 'habit'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Couch and snacks', 'Streaming', 'Auto play next', 'All night', 'Weekend marathon', 'Netflix', 'Cliffhanger'],
            'medium': ['Whole season overnight', 'Next episode autoplay', 'No sleep', 'Recap skip', 'Credits skip', 'Binge racing', 'Completionist'],
            'hard': ['Viewing habit', 'Marathon viewing', 'Streaming culture', 'On demand', 'Release strategy', 'Drop model', 'Watercooler talk']
        },
        'imposters': {
            'easy': ['Rewatch', 'Channel surf', 'Skim', 'Casual viewing'],
            'medium': ['Marathon viewing', 'Season binge', 'Series binge', 'Weekend watch'],
            'hard': ['Binge viewing', 'Serial viewing', 'Episodic marathon', 'Streaming binge']
        }
    },
    'Video streaming': {
        'description': 'On-demand delivery of films and shows over the internet.',
        'tags': ['online', 'service', 'movies'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Recommendations', 'Skip intro', 'Monthly fee', 'Original series', 'Watch anywhere', 'Offline download', 'Multiple profiles'],
            'medium': ['Binge worthy shows', 'Monthly fee', 'Netflix', 'Disney Plus', 'HBO Max', 'Amazon Prime', 'Apple TV Plus'],
            'hard': ['Online platform', 'Monthly subscription', 'SVOD', 'OTT service', 'Content library', 'Streaming war', 'Cord cutting']
        },
        'imposters': {
            'easy': ['Cable', 'Cinema', 'Rental', 'Broadcast TV'],
            'medium': ['Streaming service', 'VOD platform', 'OTT app', 'Streaming app'],
            'hard': ['Streaming platform', 'Video on demand', 'Subscription video', 'Streaming provider']
        }
    },
    'Movie night': {
        'description': 'A casual gathering to watch a film together at home.',
        'tags': ['event', 'home', 'social'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Dim lights', 'Blankets', 'Popcorn bowl', 'Pajamas', 'Choose movie', 'Friends over', 'Cozy atmosphere'],
            'medium': ['Friends and popcorn', 'Pick a film', 'Netflix and chill', 'Movie marathon', 'Theme night', 'Snack bar', 'Intermission'],
            'hard': ['Social event', 'Home cinema', 'Viewing party', 'Film club', 'Outdoor screening', 'Projector setup', 'Drive in vibes']
        },
        'imposters': {
            'easy': ['Game night', 'Party', 'Concert', 'Dinner party'],
            'medium': ['Film night', 'Cinema night', 'Screening party', 'Watch party'],
            'hard': ['Movie evening', 'Film gathering', 'Home screening', 'Viewing event']
        }
    },
    'Movie poster': {
        'description': 'A promotional artwork displaying film title, stars, and imagery.',
        'tags': ['advertising', 'art', 'promotion'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Tagline and title', 'Star faces', 'Release date', 'Colorful artwork', 'Theater lobby', 'Collectible', 'Framed art'],
            'medium': ['Hung in lobbies', 'Collectibles', 'One sheet', 'Teaser poster', 'Character poster', 'International poster', 'DVD cover'],
            'hard': ['Promotional art', 'Film advert', 'Key art', 'Poster artist', 'Drew Struzan', 'Saul Bass', 'Movie marketing']
        },
        'imposters': {
            'easy': ['Trailer', 'Billboard', 'Flyer', 'Lobby card'],
            'medium': ['Film poster', 'Movie artwork', 'Promotional poster', 'Theatrical poster'],
            'hard': ['One sheet', 'Key art', 'Poster design', 'Movie advertisement']
        }
    },
    'Ticket stub': {
        'description': 'The torn portion of an admission ticket kept as a memento.',
        'tags': ['memorabilia', 'ticket', 'keepsake'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Seat number', 'Showtime printed', 'Torn edge', 'Ticket booth', 'Admission proof', 'Collectible', 'Wallet keepsake'],
            'medium': ['Saved in wallets', 'Torn at entry', 'Stub collection', 'Movie memory', 'Date reminder', 'Theater name', 'Price paid'],
            'hard': ['Cinema keepsake', 'Admission slip', 'Ticket collector', 'Memorabilia', 'Ephemera', 'Ticket stub album', 'Nostalgia item']
        },
        'imposters': {
            'easy': ['Popcorn bucket', 'Poster', 'Receipt', 'Program'],
            'medium': ['Movie ticket', 'Admission ticket', 'Cinema stub', 'Ticket remnant'],
            'hard': ['Ticket scrap', 'Entry stub', 'Cinema ticket', 'Movie stub']
        }
    },
    'Movie glasses': {
        'description': 'Special eyewear for viewing three-dimensional films in theaters.',
        'tags': ['3d', 'cinema', 'glasses'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Tinted lenses', 'Depth effect', 'Red blue', 'Polarized', 'RealD', 'IMAX 3D', 'Plastic frames'],
            'medium': ['Things pop out', 'Cardboard or plastic', 'Return bin', 'Recycle', 'Sanitize', 'Fit over glasses', 'Clip on'],
            'hard': ['Cinema accessory', 'Viewing gear', 'Stereoscopic', 'Parallax', 'Anaglyph', 'Polarized light', 'Active shutter']
        },
        'imposters': {
            'easy': ['Sunglasses', 'Goggles', 'Monocle', 'Reading glasses'],
            'medium': ['3D glasses', 'Theater glasses', 'Stereo glasses', 'Polarized glasses'],
            'hard': ['3D eyewear', 'Stereo specs', 'Cinema 3D', 'Movie 3D']
        }
    },
    'Extended cut': {
        'description': 'A longer version of a film with scenes restored from editing room floor.',
        'tags': ['director', 'edition', 'extended'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Longer runtime', 'Original vision', 'Deleted scenes', 'More footage', 'Uncut version', 'Director preferred', 'Complete story'],
            'medium': ['Deleted scenes restored', 'Collectors buy', 'Special edition', 'Bonus features', 'Making of', 'Commentary track', 'Behind scenes'],
            'hard': ['Movie version', 'Longer edition', 'Director\'s cut', 'Assembly cut', 'Workprint', 'Rough cut', 'Final cut privilege']
        },
        'imposters': {
            'easy': ['Remake', 'Sequel', 'Trailer', 'Prequel'],
            'medium': ['Director\'s cut', 'Uncut version', 'Special edition', 'Extended edition'],
            'hard': ['Director cut', 'Extended version', 'Longer cut', 'Complete cut']
        }
    },
    'Blooper': {
        'description': 'A filmed mistake showing actors forgetting lines or prop failures.',
        'tags': ['mistake', 'outtake', 'behind-scenes'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Forgotten lines', 'Giggling actors', 'Prop fails', 'Wardrobe malfunction', 'Laugh break', 'NG take', 'Cut print it'],
            'medium': ['Shown during credits', 'Funny flubs', 'Gag reel', 'Outtake reel', 'Bloopers reel', 'DVD extra', 'End credits'],
            'hard': ['Filming mistake', 'Outtake', 'NG', 'Retake', 'Flubbed line', 'Corpsing', 'On set accident']
        },
        'imposters': {
            'easy': ['Spoiler', 'Cameo', 'Trailer', 'Deleted scene'],
            'medium': ['Outtake', 'Gag reel', 'Bloopers reel', 'NG take'],
            'hard': ['Mistake take', 'Flub', 'Corpsing', 'Retake']
        }
    },
    'Box set': {
        'description': 'A packaged collection of related films or complete series.',
        'tags': ['collection', 'edition', 'collector'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Many discs', 'Special packaging', 'Art book', 'Collectible box', 'Limited edition', 'Numbered', 'Certificate'],
            'medium': ['Gift for fans', 'Shelf display', 'Complete series', 'All seasons', 'Bonus discs', 'Art cards', 'Steelbook'],
            'hard': ['Collector item', 'Complete series', 'Box set edition', 'Anthology set', 'Franchise collection', 'Saga box', 'Ultimate edition']
        },
        'imposters': {
            'easy': ['Trailer', 'Poster', 'Single', 'Steelbook'],
            'medium': ['Collection set', 'Complete box', 'Series box', 'Anthology box'],
            'hard': ['Box collection', 'Complete collection', 'Series collection', 'Franchise box']
        }
    },
    'Costume designer': {
        'description': 'The artist who creates character wardrobes for film productions.',
        'tags': ['fashion', 'crew', 'film-maker'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Fabric choices', 'Fittings', 'Sketches', 'Period research', 'Color palette', 'Character wardrobe', 'Quick change'],
            'medium': ['Period outfits', 'Sketches clothes', 'Edith Head', 'Colleen Atwood', 'Sandy Powell', 'Oscar winner', 'Wardrobe department'],
            'hard': ['Film crew role', 'Wardrobe creator', 'Costume design', 'Costume supervision', 'Fabric sourcing', 'Aging costumes', 'Continuity']
        },
        'imposters': {
            'easy': ['Makeup artist', 'Director', 'Tailor', 'Fashion designer'],
            'medium': ['Wardrobe designer', 'Costume supervisor', 'Costumer', 'Wardrobe head'],
            'hard': ['Costume design', 'Wardrobe design', 'Costume department', 'Costume crew']
        }
    },
    'Screenwriter': {
        'description': 'The writer who crafts dialogue and action for film scripts.',
        'tags': ['author', 'script', 'film'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Typing scripts', 'Plot outlines', 'Final Draft', 'Scene heading', 'Dialogue block', 'Action line', 'Slug line'],
            'medium': ['Writes dialogue', 'Rewrites drafts', 'Spec script', 'Optioned', 'Pitch meeting', 'Coverage', 'Black List'],
            'hard': ['Movie author', 'Script author', 'Screenplay writer', 'Script doctor', 'Writing credit', 'Arbitration', 'WGA']
        },
        'imposters': {
            'easy': ['Novelist', 'Director', 'Editor', 'Playwright'],
            'medium': ['Scriptwriter', 'Screenplay author', 'Film writer', 'Script author'],
            'hard': ['Screenplay writer', 'Script writer', 'Film screenwriter', 'Movie writer']
        }
    },
    'Movie star': {
        'description': 'A famous actor whose name draws audiences to theaters.',
        'tags': ['actor', 'celebrity', 'hollywood'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Autographs', 'Big salary', 'Red carpet', 'Paparazzi', 'Magazine cover', 'Fan mail', 'Box office draw'],
            'medium': ['Red carpets', 'Paparazzi chase', 'Leading role', 'Top billing', 'A-list', 'Opening weekend', 'Franchise face'],
            'hard': ['Famous actor', 'Celebrity', 'Star power', 'Bankable star', 'Marquee name', 'Box office star', 'Hollywood icon']
        },
        'imposters': {
            'easy': ['Director', 'Extra', 'Producer', 'Stunt double'],
            'medium': ['Lead actor', 'A-list actor', 'Hollywood star', 'Film star'],
            'hard': ['Leading actor', 'Star actor', 'Cinema star', 'Screen star']
        }
    },
    'Award show': {
        'description': 'A televised ceremony honoring excellence in filmmaking.',
        'tags': ['ceremony', 'awards', 'celebration'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Golden statues', 'Host jokes', 'Red carpet', 'Acceptance speech', 'Envelope please', 'Thank you mom', 'Play off music'],
            'medium': ['Speeches and envelopes', 'Glamorous outfits', 'Academy Awards', 'Golden Globes', 'SAG Awards', 'BAFTA', 'Critics Choice'],
            'hard': ['Ceremony', 'Film honors', 'Oscar night', 'Voting body', 'Campaigning', 'For your consideration', 'Academy member']
        },
        'imposters': {
            'easy': ['Premiere', 'Festival', 'Concert', 'Gala'],
            'medium': ['Awards ceremony', 'Film awards', 'Movie awards', 'Cinema awards'],
            'hard': ['Awards show', 'Film ceremony', 'Movie honors', 'Cinema honors']
        }
    },
    'Indie film': {
        'description': 'A low-budget movie produced outside the major studio system.',
        'tags': ['independent', 'low-budget', 'art'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Quirky characters', 'Handheld camera', 'Film festival', 'Sundance', 'Limited release', 'Art house', 'Mumblecore'],
            'medium': ['Festival favorite', 'Low budget', 'Creative freedom', 'First feature', 'Microbudget', 'Guerrilla filmmaking', 'Digital video'],
            'hard': ['Small movie', 'Independent cinema', 'Indie spirit', 'Auteur driven', 'Non-studio', 'Art film', 'Alternative cinema']
        },
        'imposters': {
            'easy': ['Blockbuster', 'Documentary', 'Short film', 'Student film'],
            'medium': ['Independent film', 'Indie movie', 'Art house film', 'Low budget film'],
            'hard': ['Indie feature', 'Independent feature', 'Art cinema', 'Alternative film']
        }
    },
    'Short film': {
        'description': 'A brief motion picture typically under forty minutes in length.',
        'tags': ['brief', 'narrative', 'festival'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Under half hour', 'Tight story', 'Film school', 'Student project', 'Festival entry', 'Proof of concept', 'Calling card'],
            'medium': ['Student projects', 'Festival category', 'Short film fest', 'Oscar short', 'Live action short', 'Animated short', 'Documentary short'],
            'hard': ['Brief movie', 'Short subject', 'Short film festival', 'Academy short', 'Short form', 'Micro cinema', 'Brief narrative']
        },
        'imposters': {
            'easy': ['Feature film', 'Trailer', 'Commercial', 'Music video'],
            'medium': ['Short subject', 'Brief film', 'Short movie', 'Mini film'],
            'hard': ['Short feature', 'Short narrative', 'Short form', 'Brief cinema']
        }
    },
    'Feature film': {
        'description': 'A full-length theatrical movie typically ninety minutes or more.',
        'tags': ['main', 'feature', 'full-length'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Opening credits', 'Three acts', 'Theatrical release', 'Box office', 'Runtime', 'Wide release', 'Premiere night'],
            'medium': ['Theater release', 'Two hours', 'Feature length', 'Full feature', 'Main attraction', 'Headline film', 'Tentpole'],
            'hard': ['Full length movie', 'Main picture', 'Feature length', 'Theatrical feature', 'Cinematic feature', 'Motion picture', 'Film feature']
        },
        'imposters': {
            'easy': ['Short film', 'Series', 'Documentary', 'TV movie'],
            'medium': ['Feature length', 'Full feature', 'Theatrical film', 'Cinema feature'],
            'hard': ['Feature movie', 'Full film', 'Theatrical movie', 'Cinema movie']
        }
    },
    'Horror villain': {
        'description': 'The menacing antagonist who stalks and kills in scary films.',
        'tags': ['evil', 'antagonist', 'monster'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Creepy mask', 'Heavy breathing', 'Slow walk', 'Unstoppable', 'Signature weapon', 'Backstory trauma', 'Final girl'],
            'medium': ['Masked killer', 'Never stays down', 'Supernatural strength', 'Jason Voorhees', 'Michael Myers', 'Freddy Krueger', 'Ghostface'],
            'hard': ['Scary antagonist', 'Slasher figure', 'Horror icon', 'Final girl trope', 'Body count', 'Franchise villain', 'Immortal killer']
        },
        'imposters': {
            'easy': ['Monster', 'Ghost', 'Zombie', 'Demon'],
            'medium': ['Slasher villain', 'Horror antagonist', 'Movie monster', 'Killer'],
            'hard': ['Slasher icon', 'Horror icon', 'Movie killer', 'Slasher villain']
        }
    },
    'Jump scare': {
        'description': 'A sudden loud noise or image designed to startle the audience.',
        'tags': ['horror', 'technique', 'startle'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Quiet build up', 'Something leaps out', 'Loud noise', 'Cat jumps', 'Mirror reflection', 'Door slams', 'Silence breaks'],
            'medium': ['Loud bang', 'Audience screams', 'Orchestra sting', 'False scare', 'Real scare', 'Cat scare', 'Cheap thrill'],
            'hard': ['Horror trick', 'Sudden fright', 'Startle effect', 'Acoustic startle', 'Visual shock', 'Tension release', 'Cheap scare']
        },
        'imposters': {
            'easy': ['Plot twist', 'Cliffhanger', 'Spoiler', 'Red herring'],
            'medium': ['Startle scare', 'Sudden scare', 'Shock moment', 'Fright gag'],
            'hard': ['Startle technique', 'Shock tactic', 'Fright moment', 'Scare gag']
        }
    },
    'Haunted doll': {
        'description': 'A possessed toy that moves and kills in supernatural horror.',
        'tags': ['horror', 'prop', 'cursed'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Porcelain face', 'Glassy eyes', 'Turns head', 'Giggles', 'Music box', 'Locked room', 'Child\'s toy'],
            'medium': ['Moves at night', 'Cursed object', 'Annabelle', 'Chucky', 'Robert the Doll', 'Possessed toy', 'Demonic doll'],
            'hard': ['Horror prop', 'Creepy toy', 'Killer doll', 'Haunted object', 'Doll horror', 'Possessed plaything', 'Supernatural toy']
        },
        'imposters': {
            'easy': ['Puppet', 'Ghost', 'Mannequin', 'Ventriloquist dummy'],
            'medium': ['Killer doll', 'Possessed doll', 'Evil doll', 'Demon doll'],
            'hard': ['Haunted toy', 'Cursed doll', 'Demonic toy', 'Supernatural doll']
        }
    },
    'Found footage': {
        'description': 'A horror style presented as discovered recordings from missing people.',
        'tags': ['horror', 'style', 'mockumentary'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Handheld recording', 'Missing filmmakers', 'Shaky cam', 'Night vision', 'Battery dying', 'Last recording', 'Raw footage'],
            'medium': ['Lost tapes', 'Night vision', 'Blair Witch', 'Paranormal Activity', 'REC', 'Cloverfield', 'Chronicle'],
            'hard': ['Horror style', 'Shaky camera', 'POV horror', 'Subjective camera', 'Diegetic camera', 'Mock documentary', 'Pseudo documentary']
        },
        'imposters': {
            'easy': ['Mockumentary', 'Documentary', 'Thriller', 'Home video'],
            'medium': ['Found film', 'Discovered footage', 'Recovered film', 'Lost film'],
            'hard': ['Found footage film', 'POV horror', 'Subjective horror', 'Camera horror']
        }
    },
    'Slasher': {
        'description': 'A horror subgenre featuring a knife-wielding killer stalking victims.',
        'tags': ['horror', 'killer', 'murder'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Knife wielding', 'Sequel heavy', 'Final girl', 'Camp counselors', 'Spring break', 'Body count', 'Masked killer'],
            'medium': ['Teens at camp', 'Final girl', 'Halloween night', 'Prom night', 'Friday 13th', 'Elm Street', 'Texas Chainsaw'],
            'hard': ['Horror subgenre', 'Masked killer film', 'Slasher formula', 'Kill count', 'Final girl trope', 'Slasher rules', 'Body horror']
        },
        'imposters': {
            'easy': ['Thriller', 'Zombie', 'Haunted house', 'Monster movie'],
            'medium': ['Slasher film', 'Knife killer', 'Masked murderer', 'Teen slasher'],
            'hard': ['Slasher movie', 'Slasher horror', 'Knife slasher', 'Masked slasher']
        }
    },
    'Ghost story': {
        'description': 'A narrative about spirits returning to haunt the living.',
        'tags': ['supernatural', 'horror', 'spirit'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Old mansions', 'Whispering voices', 'Cold spots', 'Moving objects', 'Apparition', 'Ouija board', 'Seance'],
            'medium': ['Told around campfires', 'Restless spirits', 'Victorian ghost', 'Gothic horror', 'Haunting', 'Poltergeist', 'Exorcism'],
            'hard': ['Haunting plot', 'Ghost narrative', 'Spectral tale', 'Phantom story', 'Spirit story', 'Apparition tale', 'Supernatural tale']
        },
        'imposters': {
            'easy': ['Fairy tale', 'Legend', 'Mystery', 'Folk tale'],
            'medium': ['Ghost tale', 'Spirit story', 'Haunting tale', 'Phantom story'],
            'hard': ['Ghost narrative', 'Spirit narrative', 'Haunting narrative', 'Phantom narrative']
        }
    },
    'Love story': {
        'description': 'A romantic narrative about two people falling in love.',
        'tags': ['romance', 'drama', 'relationship'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Grand gestures', 'Rain kisses', 'Meet cute', 'First date', 'Love letter', 'Proposal', 'Wedding'],
            'medium': ['Doomed couples', 'Tear jerker', 'Star crossed', 'Forbidden love', 'Second chance', 'Love triangle', 'Soulmate'],
            'hard': ['Heartfelt plot', 'Romantic arc', 'Love journey', 'Relationship drama', 'Romance arc', 'Couple story', 'Love narrative']
        },
        'imposters': {
            'easy': ['Fairy tale', 'Tragedy', 'Comedy', 'Romance'],
            'medium': ['Romance story', 'Love tale', 'Romantic story', 'Love narrative'],
            'hard': ['Romantic drama', 'Love romance', 'Romantic tale', 'Love romance']
        }
    },
    'Tragedy': {
        'description': 'A dramatic work ending in disaster for the main character.',
        'tags': ['drama', 'ending', 'sad'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Fatal flaw', 'Downfall', 'Sad ending', 'Tears', 'Death', 'Loss', 'Misfortune'],
            'medium': ['Shakespeare classics', 'Heartbreak', 'Greek tragedy', 'Hamartia', 'Catharsis', 'Hubris', 'Fate'],
            'hard': ['Story type', 'Sad ending', 'Tragic hero', 'Tragic flaw', 'Tragic arc', 'Tragic end', 'Tragic fate']
        },
        'imposters': {
            'easy': ['Comedy', 'Drama', 'Romance', 'Melodrama'],
            'medium': ['Tragic drama', 'Sad story', 'Tragic tale', 'Tragic narrative'],
            'hard': ['Tragic story', 'Tragedy drama', 'Sad drama', 'Tragic film']
        }
    },
    'Satire': {
        'description': 'Comedy using irony and exaggeration to criticize society.',
        'tags': ['comedy', 'mockery', 'humor'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Exaggeration', 'Irony', 'Mockery', 'Parody', 'Social commentary', 'Political humor', 'Biting wit'],
            'medium': ['Political humor', 'Biting wit', 'Jonathan Swift', 'Mark Twain', 'South Park', 'The Onion', 'Dr Strangelove'],
            'hard': ['Social mockery', 'Satirical edge', 'Horatian', 'Juvenalian', 'Menippean', 'Satirical novel', 'Satirical film']
        },
        'imposters': {
            'easy': ['Parody', 'Comedy', 'Farce', 'Spoof'],
            'medium': ['Satirical comedy', 'Social satire', 'Political satire', 'Satirical film'],
            'hard': ['Satire film', 'Satirical movie', 'Satire comedy', 'Satirical drama']
        }
    },
    'Slapstick': {
        'description': 'Physical comedy with exaggerated falls, collisions, and chases.',
        'tags': ['comedy', 'physical', 'humorous'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Pratfalls', 'Banana peels', 'Pie face', 'Slippery floor', 'Chase scene', 'Keystone Kops', 'Silent comedy'],
            'medium': ['Pies in face', 'Silent era', 'Charlie Chaplin', 'Buster Keaton', 'Harold Lloyd', 'Laurel Hardy', 'Three Stooges'],
            'hard': ['Comedy style', 'Physical humor', 'Slapstick comedy', 'Visual gag', 'Physical gag', 'Knockabout', 'Burlesque']
        },
        'imposters': {
            'easy': ['Satire', 'Parody', 'Mime', 'Clown'],
            'medium': ['Physical comedy', 'Slapstick comedy', 'Visual comedy', 'Knockabout comedy'],
            'hard': ['Slapstick film', 'Physical comedy film', 'Slapstick movie', 'Knockabout film']
        }
    },
    'Underdog': {
        'description': 'A disadvantaged competitor who unexpectedly triumphs.',
        'tags': ['story', 'triumph', 'champion'],
        'difficulty': 'medium',
        'hints': {
            'easy': ['Long odds', 'Triumph', 'Nobody believes', 'Training montage', 'Rocky Balboa', 'Rudy Ruettiger', 'Cinderella story'],
            'medium': ['Nobody believes in them', 'Big comeback', 'Against odds', 'David vs Goliath', 'Miracle', 'Upset victory', 'Dark horse'],
            'hard': ['Story trope', 'Unlikely hero', 'Underdog archetype', 'Cinderella trope', 'Rags to riches', 'Triumph over adversity', 'Victory against odds']
        },
        'imposters': {
            'easy': ['Champion', 'Villain', 'Rookie', 'Favorite'],
            'medium': ['Long shot', 'Dark horse', 'Outsider', 'Longshot'],
            'hard': ['Underdog story', 'Underdog trope', 'Cinderella story', 'David and Goliath']
        }
    }
}

def make_record(word):
    data = complete_data.get(word, {})
    return {
        'word': word,
        'category': 'movies_entertainment',
        'subcategory': 'Movies',
        'difficulty': data.get('difficulty', 'medium'),
        'description': data.get('description', ''),
        'tags': data.get('tags', ['movie', 'entertainment']),
        'hints': data.get('hints', {'easy': [], 'medium': [], 'hard': []}),
        'imposters': data.get('imposters', {'easy': [], 'medium': [], 'hard': []})
    }

records_008 = [make_record(w) for w in prompt_008_words]

# Write 008_movies.json
target_path = os.path.join('tool', 'words', 'replies', '008_movies.json')
with open(target_path, 'w', encoding='utf-8') as f:
    json.dump(records_008, f, indent=2, ensure_ascii=False)

print('Wrote {} records to {}'.format(len(records_008), target_path))