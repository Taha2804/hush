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

descriptions = {
    'Sword fight': 'A fight between opponents wielding bladed weapons like swords or knives.',
    'Kung fu': 'A martial art from China featuring acrobatic fighting techniques and disciplined training.',
    'Samurai film': 'A Japanese film genre featuring warriors, honor codes, and sword battles.',
    'Spy movie': 'A film about secret agents who work undercover for governments.',
    'Monster movie': 'A horror film featuring creatures that terrorize people.',
    'Pirate movie': 'An adventure film set on ships with swashbuckling pirates and sea battles.',
    'Dinosaur movie': 'A film featuring prehistoric reptiles brought to life through special effects.',
    'Space opera': 'An adventurous science fiction film set in outer space with grand battles.',
    'Fairy tale': 'A story based on traditional folk tales with magical elements and happy endings.',
    'Teen movie': 'A film focusing on the experiences and challenges of young teenagers.',
    'Sports movie': 'A drama about athletes pursuing victory in competitive sporting events.',
    'Courtroom drama': 'A legal drama featuring trials, lawyers, and courtroom confrontations.',
    'Disaster film': 'A thriller showing characters surviving catastrophic natural or man-made events.',
    'Martial arts': 'Combat techniques practiced in East Asia featuring kicks, breaks, and forms.',
    'Bollywood': 'The Hindi-language film industry from India known for songs, dance, and colorful sets.',
    'Hollywood': 'The American film industry center famous for major productions and movie stars.',
    'Anime': 'Japanese animation featuring colorful art and stories ranging from youth to adult themes.',
    'Cartoon': 'Animated entertainment with simple drawings, often featuring humor for children.',
    'Sitcom': 'A television comedy with humorous situations facing a recurring cast of characters.',
    'Soap opera': 'A long-running drama with continuing storylines and emotional family conflicts.',
    'Reality show': 'A television program featuring real people in unscripted situations.',
    'Game show': 'A TV program where contestants answer questions for prizes or winnings.',
    'Talk show': 'A TV program featuring conversations with guests, often including comedy or news.',
    'Binge watch': 'Watching multiple episodes or films of a series in one sitting without interruption.',
    'Video streaming': 'Online service that delivers movies and TV shows directly to devices.',
    'Movie night': 'A social gathering to watch films together at home with snacks and relaxation.',
    'Movie poster': 'A promotional image advertising a film featuring artwork, title, and star photos.',
    'Ticket stub': 'The torn piece of paper or card from buying cinema admission.',
    'Movie glasses': '3D viewing glasses used to watch films with stereoscopic three-dimensional effects.',
    'Extended cut': 'A longer version of a film with additional scenes not in the theatrical release.',
    'Blooper': 'A mistake caught on film during production that shows actors forgetting lines.',
    'Box set': 'A collection of related films or episodes released together in a special package.',
    'Costume designer': 'The film crew member responsible for creating period or fictional clothing.',
    'Screenwriter': 'The person who writes the script with dialogue and scene descriptions for a film.',
    'Movie star': 'A famous actor who appears prominently in films and appears on magazine covers.',
    'Award show': 'A ceremony honoring outstanding achievements in film with presents of golden statues.',
    'Indie film': 'A low-budget film produced independently without major studio financing.',
    'Short film': 'A brief motion picture usually under thirty minutes with a tight narrative.',
    'Feature film': 'A full-length narrative film typically running one to three hours.',
    'Horror villain': 'The evil antagonist in a horror film designed to scare and terrorize viewers.',
    'Jump scare': 'A horror technique where something suddenly appears to startle the audience.',
    'Haunted doll': 'A horror movie prop representing a cursed toy with supernatural powers.',
    'Found footage': 'A horror style where the film appears to be shot by the characters themselves.',
    'Slasher': 'A horror film featuring a masked killer who systematically hunts and murder victims.',
    'Ghost story': 'A tale about spirits or supernatural beings that haunt the living.',
    'Love story': 'A romantic narrative focusing on the development of a romantic relationship.',
    'Tragedy': 'A dramatic work ending in disaster or untimely death for its central character.',
    'Satire': 'Comedy that uses humor, irony, or exaggeration to critique society or politics.',
    'Slapstick': 'Physical comedy involving exaggerated movement, falls, and violent humor.',
    'Underdog': 'A character who is expected to lose but triumphs against all odds.'
}

tags = {
    'Sword fight': ['action', 'combat', 'epic'],
    'Kung fu': ['martial-arts', 'action', 'fight'],
    'Samurai film': ['japanese', 'action', 'warrior'],
    'Spy movie': ['action', 'thriller', 'espionage'],
    'Monster movie': ['horror', 'creature', 'adventure'],
    'Pirate movie': ['adventure', 'seas', 'treasure'],
    'Dinosaur movie': ['prehistoric', 'adventure', 'creature'],
    'Space opera': ['science-fiction', 'space', 'adventure'],
    'Fairy tale': ['fantasy', 'magic', 'story'],
    'Teen movie': ['teen', 'drama', 'coming-of-age'],
    'Sports movie': ['sports', 'inspiring', 'drama'],
    'Courtroom drama': ['legal', 'drama', 'court'],
    'Disaster film': ['catastrophe', 'thriller', 'survival'],
    'Martial arts': ['combat', 'sport', 'training'],
    'Bollywood': ['indian', 'musical', 'cinema'],
    'Hollywood': ['american', 'cinema', 'industry'],
    'Anime': ['japanese', 'animation', 'cartoon'],
    'Cartoon': ['animation', 'kids', 'humor'],
    'Sitcom': ['comedy', 'television', 'laughter'],
    'Soap opera': ['drama', 'television', 'serial'],
    'Reality show': ['television', 'unscripted', 'competition'],
    'Game show': ['television', 'quiz', 'prizes'],
    'Talk show': ['television', 'interview', 'comedy'],
    'Binge watch': ['streaming', 'marathon', 'habit'],
    'Video streaming': ['online', 'service', 'movies'],
    'Movie night': ['event', 'home', 'social'],
    'Movie poster': ['advertising', 'art', 'promotion'],
    'Ticket stub': ['memorabilia', 'ticket', 'keepsake'],
    'Movie glasses': ['3d', 'cinema', 'glasses'],
    'Extended cut': ['director', 'edition', 'extended'],
    'Blooper': ['mistake', 'outtake', 'behind-scenes'],
    'Box set': ['collection', 'edition', 'collector'],
    'Costume designer': ['fashion', 'crew', 'film-maker'],
    'Screenwriter': ['author', 'script', 'film'],
    'Movie star': ['actor', 'celebrity', 'hollywood'],
    'Award show': ['ceremony', 'awards', 'celebration'],
    'Indie film': ['independent', 'low-budget', 'art'],
    'Short film': ['brief', 'narrative', 'festival'],
    'Feature film': ['main', 'feature', 'full-length'],
    'Horror villain': ['evil', 'antagonist', 'monster'],
    'Jump scare': ['horror', 'technique', 'startle'],
    'Haunted doll': ['horror', 'prop', 'cursed'],
    'Found footage': ['horror', 'style', 'mockumentary'],
    'Slasher': ['horror', 'killer', 'murder'],
    'Ghost story': ['supernatural', 'horror', 'spirit'],
    'Love story': ['romance', 'drama', 'relationship'],
    'Tragedy': ['drama', 'ending', 'sad'],
    'Satire': ['comedy', 'mockery', 'humor'],
    'Slapstick': ['comedy', 'physical', 'humorous'],
    'Underdog': ['story', 'triumph', 'champion']
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

records_008 = []
for word in prompt_008_words:
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
    records_008.append(record)

# Write directly to the target file relative to working directory
target_path = os.path.join('tool', 'words', 'replies', '008_movies.json')
with open(target_path, 'w', encoding='utf-8') as f:
    json.dump(records_008, f, indent=2, ensure_ascii=False)

print('Wrote {} records to {}'.format(len(records_008), target_path))