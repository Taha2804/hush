import sys
sys.path.insert(0, 'tool/words')
import wordlib as W
from generate_words import remaining_legacy

for lid, cat, words in remaining_legacy('countries'):
    print(f'{lid}: {len(words)} words')
    for w in words[:10]:
        print(f'  {w["word"]}')
