import json, os

# Read the source pack file for hints and imposters
with open('assets/packs/movies_entertainment.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

words_data = data.get('words', [])

# Create lookup for words
word_lookup = {}
for w in words_data:
    word_lookup[w['word']] = w

# Define complete records for 009_movies.txt (21 words)
prompt_009_words = [
    'Buddy cop', 'Femme fatale', 'Mad scientist', 'Evil twin', 'Last stand',
    'Damsel', 'Princess', 'Treasure map', 'Secret agent', 'Time loop',
    'Multiverse', 'Dream sequence', 'Cyborg', 'Post apocalyptic', 'Dystopia',
    'Ensemble cast', 'Antihero', 'Henchman', 'Bodyguard', 'Chase scene', 'Opening scene'
]

descriptions = {
    'Buddy cop': 'Two mismatched partners work together to solve crimes in this comedic crime drama.',
    'Femme fatale': 'A seductive and dangerous woman who leads men into trouble or death.',
    'Mad scientist': 'An eccentric researcher who conducts unethical experiments in pursuit of knowledge.',
    'Evil twin': 'A sinister identical sibling who plots against their brother or sister.',
    'Last stand': 'A final heroic defense where outnumbered fighters make their last stand.',
    'Damsel': 'A character who waits to be rescued from danger or captivity.',
    'Princess': 'A royal female character often residing in a castle and awaiting rescue.',
    'Treasure map': 'An ancient chart marked with symbols showing where hidden riches are buried.',
    'Secret agent': 'An undercover operative equipped with gadgets and a license to act against threats.',
    'Time loop': 'A narrative device where characters relive the same period of time repeatedly.',
    'Multiverse': 'A story exploring alternate realities and versions of events or characters.',
    'Dream sequence': 'A surreal scene depicting impossible events that occurs during sleep.',
    'Cyborg': 'A being with both organic and mechanical parts, often enhanced with technology.',
    'Post apocalyptic': 'A setting showing a world after a catastrophic event has ruined civilization.',
    'Dystopia': 'An oppressive future society with surveillance, controlled populations, and grey uniforms.',
    'Ensemble cast': 'A film featuring many stars with interwoven stories and equal billing.',
    'Antihero': 'A protagonist who lacks conventional heroic qualities and often breaks the rules.',
    'Henchman': 'A loyal follower who works for a villain and is often easily defeated.',
    'Bodyguard': 'A protector who shields a celebrity or important person from harm.',
    'Chase scene': 'An action sequence featuring pursuit, rooftop runs, and market stalls toppled.',
    'Opening scene': 'The first moments of a story that hooks the audience and sets the tone.'
}

tags = {
    'Buddy cop': ['action', 'comedy', 'detective'],
    'Femme fatale': ['noir', 'danger', 'seduction'],
    'Mad scientist': ['labs', 'experiments', 'eccentric'],
    'Evil twin': ['twins', 'deception', 'plot'],
    'Last stand': ['heroic', 'defense', 'final-battle'],
    'Damsel': ['rescue', 'captive', 'trope'],
    'Princess': ['royal', 'ballgown', 'tiara'],
    'Treasure map': ['pirate', 'adventure', 'hidden'],
    'Secret agent': ['spy', 'gadgets', 'undercover'],
    'Time loop': ['repetition', 'sci-fi', 'drama'],
    'Multiverse': ['alternate', 'realities', 'sci-fi'],
    'Dream sequence': ['surreal', 'sleep', 'visions'],
    'Cyborg': ['robot', 'enhanced', 'technology'],
    'Post apocalyptic': ['ruins', 'survivors', 'wasteland'],
    'Dystopia': ['oppressive', 'control', 'future'],
    'Ensemble cast': ['many', 'stars', 'interwoven'],
    'Antihero': ['flawed', 'protagonist', 'morally-grey'],
    'Henchman': ['villain', 'follower', 'muscle'],
    'Bodyguard': ['protector', 'defense', 'celebrity'],
    'Chase scene': ['action', 'pursuit', 'drama'],
    'Opening scene': ['hook', 'beginning', 'setup']
}

def ensure_hints(hints_list, count=7):
    if not hints_list:
        return ['Glimpse', 'Moment', 'Scene', 'Shot', 'View', 'Flash', 'Image']
    if len(hints_list) < count:
        result = hints_list.copy()
        while len(result) < count:
            for h in hints_list:
                if len(result) < count:
                    result.append(h)
        return result[:count]
    return hints_list[:10]

records_009 = []
for word in prompt_009_words:
    w = word_lookup.get(word, {})
    desc = descriptions.get(word, '')
    word_tags = tags.get(word, ['movie', 'entertainment'])
    hints = w.get('hints', {'easy': [], 'medium': [], 'hard': []})
    imposters = w.get('imposters', {'easy': [], 'medium': [], 'hard': []})

    record = {
        'word': word,
        'category': 'movies_entertainment',
        'subcategory': 'Movies',
        'difficulty': w.get('diff', 'medium'),
        'description': desc,
        'tags': word_tags,
        'hints': {
            'easy': ensure_hints(hints.get('easy', [])),
            'medium': ensure_hints(hints.get('medium', [])),
            'hard': ensure_hints(hints.get('hard', []))
        },
        'imposters': {
            'easy': imposters.get('easy', []),
            'medium': imposters.get('medium', []),
            'hard': imposters.get('hard', [])
        }
    }
    records_009.append(record)

# Write directly to the target file relative to working directory
target_path = os.path.join('tool', 'words', 'replies', '009_movies.json')
with open(target_path, 'w', encoding='utf-8') as f:
    json.dump(records_009, f, indent=2, ensure_ascii=False)

print('Wrote {} records to {}'.format(len(records_009), target_path))