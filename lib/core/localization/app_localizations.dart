import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('am'));
  }

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('am', ''),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Shuk',
      'tagline': 'Local Handyman & Services Marketplace',
      'discover': 'Discover Services',
      'nearby': 'Nearby Providers',
      'view_all': 'View All',
      'categories': 'Categories',
      'plumbing': 'Plumbing',
      'electrical': 'Electrical',
      'cleaning': 'Cleaning',
      'tutoring': 'Tutoring',
      'carpentry': 'Carpentry',
      'book_now': 'Book Now',
      'book_service': 'Book Service',
      'chat': 'Chat',
      'profile': 'Profile',
      'history': 'History',
      'home': 'Home',
      'search': 'Search',
      'verified': 'Verified',
      'pending': 'Pending',
      'online': 'Online',
      'offline': 'Offline',
      'provider_profile': 'Provider Profile',
      'jobs_done': 'Jobs Done',
      'experience': 'Experience',
      'about': 'About Provider',
      'specialties': 'Specialties',
      'reviews': 'Recent Reviews',
      'price_estimate': 'Price Estimate',
      'voice_request': 'Voice Service Request',
      'record_instruction': 'Hold button to record your plumbing or electrical issue',
      'recording': 'Recording...',
      'tap_preview': 'Tap to preview voice request',
      'submit_request': 'Submit Request',
      'payment': 'Secure Payment',
      'escrow_note': 'Escrow protected: Funds held safely until job completion',
      'telebirr_pay': 'Pay via Telebirr',
      'chapa_pay': 'Pay via Chapa',
      'pay_now': 'Pay Securely',
      'language': 'Language',
      'amharic': 'Amharic (አማርኛ)',
      'english': 'English',
      'active_bookings': 'Active Bookings',
      'incoming_requests': 'Incoming Requests',
      'earnings': 'Earnings',
      'accept': 'Accept',
      'decline': 'Decline',
      'in_service': 'In Service',
      'completed': 'Completed',
      'dispute': 'Open Dispute',
      'fayda_verify': 'Fayda e-KYC Verification',
    },
    'am': {
      'app_name': 'ሹክ',
      'tagline': 'የአገር ውስጥ አገልግሎቶች እና የዕጅ ሥራ መድረክ',
      'discover': 'አገልግሎቶችን ያግኙ',
      'nearby': 'በአቅራቢያ ያሉ ባለሙያዎች',
      'view_all': 'ሁሉንም ይመልከቱ',
      'categories': 'የአገልግሎት ዘርፎች',
      'plumbing': 'የቧንቧ ሥራ',
      'electrical': 'የኤሌክትሪክ ሥራ',
      'cleaning': 'የቤት ማጽዳት',
      'tutoring': 'የማስጠናት ሥራ',
      'carpentry': 'የእንጨት ሥራ',
      'book_now': 'አሁን እዘዝ',
      'book_service': 'አገልግሎት አስይዝ',
      'chat': 'መልዕክት',
      'profile': 'ፕሮፋይል',
      'history': 'የቀድሞ ሥራዎች',
      'home': 'ዋና ገጽ',
      'search': 'ፈልግ',
      'verified': 'የተረጋገጠ',
      'pending': 'በመጠባበቅ ላይ',
      'online': 'በመስመር ላይ',
      'offline': 'ከመስመር ውጭ',
      'provider_profile': 'የባለሙያ ፕሮፋይል',
      'jobs_done': 'የተጠናቀቁ ሥራዎች',
      'experience': 'የሥራ ልምድ',
      'about': 'ስለ ባለሙያው',
      'specialties': 'የተካነባቸው ዘርፎች',
      'reviews': 'የደንበኞች አስተያየቶች',
      'price_estimate': 'የዋጋ ግምት',
      'voice_request': 'የድምፅ አገልግሎት ጥያቄ',
      'record_instruction': 'የቧንቧ ወይም የኤሌክትሪክ ችግርዎን በድምፅ ለመቅዳት ቁልፉን ተጭነው ይያዙ',
      'recording': 'በመቅዳት ላይ...',
      'tap_preview': 'የተቀረጸውን ድምፅ ለመስማት ይጫኑ',
      'submit_request': 'ጥያቄውን ላክ',
      'payment': 'አስተማማኝ ክፍያ',
      'escrow_note': 'በዋስትና ሂሳብ የተጠበቀ፡ ሥራው እስኪጠናቀቅ ድረስ ክፍያዎ በአስተማማኝ ሁኔታ ይቀመጣል',
      'telebirr_pay': 'በቴሌብር ይክፈሉ',
      'chapa_pay': 'በጫፓ ይክፈሉ',
      'pay_now': 'በአስተማማኝ ሁኔታ ይክፈሉ',
      'language': 'ቋንቋ',
      'amharic': 'አማርኛ',
      'english': 'እንግሊዝኛ (English)',
      'active_bookings': 'የተያዙ ሥራዎች',
      'incoming_requests': 'የመጡ የሥራ ጥያቄዎች',
      'earnings': 'ገቢዎች',
      'accept': 'ተቀበል',
      'decline': 'አትቀበል',
      'in_service': 'በሥራ ላይ',
      'completed': 'ተጠናቋል',
      'dispute': 'አቤቱታ አቅርብ',
      'fayda_verify': 'የፋይዳ ማንነት ማረጋገጫ',
    }
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'am'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
