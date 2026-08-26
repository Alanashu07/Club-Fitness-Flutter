import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/parser.dart' as html;
import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/config/network/api.dart';
import 'package:club_fitness/core/constants/constants.dart';
import 'package:club_fitness/core/services/image_cache_manager.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/features/image_cache/presentation/cubit/cache_image_cubit.dart';
import 'package:club_fitness/widgets/common_widgets.dart';
import 'package:share_plus/share_plus.dart';

extension StringCapitalization on String {
  /// 1. Capitalizes the first letter of the string
  String get capitalizeFirst {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// 2. Capitalizes the first letter of each word separated by spaces
  String get capitalizeEachWord {
    return split(' ')
        .map(
          (word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
        )
        .join(' ');
  }

  /// 3. Splits camelCase or PascalCase by capital letters and capitalizes each part
  /// For example: "assetType" => "Asset Type"
  String get capitalizeFromCamelCase {
    final words = replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match[1]} ${match[2]}',
    );
    return words.capitalizeEachWord;
  }

  String get splitUnderscoreAndCapitalize {
    String words = split('_').join(' ');
    return words.capitalizeEachWord;
  }

  String get snakeCase {
    String words = split(' ').join('_');
    return words.toLowerCase();
  }

  String get twoLetters {
    return split(' ').take(2).map((e) => e.isEmpty ? e : e[0]).join();
  }

  String get firstLetter {
    return isEmpty ? '' : trim()[0];
  }

  num get numberOnly {
    List<String> letters = split('');
    List<int> numbers = [];
    for (var letter in letters) {
      int? number = int.tryParse(letter);
      if (number == null) continue;
      numbers.add(number);
    }
    if (numbers.isEmpty) return 0;
    if (numbers.length == 1) return numbers.first;
    String joined = numbers.join();
    return num.tryParse(joined) ?? 0;
  }
}

extension VideoDurationExtension on num {
  String get formatDuration {
    int hours = this ~/ 3600;
    int minutes = (this % 3600) ~/ 60;
    num seconds = this % 60;
    if (hours == 0) {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

extension NumFormatExtension on num {
  /// Returns a shortened string representation of the number using suffixes:
  /// - `k` for thousands
  /// - `M` for millions
  /// - `B` for billions
  /// - `T` for trillions
  ///
  /// Examples:
  /// ```dart
  /// 950.formatRating      // "950"
  /// 1500.formatRating     // "1.5k"
  /// 1000000.formatRating  // "1M"
  /// 2540000000.formatRating // "2.5B"
  /// 7200000000000.formatRating // "7.2T"
  /// ```
  ///
  /// This is especially useful for UI elements that display
  /// large numbers like ratings, view counts, or revenue.
  String get formatRating {
    final absValue = abs();

    if (absValue >= 1e12) {
      return _formatWithSuffix(this, 1e12, 'T');
    } else if (absValue >= 1e9) {
      return _formatWithSuffix(this, 1e9, 'B');
    } else if (absValue >= 1e6) {
      return _formatWithSuffix(this, 1e6, 'M');
    } else if (absValue >= 1e3) {
      return _formatWithSuffix(this, 1e3, 'k');
    } else {
      return toStringAsFixed(truncateToDouble() == this ? 0 : 1);
    }
  }

  String get formatInINRShortNoSymbol {
    final absValue = abs();

    if (absValue >= 1e7) {
      return _formatWithUnitNoSymbol(this, 1e7, ' Cr');
    } else if (absValue >= 1e5) {
      return _formatWithUnitNoSymbol(this, 1e5, ' L');
    } else if (absValue >= 1e3) {
      return _formatWithUnitNoSymbol(this, 1e3, 'k');
    } else {
      return toStringAsFixed(truncateToDouble() == this ? 0 : 1);
    }
  }

  int get opacityToAlpha => (this * 255).round();

  /// Internal helper to format the number with the specified divisor and suffix.
  String _formatWithSuffix(num value, double divisor, String suffix) {
    final divided = value / divisor;
    final hasDecimal = divided % 1 != 0;
    return divided.toStringAsFixed(hasDecimal ? 1 : 0) + suffix;
  }

  /// Formats the number as Indian currency using localized units like:
  /// - `Thousand` (K)
  /// - `Lakh` (L)
  /// - `Crore` (Cr)
  ///
  /// Example:
  /// ```dart
  /// 850.0.formatInINR        // ₹ 850
  /// 125000.0.formatInINR     // ₹ 1.2 Lakh
  /// 10000000.0.formatInINR   // ₹ 1 Crore
  /// ```
  ///
  /// This is suitable for financial figures and price display in Indian apps.
  String get formatInINR {
    final absValue = abs();

    if (absValue >= 1e7) {
      return _formatWithUnit(this, 1e7, ' Crore');
    } else if (absValue >= 1e5) {
      return _formatWithUnit(this, 1e5, ' Lakh');
    } else if (absValue >= 1e3) {
      return _formatWithUnit(this, 1e3, ' Thousand');
    } else {
      return '₹ ${toStringAsFixed(truncateToDouble() == this ? 0 : 1)}';
    }
  }

  String get formatInINRShort {
    final absValue = abs();

    if (absValue >= 1e7) {
      return _formatWithUnit(this, 1e7, ' Cr');
    } else if (absValue >= 1e5) {
      return _formatWithUnit(this, 1e5, ' L');
    } else if (absValue >= 1e3) {
      return _formatWithUnit(this, 1e3, 'k');
    } else {
      return '₹ ${toStringAsFixed(truncateToDouble() == this ? 0 : 1)}';
    }
  }

  String get formatIndianComma {
    // Convert the number to a string and separate integer and fractional parts
    final numberString = roundWithFixed;
    final parts = numberString.split('.');
    final integerPart = parts[0];
    final fractionalPart = parts.length > 1 ? '.${parts[1]}' : '';

    // If the integer part has 3 or fewer digits, no formatting is needed
    if (integerPart.length <= 3) {
      return numberString;
    }

    // Separate the last three digits
    final lastThree = integerPart.substring(integerPart.length - 3);
    // Get the remaining digits that need two-digit grouping
    final otherDigits = integerPart.substring(0, integerPart.length - 3);

    // Use a RegExp to insert a comma after every two digits from the right.
    // The expression (\d)(?=(\d{2})+(?!\d)) finds a digit that is followed by
    // one or more groups of two digits.
    final formattedOtherDigits = otherDigits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{2})+(?!\d))'),
      (match) => '${match[1]},',
    );

    // Combine the formatted parts and return the final string
    return '$formattedOtherDigits,$lastThree$fractionalPart';
  }

  /// Internal helper to divide and append the correct unit with currency.
  String _formatWithUnit(num value, double divisor, String unit) {
    final divided = value / divisor;
    final hasDecimal = divided % 1 != 0;
    return '₹ ${divided.toStringAsFixed(hasDecimal ? 1 : 0)}$unit';
  }

  String _formatWithUnitNoSymbol(num value, double divisor, String unit) {
    final divided = value / divisor;
    final hasDecimal = divided % 1 != 0;
    return '${divided.toStringAsFixed(hasDecimal ? 1 : 0)}$unit';
  }
}

extension StringFormatExtension on String {
  String get toINRSymbol => this == "INR" ? "₹" : this;

  num get toNum => num.tryParse(this) ?? 0;

  String get toUrl => startsWith('http')
      ? this
      : contains('media')
      ? '${EndPoints.baseUrl}/$this'
      : '${EndPoints.baseUrl}/media/$this';

  String toPascalCase() {
    String pascal = toLowerCase()
        .split(' ')
        .map((word) => word.capitalizeFirst)
        .join()
        .split('_')
        .map((e) => e.capitalizeFirst)
        .join()
        .split('-')
        .map((e) => e.capitalizeFirst)
        .join();
    if (pascal.isEmpty) return pascal;
    return pascal[0].toLowerCase() + pascal.substring(1);
  }

  String get mask {
    if (isEmpty) return this;
    if (length < 3) return this;
    return substring(0, 2) + 'X' * (length - 2);
  }

  Future<String?> get imagePath async {
    if (isEmpty) return null;
    try {
      String imageUrl = toUrl;
      final result = await RoutesClass.context!
          .read<CacheImageCubit>()
          .getOrDownloadImage(imageUrl);
      if (result != null) return result.filePath;
      int deleteDays = 30;
      final Duration userPreferredCacheDuration = Duration(days: deleteDays);
      final cacheManager = ImageCacheManager(
        maxAge: userPreferredCacheDuration,
        maxObjects: 30000,
      );
      final file = await cacheManager.getSingleFile(imageUrl);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  String or(String other) {
    return isNotEmpty ? this : other;
  }

  String? orNull() => isNotEmpty ? this : null;
}

extension HtmlExtension on String {
  bool get isHtmlEmpty {
    if (trim().isEmpty) return true;

    // Parse and extract plain text
    final document = html.parse(this);
    final text = document.body?.text.trim() ?? '';

    return text.isEmpty;
  }

  bool get isNotEmptyHtml => !isHtmlEmpty;
}

extension WidgetConvertorExtension on String {
  Widget toText({TextStyle? style, int? maxLines, Color? color}) =>
      TextWidget(this, style: style, maxLines: maxLines, color: color);
}

///Shares the current path. [thumbnail] should be a valid url not file path.
Future<String> shareCurrentPath(
  BuildContext context, {
  String? thumbnail,
}) async {
  final routerState = context.router.state;
  final path = routerState.uri.path;
  return await '${EndPoints.appBaseUrl}$path'.shareUrl(thumbnail: thumbnail);
}

String get currentPathUrl {
  final routerState = RoutesClass.context!.router.state;
  final path = routerState.uri.path;
  return '${EndPoints.appBaseUrl}$path';
}

void copyCurrentPathUrl() =>
    Clipboard.setData(ClipboardData(text: currentPathUrl));

extension ShareExtension on String {
  ///Should only pass the thumbnail url not file path
  Future<String> shareUrl({String? thumbnail}) async {
    String? thumbnailPath = await thumbnail?.imagePath;
    final result = await SharePlus.instance.share(
      ShareParams(
        text: this,
        previewThumbnail: thumbnailPath == null ? null : XFile(thumbnailPath),
        files: thumbnailPath == null ? null : [XFile(thumbnailPath)],
      ),
    );
    return result.raw.getAppNameFromRaw;
  }

  String get getAppNameFromRaw {
    if (isEmpty) return '';
    // Only keep the package part before the "/"
    final package = split("/").first;

    const packageMap = {
      // Social Media
      "com.whatsapp": "WhatsApp",
      "com.whatsapp.w4b": "WhatsApp Business",
      "com.facebook.katana": "Facebook",
      "com.facebook.orca": "Messenger",
      "com.instagram.android": "Instagram",
      "com.twitter.android": "Twitter (X)",
      "com.snapchat.android": "Snapchat",
      "com.linkedin.android": "LinkedIn",
      "com.pinterest": "Pinterest",
      "com.reddit.frontpage": "Reddit",
      "com.zhiliaoapp.musically": "TikTok",
      "com.discord": "Discord",
      "com.tumblr": "Tumblr",
      "com.telegram.messenger": "Telegram",
      "org.telegram.messenger": "Telegram",
      "com.viber.voip": "Viber",
      "jp.naver.line.android": "LINE",
      "com.skype.raider": "Skype",

      // Google Apps
      "com.google.android.gm": "Gmail",
      "com.google.android.gms": "Google Nearby Share",
      "com.google.android.apps.maps": "Google Maps",
      "com.google.android.youtube": "YouTube",
      "com.google.android.apps.photos": "Google Photos",
      "com.google.android.apps.docs": "Google Docs",
      "com.google.android.apps.docs.editors.sheets": "Google Sheets",
      "com.google.android.apps.docs.editors.slides": "Google Slides",
      "com.google.android.keep": "Google Keep",
      "com.google.android.calendar": "Google Calendar",
      "com.google.android.googlequicksearchbox": "Google",
      "com.google.android.apps.translate": "Google Translate",
      "com.google.android.apps.messaging": "Google Messages",
      "com.google.android.contacts": "Google Contacts",
      "com.google.android.videos": "Google TV",
      "com.google.android.apps.authenticator2": "Google Authenticator",
      "com.android.chrome": "Chrome",
      "com.google.android.inputmethod.latin": "Gboard",

      // Microsoft Apps
      "com.microsoft.office.outlook": "Outlook",
      "com.microsoft.office.word": "Microsoft Word",
      "com.microsoft.office.excel": "Microsoft Excel",
      "com.microsoft.office.powerpoint": "Microsoft PowerPoint",
      "com.microsoft.teams": "Microsoft Teams",
      "com.microsoft.office.onenote": "OneNote",
      "com.microsoft.todos": "Microsoft To Do",

      // Entertainment & Streaming
      "com.netflix.mediaclient": "Netflix",
      "com.amazon.avod.thirdpartyclient": "Prime Video",
      "com.spotify.music": "Spotify",
      "com.google.android.apps.youtube.music": "YouTube Music",
      "com.amazon.mp3": "Amazon Music",
      "com.apple.android.music": "Apple Music",
      "tv.twitch.android.app": "Twitch",
      "com.disney.disneyplus": "Disney+",
      "com.hbo.hbonow": "HBO Max",
      "com.hulu.plus": "Hulu",

      // Shopping & Food
      "com.amazon.mShop.android.shopping": "Amazon",
      "com.ebay.mobile": "eBay",
      "com.contextlogic.wish": "Wish",
      "com.alibaba.aliexpresshd": "AliExpress",
      "in.amazon.mShop.android.shopping": "Amazon India",
      "com.ubercab": "Uber",
      "com.ubercab.eats": "Uber Eats",
      "com.application.zomato": "Zomato",
      "in.swiggy.android": "Swiggy",
      "com.grubhub.android": "Grubhub",
      "com.doordash": "DoorDash",

      // Banking & Finance
      "com.paypal.android.p2pmobile": "PayPal",
      "com.google.android.apps.walletnfcrel": "Google Wallet",
      "com.phonepe.app": "PhonePe",
      "net.one97.paytm": "Paytm",
      "com.coinbase.android": "Coinbase",
      "com.robinhood.android": "Robinhood",

      // Productivity & Utilities
      "com.dropbox.android": "Dropbox",
      "com.evernote": "Evernote",
      "com.notion.id": "Notion",
      "com.todoist": "Todoist",
      "ws.xsoh.etar": "Etar Calendar",
      "com.simplemobiletools.calendar.pro": "Simple Calendar",
      "me.proton.android.drive": "Proton Drive",
      "org.mozilla.firefox": "Firefox",
      "com.brave.browser": "Brave",
      "com.opera.browser": "Opera",
      "com.opera.mini.native": "Opera Mini",
      "org.mozilla.focus": "Firefox Focus",
      "com.duckduckgo.mobile.android": "DuckDuckGo",

      // Photography & Editing
      "com.adobe.lrmobile": "Lightroom",
      "com.vsco.cam": "VSCO",
      "com.picsart.studio": "PicsArt",
      "com.canva.editor": "Canva",
      "com.niksoftware.snapseed": "Snapseed",

      // Gaming
      "com.supercell.clashofclans": "Clash of Clans",
      "com.king.candycrushsaga": "Candy Crush Saga",
      "com.pubg.imobile": "PUBG Mobile",
      "com.mobile.legends": "Mobile Legends",
      "com.roblox.client": "Roblox",
      "com.epicgames.fortnite": "Fortnite",

      // Health & Fitness
      "com.fitbit.FitbitMobile": "Fitbit",
      "com.google.android.apps.fitness": "Google Fit",
      "com.nike.plusgps": "Nike Run Club",
      "com.myfitnesspal.android": "MyFitnessPal",
      "com.strava": "Strava",
      "com.calm.android": "Calm",
      "com.headspace.android": "Headspace",

      // News & Reading
      "flipboard.app": "Flipboard",
      "com.medium.reader": "Medium",
      "com.ideashower.readitlater.pro": "Pocket",
      "com.google.android.apps.magazines": "Google News",

      // Travel
      "com.airbnb.android": "Airbnb",
      "com.booking": "Booking.com",
      "com.tripadvisor.tripadvisor": "TripAdvisor",
      "com.makemytrip": "MakeMyTrip",
      "com.cleartrip.android": "Cleartrip",
    };

    return packageMap[package] ??
        package; // fallback to package name if not in map
  }
}

extension AssetConvertorExtension on String {
  Either<String, IconData> get getAmenityAsset {
    // final normalized = trim().toLowerCase();

    // const assetMap = {
    //   "luxury": SvgConstant.luxury,
    //   "gated community": AssetConstants.gatedCommunity,
    //   "eco-friendly": SvgConstant.ecoFriendly,
    //   "smart home": SvgConstant.smartHome,
    //   "green zone": AssetConstants.greenZone,
    //   "premium location": AssetConstants.premiumLocation,
    //   "high livability": '',
    //   "swimming_pool": SvgConstant.swimmingPool,
    //   "lift": SvgConstant.lift,
    //   "fireplace": SvgConstant.fireplace,
    //   "wifi_connectivity": SvgConstant.wifiConnectivity,
    //   "power_backup": SvgConstant.powerBackup,
    //   "visitor_parking": SvgConstant.visitorParking,
    //   "security_firealarm": SvgConstant.fireAlarm,
    //   "fitness_centre": SvgConstant.fitnessCentre,
    //   "childrens_park": AssetConstants.childrensPark,
    //   "club_house": AssetConstants.clubHouse,
    //   "multipurpose_room": AssetConstants.multiPurposeRoom,
    //   "sports_facility": SvgConstant.sportsFacility,
    //   "rain_water_harvesting": AssetConstants.rainWaterHarvesting,
    //   "intercom": SvgConstant.intercom,
    //   "maintenance_staff": AssetConstants.maintenanceStaff,
    //   "water_purifier": AssetConstants.waterPurifier,
    //   "vaastu_compliant": SvgConstant.vastuCompliant,
    //   "natural_light": AssetConstants.naturalLight,
    //   "shopping_centre": SvgConstant.shoppingCentre,
    //   "atm": SvgConstant.atm,
    //   "waste_disposal": SvgConstant.wasteDisposal,
    //   "piped_gas": AssetConstants.pipedGas,
    //   "modular_kitchen": AssetConstants.modularKitchen,
    //   "balcony": AssetConstants.balcony,
    //   "gated_community": AssetConstants.gatedCommunity,
    //   "cctv_surveillance": SvgConstant.cctvSurveillance,
    //   "security_guards": SvgConstant.securityGuard,
    //   "water_supply": AssetConstants.waterSupply,
    //   "solar_panels": SvgConstant.solarPanel,
    //   "pet_friendly": SvgConstant.petFriendly,
    //   "investment": SvgConstant.investment,
    //   "connectivity": SvgConstant.connectivity,
    //   "family": SvgConstant.family,
    //   "modern amenities": AssetConstants.amenities,
    //   "private garden": AssetConstants.gardening,
    //   "ready-to-move": AssetConstants.readyToMove,
    //   "near metro": SvgConstant.nearMetro,
    //   "": '',
    // };

    // const iconMap = {
    //   "low density": Flaticon.rrGroupCommunitySocialMedia,
    //   "premium fittings": Flaticon.rrCrown,
    //   "villa": Flaticon.rrPeopleRoof,
    //   "prime location": Flaticon.rrLandLocation,
    //   "limited residences": Flaticon.rrWarehouseAlt,
    //   "not eco-friendly": Flaticon.rrLeaf,
    // };
    // String? asset = assetMap[normalized];
    // if (asset != null) {
    //   return Left(asset);
    // }

    // IconData? icon = iconMap[normalized];
    // if (icon != null) {
    //   return Right(icon);
    // }

    return const Left('not-found');
  }

  Widget switchAsset({double? size, Color? color}) {
    if (isEmpty) {
      return const SizedBox.shrink();
    }
    if (this == 'not-found') {
      return Icon(Icons.error, size: size, color: color);
    }
    if (split('.').last == 'png') {
      return Image.asset(this, height: size, width: size, color: color);
    }
    if (split('.').last == 'svg') {
      return SvgImage(this, size: size, color: color);
    }
    return const SizedBox.shrink();
  }

  Widget toAsset({double? size, Color? color}) {
    Either<String, IconData> assetData = getAmenityAsset;
    String asset = '';
    IconData icon = Icons.error;
    assetData.fold((l) => asset = l, (r) => icon = r);
    if (icon != Icons.error) {
      return Icon(icon, size: size, color: color);
    }
    if (asset.isEmpty) {
      return const SizedBox.shrink();
    }
    if (asset == 'not-found') {
      return Icon(Icons.error, size: size, color: color);
    }
    if (asset.split('.').last == 'png') {
      return Image.asset(asset, height: size, width: size, color: color);
    }
    return SvgImage(asset, size: size, color: color);
  }
}

extension IterateExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    List<T> list = where(test).toList();
    return list.isEmpty ? null : list.first;
  }

  T? lastWhereOrNull(bool Function(T element) test) {
    List<T> list = where(test).toList();
    return list.isEmpty ? null : list.last;
  }

  List<T>? orNull() => isEmpty ? null : toList();

  List<T> or(List<T> other) => isEmpty ? other : toList();
}

extension AddOrRemoveListExtension<T> on List<T> {
  void addOrRemove(T item) => contains(item) ? remove(item) : add(item);
}
extension AddOrRemoveSetExtension<T> on Set<T> {
  void addOrRemove(T item) => contains(item) ? remove(item) : add(item);
}

extension MakeTappableExtension on Widget {
  Widget onTap(VoidCallback onTap) {
    return InkWell(onTap: onTap, child: this);
  }
}

Map<String, dynamic> jsonListToMap(dynamic dataList) {
  if (dataList == null) return {};
  if (dataList is Map) {
    return dataList.map(
      (key, value) => MapEntry(key is String ? key : key.toString(), value),
    );
  }
  if (dataList is String) {
    return {"key": dataList};
  }
  return {};
}

class SmartIconConvertor {
  // Map of keywords to icons
  static final Map<String, IconData> _keywordIconMap = {
    // Speed & Performance
    "fast": Icons.flash_on,
    "quick": Icons.flash_on,
    "express": Icons.flash_on,
    "instant": Icons.bolt,
    "rapid": Icons.speed,
    "turbo": Icons.speed,
    "boost": Icons.trending_up,

    // Quality & Excellence
    "top": Icons.star,
    "best": Icons.star,
    "premium": Icons.workspace_premium,
    "quality": Icons.verified,
    "excellent": Icons.star_rate,
    "superior": Icons.verified_user,
    "elite": Icons.military_tech,
    "pro": Icons.workspace_premium,

    // Popularity & Trends
    "popular": Icons.thumb_up,
    "trend": Icons.whatshot,
    "trending": Icons.trending_up,
    "hot": Icons.whatshot,
    "viral": Icons.whatshot,
    "favorite": Icons.favorite,
    "liked": Icons.thumb_up,

    // New & Fresh
    "new": Icons.fiber_new,
    "latest": Icons.fiber_new,
    "fresh": Icons.new_releases,
    "recent": Icons.schedule,
    "updated": Icons.update,
    "just": Icons.fiber_new,

    // Security & Trust
    "verified": Icons.verified,
    "secure": Icons.lock,
    "safe": Icons.shield,
    "protected": Icons.security,
    "trusted": Icons.verified_user,
    "guaranteed": Flaticon.rrShieldCheck,
    "certified": Icons.verified,
    "certify": Icons.verified,
    "authentic": Icons.verified_user,
    "official": Icons.admin_panel_settings,
    "privacy": Icons.privacy_tip,

    // Pricing & Offers
    "free": Icons.card_giftcard,
    "discount": Icons.local_offer,
    "sale": Icons.local_offer,
    "deal": Icons.local_offer,
    "offer": Icons.local_offer,
    "promo": Icons.campaign,
    "coupon": Icons.confirmation_number,
    "save": Icons.savings,
    "money": Icons.attach_money,
    "cashback": Icons.attach_money,
    "price": Icons.attach_money,
    "cheap": Icons.money_off,
    "affordable": Icons.attach_money,
    "budget": Icons.account_balance_wallet,
    "value": Icons.monetization_on,
    "clearance": Icons.sell,

    // Gifts & Rewards
    "gift": Icons.card_giftcard,
    "reward": Icons.redeem,
    "bonus": Icons.add_circle,
    "prize": Icons.emoji_events,
    "win": Icons.emoji_events,
    "loyalty": Icons.loyalty,
    "points": Icons.stars,

    // Delivery & Shipping
    "delivery": Icons.local_shipping,
    "shipping": Icons.local_shipping,
    "ship": Icons.local_shipping,
    "package": Icons.inventory_2,
    "track": Icons.location_on,
    "tracking": Icons.my_location,
    "warehouse": Icons.warehouse,
    "logistics": Icons.local_shipping,

    // Customer Service
    "support": Icons.support_agent,
    "help": Icons.support_agent,
    "service": Icons.miscellaneous_services,
    "customer": Icons.person,
    "care": Icons.favorite_border,
    "assist": Icons.help,
    "contact": Icons.contact_support,
    "chat": Icons.chat,
    "call": Icons.phone,
    "email": Icons.email,

    // Time & Urgency
    "limited": Icons.timer,
    "urgent": Icons.warning,
    "hurry": Icons.av_timer,
    "now": Icons.access_time,
    "today": Icons.today,
    "soon": Icons.schedule,
    "ending": Icons.hourglass_bottom,
    "expires": Icons.event_busy,
    "countdown": Icons.timer,

    // Exclusivity & Special
    "exclusive": Icons.star_border_purple500,
    "special": Icons.auto_awesome,
    "unique": Icons.diamond,
    "rare": Icons.diamond,
    "vip": Icons.stars,
    "member": Icons.card_membership,
    "members": Icons.card_membership,

    // Innovation & Creativity
    "innovative": Icons.lightbulb,
    "innovation": Icons.lightbulb,
    "creative": Icons.lightbulb_outline,
    "smart": Icons.psychology,
    "intelligent": Icons.psychology,
    "tech": Icons.computer,
    "technology": Icons.devices,
    "digital": Icons.smartphone,
    "ai": Icons.smart_toy,
    "automation": Icons.settings_suggest,

    // Professional & Business
    "professional": Icons.work,
    "business": Icons.business,
    "corporate": Icons.business_center,
    "expert": Icons.school,
    "specialist": Icons.medical_services,

    // Environment & Sustainability
    "eco": Icons.eco,
    "organic": Icons.eco,
    "green": Icons.nature,
    "natural": Icons.grass,
    "sustainable": Icons.recycling,
    "recycle": Icons.recycling,
    "plant": Icons.local_florist,
    "earth": Icons.public,
    "nature": Icons.park,

    // Design & Style
    "modern": Icons.design_services,
    "minimalist": Icons.crop_square,
    "elegant": Icons.star_outline,
    "stylish": Icons.style,
    "beautiful": Icons.auto_awesome,
    "aesthetic": Icons.palette,
    "design": Icons.brush,
    "custom": Icons.tune,
    "personalized": Icons.person_pin,

    // Functionality & Features
    "functional": Icons.build,
    "feature": Icons.featured_play_list,
    "tool": Icons.build_circle,
    "utility": Icons.construction,
    "powerful": Icons.flash_on,
    "enhanced": Icons.upgrade,
    "advanced": Icons.science,
    "automatic": Icons.autorenew,

    // Recognition & Awards
    "award": Icons.emoji_events,
    "award-winning": Icons.emoji_events,
    "winner": Icons.emoji_events,
    "champion": Icons.military_tech,
    "medal": Icons.workspace_premium,
    "trophy": Icons.emoji_events,
    "achievement": Icons.stars,

    // Luxury & High-End
    "luxury": Icons.star,
    "luxurious": Icons.diamond,
    "deluxe": Icons.king_bed,
    "prestige": Icons.workspace_premium,
    "gold": Icons.stars,
    "platinum": Icons.diamond,

    // Health & Wellness
    "health": Icons.health_and_safety,
    "healthy": Icons.favorite,
    "wellness": Icons.spa,
    "fitness": Icons.fitness_center,
    "medical": Icons.medical_services,
    "doctor": Icons.local_hospital,
    "pharmacy": Icons.local_pharmacy,

    // Food & Dining
    "food": Icons.restaurant,
    "restaurant": Icons.restaurant_menu,
    "cafe": Icons.local_cafe,
    "coffee": Icons.coffee,
    "dining": Icons.dinner_dining,
    "meal": Icons.fastfood,
    "kitchen": Icons.kitchen,
    "chef": Icons.restaurant,
    "recipe": Icons.menu_book,

    // Entertainment & Media
    "entertainment": Icons.movie,
    "movie": Icons.local_movies,
    "music": Icons.music_note,
    "game": Icons.sports_esports,
    "gaming": Icons.sports_esports,
    "video": Icons.video_library,
    "play": Icons.play_circle,
    "watch": Icons.tv,
    "stream": Icons.live_tv,

    // Education & Learning
    "education": Icons.school,
    "learning": Icons.local_library,
    "course": Icons.class_,
    "training": Icons.model_training,
    "tutorial": Icons.cast_for_education,
    "book": Icons.menu_book,
    "study": Icons.book,
    "teach": Icons.school,

    // Travel & Location
    "travel": Icons.flight,
    "trip": Icons.luggage,
    "vacation": Icons.beach_access,
    "hotel": Icons.hotel,
    "flight": Icons.flight_takeoff,
    "map": Icons.map,
    "location": Icons.location_on,
    "destination": Icons.explore,
    "tour": Icons.tour,

    // Social & Community
    "social": Icons.people,
    "community": Icons.groups,
    "share": Icons.share,
    "friend": Icons.people_alt,
    "group": Icons.group,
    "team": Icons.groups,
    "network": Icons.hub,

    // Events & Calendar
    "event": Icons.event,
    "calendar": Icons.calendar_today,
    "schedule": Icons.schedule,
    "appointment": Icons.event_available,
    "meeting": Icons.event_note,
    "reminder": Icons.notifications,

    // Storage & Data
    "storage": Icons.storage,
    "cloud": Icons.cloud,
    "backup": Icons.backup,
    "download": Icons.download,
    "upload": Icons.upload,
    "data": Icons.data_usage,
    "file": Icons.insert_drive_file,
    "folder": Icons.folder,

    // Communication
    "notification": Icons.notifications,
    "message": Icons.message,
    "announcement": Icons.campaign,
    "news": Icons.newspaper,
    "info": Icons.info,
    "information": Icons.info_outline,

    // Settings & Control
    "settings": Icons.settings,
    "control": Icons.settings_remote,
    "manage": Icons.tune,
    "config": Icons.settings_applications,
    "option": Icons.more_horiz,

    // Success & Positive
    "success": Icons.check_circle,
    "complete": Icons.check_circle_outline,
    "done": Icons.done,
    "approved": Icons.check,
    "correct": Icons.done_all,
    "valid": Icons.check_circle,

    // Warning & Alert
    "warning": Icons.warning,
    "alert": Icons.notification_important,
    "error": Icons.error,
    "important": Icons.priority_high,
    "critical": Icons.report_problem,

    // Miscellaneous
    "like": Icons.thumb_up,
    "love": Icons.favorite,
    "bookmark": Icons.bookmark,
    "wishlist": Icons.favorite_border,
    "collection": Icons.collections,
    "gallery": Icons.photo_library,
    "camera": Icons.camera_alt,
    "photo": Icons.photo,
    "image": Icons.image,
    "search": Icons.search,
    "filter": Icons.filter_list,
    "sort": Icons.sort,
    "view": Icons.visibility,
    "home": Icons.home,
    "dashboard": Icons.dashboard,
    "menu": Icons.menu,
  };

  /// Converts a badge text into an appropriate icon
  static IconData fromBadge(String badge) {
    final lowerBadge = badge.toLowerCase();

    // Check for the first matching keyword
    for (var entry in _keywordIconMap.entries) {
      if (lowerBadge.contains(entry.key)) {
        return entry.value;
      }
    }

    // Default fallback icon if no keyword matched
    return Icons.label;
  }

  /// Optional: Get all available keywords
  static List<String> getAvailableKeywords() {
    return _keywordIconMap.keys.toList();
  }

  /// Optional: Check if a keyword is supported
  static bool hasKeyword(String keyword) {
    return _keywordIconMap.containsKey(keyword.toLowerCase());
  }
}

String convertValue(dynamic value) {
  if (value is num) return value.toString();
  if (value is String) return value;
  if (value is List) return value.join(",");
  if (value is bool) return value.toString();
  if (value is Map) {
    return value.entries
        .map((entry) {
          return "${entry.key}=${convertValue(entry.value)}";
        })
        .join("&");
  }
  return "";
}

extension FilterConvertor on Map<String, dynamic> {
  String get filterQueryParams {
    return entries
        .map((entry) {
          return "${entry.key}=${convertValue(entry.value)}";
        })
        .join("&");
  }
}

extension EmptyCheckerExtension on Object? {
  bool get isEmptyValue {
    final value = this;

    if (value == null) return true;

    if (value is String) return value.trim().isEmpty;
    if (value is Iterable) return value.isEmpty;
    if (value is Map) return value.isEmpty;

    // If you REALLY want to treat 0 as empty
    if (value is num) return value == 0;

    // If false should be considered empty
    if (value is bool) return value == false;

    // DateTime cannot be empty unless you have a rule
    if (value is DateTime) {
      // Example: consider very old placeholder dates as "empty"
      return value.year < 1970;
    }

    return false;
  }

  bool get isNotEmptyValue => !isEmptyValue;
}

class BlocLoadMoreSkipper {
  static bool skipLoadMore({
    required bool hasMore,
    required bool isFailureState,
    required bool isAlreadyLoadingState,
    required VoidCallback onResultEnded,
  }) {
    if ((!hasMore && isFailureState) || isAlreadyLoadingState) {
      return true;
    }
    if (!hasMore) {
      onResultEnded();
      return true;
    }
    if (isFailureState) {
      return true;
    }
    return false;
  }
}

extension ListContainsCheckerExtension<T> on T {
  bool isIn(Iterable<T> items) {
    return items.contains(this);
  }

  bool isNotIn(Iterable<T> items) {
    return !items.contains(this);
  }

  bool isAnyIn(Iterable<T> items) {
    return items.any((item) => item == this);
  }

  bool isEveryIn(Iterable<T> items) {
    return items.every((item) => item == this);
  }
}

extension CurrencyExtension on String {
  String get currencySymbol =>
      _Currency. getCurrencyOrNull(this)?.symbol ?? this;
}

class _Currency {
  final String name;
  final String symbol;
  const _Currency(this.name, this.symbol);

  // static _Currency getCurrency(String name) =>
  //     _kCurrency.firstWhere((c) => c.name.toUpperCase() == name.toUpperCase());

  static _Currency? getCurrencyOrNull(String name) => _kCurrency
      .firstWhereOrNull((c) => c.name.toUpperCase() == name.toUpperCase());
}

const List<_Currency> _kCurrency = [
  _Currency('USD', '\$'),
  _Currency('EUR', '€'),
  _Currency('GBP', '£'),
  _Currency('INR', '₹'),
  _Currency('JPY', '¥'),
  _Currency('AUD', 'A\$'),
  _Currency('CAD', 'C\$'),
  _Currency('CHF', 'Fr'),
  _Currency('CNY', '¥'),
  _Currency('HKD', 'HK\$'),
  _Currency('SGD', 'S\$'),
  _Currency('SEK', 'kr'),
  _Currency('NOK', 'kr'),
  _Currency('DKK', 'kr'),
  _Currency('NZD', 'NZ\$'),
  _Currency('MXN', '\$'),
  _Currency('BRL', 'R\$'),
  _Currency('ZAR', 'R'),
  _Currency('RUB', '₽'),
  _Currency('TRY', '₺'),
  _Currency('KRW', '₩'),
  _Currency('IDR', 'Rp'),
  _Currency('MYR', 'RM'),
  _Currency('THB', '฿'),
  _Currency('PHP', '₱'),
  _Currency('PKR', '₨'),
  _Currency('BDT', '৳'),
  _Currency('VND', '₫'),
  _Currency('EGP', 'E£'),
  _Currency('NGN', '₦'),
  _Currency('KES', 'KSh'),
  _Currency('GHS', 'GH₵'),
  _Currency('AED', 'د.إ'),
  _Currency('SAR', '﷼'),
  _Currency('QAR', 'QR'),
  _Currency('KWD', 'KD'),
  _Currency('BHD', 'BD'),
  _Currency('OMR', 'OMR'),
  _Currency('ILS', '₪'),
  _Currency('CZK', 'Kč'),
  _Currency('PLN', 'zł'),
  _Currency('HUF', 'Ft'),
  _Currency('RON', 'lei'),
  _Currency('HRK', 'kn'),
  _Currency('BGN', 'лв'),
  _Currency('ARS', 'AR\$'),
  _Currency('CLP', 'CL\$'),
  _Currency('COP', 'CO\$'),
  _Currency('PEN', 'S/'),
  _Currency('UYU', '\$U'),
];

//OR EXTENSIONS:

extension BoolOrExtension on bool {
  bool or(bool other) => this || other;
  bool orTrue() => this || true;
  bool orFalse() => this || false;
  bool and(bool other) => this && other;
  bool andTrue() => this && true;
  bool andFalse() => this && false;
  bool get not => !this;
}

extension MapOrExtension<K, V> on Map<K, V> {
  Map<K, V> or(Map<K, V> other) => isNotEmpty ? this : other;
  Map<K, V> orEmpty() => isNotEmpty ? this : {};
  Map<K, V>? orNull() => isNotEmpty ? this : null;
}

extension NumOrExtension on num {
  num or(num other) => this != 0 ? this : other;
  num? orNull() => this != 0 ? this : null;
}

extension IterableIndexed<T> on Iterable<T> {
  Iterable<R> mapIndexed<R>(R Function(int index, T item) f) sync* {
    var i = 0;
    for (final item in this) {
      yield f(i++, item);
    }
  }
}

extension RemoveExtension<K, V> on Map<K, V> {
  void removeEmpty(String key) =>
      removeWhere((key, value) => _removeEmpty(value));

  bool _removeEmpty(dynamic value) {
    if (value == null) return true;
    if (value is num) return value == 0;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is bool) return !value;
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }

  Map<K, V> clean() => this..removeWhere((key, value) => _removeEmpty(value));
}
