class WeatherEmojiResolver {
  const WeatherEmojiResolver();

  /// Returns an emoji based on current weather values.
  /// Returns null if no match is found.
  static String? resolve({
    required num temp,
    required num feelsLike,
    required num humidity,
    required num cloudPct,
    required num windSpeed,
    num? rainMm,
    num? snowMm,
    required num visibility,
    required num sunrise,
    required num sunset,
    required num observedAt,
    required num timezoneOffset,
  }) {
    // --- Snow ---
    if (snowMm != null && snowMm > 0) {
      if (temp <= -10) return '🌨️'; // heavy snow / blizzard
      return '❄️';
    }

    // --- Rain ---
    if (rainMm != null && rainMm > 0) {
      if (thunderstormLikely(rainMm: rainMm, windSpeed: windSpeed)) return '⛈️';
      if (rainMm >= 7.5) return '🌧️'; // heavy rain
      if (rainMm >= 2.5) return '🌦️'; // moderate rain
      return '🌦️'; // light rain
    }

    // --- Visibility: fog / mist ---
    if (visibility < 1000) return '🌫️'; // dense fog
    if (visibility < 5000 && humidity >= 85) return '🌁'; // misty / hazy

    // --- Derived: local time of day ---
    final localNow = observedAt + timezoneOffset;
    final localSunrise = sunrise + timezoneOffset;
    final localSunset = sunset + timezoneOffset;
    final isDaytime = localNow >= localSunrise && localNow <= localSunset;

    // Golden-hour window (±30 min around sunrise/sunset)
    final nearSunrise = (localNow - localSunrise).abs() <= 1800;
    final nearSunset = (localSunset - localNow).abs() <= 1800;

    // --- Wind ---
    final bool strongWind = windSpeed >= 10.8; // Beaufort 6+
    final bool moderateWind = windSpeed >= 5.5; // Beaufort 3+

    // --- Cloud cover categories ---
    final bool clearSky = cloudPct <= 10;
    final bool mostlyClear = cloudPct <= 25;
    final bool partlyCloudy = cloudPct <= 60;
    final bool mostlyCloudy = cloudPct <= 85;

    // --- Temperature extremes (felt temperature) ---
    // if (feelsLike >= 40) return '🥵'; // dangerously hot
    // if (feelsLike <= -10) return '🥶'; // dangerously cold

    // --- Strong wind with clouds ---
    if (strongWind && !clearSky) return '🌬️';

    // --- Clear / mostly-clear sky ---
    if (clearSky || mostlyClear) {
      if (nearSunrise) return '🌅';
      if (nearSunset) return '🌇';
      if (isDaytime) {
        if (temp >= 35) return '☀️';
        if (moderateWind) return '🌤️';
        return '☀️';
      } else {
        // Night: try to differentiate by humidity (hazy vs crisp)
        return humidity < 60 ? '🌙' : '🌃';
      }
    }

    // --- Partly cloudy ---
    if (partlyCloudy) {
      return isDaytime ? '⛅' : '🌙';
    }

    // --- Mostly cloudy ---
    if (mostlyCloudy) {
      return isDaytime ? '🌥️' : '☁️';
    }

    // --- Overcast ---
    if (cloudPct > 85) {
      if (strongWind) return '🌬️';
      return '☁️';
    }

    return null;
  }

  static bool thunderstormLikely({
    required num rainMm,
    required num windSpeed,
  }) {
    // Proxy: very heavy rain + strong wind suggests a convective storm
    return rainMm >= 10 && windSpeed >= 8;
  }

  /// Returns an emoji based on forecast day weather values.
  /// Returns null if no match is found.
  static String? resolveForecast({
    required num tempMin,
    required num tempMax,
    required num humidity,
    required num rainMm,
    required num snowMm,
  }) {
    final num tempMid = (tempMin + tempMax) / 2;

    // --- Snow ---
    if (snowMm > 0) {
      if (snowMm >= 10) return '🌨️'; // heavy snow
      if (rainMm > 0) return '🌨️'; // sleet / mixed
      return '❄️';
    }

    // --- Rain ---
    if (rainMm > 0) {
      if (rainMm >= 20 && humidity >= 80) return '⛈️'; // likely convective
      if (rainMm >= 10) return '🌧️'; // heavy rain
      if (rainMm >= 3) return '🌦️'; // moderate rain
      return '🌦️'; // light rain
    }

    // --- Fog / Mist (no precip but very humid) ---
    if (humidity >= 95) return '🌫️';
    if (humidity >= 88 && tempMid < 20) return '🌁';

    // --- Cloud cover proxied from humidity + temp spread ---
    // A wide temp spread (day heated up a lot) → clearer sky
    // A narrow spread + moderate humidity → more overcast
    final num tempSpread = tempMax - tempMin;

    // --- Temperature extremes ---
    if (tempMax >= 42) return '🥵';
    if (tempMin <= -15) return '🥶';

    // Likely clear/sunny day
    if (tempSpread >= 10 && humidity < 50) {
      if (tempMax >= 35) return '☀️';
      return '🌤️';
    }

    // Partly cloudy
    if (tempSpread >= 7 && humidity < 65) {
      return '⛅';
    }

    // Mostly cloudy
    if (tempSpread >= 4 && humidity < 80) {
      return '🌥️';
    }

    // Overcast
    if (humidity >= 70 || tempSpread < 4) {
      return '☁️';
    }

    return null;
  }
}
