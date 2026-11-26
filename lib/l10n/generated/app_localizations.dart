import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'NeoParlour Partner'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account or log in to book and manage your appointments'**
  String get loginSubtitle;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get continueWithFacebook;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueBtn;

  /// No description provided for @salonOwnerTab.
  ///
  /// In en, this message translates to:
  /// **'SALON OWNER'**
  String get salonOwnerTab;

  /// No description provided for @staffTab.
  ///
  /// In en, this message translates to:
  /// **'STAFF'**
  String get staffTab;

  /// No description provided for @mobileOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number or Email'**
  String get mobileOrEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @iAgreeToThe.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get iAgreeToThe;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @comma.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get comma;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' And '**
  String get and;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @iAgreeMarketing.
  ///
  /// In en, this message translates to:
  /// **'I agree to receive marketing notifications with offers and news'**
  String get iAgreeMarketing;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @pleaseAcceptAgreements.
  ///
  /// In en, this message translates to:
  /// **'Please accept all agreements to continue.'**
  String get pleaseAcceptAgreements;

  /// No description provided for @pleaseEnterIdAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter both ID and Password'**
  String get pleaseEnterIdAndPassword;

  /// No description provided for @validMobileError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit mobile number'**
  String get validMobileError;

  /// No description provided for @otpSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'OTP sent successfully'**
  String get otpSentSuccess;

  /// No description provided for @failedToSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP'**
  String get failedToSendOtp;

  /// No description provided for @enterOtpError.
  ///
  /// In en, this message translates to:
  /// **'Please enter the OTP'**
  String get enterOtpError;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLengthError;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully. Please login.'**
  String get passwordResetSuccess;

  /// No description provided for @failedToResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset password'**
  String get failedToResetPassword;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @verificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verificationTitle;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @enterOtpAndNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP sent to {mobile} and your new password.'**
  String enterOtpAndNewPassword(String mobile);

  /// No description provided for @enterMobileForOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered mobile number to receive an OTP for password reset.'**
  String get enterMobileForOtp;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @resetPasswordBtn.
  ///
  /// In en, this message translates to:
  /// **'RESET PASSWORD'**
  String get resetPasswordBtn;

  /// No description provided for @sendOtpBtn.
  ///
  /// In en, this message translates to:
  /// **'SEND OTP'**
  String get sendOtpBtn;

  /// No description provided for @pleaseEnterAccountAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter both Account and Password'**
  String get pleaseEnterAccountAndPassword;

  /// No description provided for @accessDeniedRole.
  ///
  /// In en, this message translates to:
  /// **'Access Denied: Current role is {role}'**
  String accessDeniedRole(String role);

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @emailOrMobile.
  ///
  /// In en, this message translates to:
  /// **'Email Or Mobile Number'**
  String get emailOrMobile;

  /// No description provided for @rememberMeNextTime.
  ///
  /// In en, this message translates to:
  /// **'Remember me next time'**
  String get rememberMeNextTime;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingIn;

  /// No description provided for @ownerFullName.
  ///
  /// In en, this message translates to:
  /// **'Owner Full Name'**
  String get ownerFullName;

  /// No description provided for @securityTab.
  ///
  /// In en, this message translates to:
  /// **'SECURITY'**
  String get securityTab;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @fillMandatoryFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all mandatory fields'**
  String get fillMandatoryFields;

  /// No description provided for @mobileNumber10Digits.
  ///
  /// In en, this message translates to:
  /// **'Mobile number must be exactly 10 digits'**
  String get mobileNumber10Digits;

  /// No description provided for @validGmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid Gmail address'**
  String get validGmailAddress;

  /// No description provided for @continueToSalonInfo.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE TO SALON INFO'**
  String get continueToSalonInfo;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have account? '**
  String get alreadyHaveAccount;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @salonInformation.
  ///
  /// In en, this message translates to:
  /// **'SALON INFORMATION'**
  String get salonInformation;

  /// No description provided for @salonName.
  ///
  /// In en, this message translates to:
  /// **'Salon Name'**
  String get salonName;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @fillSalonInfoError.
  ///
  /// In en, this message translates to:
  /// **'Please fill Salon Name, City, and Area'**
  String get fillSalonInfoError;

  /// No description provided for @uploadMainSalonImageError.
  ///
  /// In en, this message translates to:
  /// **'Please upload a Main Salon Image'**
  String get uploadMainSalonImageError;

  /// No description provided for @uploadGalleryImagesError.
  ///
  /// In en, this message translates to:
  /// **'Please upload at least 3 Gallery Images'**
  String get uploadGalleryImagesError;

  /// No description provided for @continueToKycBtn.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE TO KYC'**
  String get continueToKycBtn;

  /// No description provided for @uploadBtn.
  ///
  /// In en, this message translates to:
  /// **'UPLOAD'**
  String get uploadBtn;

  /// No description provided for @salonGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'SALON GALLERY'**
  String get salonGalleryTitle;

  /// No description provided for @min3ImagesRequired.
  ///
  /// In en, this message translates to:
  /// **'AT LEAST 3 IMAGES REQUIRED'**
  String get min3ImagesRequired;

  /// No description provided for @uploadImageInstructions.
  ///
  /// In en, this message translates to:
  /// **'Please upload 1 exterior photo (outside view) and at least 2 interior photos (inside views) of the salon. Max 5MB per image.'**
  String get uploadImageInstructions;

  /// No description provided for @exteriorView.
  ///
  /// In en, this message translates to:
  /// **'1. EXTERIOR VIEW'**
  String get exteriorView;

  /// No description provided for @uploadOutsideBtn.
  ///
  /// In en, this message translates to:
  /// **'UPLOAD OUTSIDE'**
  String get uploadOutsideBtn;

  /// No description provided for @interiorView1.
  ///
  /// In en, this message translates to:
  /// **'2. INTERIOR VIEW 1'**
  String get interiorView1;

  /// No description provided for @uploadInside1Btn.
  ///
  /// In en, this message translates to:
  /// **'UPLOAD INSIDE 1'**
  String get uploadInside1Btn;

  /// No description provided for @interiorView2.
  ///
  /// In en, this message translates to:
  /// **'3. INTERIOR VIEW 2'**
  String get interiorView2;

  /// No description provided for @uploadInside2Btn.
  ///
  /// In en, this message translates to:
  /// **'UPLOAD INSIDE 2'**
  String get uploadInside2Btn;

  /// No description provided for @additionalGalleryImages.
  ///
  /// In en, this message translates to:
  /// **'ADDITIONAL GALLERY IMAGES (OPTIONAL - MAX 2)'**
  String get additionalGalleryImages;

  /// No description provided for @backBtn.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get backBtn;

  /// No description provided for @openingTime.
  ///
  /// In en, this message translates to:
  /// **'Opening Time'**
  String get openingTime;

  /// No description provided for @closingTime.
  ///
  /// In en, this message translates to:
  /// **'Closing Time'**
  String get closingTime;

  /// No description provided for @salonMedia.
  ///
  /// In en, this message translates to:
  /// **'SALON MEDIA'**
  String get salonMedia;

  /// No description provided for @notUploaded.
  ///
  /// In en, this message translates to:
  /// **'NOT UPLOADED'**
  String get notUploaded;

  /// No description provided for @removeBtn.
  ///
  /// In en, this message translates to:
  /// **'REMOVE'**
  String get removeBtn;

  /// No description provided for @uploadFileBtn.
  ///
  /// In en, this message translates to:
  /// **'UPLOAD FILE'**
  String get uploadFileBtn;

  /// No description provided for @kycVerification.
  ///
  /// In en, this message translates to:
  /// **'KYC VERIFICATION'**
  String get kycVerification;

  /// No description provided for @atLeast1DocRequired.
  ///
  /// In en, this message translates to:
  /// **'AT LEAST 1 DOCUMENT REQUIRED'**
  String get atLeast1DocRequired;

  /// No description provided for @kycInstructions.
  ///
  /// In en, this message translates to:
  /// **'Please upload at least one valid identity or business document for KYC verification purpose. Max 5MB. Accepted formats: Image/PDF.'**
  String get kycInstructions;

  /// No description provided for @aadhaarGovtId.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar / Government ID'**
  String get aadhaarGovtId;

  /// No description provided for @panCard.
  ///
  /// In en, this message translates to:
  /// **'PAN Card'**
  String get panCard;

  /// No description provided for @shopEstLicense.
  ///
  /// In en, this message translates to:
  /// **'Shop & Est. License'**
  String get shopEstLicense;

  /// No description provided for @bankAccountProof.
  ///
  /// In en, this message translates to:
  /// **'Bank Account Proof'**
  String get bankAccountProof;

  /// No description provided for @iAgreeWithThe.
  ///
  /// In en, this message translates to:
  /// **'I agree with the '**
  String get iAgreeWithThe;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @pleaseAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept Terms of Use'**
  String get pleaseAcceptTerms;

  /// No description provided for @pleaseUpload1KycDoc.
  ///
  /// In en, this message translates to:
  /// **'Please upload at least 1 KYC document.'**
  String get pleaseUpload1KycDoc;

  /// No description provided for @ownerAndSalonRegistration.
  ///
  /// In en, this message translates to:
  /// **'OWNER & SALON REGISTRATION'**
  String get ownerAndSalonRegistration;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get errorPrefix;

  /// No description provided for @couldNotRetrieveFileContent.
  ///
  /// In en, this message translates to:
  /// **'Could not retrieve file content.'**
  String get couldNotRetrieveFileContent;

  /// No description provided for @errorPickingFile.
  ///
  /// In en, this message translates to:
  /// **'Error picking file: '**
  String get errorPickingFile;

  /// No description provided for @errorTakingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Error taking photo: '**
  String get errorTakingPhoto;

  /// No description provided for @selectDocumentSource.
  ///
  /// In en, this message translates to:
  /// **'Select Document Source'**
  String get selectDocumentSource;

  /// No description provided for @uploadFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Upload from Gallery / Files'**
  String get uploadFromGallery;

  /// No description provided for @selectImageOrPdf.
  ///
  /// In en, this message translates to:
  /// **'Select image or PDF document'**
  String get selectImageOrPdf;

  /// No description provided for @takeAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takeAPhoto;

  /// No description provided for @captureUsingCamera.
  ///
  /// In en, this message translates to:
  /// **'Capture using device camera'**
  String get captureUsingCamera;

  /// No description provided for @cityTitle.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityTitle;

  /// No description provided for @areaTitle.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get areaTitle;

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'Search City'**
  String get searchCity;

  /// No description provided for @searchArea.
  ///
  /// In en, this message translates to:
  /// **'Search Area'**
  String get searchArea;

  /// No description provided for @ownerDetails.
  ///
  /// In en, this message translates to:
  /// **'OWNER DETAILS'**
  String get ownerDetails;

  /// No description provided for @stepPersonal.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL'**
  String get stepPersonal;

  /// No description provided for @stepSalon.
  ///
  /// In en, this message translates to:
  /// **'SALON'**
  String get stepSalon;

  /// No description provided for @stepKyc.
  ///
  /// In en, this message translates to:
  /// **'KYC'**
  String get stepKyc;

  /// No description provided for @stepOtp.
  ///
  /// In en, this message translates to:
  /// **'OTP'**
  String get stepOtp;

  /// No description provided for @otpResentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP resent successfully'**
  String get otpResentSuccessfully;

  /// No description provided for @failedToResendOtp.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend OTP: '**
  String get failedToResendOtp;

  /// No description provided for @enterFull6DigitOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter full 6-digit OTP'**
  String get enterFull6DigitOtp;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration Successful'**
  String get registrationSuccessful;

  /// No description provided for @accountCreatedPleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Your account has been created. Please login.'**
  String get accountCreatedPleaseLogin;

  /// No description provided for @loginNow.
  ///
  /// In en, this message translates to:
  /// **'LOGIN NOW'**
  String get loginNow;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification Failed: '**
  String get verificationFailed;

  /// No description provided for @verifyOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'VERIFY OTP'**
  String get verifyOtpTitle;

  /// No description provided for @sentVerificationCodeTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to your\nmobile number '**
  String get sentVerificationCodeTo;

  /// No description provided for @verifyBtn.
  ///
  /// In en, this message translates to:
  /// **'VERIFY'**
  String get verifyBtn;

  /// No description provided for @uploadingRegistrationPhotosPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Uploading photos and setting up your salon account, please wait...'**
  String get uploadingRegistrationPhotosPleaseWait;

  /// No description provided for @didntReceiveOtp.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive OTP? '**
  String get didntReceiveOtp;

  /// No description provided for @resendOtpBtn.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtpBtn;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in '**
  String get resendIn;

  /// No description provided for @failedToLoadPlans.
  ///
  /// In en, this message translates to:
  /// **'Failed to load plans: '**
  String get failedToLoadPlans;

  /// No description provided for @failedToOpenPricingPortal.
  ///
  /// In en, this message translates to:
  /// **'Failed to open pricing portal: '**
  String get failedToOpenPricingPortal;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip For Now'**
  String get skipForNow;

  /// No description provided for @whatYouCanGet.
  ///
  /// In en, this message translates to:
  /// **'What You Can Get?'**
  String get whatYouCanGet;

  /// No description provided for @staffManagement.
  ///
  /// In en, this message translates to:
  /// **'Staff Management'**
  String get staffManagement;

  /// No description provided for @inventoryManagement.
  ///
  /// In en, this message translates to:
  /// **'Inventory Management'**
  String get inventoryManagement;

  /// No description provided for @subscribeOnWebsite.
  ///
  /// In en, this message translates to:
  /// **'SUBSCRIBE ON WEBSITE'**
  String get subscribeOnWebsite;

  /// No description provided for @appointmentRescheduled.
  ///
  /// In en, this message translates to:
  /// **'Appointment rescheduled successfully'**
  String get appointmentRescheduled;

  /// No description provided for @cancelAppointmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Appointment'**
  String get cancelAppointmentTitle;

  /// No description provided for @enterCancelReason.
  ///
  /// In en, this message translates to:
  /// **'Enter cancellation reason...'**
  String get enterCancelReason;

  /// No description provided for @appointmentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Appointment cancelled successfully'**
  String get appointmentCancelled;

  /// No description provided for @selectStaff.
  ///
  /// In en, this message translates to:
  /// **'Select Staff'**
  String get selectStaff;

  /// No description provided for @noStaffAvailable.
  ///
  /// In en, this message translates to:
  /// **'No staff available'**
  String get noStaffAvailable;

  /// No description provided for @staffAssignedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Staff assigned successfully'**
  String get staffAssignedSuccessfully;

  /// No description provided for @welcomePrefix.
  ///
  /// In en, this message translates to:
  /// **'WELCOME '**
  String get welcomePrefix;

  /// No description provided for @ownerDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get ownerDefaultName;

  /// No description provided for @todayOverview.
  ///
  /// In en, this message translates to:
  /// **'TODAY OVERVIEW'**
  String get todayOverview;

  /// No description provided for @weeklyOverview.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY OVERVIEW'**
  String get weeklyOverview;

  /// No description provided for @monthlyOverview.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY OVERVIEW'**
  String get monthlyOverview;

  /// No description provided for @yearlyOverview.
  ///
  /// In en, this message translates to:
  /// **'YEARLY OVERVIEW'**
  String get yearlyOverview;

  /// No description provided for @filterToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get filterToday;

  /// No description provided for @filterWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get filterWeekly;

  /// No description provided for @filterMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get filterMonthly;

  /// No description provided for @filterYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get filterYearly;

  /// No description provided for @statRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get statRevenue;

  /// No description provided for @statBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get statBookings;

  /// No description provided for @statOfferUsage.
  ///
  /// In en, this message translates to:
  /// **'Offer Usage'**
  String get statOfferUsage;

  /// No description provided for @statCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statCompleted;

  /// No description provided for @statCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statCancelled;

  /// No description provided for @statRescheduled.
  ///
  /// In en, this message translates to:
  /// **'Rescheduled'**
  String get statRescheduled;

  /// No description provided for @totalFor.
  ///
  /// In en, this message translates to:
  /// **'Total for '**
  String get totalFor;

  /// No description provided for @countFor.
  ///
  /// In en, this message translates to:
  /// **'Count for '**
  String get countFor;

  /// No description provided for @usedPeriod.
  ///
  /// In en, this message translates to:
  /// **'Used '**
  String get usedPeriod;

  /// No description provided for @totalPeriod.
  ///
  /// In en, this message translates to:
  /// **'Total '**
  String get totalPeriod;

  /// No description provided for @upcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING APPOINTMENTS'**
  String get upcomingAppointments;

  /// No description provided for @noUpcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments'**
  String get noUpcomingAppointments;

  /// No description provided for @staffPrefix.
  ///
  /// In en, this message translates to:
  /// **'Staff: '**
  String get staffPrefix;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @cancelReasonPrefix.
  ///
  /// In en, this message translates to:
  /// **'Cancel Reason: '**
  String get cancelReasonPrefix;

  /// No description provided for @ownerRescheduleReasonPrefix.
  ///
  /// In en, this message translates to:
  /// **'Owner Reschedule Reason: '**
  String get ownerRescheduleReasonPrefix;

  /// No description provided for @customerRescheduleReasonPrefix.
  ///
  /// In en, this message translates to:
  /// **'Customer Reschedule Reason: '**
  String get customerRescheduleReasonPrefix;

  /// No description provided for @rescheduleBtn.
  ///
  /// In en, this message translates to:
  /// **'RESCHEDULE'**
  String get rescheduleBtn;

  /// No description provided for @cancelBtn.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancelBtn;

  /// No description provided for @assignStaffBtn.
  ///
  /// In en, this message translates to:
  /// **'ASSIGN STAFF'**
  String get assignStaffBtn;

  /// No description provided for @splashOneTop.
  ///
  /// In en, this message translates to:
  /// **'Your'**
  String get splashOneTop;

  /// No description provided for @splashOneMid.
  ///
  /// In en, this message translates to:
  /// **'EXCLUSIVE SALON'**
  String get splashOneMid;

  /// No description provided for @splashOneBottom.
  ///
  /// In en, this message translates to:
  /// **'Management App'**
  String get splashOneBottom;

  /// No description provided for @splashTwoTop.
  ///
  /// In en, this message translates to:
  /// **'Your'**
  String get splashTwoTop;

  /// No description provided for @splashTwoMid.
  ///
  /// In en, this message translates to:
  /// **'PARLOUR'**
  String get splashTwoMid;

  /// No description provided for @splashTwoBottom.
  ///
  /// In en, this message translates to:
  /// **'Platter'**
  String get splashTwoBottom;

  /// No description provided for @splashThreeTop.
  ///
  /// In en, this message translates to:
  /// **'Smart Salon'**
  String get splashThreeTop;

  /// No description provided for @splashThreeMid.
  ///
  /// In en, this message translates to:
  /// **'SEAMLESS'**
  String get splashThreeMid;

  /// No description provided for @splashThreeBottom.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get splashThreeBottom;

  /// No description provided for @skipSplash.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipSplash;

  /// No description provided for @changeMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Change Mobile Number'**
  String get changeMobileNumber;

  /// No description provided for @versionFooter.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0 | Powered By Neopaceinfotech LLP'**
  String get versionFooter;

  /// No description provided for @maintenanceInProgressToast.
  ///
  /// In en, this message translates to:
  /// **'Server maintenance is still in progress. Please check again in a few minutes.'**
  String get maintenanceInProgressToast;

  /// No description provided for @maintenanceNoInternetToast.
  ///
  /// In en, this message translates to:
  /// **'Unable to reach server. Please check your internet connection.'**
  String get maintenanceNoInternetToast;

  /// No description provided for @maintenanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Partner Portal Under Maintenance'**
  String get maintenanceTitle;

  /// No description provided for @maintenanceSafeMessage.
  ///
  /// In en, this message translates to:
  /// **'Your salon records, appointment schedules, and staff data are safe and secure.'**
  String get maintenanceSafeMessage;

  /// No description provided for @maintenanceEstimatedCompletion.
  ///
  /// In en, this message translates to:
  /// **'Estimated Completion: '**
  String get maintenanceEstimatedCompletion;

  /// No description provided for @checkingStatus.
  ///
  /// In en, this message translates to:
  /// **'Checking Status...'**
  String get checkingStatus;

  /// No description provided for @checkSystemStatus.
  ///
  /// In en, this message translates to:
  /// **'Check System Status'**
  String get checkSystemStatus;

  /// No description provided for @drawerProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get drawerProfile;

  /// No description provided for @drawerAboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get drawerAboutUs;

  /// No description provided for @drawerSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get drawerSupport;

  /// No description provided for @drawerMyBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get drawerMyBookings;

  /// No description provided for @drawerSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get drawerSubscription;

  /// No description provided for @drawerChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get drawerChangePassword;

  /// No description provided for @drawerLogout.
  ///
  /// In en, this message translates to:
  /// **'LOGOUT'**
  String get drawerLogout;

  /// No description provided for @drawerPoweredBy.
  ///
  /// In en, this message translates to:
  /// **'Powered By Neopaceinfotech LLP'**
  String get drawerPoweredBy;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'ANALYTICS'**
  String get navAnalytics;

  /// No description provided for @navManage.
  ///
  /// In en, this message translates to:
  /// **'MANAGE'**
  String get navManage;

  /// No description provided for @navNotification.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATION'**
  String get navNotification;

  /// No description provided for @navSetting.
  ///
  /// In en, this message translates to:
  /// **'SETTING'**
  String get navSetting;

  /// No description provided for @manageTitle.
  ///
  /// In en, this message translates to:
  /// **'MANAGE'**
  String get manageTitle;

  /// No description provided for @manageSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get manageSchedule;

  /// No description provided for @manageService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get manageService;

  /// No description provided for @manageInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get manageInventory;

  /// No description provided for @manageStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get manageStaff;

  /// No description provided for @manageFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get manageFeedback;

  /// No description provided for @manageHomeServices.
  ///
  /// In en, this message translates to:
  /// **'Home Services'**
  String get manageHomeServices;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get manageSubscription;

  /// No description provided for @manageAddOffers.
  ///
  /// In en, this message translates to:
  /// **'Add Offers'**
  String get manageAddOffers;

  /// No description provided for @manageAddProducts.
  ///
  /// In en, this message translates to:
  /// **'Add Products'**
  String get manageAddProducts;

  /// No description provided for @manageAddPackages.
  ///
  /// In en, this message translates to:
  /// **'Add Packages'**
  String get manageAddPackages;

  /// No description provided for @drawerMyReferrals.
  ///
  /// In en, this message translates to:
  /// **'My Referrals'**
  String get drawerMyReferrals;

  /// No description provided for @drawerLeaveRequest.
  ///
  /// In en, this message translates to:
  /// **'Leave Request'**
  String get drawerLeaveRequest;

  /// No description provided for @drawerInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get drawerInventory;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'CHANGE PASSWORD'**
  String get changePasswordTitle;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please Enter A New Password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Current Password'**
  String get enterCurrentPassword;

  /// No description provided for @createNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get createNewPassword;

  /// No description provided for @submitBtn.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT'**
  String get submitBtn;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'EDIT PROFILE'**
  String get editProfileTitle;

  /// No description provided for @editBtn.
  ///
  /// In en, this message translates to:
  /// **'EDIT'**
  String get editBtn;

  /// No description provided for @ownerProfileTab.
  ///
  /// In en, this message translates to:
  /// **'OWNER PROFILE'**
  String get ownerProfileTab;

  /// No description provided for @staffProfileTab.
  ///
  /// In en, this message translates to:
  /// **'STAFF PROFILE'**
  String get staffProfileTab;

  /// No description provided for @salonProfileTab.
  ///
  /// In en, this message translates to:
  /// **'SALON PROFILE'**
  String get salonProfileTab;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @dob.
  ///
  /// In en, this message translates to:
  /// **'Date Of Birth'**
  String get dob;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Info'**
  String get contactInfo;

  /// No description provided for @salonDetails.
  ///
  /// In en, this message translates to:
  /// **'Salon Details'**
  String get salonDetails;

  /// No description provided for @salonCode.
  ///
  /// In en, this message translates to:
  /// **'Salon Code'**
  String get salonCode;

  /// No description provided for @salonPhone.
  ///
  /// In en, this message translates to:
  /// **'Salon Phone'**
  String get salonPhone;

  /// No description provided for @businessHours.
  ///
  /// In en, this message translates to:
  /// **'Business Hours & Fees'**
  String get businessHours;

  /// No description provided for @homeServiceCharges.
  ///
  /// In en, this message translates to:
  /// **'Home Service Charges (₹)'**
  String get homeServiceCharges;

  /// No description provided for @salonQrCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'SALON QR CODE'**
  String get salonQrCodeTitle;

  /// No description provided for @downloadQr.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD QR'**
  String get downloadQr;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get saveChanges;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGender;

  /// No description provided for @mySubscriptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'MY SUBSCRIPTIONS'**
  String get mySubscriptionsTitle;

  /// No description provided for @noSubscriptionsFound.
  ///
  /// In en, this message translates to:
  /// **'No subscriptions found.'**
  String get noSubscriptionsFound;

  /// No description provided for @planLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan:'**
  String get planLabel;

  /// No description provided for @startDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDateLabel;

  /// No description provided for @endDateLabel.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDateLabel;

  /// No description provided for @paymentIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment ID:'**
  String get paymentIdLabel;

  /// No description provided for @downloadInvoiceBtn.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD INVOICE'**
  String get downloadInvoiceBtn;

  /// No description provided for @downloadingInvoiceMsg.
  ///
  /// In en, this message translates to:
  /// **'Downloading invoice...'**
  String get downloadingInvoiceMsg;

  /// No description provided for @invoiceDownloadedMsg.
  ///
  /// In en, this message translates to:
  /// **'Invoice downloaded successfully!'**
  String get invoiceDownloadedMsg;

  /// No description provided for @failedDownloadInvoiceMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to download invoice:'**
  String get failedDownloadInvoiceMsg;

  /// No description provided for @aboutUsTitle.
  ///
  /// In en, this message translates to:
  /// **'ABOUT US'**
  String get aboutUsTitle;

  /// No description provided for @aboutNeoParlour.
  ///
  /// In en, this message translates to:
  /// **'About Neo Parlour'**
  String get aboutNeoParlour;

  /// No description provided for @aboutNeoParlourP1.
  ///
  /// In en, this message translates to:
  /// **'Neo Parlour is a smart salon management application built to simplify the way salons operate. We understand that managing a salon involves juggling multiple tasks—appointment bookings, inventory tracking, and staff coordination—all at the same time. These everyday challenges can create confusion and take focus away from what truly matters: growing your business and serving your customers.'**
  String get aboutNeoParlourP1;

  /// No description provided for @aboutNeoParlourP2.
  ///
  /// In en, this message translates to:
  /// **'That’s where Neo Parlour comes in.'**
  String get aboutNeoParlourP2;

  /// No description provided for @aboutNeoParlourP3.
  ///
  /// In en, this message translates to:
  /// **'Our platform brings everything together in one place, allowing salon owners to efficiently manage appointments, monitor inventory, and organize staff schedules with ease. By reducing manual work and minimizing errors, Neo Parlour helps bring clarity, structure, and control to your daily operations.'**
  String get aboutNeoParlourP3;

  /// No description provided for @notificationsTab.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTab;

  /// No description provided for @birthdaysTab.
  ///
  /// In en, this message translates to:
  /// **'Birthdays'**
  String get birthdaysTab;

  /// No description provided for @requestsTab.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requestsTab;

  /// No description provided for @ordersTab.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTab;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @noBirthdaysFound.
  ///
  /// In en, this message translates to:
  /// **'No Birthdays found !'**
  String get noBirthdaysFound;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get noPendingRequests;

  /// No description provided for @swapRequestsHeader.
  ///
  /// In en, this message translates to:
  /// **'SWAP REQUESTS'**
  String get swapRequestsHeader;

  /// No description provided for @leaveRequestsHeader.
  ///
  /// In en, this message translates to:
  /// **'LEAVE REQUESTS'**
  String get leaveRequestsHeader;

  /// No description provided for @approveBtn.
  ///
  /// In en, this message translates to:
  /// **'APPROVE'**
  String get approveBtn;

  /// No description provided for @rejectBtn.
  ///
  /// In en, this message translates to:
  /// **'REJECT'**
  String get rejectBtn;

  /// No description provided for @searchByNameOrMobile.
  ///
  /// In en, this message translates to:
  /// **'Search by Name or Mobile...'**
  String get searchByNameOrMobile;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterOrdered.
  ///
  /// In en, this message translates to:
  /// **'Ordered'**
  String get filterOrdered;

  /// No description provided for @filterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filterCompleted;

  /// No description provided for @filterCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get filterCancelled;

  /// No description provided for @noProductRequestsFound.
  ///
  /// In en, this message translates to:
  /// **'No product requests found'**
  String get noProductRequestsFound;

  /// No description provided for @totalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmountLabel;

  /// No description provided for @serviceListTab.
  ///
  /// In en, this message translates to:
  /// **'Service List'**
  String get serviceListTab;

  /// No description provided for @addServiceTab.
  ///
  /// In en, this message translates to:
  /// **'Add Service'**
  String get addServiceTab;

  /// No description provided for @servicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get servicesTitle;

  /// No description provided for @servicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your salon services and preview how customers see them.'**
  String get servicesSubtitle;

  /// No description provided for @editingServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'EDITING SERVICE'**
  String get editingServiceTitle;

  /// No description provided for @addNewServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'ADD NEW SERVICE'**
  String get addNewServiceTitle;

  /// No description provided for @cancelEditBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel Edit'**
  String get cancelEditBtn;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @typeCustomCategory.
  ///
  /// In en, this message translates to:
  /// **'Type Custom Category'**
  String get typeCustomCategory;

  /// No description provided for @selectPreloadedBtn.
  ///
  /// In en, this message translates to:
  /// **'Select Preloaded'**
  String get selectPreloadedBtn;

  /// No description provided for @selectServiceNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Service Name'**
  String get selectServiceNameLabel;

  /// No description provided for @serviceNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Service Name'**
  String get serviceNameLabel;

  /// No description provided for @selectCategoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a category first'**
  String get selectCategoryFirst;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @durationMinLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration (min)'**
  String get durationMinLabel;

  /// No description provided for @updateBtn.
  ///
  /// In en, this message translates to:
  /// **'UPDATE'**
  String get updateBtn;

  /// No description provided for @saveBtn.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get saveBtn;

  /// No description provided for @serviceListPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Service List (Customer Preview)'**
  String get serviceListPreviewTitle;

  /// No description provided for @serviceListPreviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Preview how customers will see your services.'**
  String get serviceListPreviewSubtitle;

  /// No description provided for @manageServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Services'**
  String get manageServicesTitle;

  /// No description provided for @reorderBtn.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorderBtn;

  /// No description provided for @reorderHint.
  ///
  /// In en, this message translates to:
  /// **'Hold and drag services to change display order.'**
  String get reorderHint;

  /// No description provided for @noServicesFound.
  ///
  /// In en, this message translates to:
  /// **'No services found.'**
  String get noServicesFound;

  /// No description provided for @addProductTab.
  ///
  /// In en, this message translates to:
  /// **'ADD PRODUCT'**
  String get addProductTab;

  /// No description provided for @productListTab.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT LIST'**
  String get productListTab;

  /// No description provided for @productsTitle.
  ///
  /// In en, this message translates to:
  /// **'PRODUCTS'**
  String get productsTitle;

  /// No description provided for @editingProductTitle.
  ///
  /// In en, this message translates to:
  /// **'EDITING PRODUCT'**
  String get editingProductTitle;

  /// No description provided for @addProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'ADD PRODUCTS'**
  String get addProductsTitle;

  /// No description provided for @mainProductImage.
  ///
  /// In en, this message translates to:
  /// **'Main Product Image'**
  String get mainProductImage;

  /// No description provided for @additionalImages.
  ///
  /// In en, this message translates to:
  /// **'Additional Images'**
  String get additionalImages;

  /// No description provided for @cameraBtn.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraBtn;

  /// No description provided for @galleryBtn.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryBtn;

  /// No description provided for @productNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productNameLabel;

  /// No description provided for @productTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Type'**
  String get productTypeLabel;

  /// No description provided for @productDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Description'**
  String get productDescriptionLabel;

  /// No description provided for @stockLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stockLabel;

  /// No description provided for @restockLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Restock Level'**
  String get restockLevelLabel;

  /// No description provided for @discountPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount Price'**
  String get discountPriceLabel;

  /// No description provided for @productUpdatedMsg.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully!'**
  String get productUpdatedMsg;

  /// No description provided for @productAddedMsg.
  ///
  /// In en, this message translates to:
  /// **'Product added successfully!'**
  String get productAddedMsg;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found.'**
  String get noProductsFound;

  /// No description provided for @activeBadge.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get activeBadge;

  /// No description provided for @inactiveBadge.
  ///
  /// In en, this message translates to:
  /// **'INACTIVE'**
  String get inactiveBadge;

  /// No description provided for @addPackageTab.
  ///
  /// In en, this message translates to:
  /// **'ADD PACKAGE'**
  String get addPackageTab;

  /// No description provided for @packageListTab.
  ///
  /// In en, this message translates to:
  /// **'PACKAGE LIST'**
  String get packageListTab;

  /// No description provided for @packagesTitle.
  ///
  /// In en, this message translates to:
  /// **'PACKAGES'**
  String get packagesTitle;

  /// No description provided for @editingPackageTitle.
  ///
  /// In en, this message translates to:
  /// **'EDITING PACKAGE'**
  String get editingPackageTitle;

  /// No description provided for @addNewPackageTitle.
  ///
  /// In en, this message translates to:
  /// **'ADD NEW PACKAGE'**
  String get addNewPackageTitle;

  /// No description provided for @packageNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Package Name'**
  String get packageNameLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @packagePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Package Price'**
  String get packagePriceLabel;

  /// No description provided for @usageLimitPerCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'Usage Limit Per Customer'**
  String get usageLimitPerCustomerLabel;

  /// No description provided for @totalUsageLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Usage Limit'**
  String get totalUsageLimitLabel;

  /// No description provided for @selectServicesLabel.
  ///
  /// In en, this message translates to:
  /// **'SELECT SERVICES'**
  String get selectServicesLabel;

  /// No description provided for @tapToAddServices.
  ///
  /// In en, this message translates to:
  /// **'Tap to add services'**
  String get tapToAddServices;

  /// No description provided for @servicesSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} services selected'**
  String servicesSelectedCount(int count);

  /// No description provided for @savePackageBtn.
  ///
  /// In en, this message translates to:
  /// **'SAVE PACKAGE'**
  String get savePackageBtn;

  /// No description provided for @selectServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Services'**
  String get selectServicesTitle;

  /// No description provided for @noPackagesFound.
  ///
  /// In en, this message translates to:
  /// **'No packages found.'**
  String get noPackagesFound;

  /// No description provided for @perCustLabel.
  ///
  /// In en, this message translates to:
  /// **'Per Cust: '**
  String get perCustLabel;

  /// No description provided for @limitLabel.
  ///
  /// In en, this message translates to:
  /// **'Limit: '**
  String get limitLabel;

  /// No description provided for @claimedOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Claimed Offer'**
  String get claimedOfferTitle;

  /// No description provided for @offerRevenueTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer Revenue'**
  String get offerRevenueTitle;

  /// No description provided for @bookingViaOffersTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Via Offers'**
  String get bookingViaOffersTitle;

  /// No description provided for @newCustomersViaOffersTitle.
  ///
  /// In en, this message translates to:
  /// **'New Customers Via Offers'**
  String get newCustomersViaOffersTitle;

  /// No description provided for @viewDetailsBtn.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetailsBtn;

  /// No description provided for @allBookingsTitle.
  ///
  /// In en, this message translates to:
  /// **'ALL BOOKINGS'**
  String get allBookingsTitle;

  /// No description provided for @offerTitle.
  ///
  /// In en, this message translates to:
  /// **'OFFER'**
  String get offerTitle;

  /// No description provided for @offersTitle.
  ///
  /// In en, this message translates to:
  /// **'OFFERS'**
  String get offersTitle;

  /// No description provided for @editingOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'EDITING OFFER'**
  String get editingOfferTitle;

  /// No description provided for @createNewOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'CREATE NEW OFFER'**
  String get createNewOfferTitle;

  /// No description provided for @offerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Offer Name'**
  String get offerNameLabel;

  /// No description provided for @descriptionOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptionalLabel;

  /// No description provided for @percentageOffLabel.
  ///
  /// In en, this message translates to:
  /// **'Percentage Off (%)'**
  String get percentageOffLabel;

  /// No description provided for @fixedDiscountLabel.
  ///
  /// In en, this message translates to:
  /// **'Fixed Discount Amount'**
  String get fixedDiscountLabel;

  /// No description provided for @limitPerCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'Limit Per Customer'**
  String get limitPerCustomerLabel;

  /// No description provided for @validFromLabel.
  ///
  /// In en, this message translates to:
  /// **'Valid From'**
  String get validFromLabel;

  /// No description provided for @validToLabel.
  ///
  /// In en, this message translates to:
  /// **'Valid To'**
  String get validToLabel;

  /// No description provided for @applicableServicesLabel.
  ///
  /// In en, this message translates to:
  /// **'Applicable Services'**
  String get applicableServicesLabel;

  /// No description provided for @createOfferBtn.
  ///
  /// In en, this message translates to:
  /// **'CREATE OFFER'**
  String get createOfferBtn;

  /// No description provided for @existingOffersTitle.
  ///
  /// In en, this message translates to:
  /// **'EXISTING OFFERS'**
  String get existingOffersTitle;

  /// No description provided for @noOffersFound.
  ///
  /// In en, this message translates to:
  /// **'No offers created yet.'**
  String get noOffersFound;

  /// No description provided for @totalLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Limit: '**
  String get totalLimitLabel;

  /// No description provided for @addStaffTab.
  ///
  /// In en, this message translates to:
  /// **'ADD STAFF'**
  String get addStaffTab;

  /// No description provided for @staffListTab.
  ///
  /// In en, this message translates to:
  /// **'STAFF LIST'**
  String get staffListTab;

  /// No description provided for @staffTitle.
  ///
  /// In en, this message translates to:
  /// **'STAFF'**
  String get staffTitle;

  /// No description provided for @selectImageSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get selectImageSourceTitle;

  /// No description provided for @cameraLabel.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraLabel;

  /// No description provided for @galleryLabel.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryLabel;

  /// No description provided for @editingStaffTitle.
  ///
  /// In en, this message translates to:
  /// **'EDITING STAFF'**
  String get editingStaffTitle;

  /// No description provided for @addNewStaffTitle.
  ///
  /// In en, this message translates to:
  /// **'ADD NEW STAFF'**
  String get addNewStaffTitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @emailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddressLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @birthdateLabel.
  ///
  /// In en, this message translates to:
  /// **'Birthdate'**
  String get birthdateLabel;

  /// No description provided for @manageStaffTitle.
  ///
  /// In en, this message translates to:
  /// **'MANAGE STAFF'**
  String get manageStaffTitle;

  /// No description provided for @noStaffFound.
  ///
  /// In en, this message translates to:
  /// **'No staff members found.'**
  String get noStaffFound;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'MALE'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'FEMALE'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'OTHER'**
  String get genderOther;

  /// No description provided for @addItemsTab.
  ///
  /// In en, this message translates to:
  /// **'ADD ITEMS'**
  String get addItemsTab;

  /// No description provided for @inventoryDetailsTab.
  ///
  /// In en, this message translates to:
  /// **'INVENTORY DETAILS'**
  String get inventoryDetailsTab;

  /// No description provided for @inventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'INVENTORY'**
  String get inventoryTitle;

  /// No description provided for @itemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemNameLabel;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @costLabel.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get costLabel;

  /// No description provided for @categoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesLabel;

  /// No description provided for @unitTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit Type'**
  String get unitTypeLabel;

  /// No description provided for @retryBtn.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryBtn;

  /// No description provided for @noInventoryItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No inventory items found'**
  String get noInventoryItemsFound;

  /// No description provided for @allCategoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategoriesLabel;

  /// No description provided for @qtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Qty - '**
  String get qtyLabel;

  /// No description provided for @categoryPrefix.
  ///
  /// In en, this message translates to:
  /// **'Category : '**
  String get categoryPrefix;

  /// No description provided for @unitPrefix.
  ///
  /// In en, this message translates to:
  /// **'Unit : '**
  String get unitPrefix;

  /// No description provided for @costPrefix.
  ///
  /// In en, this message translates to:
  /// **'Cost : ₹'**
  String get costPrefix;

  /// No description provided for @reorderPrefix.
  ///
  /// In en, this message translates to:
  /// **'Reorder : '**
  String get reorderPrefix;

  /// No description provided for @viewAssignedStaffBtn.
  ///
  /// In en, this message translates to:
  /// **'View Assigned Staff'**
  String get viewAssignedStaffBtn;

  /// No description provided for @assignPrefix.
  ///
  /// In en, this message translates to:
  /// **'Assign '**
  String get assignPrefix;

  /// No description provided for @selectStaffMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Staff Member'**
  String get selectStaffMemberTitle;

  /// No description provided for @chooseStaffHint.
  ///
  /// In en, this message translates to:
  /// **'Choose Staff'**
  String get chooseStaffHint;

  /// No description provided for @allocatedQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Allocated Quantity'**
  String get allocatedQuantityLabel;

  /// No description provided for @enterQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get enterQuantityHint;

  /// No description provided for @notesOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesOptionalLabel;

  /// No description provided for @addNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add notes...'**
  String get addNotesHint;

  /// No description provided for @assignActionBtn.
  ///
  /// In en, this message translates to:
  /// **'ASSIGN'**
  String get assignActionBtn;

  /// No description provided for @revenueTab.
  ///
  /// In en, this message translates to:
  /// **'REVENUE'**
  String get revenueTab;

  /// No description provided for @offerTab.
  ///
  /// In en, this message translates to:
  /// **'OFFER'**
  String get offerTab;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'ANALYTICS'**
  String get analyticsTitle;

  /// No description provided for @filterCustomRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get filterCustomRange;

  /// No description provided for @totalRevenueLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenueLabel;

  /// No description provided for @customLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customLabel;

  /// No description provided for @selectDateHint.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDateHint;

  /// No description provided for @revenueTrendsTitle.
  ///
  /// In en, this message translates to:
  /// **'REVENUE TRENDS'**
  String get revenueTrendsTitle;

  /// No description provided for @claimedOfferCard.
  ///
  /// In en, this message translates to:
  /// **'Claimed Offer'**
  String get claimedOfferCard;

  /// No description provided for @offerRevenueCard.
  ///
  /// In en, this message translates to:
  /// **'Offer Revenue'**
  String get offerRevenueCard;

  /// No description provided for @allOffersTitle.
  ///
  /// In en, this message translates to:
  /// **'ALL OFFERS'**
  String get allOffersTitle;

  /// No description provided for @appointmentsPerStaffCard.
  ///
  /// In en, this message translates to:
  /// **'Appointments Per Staff'**
  String get appointmentsPerStaffCard;

  /// No description provided for @staffRevenueCard.
  ///
  /// In en, this message translates to:
  /// **'Staff Revenue'**
  String get staffRevenueCard;

  /// No description provided for @staffAttendanceTitle.
  ///
  /// In en, this message translates to:
  /// **'STAFF ATTENDANCE'**
  String get staffAttendanceTitle;

  /// No description provided for @noAttendanceRecords.
  ///
  /// In en, this message translates to:
  /// **'No attendance records found.'**
  String get noAttendanceRecords;

  /// No description provided for @comingSoonLabel.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoonLabel;

  /// No description provided for @revenueLabel.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenueLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// No description provided for @staffIdPrefix.
  ///
  /// In en, this message translates to:
  /// **'Staff ID: '**
  String get staffIdPrefix;

  /// No description provided for @offerRevenueDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer Revenue Details'**
  String get offerRevenueDetailsTitle;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get noDescriptionAvailable;

  /// No description provided for @offerClaimDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer Claim Details'**
  String get offerClaimDetailsTitle;

  /// No description provided for @noUsageDataFound.
  ///
  /// In en, this message translates to:
  /// **'No usage data found'**
  String get noUsageDataFound;

  /// No description provided for @unlimitedLabel.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimitedLabel;

  /// No description provided for @usedLabel.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get usedLabel;

  /// No description provided for @staffRevenueTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff Revenue'**
  String get staffRevenueTitle;

  /// No description provided for @staffAppointmentDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff Appointment Details'**
  String get staffAppointmentDetailsTitle;

  /// No description provided for @appsLabel.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get appsLabel;

  /// No description provided for @totalClientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Total Clients'**
  String get totalClientsTitle;

  /// No description provided for @totalServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Total Services'**
  String get totalServicesTitle;

  /// No description provided for @employeesTitle.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get employeesTitle;

  /// No description provided for @appointmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get appointmentTitle;

  /// No description provided for @noBookingsFound.
  ///
  /// In en, this message translates to:
  /// **'No bookings found'**
  String get noBookingsFound;

  /// No description provided for @scheduledTab.
  ///
  /// In en, this message translates to:
  /// **'SCHEDULED'**
  String get scheduledTab;

  /// No description provided for @cancelledTab.
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get cancelledTab;

  /// No description provided for @completedTab.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get completedTab;

  /// No description provided for @markAppointmentCompleteHint.
  ///
  /// In en, this message translates to:
  /// **'To Mark appointment as complete connect with the staff'**
  String get markAppointmentCompleteHint;

  /// No description provided for @noAppointmentsFound.
  ///
  /// In en, this message translates to:
  /// **'No appointments found'**
  String get noAppointmentsFound;

  /// No description provided for @scheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'SCHEDULE'**
  String get scheduleTitle;

  /// No description provided for @cancellationReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Reason'**
  String get cancellationReasonTitle;

  /// No description provided for @enterCancellationReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Enter reason for cancellation'**
  String get enterCancellationReasonHint;

  /// No description provided for @cancelAppointmentBtn.
  ///
  /// In en, this message translates to:
  /// **'CANCEL APPOINTMENT'**
  String get cancelAppointmentBtn;

  /// No description provided for @appointmentCancelledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Appointment cancelled!'**
  String get appointmentCancelledSuccess;

  /// No description provided for @assignNewStaffTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign New Staff'**
  String get assignNewStaffTitle;

  /// No description provided for @staffAssignedToPrefix.
  ///
  /// In en, this message translates to:
  /// **'Staff assigned to '**
  String get staffAssignedToPrefix;

  /// No description provided for @successfullySuffix.
  ///
  /// In en, this message translates to:
  /// **' successfully'**
  String get successfullySuffix;

  /// No description provided for @billToOptionalTitle.
  ///
  /// In en, this message translates to:
  /// **'BILL TO (OPTIONAL)'**
  String get billToOptionalTitle;

  /// No description provided for @searchByNameNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Search By Name, Number'**
  String get searchByNameNumberHint;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountHint;

  /// No description provided for @discountHint.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discountHint;

  /// No description provided for @taxesHint.
  ///
  /// In en, this message translates to:
  /// **'Taxes'**
  String get taxesHint;

  /// No description provided for @invoiceNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'INVOICE NOTE'**
  String get invoiceNoteTitle;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteHint;

  /// No description provided for @createInvoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'CREATE INVOICE'**
  String get createInvoiceTitle;

  /// No description provided for @amountPayableTitle.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT PAYABLE'**
  String get amountPayableTitle;

  /// No description provided for @invoiceGeneratedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Invoice generated Successful'**
  String get invoiceGeneratedSuccess;

  /// No description provided for @shareInvoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Share this with your customer'**
  String get shareInvoiceHint;

  /// No description provided for @selectServiceHint.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get selectServiceHint;

  /// No description provided for @presentEmployeesTitle.
  ///
  /// In en, this message translates to:
  /// **'Present Employees'**
  String get presentEmployeesTitle;

  /// No description provided for @totalEmployeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Total Employee'**
  String get totalEmployeeTitle;

  /// No description provided for @onLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'On Leave'**
  String get onLeaveTitle;

  /// No description provided for @attendanceTitle.
  ///
  /// In en, this message translates to:
  /// **'ATTENDANCE'**
  String get attendanceTitle;

  /// No description provided for @totalAttendanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Total Attendance'**
  String get totalAttendanceTitle;

  /// No description provided for @staffNameHint.
  ///
  /// In en, this message translates to:
  /// **'Staff Name'**
  String get staffNameHint;

  /// No description provided for @dateTitle.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get dateTitle;

  /// No description provided for @monShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monShort;

  /// No description provided for @tueShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tueShort;

  /// No description provided for @wedShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wedShort;

  /// No description provided for @thuShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thuShort;

  /// No description provided for @friShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friShort;

  /// No description provided for @satShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get satShort;

  /// No description provided for @sunShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunShort;

  /// No description provided for @totalHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Hours'**
  String get totalHoursLabel;

  /// No description provided for @presentLabel.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get presentLabel;

  /// No description provided for @daysLabel.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get daysLabel;

  /// No description provided for @leavesLabel.
  ///
  /// In en, this message translates to:
  /// **'Leaves'**
  String get leavesLabel;

  /// No description provided for @paidLeaveLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid Leave'**
  String get paidLeaveLabel;

  /// No description provided for @halfDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Half day'**
  String get halfDayLabel;

  /// No description provided for @sickLeaveLabel.
  ///
  /// In en, this message translates to:
  /// **'Sick Leave'**
  String get sickLeaveLabel;

  /// No description provided for @casualLeaveLabel.
  ///
  /// In en, this message translates to:
  /// **'Casual Leave'**
  String get casualLeaveLabel;

  /// No description provided for @inventoryUsedTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory Used'**
  String get inventoryUsedTitle;

  /// No description provided for @itemTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Item type'**
  String get itemTypeLabel;

  /// No description provided for @toolsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get toolsLabel;

  /// No description provided for @shampooLabel.
  ///
  /// In en, this message translates to:
  /// **'Shampoo'**
  String get shampooLabel;

  /// No description provided for @returnLabel.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnLabel;

  /// No description provided for @notAvailableText.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailableText;

  /// No description provided for @memberSincePrefix.
  ///
  /// In en, this message translates to:
  /// **'Member Since '**
  String get memberSincePrefix;

  /// No description provided for @appointmentHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointment History'**
  String get appointmentHistoryTitle;

  /// No description provided for @noHistoryAvailable.
  ///
  /// In en, this message translates to:
  /// **'No history available'**
  String get noHistoryAvailable;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get historyTitle;

  /// No description provided for @visitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get visitsLabel;

  /// No description provided for @lastVisitLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Visit'**
  String get lastVisitLabel;

  /// No description provided for @noServicesText.
  ///
  /// In en, this message translates to:
  /// **'No Services'**
  String get noServicesText;

  /// No description provided for @staffAssignmentsPrefix.
  ///
  /// In en, this message translates to:
  /// **'Staff Assignments - '**
  String get staffAssignmentsPrefix;

  /// No description provided for @noStaffAssignedItem.
  ///
  /// In en, this message translates to:
  /// **'No staff assigned to this item yet'**
  String get noStaffAssignedItem;

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown Date'**
  String get unknownDate;

  /// No description provided for @unknownStaff.
  ///
  /// In en, this message translates to:
  /// **'Unknown Staff'**
  String get unknownStaff;

  /// No description provided for @assignedByPrefix.
  ///
  /// In en, this message translates to:
  /// **'Assigned by: '**
  String get assignedByPrefix;

  /// No description provided for @systemLabel.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemLabel;

  /// No description provided for @reassignTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reassign / Update Usage'**
  String get reassignTooltip;

  /// No description provided for @allocatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Allocated'**
  String get allocatedLabel;

  /// No description provided for @remainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remainingLabel;

  /// No description provided for @appointmentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointmentsLabel;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes:'**
  String get notesLabel;

  /// No description provided for @assignedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Assigned: '**
  String get assignedPrefix;

  /// No description provided for @viewUsageBtn.
  ///
  /// In en, this message translates to:
  /// **'View Usage'**
  String get viewUsageBtn;

  /// No description provided for @updateAssignmentPrefix.
  ///
  /// In en, this message translates to:
  /// **'Update Assignment - '**
  String get updateAssignmentPrefix;

  /// No description provided for @totalUsedQuantity.
  ///
  /// In en, this message translates to:
  /// **'Total Used Quantity'**
  String get totalUsedQuantity;

  /// No description provided for @newTotalAllocatedQuantity.
  ///
  /// In en, this message translates to:
  /// **'New Total Allocated Quantity'**
  String get newTotalAllocatedQuantity;

  /// No description provided for @enterTotalQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'Enter total quantity'**
  String get enterTotalQuantityHint;

  /// No description provided for @notesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesTitle;

  /// No description provided for @updateNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Update notes...'**
  String get updateNotesHint;

  /// No description provided for @assignmentUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Assignment updated successfully'**
  String get assignmentUpdatedSuccess;

  /// No description provided for @noApprovedRequests.
  ///
  /// In en, this message translates to:
  /// **'No Approved Requests'**
  String get noApprovedRequests;

  /// No description provided for @leaveRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'LEAVE REQUEST'**
  String get leaveRequestTitle;

  /// No description provided for @pendingTab.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get pendingTab;

  /// No description provided for @approvedTab.
  ///
  /// In en, this message translates to:
  /// **'APPROVED'**
  String get approvedTab;

  /// No description provided for @leaveTypePaid.
  ///
  /// In en, this message translates to:
  /// **'Leave Type - Paid'**
  String get leaveTypePaid;

  /// No description provided for @durationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Duration : 01-04-2026 To 02-04-2026'**
  String get durationPlaceholder;

  /// No description provided for @emailSupportError.
  ///
  /// In en, this message translates to:
  /// **'Could not open email client. Please email jeevan.j@neopaceinfotech.com.'**
  String get emailSupportError;

  /// No description provided for @dialerSupportError.
  ///
  /// In en, this message translates to:
  /// **'Could not open dialer. Please call 9119591956 directly.'**
  String get dialerSupportError;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get supportTitle;

  /// No description provided for @supportHelpText.
  ///
  /// In en, this message translates to:
  /// **'We’re here to help you every step of the way.'**
  String get supportHelpText;

  /// No description provided for @emailSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupportTitle;

  /// No description provided for @phoneSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone Support'**
  String get phoneSupportTitle;

  /// No description provided for @workingHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHoursTitle;

  /// No description provided for @workingHoursValue.
  ///
  /// In en, this message translates to:
  /// **'10 am to 7pm'**
  String get workingHoursValue;

  /// No description provided for @supportFooterText.
  ///
  /// In en, this message translates to:
  /// **'We aim to provide fast, reliable, and friendly support to ensure your experience with Neo Parlour is always smooth and hassle-free.'**
  String get supportFooterText;

  /// No description provided for @noPendingFeedback.
  ///
  /// In en, this message translates to:
  /// **'No Pending Feedback Found'**
  String get noPendingFeedback;

  /// No description provided for @noApprovedFeedback.
  ///
  /// In en, this message translates to:
  /// **'No Approved Feedback Found'**
  String get noApprovedFeedback;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'FEEDBACK'**
  String get feedbackTitle;

  /// No description provided for @customerPrefix.
  ///
  /// In en, this message translates to:
  /// **'Customer #'**
  String get customerPrefix;

  /// No description provided for @feedbackRejectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Feedback rejected successfully!'**
  String get feedbackRejectedSuccess;

  /// No description provided for @feedbackApprovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Feedback approved successfully!'**
  String get feedbackApprovedSuccess;

  /// No description provided for @mainSalonImageLabel.
  ///
  /// In en, this message translates to:
  /// **'MAIN SALON IMAGE'**
  String get mainSalonImageLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
