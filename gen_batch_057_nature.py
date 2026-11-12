import json
import sys
import os

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

recs = []

# Delta - landform at river mouth
recs.append({
    'word': 'Delta',
    'category': 'nature_environment',
    'subcategory': 'Wetland',
    'difficulty': 'easy',
    'description': 'A landform where sediment deposits at a river mouth into a larger body of water.',
    'tags': ['nature', 'wetland', 'river'],
    'hints': {
        'easy': ['Mouth of river', 'Water edge', 'Sediment tip', 'Coastal area', 'Estuary spot', 'River fan'],
        'medium': ['Sediment buildup', 'Freshwater mix', 'Tidal influence', 'Alluvial fan', 'Water spread', 'River mouth area'],
        'hard': ['Deltaic switching', 'Bird foot delta', 'Arcuate delta', 'Cuspate delta', 'Marine delta', 'Delta plain']
    },
    'imposters': {
        'easy': ['Estuary', 'Lagoon'],
        'medium': ['Gulf', 'Cove'],
        'hard': ['Peninsula', 'Archipelago']
    }
})

# Lagoon - shallow coastal water
recs.append({
    'word': 'Lagoon',
    'category': 'nature_environment',
    'subcategory': 'Wetland',
    'difficulty': 'easy',
    'description': 'A shallow body of water separated from the sea by sandbars or coral reefs.',
    'tags': ['nature', 'wetland', 'water'],
    'hints': {
        'easy': ['Shallow pond', 'Coastal sea', 'Blue water', 'Lagoon edge', 'Paradise cove', 'Salt pond'],
        'medium': ['Sandbar reef', 'Barrier reef', 'Lagoon life', 'Brackish water', 'Coastal lagoon', 'Lagoon habitat'],
        'hard': ['Atoll lagoon', 'Ria lagoon', 'Lagoon flow', 'Lagoon salt', 'Lagoon depth', 'Lagoon sediment']
    },
    'imposters': {
        'easy': ['Bay', 'Cove'],
        'medium': ['Inlet', 'Sound'],
        'hard': ['Canyon', 'Cavern']
    }
})

# Bay - partially enclosed water
recs.append({
    'word': 'Bay',
    'category': 'nature_environment',
    'subcategory': 'Coastal',
    'difficulty': 'easy',
    'description': 'A body of water partially enclosed by land with a wider opening than a gulf.',
    'tags': ['nature', 'water', 'coastal'],
    'hints': {
        'easy': ['Indented coast', 'Harbor area', 'Inlet', 'Coastal curve', 'Sheltered water', 'Ocean inlet'],
        'medium': ['Coastal inlet', 'Harbor bay', 'Coastline curve', 'Sheltered bay', 'Marine inlet', 'Bay shape'],
        'hard': ['Fjord bay', 'Ria bay', 'Arte bay', 'Bay formation', 'Coastal geology', 'Bay morphology']
    },
    'imposters': {
        'easy': ['Gulf', 'Cove'],
        'medium': ['Canyon', 'Cavern'],
        'hard': ['Strait', 'Channel']
    }
})

# Gorge - narrow rocky passage
recs.append({
    'word': 'Gorge',
    'category': 'nature_environment',
    'subcategory': 'Landform',
    'difficulty': 'medium',
    'description': 'A narrow canyon with steep rocky walls carved by a river over time.',
    'tags': ['nature', 'landform', 'rocky'],
    'hints': {
        'easy': ['Deep valley', 'Steep sides', 'Rocky passage', 'River gorge', 'Deep ravine', 'Narrow canyon'],
        'medium': ['River carved', 'Steep gorge', 'Rocky walls', 'River bed', 'Deep cut', 'Narrow passage'],
        'hard': ['River incision', 'Downcutting', 'Vertical walls', 'Gorge formation', 'Erosion pattern', 'Rock strata']
    },
    'imposters': {
        'easy': ['Valley', 'Ravine'],
        'medium': ['Gulch', 'Chasm'],
        'hard': ['Crack', 'Fissure']
    }
})

# Plateau - flat elevated area
recs.append({
    'word': 'Plateau',
    'category': 'nature_environment',
    'subcategory': 'Landform',
    'difficulty': 'medium',
    'description': 'A flat-topped elevated area standing above the surrounding land.',
    'tags': ['nature', 'landform', 'elevated'],
    'hints': {
        'easy': ['Flat top', 'High plain', 'Upland', 'Tableland', 'High plain area', 'Meseta'],
        'medium': ['Elevated plateau', 'Flat summit', 'Table top', 'Intermontane', 'Uplifted terrain', 'High plain'],
        'hard': ['Piedmont', 'Lava plateau', 'Intermontane plateau', 'Plateau escarpment', 'Plateau margin', 'High plain area']
    },
    'imposters': {
        'easy': ['Hill', 'Mound'],
        'medium': ['Mountain', 'Knob'],
        'hard': ['Ridge', 'Summit']
    }
})

# Marsh - grassy wetland
recs.append({
    'word': 'Marsh',
    'category': 'nature_environment',
    'subcategory': 'Wetland',
    'difficulty': 'easy',
    'description': 'A wetland dominated by grasses, reeds, and cattails that seasonally floods.',
    'tags': ['nature', 'wetland', 'grasses'],
    'hints': {
        'easy': ['Grassy area', 'Reed bed', 'Cattail marsh', 'Wet meadow', 'Grassy ground', 'Wetland grasses'],
        'medium': ['Freshwater marsh', 'Saltwater marsh', 'Marsh plants', 'Marsh ecosystem', 'Grassy wetland', 'Marsh habitat'],
        'hard': ['Marsh hydrology', 'Marsh succession', 'Marsh soil', 'Marsh vegetation', 'Marsh ecology', 'Marsh management']
    },
    'imposters': {
        'easy': ['Swamp', 'Bog'],
        'medium': ['Moor', 'Fen'],
        'hard': ['Cliff', 'Ravine']
    }
})

# Bog - acidic peat wetland
recs.append({
    'word': 'Bog',
    'category': 'nature_environment',
    'subcategory': 'Wetland',
    'difficulty': 'medium',
    'description': 'An acidic wetland that accumulates peat with sphagnum moss and stunted vegetation.',
    'tags': ['nature', 'wetland', 'acidic'],
    'hints': {
        'easy': ['Peaty wetland', 'Sphagnum moss', 'Acidic water', 'Bog area', 'Spongy ground', 'Bogland'],
        'medium': ['Acidic wetland', 'Peat formation', 'Bog moss', 'Bog environment', 'Acid bog', 'Peat bog'],
        'hard': ['Bog hydrology', 'Peat accumulation', 'Bog carbon', 'Bog succession', 'Bog pH', 'Bog conservation']
    },
    'imposters': {
        'easy': ['Marsh', 'Swamp'],
        'medium': ['Fen', 'Moor'],
        'hard': ['Crater', 'Depression']
    }
})

# Dune - wind-formed sand mound
recs.append({
    'word': 'Dune',
    'category': 'nature_environment',
    'subcategory': 'Landform',
    'difficulty': 'easy',
    'description': 'A mound or ridge of sand formed by wind action in deserts or coastal areas.',
    'tags': ['nature', 'landform', 'sand'],
    'hints': {
        'easy': ['Sand mound', 'Wind dune', 'Desert dune', 'Sand dune', 'Windblown sand', 'Coastal dune'],
        'medium': ['Dune crest', 'Dune slipface', 'Sand accumulation', 'Wind-formed', 'Sand dune', 'Dune crest'],
        'hard': ['Barchan dune', 'Transverse dune', 'Longitudinal dune', 'Parabolic dune', 'Dune migration', 'Dune formation']
    },
    'imposters': {
        'easy': ['Beach', 'Mound'],
        'medium': ['Hill', 'Ridge'],
        'hard': ['Pyramid', 'Hill']
    }
})

# Crater - circular depression
recs.append({
    'word': 'Crater',
    'category': 'nature_environment',
    'subcategory': 'Landform',
    'difficulty': 'medium',
    'description': 'A circular depression on a planet or moon from meteorite impact or volcanic activity.',
    'tags': ['nature', 'landform', 'geological'],
    'hints': {
        'easy': ['Impact crater', 'Circular depression', 'Meteor crater', 'Crater rim', 'Volcano crater', 'Moon crater'],
        'medium': ['Crater floor', 'Crater rim', 'Meteorite', 'Impact site', 'Crater lake', 'Volcanic crater'],
        'hard': ['Meteoritic', 'Impact ejecta', 'Crater chronology', 'Crater saturation', 'Basin formation', 'Crater morphology']
    },
    'imposters': {
        'easy': ['Pit', 'Hole'],
        'medium': ['Canyon', 'Gulch'],
        'hard': ['Caldera', 'Maar']
    }
})

# Fossil - ancient remains
recs.append({
    'word': 'Fossil',
    'category': 'nature_environment',
    'subcategory': 'Archaeological',
    'difficulty': 'medium',
    'description': 'The preserved remains or impressions of ancient plants or animals embedded in rock.',
    'tags': ['nature', 'archaeological', 'ancient'],
    'hints': {
        'easy': ['Ancient remains', 'Prehistoric', 'Rock fossil', 'Old age', 'Bone fragment', 'Old object'],
        'medium': ['Paleontology', 'Fossilized', 'Prehistoric life', 'Rock layer', 'Fossil record', 'Ancient organism'],
        'hard': ['Permineralization', 'Carbonization', 'Trace fossil', 'Index fossil', 'Fossilization', 'Paleoenvironment']
    },
    'imposters': {
        'easy': ['Rock', 'Stone'],
        'medium': ['Bone', 'Shell'],
        'hard': ['Artifact', 'Relic']
    }
})

# Amber - fossilized resin
recs.append({
    'word': 'Amber',
    'category': 'nature_environment',
    'subcategory': 'Gemstone',
    'difficulty': 'medium',
    'description': 'Fossilized tree resin that has hardened over millions of years, often with preserved insects.',
    'tags': ['nature', 'gemstone', 'fossilized'],
    'hints': {
        'easy': ['Fossil resin', 'Golden gem', 'Ancient resin', 'Amber color', 'Tree resin', 'Preserved insect'],
        'medium': ['Fossilized resin', 'Burmese amber', 'Succinite', 'Amber jewelry', 'Resin hardening', 'Inclusion'],
        'hard': ['Copal', 'Resin polymerization', 'Amber age', 'Succinic acid', 'Resin chemistry', 'Amber preservation']
    },
    'imposters': {
        'easy': ['Crystal', 'Glass'],
        'medium': ['Stone', 'Gem'],
        'hard': ['Jewel', 'Ornament']
    }
})

# Crystal - solid with ordered structure
recs.append({
    'word': 'Crystal',
    'category': 'nature_environment',
    'subcategory': 'Mineral',
    'difficulty': 'easy',
    'description': 'A solid material with atoms arranged in a highly ordered, repeating pattern.',
    'tags': ['nature', 'mineral', 'solid'],
    'hints': {
        'easy': ['Clear solid', 'Quartz crystal', 'Geode', 'Crystal form', 'Faceted stone', 'Mineral crystal'],
        'medium': ['Crystal lattice', 'Quartz', 'Faceted', 'Crystal growth', 'Mineral structure', 'Crystal system'],
        'hard': ['Crystal habit', 'Piezoelectric', 'Crystal twinning', 'Lattice parameter', 'Crystal cleavage', 'Crystal habit']
    },
    'imposters': {
        'easy': ['Rock', 'Stone'],
        'medium': ['Gemstone', 'Mineral'],
        'hard': ['Quartz', 'Gem']
    }
})

any_err = False
for r in recs:
    errs, warns = W.validate_record(r, cats, lists)
    if errs:
        print('FAIL:', r['word'], 'errs:', errs)
        any_err = True
    elif warns:
        print('WARN:', r['word'], 'warns:', warns)

if not any_err:
    print('ALL PASSED!')
    out_dir = r'C:\Users\badam\Desktop\hush\tool\words\replies'
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, '057_nature.json')
    with open(out_path, 'w', encoding='utf8') as f:
        json.dump(recs, f, indent=2, ensure_ascii=False)
    print('Wrote', out_path)
else:
    print('ERRORS - file not written')