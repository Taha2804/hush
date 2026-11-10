// Recorded (trimmed) API responses used by the online pipeline tests.
// Shapes mirror the real MediaWiki, Wikidata SPARQL, Wikipedia REST,
// ConceptNet and Datamuse responses. No live network is used in tests.

const wikiLinksFruit = {
  'batchcomplete': true,
  'query': {
    'pages': [
      {'pageid': 1, 'title': 'Apple', 'description': 'Fruit of the apple tree', 'pageviews': {'2026-09-01': 9000, '2026-09-02': 8800}},
      {'pageid': 2, 'title': 'Banana', 'description': 'Elongated edible fruit', 'pageviews': {'2026-09-01': 7000, '2026-09-02': 7100}},
      {'pageid': 3, 'title': 'Mango', 'description': 'Edible stone fruit', 'pageviews': {'2026-09-01': 6000}},
      {'pageid': 4, 'title': 'Cherry', 'description': 'Fruit of plants of the genus Prunus', 'pageviews': {'2026-09-01': 5000}},
      {'pageid': 5, 'title': 'Pear', 'description': 'Genus of plants', 'pageviews': {'2026-09-01': 4000}},
      {'pageid': 6, 'title': 'Peach', 'description': 'Species of fruit tree', 'pageviews': {'2026-09-01': 3500}},
      {'pageid': 7, 'title': 'List of culinary fruits', 'pageviews': {'2026-09-01': 99999}},
      {'pageid': 8, 'title': 'Apple (disambiguation)', 'pageviews': {'2026-09-01': 50}},
      {'pageid': 9, 'title': 'Plum', 'description': 'Fruit of some Prunus species', 'pageviews': {'2026-09-01': null}},
      {'pageid': 10, 'title': 'Durian 2026 season', 'pageviews': {'2026-09-01': 10}},
    ],
  },
};

const wikidataFruit = {
  'results': {
    'bindings': [
      {'itemLabel': {'value': 'apple'}, 'links': {'value': '160'}},
      {'itemLabel': {'value': 'kiwifruit'}, 'links': {'value': '90'}},
      {'itemLabel': {'value': 'Q123456'}, 'links': {'value': '80'}},
    ],
  },
};

const summaryApple = {'title': 'Apple', 'description': 'Fruit of the apple tree'};

const conceptNetApple = {
  'edges': [
    {'rel': {'label': 'IsA'}, 'start': {'label': 'apple', 'language': 'en'}, 'end': {'label': 'a fruit', 'language': 'en'}, 'weight': 9.0},
    {'rel': {'label': 'AtLocation'}, 'start': {'label': 'apple', 'language': 'en'}, 'end': {'label': 'an orchard', 'language': 'en'}, 'weight': 6.0},
    {'rel': {'label': 'UsedFor'}, 'start': {'label': 'apple', 'language': 'en'}, 'end': {'label': 'making pie', 'language': 'en'}, 'weight': 5.0},
    {'rel': {'label': 'HasProperty'}, 'start': {'label': 'apple', 'language': 'en'}, 'end': {'label': 'crunchy', 'language': 'en'}, 'weight': 4.0},
    {'rel': {'label': 'HasProperty'}, 'start': {'label': 'apple', 'language': 'en'}, 'end': {'label': 'red', 'language': 'en'}, 'weight': 3.5},
    {'rel': {'label': 'HasA'}, 'start': {'label': 'apple', 'language': 'en'}, 'end': {'label': 'apple seeds', 'language': 'en'}, 'weight': 3.0},
    {'rel': {'label': 'Synonym'}, 'start': {'label': 'apple', 'language': 'en'}, 'end': {'label': 'pome', 'language': 'en'}, 'weight': 2.0},
    {'rel': {'label': 'RelatedTo'}, 'start': {'label': 'apple', 'language': 'en'}, 'end': {'label': 'pear', 'language': 'en'}, 'weight': 2.0},
    {'rel': {'label': 'RelatedTo'}, 'start': {'label': 'apple', 'language': 'en'}, 'end': {'label': 'peach', 'language': 'en'}, 'weight': 1.5},
    {'rel': {'label': 'IsA'}, 'start': {'label': 'pomme', 'language': 'fr'}, 'end': {'label': 'fruit', 'language': 'en'}, 'weight': 1.0},
  ],
};

const datamuseTrgApple = [
  {'word': 'cider', 'score': 1000},
  {'word': 'orchard', 'score': 900},
  {'word': 'apples', 'score': 800},
];

const datamuseMlApple = [
  {'word': 'pear', 'score': 1000},
  {'word': 'cherry', 'score': 900},
  {'word': 'pome', 'score': 850},
  {'word': 'apples', 'score': 800},
];

const datamuseSynApple = [
  {'word': 'pome', 'score': 1000},
];

/// Fixture map for [FixtureFetcher]: URL substring -> response.
Map<String, dynamic> fruitFixtures() => {
      'generator=links': wikiLinksFruit,
      'query.wikidata.org': wikidataFruit,
      'page/summary/Apple': summaryApple,
      'node=/c/en/apple': conceptNetApple,
      'rel_trg=Apple': datamuseTrgApple,
      'ml=Apple': datamuseMlApple,
      'rel_syn=Apple': datamuseSynApple,
      'meta=siteinfo': {'query': {'general': {'sitename': 'Wikipedia'}}},
    };
