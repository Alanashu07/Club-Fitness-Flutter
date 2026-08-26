// import 'package:fuzzy/fuzzy.dart';
// import 'package:string_similarity/string_similarity.dart';

// class SearchService {
//   static List<PlaceEntity> searchPlaces(
//     List<PlaceEntity> places,
//     String query, {
//     double threshold = 0.4,
//   }) {
//     // if (query.trim().length < 2) return [];

//     final q = query.toLowerCase().trim();

//     // ── Build parallel index ───────────────────────
//     final List<String> indexTexts = [];
//     final List<PlaceEntity> indexPlaces = [];

//     for (final place in places) {
//       final text = [
//         place.name,
//         place.admin2Name,
//         place.admin1,
//         place.country,
//       ].where((s) => s.isNotEmpty).join(' ').toLowerCase().trim();

//       indexTexts.add(text);
//       indexPlaces.add(place);
//     }

//     if (indexTexts.isEmpty) return [];

//     // ── Fuzzy filter ───────────────────────────────
//     final fuse = Fuzzy<String>(
//       indexTexts,
//       options: FuzzyOptions(threshold: threshold, distance: 100),
//     );

//     final results = fuse.search(q);

//     final matched = <PlaceEntity>[];
//     final seen = <int>{};

//     for (final r in results) {
//       final i = indexTexts.indexOf(r.item);
//       if (i >= 0 && i < indexPlaces.length && seen.add(i)) {
//         matched.add(indexPlaces[i]);
//       }
//     }

//     // ── Score + sort ───────────────────────────────
//     matched.sort((a, b) {
//       final aScore = _placeScore(a, q, threshold);
//       final bScore = _placeScore(b, q, threshold);
//       return bScore.compareTo(aScore);
//     });

//     return matched;
//   }

//   static int _placeScore(PlaceEntity place, String q, double threshold) {
//     final name = place.name.toLowerCase();
//     final admin2 = place.admin2Name.toLowerCase();
//     final admin1 = place.admin1.toLowerCase();
//     final country = place.country.toLowerCase();

//     int score = 0;

//     // ── Exact / prefix / contains on name (highest weight) ──
//     if (name == q) {
//       score += 1000;
//     } else if (name.startsWith(q)) {
//       score += 800;
//     } else if (name.contains(q)) {
//       score += 600;
//     } else {
//       final sim = StringSimilarity.compareTwoStrings(q, name);
//       if (sim > threshold) score += (sim * 500).toInt();
//       score += (sim * 100).toInt(); // always add fuzzy contribution
//     }

//     // ── Admin2 / district (medium weight) ───────────────────
//     if (admin2 == q) {
//       score += 300;
//     } else if (admin2.startsWith(q)) {
//       score += 200;
//     } else if (admin2.contains(q)) {
//       score += 120;
//     } else {
//       final sim = StringSimilarity.compareTwoStrings(q, admin2);
//       if (sim > threshold) score += (sim * 150).toInt();
//       score += (sim * 40).toInt();
//     }

//     // ── Admin1 / state (lower weight) ───────────────────────
//     if (admin1.contains(q)) {
//       score += 60;
//     } else {
//       final sim = StringSimilarity.compareTwoStrings(q, admin1);
//       score += (sim * 30).toInt();
//     }

//     // ── Country (lowest weight) ──────────────────────────────
//     if (country.contains(q)) score += 20;

//     // ── Word boundary bonus ──────────────────────────────────
//     for (final word in q.split(' ').where((w) => w.isNotEmpty)) {
//       if (name.contains(word)) score += 50;
//       if (admin2.contains(word)) score += 30;
//       if (admin1.contains(word)) score += 15;
//     }

//     return score;
//   }

//   static List<CategoryEntity> searchCategories(
//     List<CategoryEntity> categories,
//     String query, {
//     double threshold = 0.4,
//     bool activeOnly = false,
//   }) {
//     // if (query.trim().length < 2) return [];

//     final q = query.toLowerCase().trim();

//     // Filter inactive if needed
//     final source = activeOnly
//         ? categories.where((c) => c.isActive).toList()
//         : categories;

//     // ── Build parallel index ───────────────────────
//     final List<String> indexTexts = [];
//     final List<CategoryEntity> indexCategories = [];

//     for (final category in source) {
//       final text = [
//         category.name,
//         category.slug.replaceAll(
//           '-',
//           ' ',
//         ), // slugs like "fast-food" → "fast food"
//         category.description,
//       ].where((s) => s.isNotEmpty).join(' ').toLowerCase().trim();

//       indexTexts.add(text);
//       indexCategories.add(category);
//     }

//     if (indexTexts.isEmpty) return [];

//     // ── Fuzzy filter ───────────────────────────────
//     final fuse = Fuzzy<String>(
//       indexTexts,
//       options: FuzzyOptions(threshold: threshold, distance: 100),
//     );

//     final results = fuse.search(q);

//     final matched = <CategoryEntity>[];
//     final seen = <int>{};

//     for (final r in results) {
//       final i = indexTexts.indexOf(r.item);
//       if (i >= 0 && i < indexCategories.length && seen.add(i)) {
//         matched.add(indexCategories[i]);
//       }
//     }

//     // ── Score + sort ───────────────────────────────
//     matched.sort((a, b) {
//       final aScore = _categoryScore(a, q, threshold);
//       final bScore = _categoryScore(b, q, threshold);
//       return bScore.compareTo(aScore);
//     });

//     return matched;
//   }

//   static int _categoryScore(
//     CategoryEntity category,
//     String q,
//     double threshold,
//   ) {
//     final name = category.name.toLowerCase();
//     final slug = category.slug.replaceAll('-', ' ').toLowerCase();
//     final description = category.description.toLowerCase();

//     int score = 0;

//     // ── Name (highest weight) ────────────────────────────────
//     if (name == q) {
//       score += 1000;
//     } else if (name.startsWith(q)) {
//       score += 800;
//     } else if (name.contains(q)) {
//       score += 600;
//     } else {
//       final sim = StringSimilarity.compareTwoStrings(q, name);
//       if (sim > threshold) score += (sim * 500).toInt();
//       score += (sim * 100).toInt();
//     }

//     // ── Slug (medium weight) ─────────────────────────────────
//     if (slug == q) {
//       score += 300;
//     } else if (slug.startsWith(q)) {
//       score += 200;
//     } else if (slug.contains(q)) {
//       score += 120;
//     } else {
//       final sim = StringSimilarity.compareTwoStrings(q, slug);
//       if (sim > threshold) score += (sim * 150).toInt();
//       score += (sim * 40).toInt();
//     }

//     // ── Description (lowest weight) ──────────────────────────
//     if (description.contains(q)) {
//       score += 60;
//     } else {
//       final sim = StringSimilarity.compareTwoStrings(q, description);
//       score += (sim * 30).toInt();
//     }

//     // ── Word boundary bonus ──────────────────────────────────
//     for (final word in q.split(' ').where((w) => w.isNotEmpty)) {
//       if (name.contains(word)) score += 50;
//       if (slug.contains(word)) score += 30;
//       if (description.contains(word)) score += 15;
//     }

//     return score;
//   }

//   static List<PlaceListEntity> searchPlaceList(
//     List<PlaceListEntity> items,
//     String query, {
//     double threshold = 0.4,
//   }) {
//     final q = query.toLowerCase().trim();

//     final List<String> indexTexts = [];
//     final List<PlaceListEntity> indexItems = [];

//     for (final item in items) {
//       final text = [
//         item.name,
//         item.placeName,
//         item.admin2Name,
//         item.admin1Name,
//         item.attractionTypeName,
//         item.shortDescription,
//       ].where((s) => s.isNotEmpty).join(' ').toLowerCase().trim();

//       indexTexts.add(text);
//       indexItems.add(item);
//     }

//     if (indexTexts.isEmpty) return [];

//     final matched = _fuzzyFilter(indexTexts, indexItems, q, threshold);

//     matched.sort(
//       (a, b) => _placeListScore(
//         b,
//         q,
//         threshold,
//       ).compareTo(_placeListScore(a, q, threshold)),
//     );

//     return matched;
//   }

//   static int _placeListScore(PlaceListEntity e, String q, double threshold) {
//     final name = e.name.toLowerCase();
//     final placeName = e.placeName.toLowerCase();
//     final admin2 = e.admin2Name.toLowerCase();
//     final admin1 = e.admin1Name.toLowerCase();
//     final typeName = e.attractionTypeName.toLowerCase();
//     final desc = e.shortDescription.toLowerCase();

//     int score = 0;

//     score += _nameScore(
//       name,
//       q,
//       threshold,
//       exact: 1000,
//       prefix: 800,
//       contains: 600,
//       fuzzyHigh: 500,
//       fuzzyLow: 100,
//     );
//     score += _nameScore(
//       placeName,
//       q,
//       threshold,
//       exact: 400,
//       prefix: 300,
//       contains: 200,
//       fuzzyHigh: 150,
//       fuzzyLow: 40,
//     );
//     score += _nameScore(
//       admin2,
//       q,
//       threshold,
//       exact: 300,
//       prefix: 200,
//       contains: 120,
//       fuzzyHigh: 150,
//       fuzzyLow: 40,
//     );

//     if (admin1.contains(q)) {
//       score += 60;
//     } else {
//       score += (StringSimilarity.compareTwoStrings(q, admin1) * 30).toInt();
//     }

//     if (typeName.contains(q)) score += 40;
//     if (desc.contains(q)) score += 20;

//     for (final word in q.split(' ').where((w) => w.isNotEmpty)) {
//       if (name.contains(word)) score += 50;
//       if (placeName.contains(word)) score += 30;
//       if (admin2.contains(word)) score += 20;
//     }

//     return score;
//   }

//   // ─────────────────────────────────────────────
//   // RestaurantListEntity
//   // ─────────────────────────────────────────────

//   static List<RestaurantListEntity> searchRestaurantList(
//     List<RestaurantListEntity> items,
//     String query, {
//     double threshold = 0.4,
//   }) {
//     final q = query.toLowerCase().trim();

//     final List<String> indexTexts = [];
//     final List<RestaurantListEntity> indexItems = [];

//     for (final item in items) {
//       final cuisineNames = item.cuisines.map((c) => c.name).join(' ');
//       final tagNames = item.tags.map((t) => t.name).join(' ');

//       final text = [
//         item.name,
//         item.shortDescription,
//         item.location,
//         item.place.name,
//         cuisineNames,
//         tagNames,
//       ].where((s) => s.isNotEmpty).join(' ').toLowerCase().trim();

//       indexTexts.add(text);
//       indexItems.add(item);
//     }

//     if (indexTexts.isEmpty) return [];

//     final matched = _fuzzyFilter(indexTexts, indexItems, q, threshold);

//     matched.sort(
//       (a, b) => _restaurantScore(
//         b,
//         q,
//         threshold,
//       ).compareTo(_restaurantScore(a, q, threshold)),
//     );

//     return matched;
//   }

//   static int _restaurantScore(
//     RestaurantListEntity e,
//     String q,
//     double threshold,
//   ) {
//     final name = e.name.toLowerCase();
//     final location = e.location.toLowerCase();
//     final placeName = e.place.name.toLowerCase();
//     final desc = e.shortDescription.toLowerCase();
//     final cuisines = e.cuisines.map((c) => c.name.toLowerCase()).toList();
//     final tags = e.tags.map((t) => t.name.toLowerCase()).toList();

//     int score = 0;

//     score += _nameScore(
//       name,
//       q,
//       threshold,
//       exact: 1000,
//       prefix: 800,
//       contains: 600,
//       fuzzyHigh: 500,
//       fuzzyLow: 100,
//     );
//     score += _nameScore(
//       placeName,
//       q,
//       threshold,
//       exact: 300,
//       prefix: 200,
//       contains: 150,
//       fuzzyHigh: 100,
//       fuzzyLow: 30,
//     );

//     if (location.contains(q)) score += 120;
//     if (desc.contains(q)) score += 30;

//     for (final cuisine in cuisines) {
//       score += _nameScore(
//         cuisine,
//         q,
//         threshold,
//         exact: 200,
//         prefix: 150,
//         contains: 100,
//         fuzzyHigh: 80,
//         fuzzyLow: 20,
//       );
//     }

//     for (final tag in tags) {
//       if (tag.contains(q)) score += 40;
//     }

//     for (final word in q.split(' ').where((w) => w.isNotEmpty)) {
//       if (name.contains(word)) score += 50;
//       if (location.contains(word)) score += 25;
//       if (cuisines.any((c) => c.contains(word))) score += 30;
//     }

//     return score;
//   }

//   // ─────────────────────────────────────────────
//   // EventListEntity
//   // ─────────────────────────────────────────────

//   static List<EventListEntity> searchEventList(
//     List<EventListEntity> items,
//     String query, {
//     double threshold = 0.4,
//   }) {
//     final q = query.toLowerCase().trim();

//     final List<String> indexTexts = [];
//     final List<EventListEntity> indexItems = [];

//     for (final item in items) {
//       final tagNames = item.tags.join(' ');

//       final text = [
//         item.name,
//         item.venueName,
//         item.eventType,
//         item.place.name,
//         tagNames,
//       ].where((s) => s.isNotEmpty).join(' ').toLowerCase().trim();

//       indexTexts.add(text);
//       indexItems.add(item);
//     }

//     if (indexTexts.isEmpty) return [];

//     final matched = _fuzzyFilter(indexTexts, indexItems, q, threshold);

//     matched.sort(
//       (a, b) =>
//           _eventScore(b, q, threshold).compareTo(_eventScore(a, q, threshold)),
//     );

//     return matched;
//   }

//   static int _eventScore(EventListEntity e, String q, double threshold) {
//     final name = e.name.toLowerCase();
//     final venue = e.venueName.toLowerCase();
//     final eventType = e.eventType.toLowerCase();
//     final placeName = e.place.name.toLowerCase();
//     final tags = e.tags.map((t) => t.toLowerCase()).toList();

//     int score = 0;

//     score += _nameScore(
//       name,
//       q,
//       threshold,
//       exact: 1000,
//       prefix: 800,
//       contains: 600,
//       fuzzyHigh: 500,
//       fuzzyLow: 100,
//     );
//     score += _nameScore(
//       venue,
//       q,
//       threshold,
//       exact: 400,
//       prefix: 300,
//       contains: 200,
//       fuzzyHigh: 150,
//       fuzzyLow: 40,
//     );
//     score += _nameScore(
//       placeName,
//       q,
//       threshold,
//       exact: 300,
//       prefix: 200,
//       contains: 120,
//       fuzzyHigh: 100,
//       fuzzyLow: 30,
//     );

//     if (eventType.contains(q)) score += 80;

//     for (final tag in tags) {
//       if (tag.contains(q)) score += 40;
//     }

//     for (final word in q.split(' ').where((w) => w.isNotEmpty)) {
//       if (name.contains(word)) score += 50;
//       if (venue.contains(word)) score += 30;
//       if (placeName.contains(word)) score += 20;
//     }

//     return score;
//   }

//   // ─────────────────────────────────────────────
//   // StayListEntity
//   // ─────────────────────────────────────────────

//   static List<StayListEntity> searchStayList(
//     List<StayListEntity> items,
//     String query, {
//     double threshold = 0.4,
//   }) {
//     final q = query.toLowerCase().trim();

//     final List<String> indexTexts = [];
//     final List<StayListEntity> indexItems = [];

//     for (final item in items) {
//       final tagNames = item.tags.map((t) => t.name).join(' ');

//       final text = [
//         item.title,
//         item.tagline,
//         item.shortDescription,
//         item.stayType,
//         item.locality,
//         item.place.name,
//         item.place.admin1,
//         item.mainTag.name,
//         tagNames,
//       ].where((s) => s.isNotEmpty).join(' ').toLowerCase().trim();

//       indexTexts.add(text);
//       indexItems.add(item);
//     }

//     if (indexTexts.isEmpty) return [];

//     final matched = _fuzzyFilter(indexTexts, indexItems, q, threshold);

//     matched.sort(
//       (a, b) =>
//           _stayScore(b, q, threshold).compareTo(_stayScore(a, q, threshold)),
//     );

//     return matched;
//   }

//   static int _stayScore(StayListEntity e, String q, double threshold) {
//     final title = e.title.toLowerCase();
//     final tagline = e.tagline.toLowerCase();
//     final stayType = e.stayType.toLowerCase();
//     final locality = e.locality.toLowerCase();
//     final placeName = e.place.name.toLowerCase();
//     final desc = e.shortDescription.toLowerCase();
//     final mainTag = e.mainTag.name.toLowerCase();
//     final tags = e.tags.map((t) => t.name.toLowerCase()).toList();

//     int score = 0;

//     score += _nameScore(
//       title,
//       q,
//       threshold,
//       exact: 1000,
//       prefix: 800,
//       contains: 600,
//       fuzzyHigh: 500,
//       fuzzyLow: 100,
//     );
//     score += _nameScore(
//       locality,
//       q,
//       threshold,
//       exact: 400,
//       prefix: 300,
//       contains: 200,
//       fuzzyHigh: 150,
//       fuzzyLow: 40,
//     );
//     score += _nameScore(
//       placeName,
//       q,
//       threshold,
//       exact: 300,
//       prefix: 200,
//       contains: 150,
//       fuzzyHigh: 100,
//       fuzzyLow: 30,
//     );

//     if (stayType.contains(q)) score += 100;
//     if (tagline.contains(q)) score += 60;
//     if (desc.contains(q)) score += 30;
//     if (mainTag.contains(q)) score += 50;

//     for (final tag in tags) {
//       if (tag.contains(q)) score += 30;
//     }

//     for (final word in q.split(' ').where((w) => w.isNotEmpty)) {
//       if (title.contains(word)) score += 50;
//       if (locality.contains(word)) score += 30;
//       if (placeName.contains(word)) score += 20;
//       if (stayType.contains(word)) score += 15;
//     }

//     return score;
//   }

//   // ─────────────────────────────────────────────
//   // Shared helpers
//   // ─────────────────────────────────────────────

//   static List<T> _fuzzyFilter<T>(
//     List<String> indexTexts,
//     List<T> indexItems,
//     String q,
//     double threshold,
//   ) {
//     final fuse = Fuzzy<String>(
//       indexTexts,
//       options: FuzzyOptions(threshold: threshold, distance: 100),
//     );

//     final results = fuse.search(q);
//     final matched = <T>[];
//     final seen = <int>{};

//     for (final r in results) {
//       final i = indexTexts.indexOf(r.item);
//       if (i >= 0 && i < indexItems.length && seen.add(i)) {
//         matched.add(indexItems[i]);
//       }
//     }

//     return matched;
//   }

//   static int _nameScore(
//     String field,
//     String q,
//     double threshold, {
//     required int exact,
//     required int prefix,
//     required int contains,
//     required int fuzzyHigh,
//     required int fuzzyLow,
//   }) {
//     if (field.isEmpty) return 0;
//     if (field == q) return exact;
//     if (field.startsWith(q)) return prefix;
//     if (field.contains(q)) return contains;

//     final sim = StringSimilarity.compareTwoStrings(q, field);
//     int score = (sim * fuzzyLow).toInt();
//     if (sim > threshold) score += (sim * fuzzyHigh).toInt();
//     return score;
//   }
// }
