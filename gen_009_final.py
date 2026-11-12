import json, os

# Define complete records for 009_movies.txt (21 words)
prompt_009_words = [
    'Buddy cop', 'Femme fatale', 'Mad scientist', 'Evil twin', 'Last stand',
    'Damsel', 'Princess', 'Treasure map', 'Secret agent', 'Time loop',
    'Multiverse', 'Dream sequence', 'Cyborg', 'Post apocalyptic', 'Dystopia',
    'Ensemble cast', 'Antihero', 'Henchman', 'Bodyguard', 'Chase scene', 'Opening scene'
]

# Use complete data including proper hints, imposters, descriptions, tags
complete_data = {}

# Build complete data for each word
complete_data['Buddy cop'] = {
    'description': 'Two mismatched police partners solve crimes with humor and action.',
    'tags': ['action', 'comedy', 'detective'],
    'difficulty': 'medium',
    'hints': {
        'easy': ['Odd couple', 'Partner banter', 'Car chases', 'Wisecracks', 'Mismatched', 'Police partners', 'City heroes'],
        'medium': ['Lethal Weapon', 'Beverly Hills Cop', '48 Hrs', 'Tango Cash', 'Rush Hour', 'Bad Boys', 'Hot Fuzz'],
        'hard': ['Buddy cop film', 'Odd couple cop', 'Comedy action', 'Police duo', 'Detective comedy', 'Cops and robbers', 'Partnership drama']
    },
    'imposters': {
        'easy': ['Heist', 'Spy movie', 'Western', 'Crime film'],
        'medium': ['Police duo', 'Detective pair', 'Cop comedy', 'Odd couple heroes'],
        'hard': ['Buddy cop film', 'Police partnership', 'Detective comedy', 'Odd couple cop']
    }
}

complete_data['Femme fatale'] = {
    'description': 'A dangerously seductive woman who manipulates men to their doom.',
    'tags': ['noir', 'danger', 'seduction'],
    'difficulty': 'medium',
    'hints': {
        'easy': ['Red lipstick', 'Smoky glance', 'Dangerous woman', 'Fatal attraction', 'Black dress', 'Maneater', 'Seductress'],
        'medium': ['The Maltese Falcon', 'Laura', 'Cynosure', 'Siren', 'Dangerous female', 'Deadly beauty', 'Fatal woman'],
        'hard': ['Film noir', 'Dangerous woman', 'Seductive femme', 'Femme fatale', 'Deadly woman', 'Noir dame', 'Fatal woman']
    },
    'imposters': {
        'easy': ['Villain', 'Heroine', 'Spy', 'Antagonist'],
        'medium': ['Dangerous woman', 'Fatal woman', 'Seductive woman', 'Deadly woman'],
        'hard': ['Femme fatale role', 'Fatal feminine', 'Noir siren', 'Deadly beauty']
    }
}

complete_data['Mad scientist'] = {
    'description': 'An eccentric inventor who creates dangerous experiments.',
    'tags': ['mad', 'science', 'experiment'],
    'difficulty': 'medium',
    'hints': {
        'easy': ['Wild hair', 'Bubbling beaker', 'Evil laugh', 'Lab coat', 'Electrical sparks', 'Monologue', 'Creepy creation'],
        'medium': ['Dr Frankenstein', 'Dr Moriarty', 'Dr Jekyll', 'Dr Strangelove', 'Campbel', 'Moriarty', 'Victor Frankenstein'],
        'hard': ['Movie trope', 'Eccentric scientist', 'Mad genius', 'Evil researcher', 'Nefarious scientist', 'Scientific villain', 'Unnatural science']
    },
    'imposters': {
        'easy': ['Villain', 'Inventor', 'Wizard', 'Scientist'],
        'medium': ['Eccentric researcher', 'Mad inventor', 'Evil scientist', 'Unnatural researcher'],
        'hard': ['Mad scientist role', 'Scientific villain', 'Eccentric inventor', 'Nefarious researcher']
    }
}

complete_data['Evil twin'] = {
    'description': 'A sinister identical clone who secretly plots against their sibling.',
    'tags': ['twin', 'deception', 'plot'],
    'difficulty': 'medium',
    'hints': {
        'easy': ['Mirror match', 'Wrong twin', 'Identity theft', 'Dark secret', 'Twin switch', 'Mirror image', 'Sinister copy'],
        'medium': ['The Other', 'Dark Twin', 'Twin of evil', 'Mirror twin', 'Clone evil', 'Evil copy', 'Twins of fate'],
        'hard': ['Evil twin story', 'Mirror twin trope', 'Clone villain', 'Twin deception', 'Identical evil', 'Dual identity', 'Dark reflection']
    },
    'imposters': {
        'easy': ['Doppelganger', 'Clone', 'Villain', 'Mirror'],
        'medium': ['Evil clone', 'Twin villain', 'Dark twin', 'Mirror twin'],
        'hard': ['Evil twin role', 'Mirror villain', 'Twin antagonist', 'Doppelganger role']
    }
}

complete_data['Last stand'] = {
    'description': 'The final desperate battle where defenders face overwhelming odds.',
    'tags': ['battle', 'final', 'defense'],
    'difficulty': 'medium',
    'hints': {
        'easy': ['Final defense', 'All out war', 'Heroic sacrifice', 'Last hope', 'Final battle', 'Final fight', 'Dying moment'],
        'medium': ['The Matrix', 'Saving Private Ryan', '300', 'Braveheart', 'Warrior stand', 'Heroic defense', 'Fighting to the end'],
        'hard': ['Last stand fight', 'Final defensive', 'Desperate defence', 'Heroic sacrifice', 'All or nothing', 'Final moment', 'Last battle']
    },
    'imposters': {
        'easy': ['Final battle', 'Siege', 'Retreat', 'Defense'],
        'medium': ['Heroic stand', 'Final defense', 'Fighting back', 'Last defense'],
        'hard': ['Last stand battle', 'Final stand', 'Desperate defense', 'Heroic last']
    }
}

complete_data['Damsel'] = {
    'description': 'A character who waits for rescue while in peril.',
    'tags': ['trope', 'rescued', 'victim'],
    'difficulty': 'medium',
    'hints': {
        'easy': ['Waiting to be saved', 'In danger', 'Rescue needed', 'Tied up', 'Helpless', 'Captive', 'Needing rescue'],
        'medium': ['Rescue plot', 'Needy female', 'In peril', 'Rescue mission', 'Damsel in distress', 'Victim heroine', 'Needs saving'],
        'hard': ['Damsel trope', 'Damsel in distress', 'Rescue narrative', 'Helpless woman', 'Distressed damsel', 'Needy role', 'Victim role']
    },
    'imposters': {
        'easy': ['Hero', 'Villain', 'Princess', 'Rescuee'],
        'medium': ['Damsel role', 'Rescue subject', 'Helpless woman', 'Victim heroine'],
        'hard': ['Damsel role', 'Helpless character', 'Rescue narrative', 'Distressed heroine']
    }
}

complete_data['Princess'] = {
    'description': 'A royal female who dwells in a castle and awaits adventure.',
    'tags': ['royal', 'fairy tale', 'princess'],
    'difficulty': 'medium',
    'hints': {
        'easy': ['Royal crown', 'Ball gown', 'Castle towers', 'Glass slipper', 'Happily ever after', 'Sleeping beauty', 'Royal palace'],
        'medium': ['Cinderella', 'Sleeping beauty', 'Snow white', 'Rapunzel', 'Disney princess', 'Fairycake', 'Royal family'],
        'hard': ['Princess story', 'Royal lady', 'Fairy tale princess', 'Royal title', 'Noble daughter', 'Crown princess', 'Royal heir']
    },
    'imposters': {
        'easy': ['Queen', 'Duchess', 'Damsel', 'Royalty'],
        'medium': ['Princess role', 'Royal daughter', 'Crown princess', 'Noble princess'],
        'hard': ['Princess character', 'Royal heroine', 'Crown princess', 'Noble daughter']
    }
}

complete_data['Treasure map'] = {
    'description': 'An ancient chart marking the path to hidden riches.',
    'tags': ['map', 'treasure', 'adventure'],
    'difficulty': 'medium',
    'hints': {
        'easy': ['X marks spot', 'Old parchment', 'Buried gold', 'Island mystery', 'Pirate chart', 'Island map', 'Hidden treasure'],
        'medium': ['Treasure hunt', 'Pirate legend', 'Island quest', 'Island X', 'Ancient clue', 'Cursed map', 'Buried loot'],
        'hard': ['Adventure prop', 'Treasure chart', 'Pirate legend', 'Map to riches', 'Historical map', 'Legendary map', 'Island mystery']
    },
    'imposters': {
        'easy': ['Compass', 'Chest', 'Scroll', 'Key'],
        'medium': ['Treasure chart', 'Island map', 'Pirate legend', 'X marks spot'],
        'hard': ['Treasure map', 'Island chart', 'Pirate guide', 'Legendary map']
    }
}

complete_data['Secret agent'] = {
    'description': 'An undercover operative who completes covert missions.',
    'tags': ['spy', 'agent', 'covert'],
    'difficulty': 'medium',
    'hints': {
        'easy': ['License to kill', 'Silenced pistol', 'Disguise kit', 'Earpiece', 'Gadgets', 'Mission brief', 'Safe house'],
        'medium': ['James Bond', 'Jason Bourne', 'Ethan Hunt', 'Secret ops', 'Cover identity', 'Code name', 'Field agent'],
        'hard': ['Spy role', 'Secret operative', 'Covert agent', 'Intelligence officer', 'Field operative', 'Special mission', 'Spy craft']
    },
    'imposters': {
        'easy': ['Detective', 'Hacker', 'Soldier', 'FBI'],
        'medium': ['Spy role', 'Covert agent', 'Secret operative', 'Undercover agent'],
        'hard': ['Secret agent', 'Covert operative', 'Spy role', 'Intelligence agent']
    }
}

complete_data['Time loop'] = {
    'description': 'A plot device where the same time period repeats infinitely.',
    'tags': ['time', 'loop', 'cycle'],
    'difficulty': 'medium',
    'hints': {
        'easy': ['Groundhog Day', 'Stuck in time', 'Repeats', 'Reset button', 'Same day', 'Endless cycle', 'Time repeats'],
        'medium': ['Groundhog Day', 'Edge of Tomorrow', 'Before I Fall', 'Russian Doll', 'Time repeats', 'Day returns', 'Loop nightmare'],
        'hard': ['Time loop story', 'Temporal loop', 'Repeating time', 'Infinite cycle', 'Endless repeat', 'Time trap', 'Temporal stuck']
    },
    'imposters': {
        'easy': ['Time travel', 'Dream', 'Flashback', 'Memory'],
        'medium': ['Time cycle', 'Repeating day', 'Temporal loop', 'Loop story'],
        'hard': ['Time loop plot', 'Temporal loop', 'Repeating time', 'Time loop story']
    }
}

complete_data['Multiverse'] = {
    'description': 'A setting exploring parallel realities and alternate versions.',
    'tags': ['multiverse', 'dimension', 'parallel'],
    'difficulty': 'medium',
    'hints': {
        'easy': ['Parallel world', 'Other self', 'Reality change', 'Dimension hop', 'Alternate life', 'Multiple versions', 'World switch'],
        'medium': ['Doctor Strange', 'Spiderman No Way Home', 'Everything Everywhere', 'Rick and Morty', 'Quantum realm', 'Reality jump', 'Parallel life'],
        'hard': ['Multiverse concept', 'Parallel universe', 'Dimensional travel', 'Alternate reality', 'Reality hopping', 'Multiple worlds', 'Quantum reality']
    },
    'imposters': {
        'easy': ['Time travel', 'Dream', 'Simulation', 'Alternate'],
        'medium': ['Parallel world', 'Alternate reality', 'Multiverse concept', 'Reality hop'],
        'hard': ['Multiverse story', 'Parallel universe', 'Dimensional realm', 'Alternate reality']
    }
}

complete_data['Dream sequence'] = {
    'description': 'A surreal scene occurring in a character\'s sleep or imagination.',
    'tags': ['dream', 'surreal', 'fantasy'],
    'difficulty': 'medium',
    'hints': {
        'easy': ['Sleep vision', 'Subconscious', 'Hazy images', 'Floating feeling', 'Flying dream', 'Nightmare', 'Unseen world'],
        'medium': ['Dali', 'Tarantino', 'Inception', 'Waking up shocked', 'Impossible logic', 'Subconscious mind', 'Dream logic'],
        'hard': ['Dream narrative', 'Fantasy sequence', 'Subconscious vision', 'Surreal moment', 'Mental journey', 'Unconscious vision', 'Fantasy realm']
    },
    'imposters': {
        'easy': ['Flashback', 'Montage', 'Hallucination', 'Memory'],
        'medium': ['Dream scene', 'Surreal moment', 'Fantasy sequence', 'Nightmare'],
        'hard': ['Dream sequence', 'Fantasy scene', 'Subconscious scene', 'Surreal narrative']
    }
}

complete_data['Cyborg'] = {
    'description': 'A being combining organic tissue with artificial machinery.',
    'tags': ['cyborg', 'robot', 'technology'],
    'difficulty': 'medium',
    'hints': {
        'easy': ['Robot parts', 'Metal limbs', 'Red eye', 'Future cop', 'Cyberpunk', 'Muscle machine', 'Steel skin'],
        'medium': ['RoboCop', 'Terminator', 'Six Million Dollar Man', 'Cyborg 001', 'Augmented human', 'Cybernetics', 'Body mods'],
        'hard': ['Sci-fi figure', 'Cybernetic being', 'Part human part machine', 'Artificial augment', 'Cyber body', 'Tech enhancement', 'Cyborg race']
    },
    'imposters': {
        'easy': ['Robot', 'Android', 'Alien', 'Machine'],
        'medium': ['Cyborg character', 'Cybernetic human', 'Augmented human', 'Tech-augmented'],
        'hard': ['Cyborg being', 'Cybernetic being', 'Part human part metal', 'Tech-human hybrid']
    }
}

complete_data['Post apocalyptic'] = {
    'description': 'A setting after civilization has collapsed due to catastrophe.',
    'tags': ['future', 'ruins', 'survival'],
    'difficulty': 'medium',
    'hints': {
        'easy': ['Wasteland', 'Rusty cars', 'Survivors', 'Falling ruins', 'Abandoned cities', 'New world order', 'Dying earth'],
        'medium': ['Mad Max', 'The Road', 'I Am Legend', 'Fallout', 'The Walking Dead', 'Water world', 'Skyline'],
        'hard': ['Post-apocalypse', 'Future ruin', 'Civilization fall', 'End of world', 'Dystopian future', 'Survival story', 'Collapsed society']
    },
    'imposters': {
        'easy': ['Dystopia', 'Zombie outbreak', 'Western', 'Thriller'],
        'medium': ['Post-apoc world', 'Wasteland setting', 'Fallen world', 'Survival setting'],
        'hard': ['Post-apocalyptic film', 'Future ruins', 'After civilization', 'Collapsar story']
    }
}

complete_data['Dystopia'] = {
    'description': 'An oppressive society with strict control and surveillance.',
    'tags': ['dystopia', 'control', 'oppression'],
    'difficulty': 'medium',
    'hints': {
        'easy': ['Surveillance state', 'Grey uniforms', 'Rebel movement', 'Oppressed masses', 'Totalitarian', 'Propaganda', 'Controlled life'],
        'medium': ['1984', 'Blade Runner', 'The Hunger Games', 'V for Vendetta', 'Minority Report', 'The Giver', 'Equilibrium'],
        'hard': ['Dystopian society', 'Oppressive future', 'Control state', 'Surveillance state', 'Totalitarian regime', 'Dark future', 'Utopian opposite']
    },
    'imposters': {
        'easy': ['Utopia', 'Post apocalyptic', 'Kingdom', 'Fantasy'],
        'medium': ['Dystopian world', 'Oppressive future', 'Controlled society', 'Dark society'],
        'hard': ['Dystopia setting', 'Oppressive society', 'Controlled world', 'Surveillance state']
    }
}

complete_data['Ensemble cast'] = {
    'description': 'A film with many stars whose stories interweave.',
    'tags': ['ensemble', 'many', 'stories'],
    'difficulty': 'medium',
    'hints': {
        'easy': ['Many characters', 'Multiple stories', 'All stars', 'Interwoven', 'Cast huge', 'Story threads', 'Character mix'],
        'medium': ['Love actually', 'Crash', 'Syriana', 'Traffic', 'The Avengers', 'Ocean Eleven', 'Pulp Fiction'],
        'hard': ['Ensemble film', 'Multi-character', 'Interlocking stories', 'All-star cast', 'Many protagonists', 'Character web', 'Cast size']
    },
    'imposters': {
        'easy': ['Solo lead', 'Cameo', 'Duo', 'Single'],
        'medium': ['Ensemble movie', 'Multi-star film', 'Many character', 'Character ensemble'],
        'hard': ['Ensemble cast', 'Multi-character film', 'All-star ensemble', 'Character-rich film']
    }
}

complete_data['Antihero'] = {
    'description': 'A protagonist lacking heroic qualities but still admirable.',
    'tags': ['antihero', 'flawed', 'protagonist'],
    'difficulty': 'medium',
    'hints': {
        'easy': ['Flawed hero', 'Moral grey', 'Rules breaker', 'Reluctant', 'Bad guy good', 'Dark knight', 'Vigilante'],
        'medium': ['Homelander', 'Walter White', 'Tony Soprano', 'Dexter Morgan', 'Mad Max', 'The Punisher', 'Deadpool'],
        'hard': ['Antihero character', 'Flawed protagonist', 'Moral ambiguity', 'Antihero role', 'Unconventional hero', 'Dark protagonist', 'Moral grey']
    },
    'imposters': {
        'easy': ['Villain', 'Rogue', 'Sidekick', 'Hero'],
        'medium': ['Anti-hero', 'Flawed protagonist', 'Moral grey hero', 'Unconventional hero'],
        'hard': ['Antihero role', 'Flawed hero', 'Moral grey character', 'Antihero protagonist']
    }
}

complete_data['Henchman'] = {
    'description': 'A villain\'s loyal follower who is easily defeated in battle.',
    'tags': ['henchman', 'villain', 'helper'],
    'difficulty': 'medium',
    'hints': {
        'easy': ['Muscle', 'Evil follower', 'Bad guy helper', 'Falls first', 'Masked goon', 'Muscle bound', 'Fits in'],
        'medium': ['The MiB', 'Henchpeople', 'Villains minions', 'Bad guys crew', 'Evil hench', 'Muscle squad', 'Goons'],
        'hard': ['Henchman role', 'Villain follower', 'Muscle agent', 'Evil agent', 'Bad guy helper', 'Foil protagonist', 'Side villain']
    },
    'imposters': {
        'easy': ['Sidekick', 'Mentor', 'Bodyguard', 'Assistant'],
        'medium': ['Henchman role', 'Villain follower', 'Evil helper', 'Muscle role'],
        'hard': ['Henchman character', 'Villains helper', 'Evil sidekick', 'Muscle man']
    }
}

complete_data['Bodyguard'] = {
    'description': 'A protector who shields important people from danger.',
    'tags': ['bodyguard', 'protector', 'security'],
    'difficulty': 'medium',
    'hints': {
        'easy': ['Tough shield', 'Steady presence', 'Sunglasses', 'Earpiece', 'Always watching', 'Threat remover', 'Security detail'],
        'medium': ['The Bodyguard', 'Honor', 'Puss in Boots', 'Tommy Oliver', 'Nick Fury', 'Mr Peabody', 'Protector'],
        'hard': ['Bodyguard role', 'Personal protector', 'Security detail', 'Escort service', 'Close protection', 'Protection detail', 'Security agent']
    },
    'imposters': {
        'easy': ['Henchman', 'Sidekick', 'Chauffeur', 'Secret service'],
        'medium': ['Personal bodyguard', 'Security agent', 'Protector role', 'Protection detail'],
        'hard': ['Bodyguard character', 'Protection agent', 'Personal security', 'Bodyguard role']
    }
}

complete_data['Chase scene'] = {
    'description': 'An action sequence featuring pursuit on foot or in vehicles.',
    'tags': ['chase', 'action', 'pursuit'],
    'difficulty': 'medium',
    'hints': {
        'easy': ['Running and jumping', 'Heart pounding', 'Police pursuit', 'Escape chase', 'Getaway run', 'On the move', 'High speed'],
        'medium': ['The Matrix', 'Mission Impossible', 'Ronin', '24', 'Fast and Furious', 'Police chase', 'Escape artist'],
        'hard': ['Chase sequence', 'Pursuit action', 'High velocity chase', 'Escape scene', 'Action chase', 'Thrilling chase', 'Runaway segment']
    },
    'imposters': {
        'easy': ['Car chase', 'Shootout', 'Montage', 'Fight scene'],
        'medium': ['Chase action', 'Pursuit scene', 'Hunting scene', 'Evasion scene'],
        'hard': ['Chase sequence', 'Pursuit scene', 'Running scene', 'Escape sequence']
    }
}

complete_data['Opening scene'] = {
    'description': 'The first moments of a story that hook the viewer.',
    'tags': ['opening', 'scene', 'hook'],
    'difficulty': 'medium',
    'hints': {
        'easy': ['First thing', 'Title card', 'Establishes tone', 'Hooks viewer', 'Starts strong', 'Beginning bold', 'Title sequence'],
        'medium': ['Sunset Boulevard', 'Psycho shower', 'Casablanca opening', 'Jaws boat', 'Star Wars crawl', 'Opening hook', 'First impression'],
        'hard': ['Opening sequence', 'First act hook', 'Exposition scene', 'Establishing scene', 'Intro hook', 'Opening hook', 'First moment']
    },
    'imposters': {
        'easy': ['Finale', 'Credits', 'Trailer', 'End'],
        'medium': ['Opening sequence', 'First scene', 'Intro scene', 'Beginning scene'],
        'hard': ['Opening scene', 'First act', 'Intro sequence', 'Beginning sequence']
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

records_009 = [make_record(w) for w in prompt_009_words]

# Write 009_movies.json
target_path = os.path.join('tool', 'words', 'replies', '009_movies.json')
with open(target_path, 'w', encoding='utf-8') as f:
    json.dump(records_009, f, indent=2, ensure_ascii=False)

print('Wrote {} records to {}'.format(len(records_009), target_path))