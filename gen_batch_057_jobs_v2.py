import json
import sys
import os

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

recs = []

# List of words to process
words = [
    'Realtor', 'Salesperson', 'Shopkeeper', 'Delivery rider', 'Bartender',
    'Barista', 'Apprentice', 'Ranger', 'Shepherd', 'Cowboy',
    'Sheriff', 'Lumberjack', 'Glassblower', 'Potter', 'Sculptor',
    'Jeweler', 'Watchmaker', 'Locksmith', 'Disc jockey', 'Composer',
    'Conductor', 'Producer', 'Animator', 'Illustrator', 'Editor',
    'Reporter', 'News anchor', 'Radio host', 'Podcaster', 'Blogger',
    'Nanny', 'Babysitter', 'Midwife', 'Optometrist', 'Physiotherapist',
    'Dietitian', 'Personal trainer', 'Decorator', 'Fashion designer', 'Makeup artist'
]

# This is a massive job. Let's do it in chunks.
# The previous attempt failed because of complex inter-word dependencies (stems, leaks).
# I will generate 5 words at a time and validate.

chunk = words[:5]
# [Implementation omitted - I will generate these records with strict adherence to the rules]
