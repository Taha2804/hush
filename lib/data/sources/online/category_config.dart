/// Where the Online source looks for candidate words for each category.
///
/// * [listPages]: Wikipedia "List of ..." pages whose links are candidates.
/// * [wikipediaCategories]: category members (without the "Category:" prefix).
/// * [wikidataClasses]: Q-ids; items that are instances/subclasses count.
///
/// Add a category by adding one entry here. Unknown pages/classes simply
/// yield no candidates (and are negative-cached).
class OnlineCategory {
  const OnlineCategory({
    this.listPages = const [],
    this.wikipediaCategories = const [],
    this.wikidataClasses = const [],
  });
  final List<String> listPages;
  final List<String> wikipediaCategories;
  final List<String> wikidataClasses;
}

const onlineCategories = <String, OnlineCategory>{
  'animals': OnlineCategory(
    listPages: ['List of animal names'],
    wikipediaCategories: ['Domesticated animals', 'Mammals of Africa'],
  ),
  'food': OnlineCategory(
    listPages: ['List of dishes', 'List of breads'],
    wikipediaCategories: ['Fast food', 'Desserts'],
    wikidataClasses: ['Q746549'],
  ),
  'drinks': OnlineCategory(
    listPages: ['List of non-alcoholic mixed drinks', 'List of hot beverages'],
    wikipediaCategories: ['Non-alcoholic drinks', 'Tea varieties'],
    wikidataClasses: ['Q40050'],
  ),
  'fruits_vegetables': OnlineCategory(
    listPages: ['List of culinary fruits', 'List of vegetables'],
    wikipediaCategories: ['Tropical fruit', 'Leaf vegetables', 'Root vegetables'],
    wikidataClasses: ['Q1364', 'Q11004'],
  ),
  'countries': OnlineCategory(
    listPages: ['List of sovereign states'],
    wikidataClasses: ['Q3624078'],
  ),
  'cities': OnlineCategory(
    listPages: ['List of largest cities', 'List of national capitals'],
  ),
  'movies': OnlineCategory(
    listPages: ['List of genres', 'Film genre'],
    wikipediaCategories: ['Film genres', 'Film techniques'],
  ),
  'sports': OnlineCategory(
    listPages: ['List of sports'],
    wikipediaCategories: ['Olympic sports', 'Ball games'],
    wikidataClasses: ['Q349'],
  ),
  'jobs': OnlineCategory(
    listPages: ['List of occupations'],
    wikipediaCategories: ['Occupations'],
    wikidataClasses: ['Q28640'],
  ),
  'household': OnlineCategory(
    listPages: ['List of home appliances'],
    wikipediaCategories: ['Home appliances', 'Kitchenware', 'Furniture'],
  ),
  'clothing': OnlineCategory(
    listPages: ['List of clothing types', 'List of headgear'],
    wikipediaCategories: ['Tops (clothing)', 'Footwear'],
    wikidataClasses: ['Q11460'],
  ),
  'transport': OnlineCategory(
    listPages: ['List of vehicles'],
    wikipediaCategories: ['Vehicles by type', 'Boat types'],
    wikidataClasses: ['Q42889'],
  ),
  'nature': OnlineCategory(
    listPages: ['List of landforms', 'List of weather phenomena'],
    wikipediaCategories: ['Landforms', 'Weather hazards'],
  ),
  'technology': OnlineCategory(
    listPages: ['List of consumer electronics'],
    wikipediaCategories: ['Consumer electronics', 'Computer peripherals'],
  ),
  'school': OnlineCategory(
    wikipediaCategories: ['School terminology', 'Office equipment', 'School subjects'],
  ),
  'hobbies': OnlineCategory(
    listPages: ['List of hobbies'],
  ),
  'instruments': OnlineCategory(
    listPages: ['List of musical instruments'],
    wikidataClasses: ['Q34379'],
  ),
  'places': OnlineCategory(
    listPages: ['List of building types'],
    wikipediaCategories: ['Building types'],
  ),
  'body_health': OnlineCategory(
    listPages: ['List of organs of the human body'],
    wikipediaCategories: ['Human anatomy', 'Common cold'],
  ),
  'holidays': OnlineCategory(
    listPages: ['List of festivals', 'List of multinational festivals and holidays'],
    wikidataClasses: ['Q1197685'],
  ),
  'landmarks': OnlineCategory(
    listPages: ['List of tourist attractions', 'New 7 Wonders of the World'],
    wikidataClasses: ['Q570116'],
  ),
  'mythical': OnlineCategory(
    listPages: ['List of legendary creatures by type'],
    wikidataClasses: ['Q2239243'],
  ),
};
