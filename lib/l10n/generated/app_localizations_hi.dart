// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'नियोपार्लर पार्टनर';

  @override
  String get loginTitle => 'लॉगिन';

  @override
  String get loginSubtitle =>
      'बुकिंग्स और अपॉइंटमेंट्स मैनेज करने के लिए लॉगिन करें';

  @override
  String get continueWithGoogle => 'गूगल के साथ जारी रखें';

  @override
  String get continueWithFacebook => 'फेसबुक के साथ जारी रखें';

  @override
  String get or => 'या';

  @override
  String get emailAddress => 'ईमेल एड्रेस';

  @override
  String get continueBtn => 'कंटिन्यू';

  @override
  String get salonOwnerTab => 'सैलून ओनर';

  @override
  String get staffTab => 'स्टाफ़';

  @override
  String get mobileOrEmail => 'मोबाइल नंबर या ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get iAgreeToThe => 'मैं सहमत हूँ ';

  @override
  String get privacyPolicy => 'प्राइवेसी पॉलिसी';

  @override
  String get termsOfUse => 'टर्म्स ऑफ यूज़';

  @override
  String get comma => ', ';

  @override
  String get and => ' और ';

  @override
  String get termsOfService => 'टर्म्स ऑफ सर्विस';

  @override
  String get iAgreeMarketing =>
      'मैं ऑफर्स और न्यूज़ के मार्केटिंग नोटिफिकेशन्स प्राप्त करने के लिए सहमत हूँ';

  @override
  String get forgotPassword => 'फॉरगॉट पासवर्ड?';

  @override
  String get dontHaveAccount => 'अकाउंट नहीं है? ';

  @override
  String get register => 'रजिस्टर';

  @override
  String get pleaseAcceptAgreements =>
      'कृपया जारी रखने के लिए सभी एग्रीमेंट्स अप्रूव करें।';

  @override
  String get pleaseEnterIdAndPassword =>
      'कृपया आईडी और पासवर्ड दोनों दर्ज करें';

  @override
  String get validMobileError => 'कृपया मान्य 10-अंकीय मोबाइल नंबर दर्ज करें';

  @override
  String get otpSentSuccess => 'ओटीपी सफलतापूर्वक भेजा गया';

  @override
  String get failedToSendOtp => 'ओटीपी भेजने में विफल';

  @override
  String get enterOtpError => 'कृपया ओटीपी दर्ज करें';

  @override
  String get passwordLengthError => 'पासवर्ड कम से कम 6 अक्षरों का होना चाहिए';

  @override
  String get passwordsDoNotMatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get passwordResetSuccess =>
      'पासवर्ड सफलतापूर्वक रीसेट हो गया। कृपया लॉगिन करें।';

  @override
  String get failedToResetPassword => 'पासवर्ड रीसेट करने में विफल';

  @override
  String get resetPasswordTitle => 'रीसेट पासवर्ड';

  @override
  String get verificationTitle => 'वेरिफिकेशन';

  @override
  String get forgotPasswordTitle => 'फॉरगॉट पासवर्ड?';

  @override
  String enterOtpAndNewPassword(String mobile) {
    return 'अपने नए पासवर्ड के साथ $mobile पर भेजा गया ओटीपी दर्ज करें।';
  }

  @override
  String get enterMobileForOtp =>
      'पासवर्ड रीसेट करने के लिए ओटीपी प्राप्त करने हेतु अपना रजिस्टर्ड मोबाइल नंबर दर्ज करें।';

  @override
  String get mobileNumber => 'मोबाइल नंबर';

  @override
  String get enterOtp => 'ओटीपी दर्ज करें';

  @override
  String get newPassword => 'नया पासवर्ड';

  @override
  String get confirmNewPassword => 'नए पासवर्ड की पुष्टि करें';

  @override
  String get resetPasswordBtn => 'रीसेट पासवर्ड';

  @override
  String get sendOtpBtn => 'सेंड ओटीपी';

  @override
  String get pleaseEnterAccountAndPassword =>
      'कृपया अकाउंट और पासवर्ड दोनों दर्ज करें';

  @override
  String accessDeniedRole(String role) {
    return 'एक्सेस डिनाइड: वर्तमान रोल $role है';
  }

  @override
  String get loginFailed => 'लॉगिन फेल हो गया';

  @override
  String get emailOrMobile => 'ईमेल या मोबाइल नंबर';

  @override
  String get rememberMeNextTime => 'अगली बार मुझे याद रखें';

  @override
  String get loggingIn => 'लॉगिन हो रहा है...';

  @override
  String get ownerFullName => 'ओनर का पूरा नाम';

  @override
  String get securityTab => 'सिक्योरिटी';

  @override
  String get createPassword => 'पासवर्ड बनाएं';

  @override
  String get confirmPassword => 'पासवर्ड कंफर्म करें';

  @override
  String get fillMandatoryFields => 'कृपया सभी अनिवार्य फ़ील्ड भरें';

  @override
  String get mobileNumber10Digits => 'मोबाइल नंबर 10 अंकों का होना चाहिए';

  @override
  String get validGmailAddress => 'कृपया मान्य जीमेल एड्रेस दर्ज करें';

  @override
  String get continueToSalonInfo => 'सैलून इन्फो पर जारी रखें';

  @override
  String get alreadyHaveAccount => 'क्या आपके पास पहले से अकाउंट है? ';

  @override
  String get login => 'लॉगिन';

  @override
  String get salonInformation => 'सैलून इंफॉर्मेशन';

  @override
  String get salonName => 'सैलून का नाम';

  @override
  String get address => 'पता';

  @override
  String get fillSalonInfoError => 'कृपया सैलून का नाम, शहर और क्षेत्र भरें';

  @override
  String get uploadMainSalonImageError =>
      'कृपया सैलून की मुख्य तस्वीर अपलोड करें';

  @override
  String get uploadGalleryImagesError =>
      'कृपया कम से कम 3 गैलरी तस्वीरें अपलोड करें';

  @override
  String get continueToKycBtn => 'KYC पर जारी रखें';

  @override
  String get uploadBtn => 'अपलोड';

  @override
  String get salonGalleryTitle => 'सैलून गैलरी';

  @override
  String get min3ImagesRequired => 'कम से कम 3 तस्वीरें आवश्यक हैं';

  @override
  String get uploadImageInstructions =>
      'कृपया सैलून की 1 बाहरी तस्वीर (बाहर का दृश्य) और कम से कम 2 आंतरिक तस्वीरें (अंदर का दृश्य) अपलोड करें। प्रति तस्वीर अधिकतम 5MB।';

  @override
  String get exteriorView => '1. बाहरी दृश्य';

  @override
  String get uploadOutsideBtn => 'बाहर अपलोड करें';

  @override
  String get interiorView1 => '2. आंतरिक दृश्य 1';

  @override
  String get uploadInside1Btn => 'अंदर अपलोड करें 1';

  @override
  String get interiorView2 => '3. आंतरिक दृश्य 2';

  @override
  String get uploadInside2Btn => 'अंदर अपलोड करें 2';

  @override
  String get additionalGalleryImages =>
      'अतिरिक्त गैलरी तस्वीरें (वैकल्पिक - अधिकतम 2)';

  @override
  String get backBtn => 'पीछे';

  @override
  String get openingTime => 'खुलने का समय';

  @override
  String get closingTime => 'बंद होने का समय';

  @override
  String get salonMedia => 'सैलून मीडिया';

  @override
  String get notUploaded => 'अपलोड नहीं किया गया';

  @override
  String get removeBtn => 'डिलीट करें';

  @override
  String get uploadFileBtn => 'फ़ाइल अपलोड करें';

  @override
  String get kycVerification => 'KYC वेरिफिकेशन';

  @override
  String get atLeast1DocRequired => 'कम से कम 1 दस्तावेज़ आवश्यक है';

  @override
  String get kycInstructions =>
      'कृपया KYC वेरिफिकेशन के उद्देश्य से कम से कम एक मान्य पहचान या व्यावसायिक दस्तावेज़ अपलोड करें। अधिकतम 5MB। स्वीकार्य प्रारूप: Image/PDF.';

  @override
  String get aadhaarGovtId => 'आधार / सरकारी आईडी';

  @override
  String get panCard => 'पैन कार्ड';

  @override
  String get shopEstLicense => 'शॉप और इस्टैब्लिशमेंट लाइसेंस';

  @override
  String get bankAccountProof => 'बैंक अकाउंट प्रूफ';

  @override
  String get iAgreeWithThe => 'मैं इससे सहमत हूँ ';

  @override
  String get termsAndConditions => 'नियम एवं शर्तें';

  @override
  String get pleaseAcceptTerms => 'कृपया उपयोग की शर्तें अप्रूव करें';

  @override
  String get pleaseUpload1KycDoc =>
      'कृपया कम से कम 1 KYC दस्तावेज़ अपलोड करें।';

  @override
  String get ownerAndSalonRegistration => 'ओनर और सैलून रजिस्ट्रेशन';

  @override
  String get errorPrefix => 'त्रुटि: ';

  @override
  String get couldNotRetrieveFileContent =>
      'फ़ाइल कंटेंट प्राप्त नहीं किया जा सका।';

  @override
  String get errorPickingFile => 'फ़ाइल चुनने में एरर: ';

  @override
  String get errorTakingPhoto => 'तस्वीर लेने में एरर: ';

  @override
  String get selectDocumentSource => 'दस्तावेज़ स्रोत चुनें';

  @override
  String get uploadFromGallery => 'गैलरी / फ़ाइलों से अपलोड करें';

  @override
  String get selectImageOrPdf => 'तस्वीर या PDF दस्तावेज़ चुनें';

  @override
  String get takeAPhoto => 'तस्वीर लें';

  @override
  String get captureUsingCamera => 'डिवाइस कैमरे का उपयोग करके कैप्चर करें';

  @override
  String get cityTitle => 'शहर';

  @override
  String get areaTitle => 'क्षेत्र';

  @override
  String get searchCity => 'शहर खोजें';

  @override
  String get searchArea => 'क्षेत्र खोजें';

  @override
  String get ownerDetails => 'ओनर डिटेल्स';

  @override
  String get stepPersonal => 'पर्सनल';

  @override
  String get stepSalon => 'सैलून';

  @override
  String get stepKyc => 'KYC';

  @override
  String get stepOtp => 'OTP';

  @override
  String get otpResentSuccessfully => 'OTP सफलतापूर्वक फिर से भेजा गया';

  @override
  String get failedToResendOtp => 'OTP फिर से भेजने में विफल: ';

  @override
  String get enterFull6DigitOtp => 'कृपया पूरा 6-अंकीय OTP दर्ज करें';

  @override
  String get registrationSuccessful => 'रजिस्ट्रेशन सफल';

  @override
  String get accountCreatedPleaseLogin =>
      'आपका अकाउंट बन गया है। कृपया लॉगिन करें।';

  @override
  String get loginNow => 'अभी लॉगिन करें';

  @override
  String get verificationFailed => 'वेरिफिकेशन विफल: ';

  @override
  String get verifyOtpTitle => 'OTP वेरीफाई करें';

  @override
  String get sentVerificationCodeTo =>
      'हमने आपके मोबाइल नंबर पर\nएक वेरिफिकेशन कोड भेजा है ';

  @override
  String get verifyBtn => 'वेरीफाई';

  @override
  String get uploadingRegistrationPhotosPleaseWait =>
      'फ़ोटो अपलोड हो रही हैं और आपका सैलून खाता सेट हो रहा है, कृपया प्रतीक्षा करें...';

  @override
  String get didntReceiveOtp => 'OTP नहीं मिला? ';

  @override
  String get resendOtpBtn => 'OTP फिर से भेजें';

  @override
  String get resendIn => 'फिर से भेजें ';

  @override
  String get failedToLoadPlans => 'प्लान लोड करने में विफल: ';

  @override
  String get failedToOpenPricingPortal => 'प्राइसिंग पोर्टल खोलने में विफल: ';

  @override
  String get skipForNow => 'अभी के लिए स्किप करें';

  @override
  String get whatYouCanGet => 'आपको क्या मिल सकता है?';

  @override
  String get staffManagement => 'स्टाफ मैनेजमेंट';

  @override
  String get inventoryManagement => 'इन्वेंटरी मैनेजमेंट';

  @override
  String get subscribeOnWebsite => 'वेबसाइट पर सब्सक्राइब करें';

  @override
  String get appointmentRescheduled =>
      'अपॉइंटमेंट सफलतापूर्वक रिशेड्यूल किया गया';

  @override
  String get cancelAppointmentTitle => 'अपॉइंटमेंट कैंसिल करें';

  @override
  String get enterCancelReason => 'कैंसिलेशन कारण दर्ज करें...';

  @override
  String get appointmentCancelled => 'अपॉइंटमेंट सफलतापूर्वक कैंसल्ड';

  @override
  String get selectStaff => 'स्टाफ चुनें';

  @override
  String get noStaffAvailable => 'कोई स्टाफ उपलब्ध नहीं';

  @override
  String get staffAssignedSuccessfully => 'स्टाफ सफलतापूर्वक असाइन किया गया';

  @override
  String get welcomePrefix => 'स्वागत है ';

  @override
  String get ownerDefaultName => 'ओनर';

  @override
  String get todayOverview => 'आज का ओवरव्यू';

  @override
  String get weeklyOverview => 'साप्ताहिक ओवरव्यू';

  @override
  String get monthlyOverview => 'मासिक ओवरव्यू';

  @override
  String get yearlyOverview => 'वार्षिक ओवरव्यू';

  @override
  String get filterToday => 'आज';

  @override
  String get filterWeekly => 'साप्ताहिक';

  @override
  String get filterMonthly => 'मासिक';

  @override
  String get filterYearly => 'वार्षिक';

  @override
  String get statRevenue => 'रेवेन्यू';

  @override
  String get statBookings => 'बुकिंग';

  @override
  String get statOfferUsage => 'ऑफर उपयोग';

  @override
  String get statCompleted => 'कम्प्लीटेड';

  @override
  String get statCancelled => 'कैंसल्ड';

  @override
  String get statRescheduled => 'रिशेड्यूल किया गया';

  @override
  String get totalFor => 'के लिए टोटल ';

  @override
  String get countFor => 'के लिए गिनती ';

  @override
  String get usedPeriod => 'इस्तेमाल किया गया ';

  @override
  String get totalPeriod => 'टोटल ';

  @override
  String get upcomingAppointments => 'आगामी अपॉइंटमेंट्स';

  @override
  String get noUpcomingAppointments => 'कोई आगामी अपॉइंटमेंट नहीं';

  @override
  String get staffPrefix => 'स्टाफ़: ';

  @override
  String get viewDetails => 'डिटेल्स देखें';

  @override
  String get cancelReasonPrefix => 'कैंसिलेशन कारण: ';

  @override
  String get ownerRescheduleReasonPrefix => 'मालिक के रिशेड्यूल का कारण: ';

  @override
  String get customerRescheduleReasonPrefix => 'कस्टमर के रिशेड्यूल का कारण: ';

  @override
  String get rescheduleBtn => 'रिशेड्यूल करें';

  @override
  String get cancelBtn => 'कैंसिल करें';

  @override
  String get assignStaffBtn => 'स्टाफ असाइन करें';

  @override
  String get splashOneTop => 'आपका';

  @override
  String get splashOneMid => 'एक्सक्लूसिव सैलून';

  @override
  String get splashOneBottom => 'मैनेजमेंट ऐप';

  @override
  String get splashTwoTop => 'आपका';

  @override
  String get splashTwoMid => 'पार्लर';

  @override
  String get splashTwoBottom => 'प्लैटर्स';

  @override
  String get splashThreeTop => 'स्मार्ट सैलून';

  @override
  String get splashThreeMid => 'निर्बाध';

  @override
  String get splashThreeBottom => 'अनुभव';

  @override
  String get skipSplash => 'स्किप';

  @override
  String get changeMobileNumber => 'मोबाइल नंबर बदलें';

  @override
  String get versionFooter =>
      'संस्करण 1.0.0 | Neopaceinfotech LLP द्वारा संचालित';

  @override
  String get maintenanceInProgressToast =>
      'सर्वर रखरखाव अभी भी प्रगति पर है। कृपया कुछ मिनटों में पुनः प्रयास करें।';

  @override
  String get maintenanceNoInternetToast =>
      'सर्वर तक पहुंचने में असमर्थ। कृपया अपना इंटरनेट कनेक्शन जांचें।';

  @override
  String get maintenanceTitle => 'पार्टनर पोर्टल रखरखाव के अधीन';

  @override
  String get maintenanceSafeMessage =>
      'आपके सैलून रिकॉर्ड, अपॉइंटमेंट शेड्यूल और स्टाफ डेटा सुरक्षित हैं।';

  @override
  String get maintenanceEstimatedCompletion => 'अनुमानित पूर्णता: ';

  @override
  String get checkingStatus => 'स्थिति की जांच हो रही है...';

  @override
  String get checkSystemStatus => 'सिस्टम स्थिति जांचें';

  @override
  String get drawerProfile => 'प्रोफ़ाइल';

  @override
  String get drawerAboutUs => 'अबाउट अस';

  @override
  String get drawerSupport => 'सपोर्ट';

  @override
  String get drawerMyBookings => 'मेरी बुकिंग';

  @override
  String get drawerSubscription => 'सब्सक्रिप्शन';

  @override
  String get drawerChangePassword => 'पासवर्ड बदलें';

  @override
  String get drawerLogout => 'लॉग आउट';

  @override
  String get drawerPoweredBy => 'Neopaceinfotech LLP द्वारा संचालित';

  @override
  String get navAnalytics => 'एनालिटिक्स';

  @override
  String get navManage => 'मैनेज करें';

  @override
  String get navNotification => 'नोटिफिकेशन';

  @override
  String get navSetting => 'सेटिंग';

  @override
  String get manageTitle => 'मैनेज करें';

  @override
  String get manageSchedule => 'शेड्यूल';

  @override
  String get manageService => 'सर्विस';

  @override
  String get manageInventory => 'इन्वेंटरी';

  @override
  String get manageStaff => 'स्टाफ';

  @override
  String get manageFeedback => 'फीडबैक';

  @override
  String get manageHomeServices => 'होम सर्विसेस';

  @override
  String get manageSubscription => 'सब्सक्रिप्शन';

  @override
  String get manageAddOffers => 'ऑफ़र जोड़ें';

  @override
  String get manageAddProducts => 'प्रोडक्ट जोड़ें';

  @override
  String get manageAddPackages => 'पैकेज जोड़ें';

  @override
  String get drawerMyReferrals => 'मेरे रेफरल';

  @override
  String get drawerLeaveRequest => 'छुट्टी का आवेदन';

  @override
  String get drawerInventory => 'इन्वेंटरी';

  @override
  String get changePasswordTitle => 'पासवर्ड बदलें';

  @override
  String get pleaseEnterNewPassword => 'कृपया नया पासवर्ड दर्ज करें';

  @override
  String get enterCurrentPassword => 'वर्तमान पासवर्ड दर्ज करें';

  @override
  String get createNewPassword => 'नया पासवर्ड बनाएं';

  @override
  String get submitBtn => 'सबमिट करें';

  @override
  String get editProfileTitle => 'प्रोफ़ाइल एडिट करें';

  @override
  String get editBtn => 'एडिट करें';

  @override
  String get ownerProfileTab => 'मालिक प्रोफ़ाइल';

  @override
  String get staffProfileTab => 'स्टाफ प्रोफ़ाइल';

  @override
  String get salonProfileTab => 'सैलून प्रोफ़ाइल';

  @override
  String get personalDetails => 'व्यक्तिगत डिटेल्स';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get dob => 'जन्म की तारीख';

  @override
  String get contactInfo => 'संपर्क जानकारी';

  @override
  String get salonDetails => 'सैलून डिटेल्स';

  @override
  String get salonCode => 'सैलून कोड';

  @override
  String get salonPhone => 'सैलून फोन';

  @override
  String get businessHours => 'व्यावसायिक घंटे और शुल्क';

  @override
  String get homeServiceCharges => 'होम सर्विस शुल्क (₹)';

  @override
  String get salonQrCodeTitle => 'सैलून क्यूआर कोड';

  @override
  String get downloadQr => 'क्यूआर डाउनलोड करें';

  @override
  String get deleteAccount => 'खाता डिलीट करें';

  @override
  String get saveChanges => 'परिवर्तन सेव करें';

  @override
  String get selectGender => 'लिंग चुनें';

  @override
  String get mySubscriptionsTitle => 'मेरी सब्सक्रिप्शनएं';

  @override
  String get noSubscriptionsFound => 'कोई सब्सक्रिप्शन नहीं मिली।';

  @override
  String get planLabel => 'योजना:';

  @override
  String get startDateLabel => 'प्रारंभ तिथि';

  @override
  String get endDateLabel => 'अंतिम तिथि';

  @override
  String get paymentIdLabel => 'भुगतान आईडी:';

  @override
  String get downloadInvoiceBtn => 'इनवॉइस डाउनलोड करें';

  @override
  String get downloadingInvoiceMsg => 'चालान डाउनलोड हो रहा है...';

  @override
  String get invoiceDownloadedMsg => 'चालान सफलतापूर्वक डाउनलोड हो गया!';

  @override
  String get failedDownloadInvoiceMsg => 'चालान डाउनलोड करने में विफल:';

  @override
  String get aboutUsTitle => 'अबाउट अस';

  @override
  String get aboutNeoParlour => 'नियो पार्लर के बारे में';

  @override
  String get aboutNeoParlourP1 =>
      'नियो पार्लर एक स्मार्ट सैलून प्रबंधन एप्लिकेशन है जिसे सैलून के संचालन के तरीके को सरल बनाने के लिए बनाया गया है। हम समझते हैं कि सैलून के प्रबंधन में एक ही समय में कई कार्यों—अपॉइंटमेंट बुकिंग, इन्वेंट्री ट्रैकिंग और कर्मचारियों का समन्वय—को संभालना शामिल है। ये रोज़मर्रा की चुनौतियाँ भ्रम पैदा कर सकती हैं और आपका ध्यान उस चीज़ से हटा सकती हैं जो वास्तव में मायने रखती है: अपने व्यवसाय को बढ़ाना और अपने कस्टमरों की सर्विस करना।';

  @override
  String get aboutNeoParlourP2 => 'यहीं पर नियो पार्लर काम आता है।';

  @override
  String get aboutNeoParlourP3 =>
      'हमारा मंच हर चीज़ को एक स्थान पर लाता है, जिससे सैलून मालिक अपॉइंटमेंट प्रबंधित करने, इन्वेंट्री की निगरानी करने और कर्मचारियों के कार्यक्रम को आसानी से व्यवस्थित करने में सक्षम होते हैं। मैन्युअल काम को कम करके और त्रुटियों को कम करके, नियो पार्लर आपके दैनिक संचालन में स्पष्टता, संरचना और नियंत्रण लाने में मदद करता है।';

  @override
  String get notificationsTab => 'सूचनाएं';

  @override
  String get birthdaysTab => 'जन्मदिन';

  @override
  String get requestsTab => 'अनुरोध';

  @override
  String get ordersTab => 'आदेश';

  @override
  String get noNotificationsYet => 'अभी तक कोई सूचना नहीं';

  @override
  String get noBirthdaysFound => 'कोई जन्मदिन नहीं मिला!';

  @override
  String get noPendingRequests => 'कोई पेंडिंग अनुरोध नहीं';

  @override
  String get swapRequestsHeader => 'स्वैप अनुरोध';

  @override
  String get leaveRequestsHeader => 'छुट्टी के अनुरोध';

  @override
  String get approveBtn => 'अप्रूव्ड करें';

  @override
  String get rejectBtn => 'रिजेक्ट करें';

  @override
  String get searchByNameOrMobile => 'नाम या मोबाइल से खोजें...';

  @override
  String get filterAll => 'सभी';

  @override
  String get filterOrdered => 'ऑर्डर किया गया';

  @override
  String get filterCompleted => 'कम्प्लीटेड';

  @override
  String get filterCancelled => 'कैंसिल';

  @override
  String get noProductRequestsFound => 'कोई प्रोडक्ट अनुरोध नहीं मिला';

  @override
  String get totalAmountLabel => 'टोटल अमाउंट';

  @override
  String get serviceListTab => 'सर्विस सूची';

  @override
  String get addServiceTab => 'सर्विस जोड़ें';

  @override
  String get servicesTitle => 'सर्विसेस';

  @override
  String get servicesSubtitle =>
      'अपनी सैलून सर्विसओं का प्रबंधन करें और देखें कि कस्टमर उन्हें कैसे देखते हैं।';

  @override
  String get editingServiceTitle => 'सर्विस का संपादन';

  @override
  String get addNewServiceTitle => 'नई सर्विस जोड़ें';

  @override
  String get cancelEditBtn => 'संपादन कैंसिल करें';

  @override
  String get categoryLabel => 'कैटेगरी';

  @override
  String get typeCustomCategory => 'कस्टम कैटेगरी टाइप करें';

  @override
  String get selectPreloadedBtn => 'प्रीलोडेड चुनें';

  @override
  String get selectServiceNameLabel => 'सर्विस का नाम चुनें';

  @override
  String get serviceNameLabel => 'सर्विस का नाम';

  @override
  String get selectCategoryFirst => 'पहले एक कैटेगरी चुनें';

  @override
  String get genderLabel => 'लिंग';

  @override
  String get priceLabel => 'मूल्य';

  @override
  String get durationMinLabel => 'अवधि (मिनट)';

  @override
  String get updateBtn => 'अपडेट करें';

  @override
  String get saveBtn => 'सेव करें';

  @override
  String get serviceListPreviewTitle => 'सर्विस सूची (कस्टमर पूर्वावलोकन)';

  @override
  String get serviceListPreviewSubtitle =>
      'पूर्वावलोकन करें कि कस्टमर आपकी सर्विसेस कैसे देखेंगे।';

  @override
  String get manageServicesTitle => 'सर्विसेस मैनेज करें';

  @override
  String get reorderBtn => 'पुनर्व्यवस्थित करें';

  @override
  String get reorderHint =>
      'प्रदर्शन क्रम बदलने के लिए सर्विसओं को पकड़ें और खींचें।';

  @override
  String get noServicesFound => 'कोई सर्विसेस नहीं मिलीं।';

  @override
  String get addProductTab => 'प्रोडक्ट जोड़ें';

  @override
  String get productListTab => 'प्रोडक्ट सूची';

  @override
  String get productsTitle => 'प्रोडक्ट';

  @override
  String get editingProductTitle => 'प्रोडक्ट एडिट करें';

  @override
  String get addProductsTitle => 'प्रोडक्ट जोड़ें';

  @override
  String get mainProductImage => 'मुख्य प्रोडक्ट छवि';

  @override
  String get additionalImages => 'अतिरिक्त छवियां';

  @override
  String get cameraBtn => 'कैमरा';

  @override
  String get galleryBtn => 'गैलरी';

  @override
  String get productNameLabel => 'प्रोडक्ट का नाम';

  @override
  String get productTypeLabel => 'प्रोडक्ट का प्रकार';

  @override
  String get productDescriptionLabel => 'प्रोडक्ट डिटेल्स';

  @override
  String get stockLabel => 'स्टॉक';

  @override
  String get restockLevelLabel => 'रीस्टॉक स्तर';

  @override
  String get discountPriceLabel => 'डिस्काउंट मूल्य';

  @override
  String get productUpdatedMsg => 'प्रोडक्ट सफलतापूर्वक अपडेट किया गया!';

  @override
  String get productAddedMsg => 'प्रोडक्ट सफलतापूर्वक जोड़ा गया!';

  @override
  String get noProductsFound => 'कोई प्रोडक्ट नहीं मिला।';

  @override
  String get activeBadge => 'सक्रिय';

  @override
  String get inactiveBadge => 'निष्क्रिय';

  @override
  String get addPackageTab => 'पैकेज जोड़ें';

  @override
  String get packageListTab => 'पैकेज सूची';

  @override
  String get packagesTitle => 'पैकेज';

  @override
  String get editingPackageTitle => 'पैकेज एडिट करें';

  @override
  String get addNewPackageTitle => 'नया पैकेज जोड़ें';

  @override
  String get packageNameLabel => 'पैकेज का नाम';

  @override
  String get descriptionLabel => 'डिटेल्स';

  @override
  String get packagePriceLabel => 'पैकेज मूल्य';

  @override
  String get usageLimitPerCustomerLabel => 'प्रति कस्टमर उपयोग लिमिट';

  @override
  String get totalUsageLimitLabel => 'टोटल उपयोग लिमिट';

  @override
  String get selectServicesLabel => 'सर्विसेस चुनें';

  @override
  String get tapToAddServices => 'सर्विसेस जोड़ने के लिए टैप करें';

  @override
  String servicesSelectedCount(int count) {
    return '$count सर्विसेस चुनी गईं';
  }

  @override
  String get savePackageBtn => 'पैकेज सेव करें';

  @override
  String get selectServicesTitle => 'सर्विसेस चुनें';

  @override
  String get noPackagesFound => 'कोई पैकेज नहीं मिला।';

  @override
  String get perCustLabel => 'प्रति कस्टमर: ';

  @override
  String get limitLabel => 'लिमिट: ';

  @override
  String get claimedOfferTitle => 'दावा किया गया ऑफर';

  @override
  String get offerRevenueTitle => 'ऑफर रेवेन्यू';

  @override
  String get bookingViaOffersTitle => 'ऑफर्स के माध्यम से बुकिंग';

  @override
  String get newCustomersViaOffersTitle => 'ऑफर्स के माध्यम से नए कस्टमर';

  @override
  String get viewDetailsBtn => 'डिटेल्स देखें';

  @override
  String get allBookingsTitle => 'सभी बुकिंग';

  @override
  String get offerTitle => 'ऑफर';

  @override
  String get offersTitle => 'ऑफर';

  @override
  String get editingOfferTitle => 'ऑफर एडिट करें';

  @override
  String get createNewOfferTitle => 'नया ऑफर बनाएं';

  @override
  String get offerNameLabel => 'ऑफर का नाम';

  @override
  String get descriptionOptionalLabel => 'डिटेल्स (वैकल्पिक)';

  @override
  String get percentageOffLabel => 'प्रतिशत डिस्काउंट (%)';

  @override
  String get fixedDiscountLabel => 'निश्चित डिस्काउंट अमाउंट';

  @override
  String get limitPerCustomerLabel => 'प्रति कस्टमर लिमिट';

  @override
  String get validFromLabel => 'से मान्य';

  @override
  String get validToLabel => 'तक मान्य';

  @override
  String get applicableServicesLabel => 'लागू सर्विसेस';

  @override
  String get createOfferBtn => 'ऑफर बनाएं';

  @override
  String get existingOffersTitle => 'मौजूदा ऑफर';

  @override
  String get noOffersFound => 'अभी तक कोई ऑफर नहीं बनाया गया है।';

  @override
  String get totalLimitLabel => 'टोटल लिमिट: ';

  @override
  String get addStaffTab => 'स्टाफ़ जोड़ें';

  @override
  String get staffListTab => 'स्टाफ़ सूची';

  @override
  String get staffTitle => 'स्टाफ़';

  @override
  String get selectImageSourceTitle => 'छवि स्रोत चुनें';

  @override
  String get cameraLabel => 'कैमरा';

  @override
  String get galleryLabel => 'गैलरी';

  @override
  String get editingStaffTitle => 'स्टाफ़ एडिट करें';

  @override
  String get addNewStaffTitle => 'नया स्टाफ़ जोड़ें';

  @override
  String get fullNameLabel => 'पूरा नाम';

  @override
  String get phoneNumberLabel => 'फ़ोन नंबर';

  @override
  String get emailAddressLabel => 'ईमेल पता';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get addressLabel => 'पता';

  @override
  String get birthdateLabel => 'जन्मदिन';

  @override
  String get manageStaffTitle => 'स्टाफ़ मैनेज करें';

  @override
  String get noStaffFound => 'कोई स्टाफ़ सदस्य नहीं मिला।';

  @override
  String get genderMale => 'पुरुष';

  @override
  String get genderFemale => 'महिला';

  @override
  String get genderOther => 'अन्य';

  @override
  String get addItemsTab => 'आइटम जोड़ें';

  @override
  String get inventoryDetailsTab => 'इन्वेंटरी डिटेल्स';

  @override
  String get inventoryTitle => 'इन्वेंटरी';

  @override
  String get itemNameLabel => 'आइटम का नाम';

  @override
  String get quantityLabel => 'मात्रा';

  @override
  String get costLabel => 'लागत';

  @override
  String get categoriesLabel => 'कैटेगरीज';

  @override
  String get unitTypeLabel => 'यूनिट प्रकार';

  @override
  String get retryBtn => 'पुनः प्रयास करें';

  @override
  String get noInventoryItemsFound => 'कोई इन्वेंटरी आइटम नहीं मिला';

  @override
  String get allCategoriesLabel => 'सभी कैटेगरीज';

  @override
  String get qtyLabel => 'मात्रा - ';

  @override
  String get categoryPrefix => 'कैटेगरी : ';

  @override
  String get unitPrefix => 'यूनिट : ';

  @override
  String get costPrefix => 'लागत : ₹';

  @override
  String get reorderPrefix => 'पुनः आदेश : ';

  @override
  String get viewAssignedStaffBtn => 'असाइन किए गए स्टाफ़ देखें';

  @override
  String get assignPrefix => 'असाइन करें ';

  @override
  String get selectStaffMemberTitle => 'स्टाफ़ सदस्य चुनें';

  @override
  String get chooseStaffHint => 'स्टाफ़ चुनें';

  @override
  String get allocatedQuantityLabel => 'आवंटित मात्रा';

  @override
  String get enterQuantityHint => 'मात्रा दर्ज करें';

  @override
  String get notesOptionalLabel => 'नोट्स (वैकल्पिक)';

  @override
  String get addNotesHint => 'नोट्स जोड़ें...';

  @override
  String get assignActionBtn => 'असाइन करें';

  @override
  String get revenueTab => 'रेवेन्यू';

  @override
  String get offerTab => 'ऑफर';

  @override
  String get analyticsTitle => 'एनालिटिक्स';

  @override
  String get filterCustomRange => 'कस्टम रेंज';

  @override
  String get totalRevenueLabel => 'टोटल रेवेन्यू';

  @override
  String get customLabel => 'कस्टम';

  @override
  String get selectDateHint => 'तारीख चुनें';

  @override
  String get revenueTrendsTitle => 'रेवेन्यू रुझान';

  @override
  String get claimedOfferCard => 'दावा किया गया ऑफर';

  @override
  String get offerRevenueCard => 'ऑफर रेवेन्यू';

  @override
  String get allOffersTitle => 'सभी ऑफर';

  @override
  String get appointmentsPerStaffCard => 'प्रति स्टाफ़ अपॉइंटमेंट';

  @override
  String get staffRevenueCard => 'स्टाफ़ रेवेन्यू';

  @override
  String get staffAttendanceTitle => 'स्टाफ़ अटेंडेंस';

  @override
  String get noAttendanceRecords => 'कोई अटेंडेंस रिकॉर्ड नहीं मिला।';

  @override
  String get comingSoonLabel => 'जल्द आ रहा है';

  @override
  String get revenueLabel => 'रेवेन्यू';

  @override
  String get dateLabel => 'तारीख';

  @override
  String get noDataAvailable => 'कोई डेटा उपलब्ध नहीं';

  @override
  String get fromLabel => 'से';

  @override
  String get toLabel => 'तक';

  @override
  String get staffIdPrefix => 'स्टाफ़ आईडी: ';

  @override
  String get offerRevenueDetailsTitle => 'ऑफर रेवेन्यू डिटेल्स';

  @override
  String get noDescriptionAvailable => 'कोई डिटेल्स उपलब्ध नहीं';

  @override
  String get offerClaimDetailsTitle => 'ऑफर दावा डिटेल्स';

  @override
  String get noUsageDataFound => 'कोई उपयोग डेटा नहीं मिला';

  @override
  String get unlimitedLabel => 'असीमित';

  @override
  String get usedLabel => 'इस्तेमाल किया';

  @override
  String get staffRevenueTitle => 'स्टाफ़ रेवेन्यू';

  @override
  String get staffAppointmentDetailsTitle => 'स्टाफ़ अपॉइंटमेंट डिटेल्स';

  @override
  String get appsLabel => 'ऐप्स';

  @override
  String get totalClientsTitle => 'टोटल कस्टमर';

  @override
  String get totalServicesTitle => 'टोटल सर्विसेस';

  @override
  String get employeesTitle => 'स्टाफ';

  @override
  String get appointmentTitle => 'अपॉइंटमेंट';

  @override
  String get noBookingsFound => 'कोई बुकिंग नहीं मिली';

  @override
  String get scheduledTab => 'निर्धारित';

  @override
  String get cancelledTab => 'कैंसल्ड';

  @override
  String get completedTab => 'कम्प्लीटेड';

  @override
  String get markAppointmentCompleteHint =>
      'अपॉइंटमेंट को कम्प्लीट चिह्नित करने के लिए स्टाफ से संपर्क करें';

  @override
  String get noAppointmentsFound => 'कोई अपॉइंटमेंट नहीं मिला';

  @override
  String get scheduleTitle => 'शेड्यूल';

  @override
  String get cancellationReasonTitle => 'कैंसिलेशन कारण';

  @override
  String get enterCancellationReasonHint => 'कैंसिलेशन कारण दर्ज करें';

  @override
  String get cancelAppointmentBtn => 'अपॉइंटमेंट कैंसिल करें';

  @override
  String get appointmentCancelledSuccess => 'अपॉइंटमेंट कैंसल्ड!';

  @override
  String get assignNewStaffTitle => 'नया स्टाफ असाइन करें';

  @override
  String get staffAssignedToPrefix => 'स्टाफ को असाइन किया गया: ';

  @override
  String get successfullySuffix => ' सफलतापूर्वक';

  @override
  String get billToOptionalTitle => 'बिल करें (वैकल्पिक)';

  @override
  String get searchByNameNumberHint => 'नाम, नंबर से खोजें';

  @override
  String get amountHint => 'अमाउंट';

  @override
  String get discountHint => 'डिस्काउंट';

  @override
  String get taxesHint => 'टैक्स';

  @override
  String get invoiceNoteTitle => 'इनवॉइस नोट';

  @override
  String get noteHint => 'नोट';

  @override
  String get createInvoiceTitle => 'इनवॉइस बनाएं';

  @override
  String get amountPayableTitle => 'देय अमाउंट';

  @override
  String get invoiceGeneratedSuccess => 'इनवॉइस सफलतापूर्वक उत्पन्न हुआ';

  @override
  String get shareInvoiceHint => 'इसे अपने कस्टमर के साथ साझा करें';

  @override
  String get selectServiceHint => 'सर्विस चुनें';

  @override
  String get presentEmployeesTitle => 'उपस्थित स्टाफ';

  @override
  String get totalEmployeeTitle => 'टोटल स्टाफ';

  @override
  String get onLeaveTitle => 'छुट्टी पर';

  @override
  String get attendanceTitle => 'अटेंडेंस';

  @override
  String get totalAttendanceTitle => 'टोटल अटेंडेंस';

  @override
  String get staffNameHint => 'स्टाफ का नाम';

  @override
  String get dateTitle => 'तारीख';

  @override
  String get monShort => 'सोम';

  @override
  String get tueShort => 'मंगल';

  @override
  String get wedShort => 'बुध';

  @override
  String get thuShort => 'गुरु';

  @override
  String get friShort => 'शुक्र';

  @override
  String get satShort => 'शनि';

  @override
  String get sunShort => 'रवि';

  @override
  String get totalHoursLabel => 'टोटल घंटे';

  @override
  String get presentLabel => 'उपस्थित';

  @override
  String get daysLabel => 'दिन';

  @override
  String get leavesLabel => 'छुट्टियां';

  @override
  String get paidLeaveLabel => 'सवैतनिक अवकाश';

  @override
  String get halfDayLabel => 'आधा दिन';

  @override
  String get sickLeaveLabel => 'बीमार अवकाश';

  @override
  String get casualLeaveLabel => 'आकस्मिक अवकाश';

  @override
  String get inventoryUsedTitle => 'इस्तेमाल की गई इन्वेंटरी';

  @override
  String get itemTypeLabel => 'आइटम प्रकार';

  @override
  String get toolsLabel => 'उपकरण';

  @override
  String get shampooLabel => 'शैम्पू';

  @override
  String get returnLabel => 'वापसी';

  @override
  String get notAvailableText => 'उपलब्ध नहीं';

  @override
  String get memberSincePrefix => 'सदस्य: ';

  @override
  String get appointmentHistoryTitle => 'अपॉइंटमेंट हिस्ट्री';

  @override
  String get noHistoryAvailable => 'कोई हिस्ट्री उपलब्ध नहीं';

  @override
  String get historyTitle => 'हिस्ट्री';

  @override
  String get visitsLabel => 'विज़िट';

  @override
  String get lastVisitLabel => 'अंतिम विज़िट';

  @override
  String get noServicesText => 'कोई सर्विस नहीं';

  @override
  String get staffAssignmentsPrefix => 'स्टाफ असाइनमेंट - ';

  @override
  String get noStaffAssignedItem =>
      'अभी तक इस आइटम के लिए कोई स्टाफ असाइन नहीं किया गया है';

  @override
  String get unknownDate => 'अज्ञात तिथि';

  @override
  String get unknownStaff => 'अज्ञात स्टाफ';

  @override
  String get assignedByPrefix => 'द्वारा असाइन किया गया: ';

  @override
  String get systemLabel => 'सिस्टम';

  @override
  String get reassignTooltip => 'पुनः असाइन करें / उपयोग अपडेट करें';

  @override
  String get allocatedLabel => 'आवंटित';

  @override
  String get remainingLabel => 'शेष';

  @override
  String get appointmentsLabel => 'अपॉइंटमेंट्स';

  @override
  String get unitLabel => 'यूनिट';

  @override
  String get notesLabel => 'नोट्स:';

  @override
  String get assignedPrefix => 'असाइन किया गया: ';

  @override
  String get viewUsageBtn => 'उपयोग देखें';

  @override
  String get updateAssignmentPrefix => 'असाइनमेंट अपडेट करें - ';

  @override
  String get totalUsedQuantity => 'टोटल प्रयुक्त मात्रा';

  @override
  String get newTotalAllocatedQuantity => 'नई टोटल आवंटित मात्रा';

  @override
  String get enterTotalQuantityHint => 'टोटल मात्रा दर्ज करें';

  @override
  String get notesTitle => 'नोट्स';

  @override
  String get updateNotesHint => 'नोट्स अपडेट करें...';

  @override
  String get assignmentUpdatedSuccess => 'असाइनमेंट सफलतापूर्वक अपडेट किया गया';

  @override
  String get noApprovedRequests => 'कोई अप्रूव्ड अनुरोध नहीं';

  @override
  String get leaveRequestTitle => 'छुट्टी का आवेदन';

  @override
  String get pendingTab => 'पेंडिंग';

  @override
  String get approvedTab => 'अप्रूव्ड';

  @override
  String get leaveTypePaid => 'छुट्टी का प्रकार - सवैतनिक';

  @override
  String get durationPlaceholder => 'अवधि: 01-04-2026 से 02-04-2026';

  @override
  String get emailSupportError =>
      'ईमेल क्लाइंट नहीं खुल सका। कृपया jeevan.j@neopaceinfotech.com पर ईमेल करें।';

  @override
  String get dialerSupportError =>
      'डायलर नहीं खुल सका। कृपया सीधे 9119591956 पर कॉल करें।';

  @override
  String get supportTitle => 'सपोर्ट';

  @override
  String get supportHelpText => 'हम हर कदम पर आपकी मदद करने के लिए यहाँ हैं।';

  @override
  String get emailSupportTitle => 'ईमेल सपोर्ट';

  @override
  String get phoneSupportTitle => 'फ़ोन सपोर्ट';

  @override
  String get workingHoursTitle => 'काम के घंटे';

  @override
  String get workingHoursValue => 'सुबह 10 बजे से शाम 7 बजे तक';

  @override
  String get supportFooterText =>
      'हम तेज़, विश्वसनीय और मैत्रीपूर्ण सपोर्ट प्रदान करने का लक्ष्य रखते हैं ताकि नियो पार्लर के साथ आपका अनुभव हमेशा सहज और परेशानी मुक्त रहे।';

  @override
  String get noPendingFeedback => 'कोई पेंडिंग फीडबैक नहीं मिला';

  @override
  String get noApprovedFeedback => 'कोई अप्रूव्ड फीडबैक नहीं मिला';

  @override
  String get feedbackTitle => 'फीडबैक';

  @override
  String get customerPrefix => 'कस्टमर #';

  @override
  String get feedbackRejectedSuccess => 'फीडबैक सफलतापूर्वक रिजेक्टेड!';

  @override
  String get feedbackApprovedSuccess => 'फीडबैक सफलतापूर्वक अप्रूव्ड!';

  @override
  String get mainSalonImageLabel => 'मुख्य सैलून छवि';
}
