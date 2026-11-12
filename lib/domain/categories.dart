/// Category ids of the v2 word database. Full metadata (name, description,
/// icon, counts, difficulty split) ships in assets/packs/index.json, built
/// from tool/words/categories.json.
library;

/// The optional 18+ category. Disabled by default, never part of Random Mix
/// unless the (age-confirmed) player turns it on.
const adultCategoryId = 'after_dark';

/// Old pack id -> v2 category id (several old packs were merged).
const legacyCategoryIds = <String, String>{
  'animals': 'animals_wildlife',
  'food': 'food_drinks',
  'drinks': 'food_drinks',
  'fruits_vegetables': 'food_drinks',
  'technology': 'science_technology',
  'countries': 'geography_places',
  'cities': 'geography_places',
  'places': 'geography_places',
  'movies': 'movies_entertainment',
  'sports': 'sports_games',
  'hobbies': 'hobbies_leisure',
  'household': 'everyday_objects',
  'clothing': 'everyday_objects',
  'jobs': 'professions_jobs',
  'holidays': 'history_culture',
  'nature': 'nature_environment',
  'transport': 'vehicles_transport',
  'instruments': 'music_art',
  'mythical': 'mythology_fiction',
  'school': 'education_knowledge',
  'landmarks': 'travel_tourism',
};

/// Maps saved category ids to v2 ids, de-duplicated, order kept.
List<String> migrateCategoryIds(List<String> ids) {
  final out = <String>[];
  for (final id in ids) {
    final v2 = legacyCategoryIds[id] ?? id;
    if (!out.contains(v2)) out.add(v2);
  }
  return out;
}
