// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NeoParlour Partner';

  @override
  String get loginTitle => 'LOGIN';

  @override
  String get loginSubtitle =>
      'Create an account or log in to book and manage your appointments';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithFacebook => 'Continue with Facebook';

  @override
  String get or => 'OR';

  @override
  String get emailAddress => 'Email address';

  @override
  String get continueBtn => 'CONTINUE';

  @override
  String get salonOwnerTab => 'SALON OWNER';

  @override
  String get staffTab => 'STAFF';

  @override
  String get mobileOrEmail => 'Mobile Number or Email';

  @override
  String get password => 'Password';

  @override
  String get iAgreeToThe => 'I agree to the ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get comma => ', ';

  @override
  String get and => ' And ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get iAgreeMarketing =>
      'I agree to receive marketing notifications with offers and news';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get register => 'Register';

  @override
  String get pleaseAcceptAgreements =>
      'Please accept all agreements to continue.';

  @override
  String get pleaseEnterIdAndPassword => 'Please enter both ID and Password';

  @override
  String get validMobileError => 'Please enter a valid 10-digit mobile number';

  @override
  String get otpSentSuccess => 'OTP sent successfully';

  @override
  String get failedToSendOtp => 'Failed to send OTP';

  @override
  String get enterOtpError => 'Please enter the OTP';

  @override
  String get passwordLengthError => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordResetSuccess =>
      'Password reset successfully. Please login.';

  @override
  String get failedToResetPassword => 'Failed to reset password';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get verificationTitle => 'Verification';

  @override
  String get forgotPasswordTitle => 'Forgot Password?';

  @override
  String enterOtpAndNewPassword(String mobile) {
    return 'Enter the OTP sent to $mobile and your new password.';
  }

  @override
  String get enterMobileForOtp =>
      'Enter your registered mobile number to receive an OTP for password reset.';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get resetPasswordBtn => 'RESET PASSWORD';

  @override
  String get sendOtpBtn => 'SEND OTP';

  @override
  String get pleaseEnterAccountAndPassword =>
      'Please enter both Account and Password';

  @override
  String accessDeniedRole(String role) {
    return 'Access Denied: Current role is $role';
  }

  @override
  String get loginFailed => 'Login Failed';

  @override
  String get emailOrMobile => 'Email Or Mobile Number';

  @override
  String get rememberMeNextTime => 'Remember me next time';

  @override
  String get loggingIn => 'Logging in...';

  @override
  String get ownerFullName => 'Owner Full Name';

  @override
  String get securityTab => 'SECURITY';

  @override
  String get createPassword => 'Create a password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get fillMandatoryFields => 'Please fill all mandatory fields';

  @override
  String get mobileNumber10Digits => 'Mobile number must be exactly 10 digits';

  @override
  String get validGmailAddress => 'Please enter a valid Gmail address';

  @override
  String get continueToSalonInfo => 'CONTINUE TO SALON INFO';

  @override
  String get alreadyHaveAccount => 'Already have account? ';

  @override
  String get login => 'Login';

  @override
  String get salonInformation => 'SALON INFORMATION';

  @override
  String get salonName => 'Salon Name';

  @override
  String get address => 'Address';

  @override
  String get fillSalonInfoError => 'Please fill Salon Name, City, and Area';

  @override
  String get uploadMainSalonImageError => 'Please upload a Main Salon Image';

  @override
  String get uploadGalleryImagesError =>
      'Please upload at least 3 Gallery Images';

  @override
  String get continueToKycBtn => 'CONTINUE TO KYC';

  @override
  String get uploadBtn => 'UPLOAD';

  @override
  String get salonGalleryTitle => 'SALON GALLERY';

  @override
  String get min3ImagesRequired => 'AT LEAST 3 IMAGES REQUIRED';

  @override
  String get uploadImageInstructions =>
      'Please upload 1 exterior photo (outside view) and at least 2 interior photos (inside views) of the salon. Max 5MB per image.';

  @override
  String get exteriorView => '1. EXTERIOR VIEW';

  @override
  String get uploadOutsideBtn => 'UPLOAD OUTSIDE';

  @override
  String get interiorView1 => '2. INTERIOR VIEW 1';

  @override
  String get uploadInside1Btn => 'UPLOAD INSIDE 1';

  @override
  String get interiorView2 => '3. INTERIOR VIEW 2';

  @override
  String get uploadInside2Btn => 'UPLOAD INSIDE 2';

  @override
  String get additionalGalleryImages =>
      'ADDITIONAL GALLERY IMAGES (OPTIONAL - MAX 2)';

  @override
  String get backBtn => 'BACK';

  @override
  String get openingTime => 'Opening Time';

  @override
  String get closingTime => 'Closing Time';

  @override
  String get salonMedia => 'SALON MEDIA';

  @override
  String get notUploaded => 'NOT UPLOADED';

  @override
  String get removeBtn => 'REMOVE';

  @override
  String get uploadFileBtn => 'UPLOAD FILE';

  @override
  String get kycVerification => 'KYC VERIFICATION';

  @override
  String get atLeast1DocRequired => 'AT LEAST 1 DOCUMENT REQUIRED';

  @override
  String get kycInstructions =>
      'Please upload at least one valid identity or business document for KYC verification purpose. Max 5MB. Accepted formats: Image/PDF.';

  @override
  String get aadhaarGovtId => 'Aadhaar / Government ID';

  @override
  String get panCard => 'PAN Card';

  @override
  String get shopEstLicense => 'Shop & Est. License';

  @override
  String get bankAccountProof => 'Bank Account Proof';

  @override
  String get iAgreeWithThe => 'I agree with the ';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get pleaseAcceptTerms => 'Please accept Terms of Use';

  @override
  String get pleaseUpload1KycDoc => 'Please upload at least 1 KYC document.';

  @override
  String get ownerAndSalonRegistration => 'OWNER & SALON REGISTRATION';

  @override
  String get errorPrefix => 'Error: ';

  @override
  String get couldNotRetrieveFileContent => 'Could not retrieve file content.';

  @override
  String get errorPickingFile => 'Error picking file: ';

  @override
  String get errorTakingPhoto => 'Error taking photo: ';

  @override
  String get selectDocumentSource => 'Select Document Source';

  @override
  String get uploadFromGallery => 'Upload from Gallery / Files';

  @override
  String get selectImageOrPdf => 'Select image or PDF document';

  @override
  String get takeAPhoto => 'Take a Photo';

  @override
  String get captureUsingCamera => 'Capture using device camera';

  @override
  String get cityTitle => 'City';

  @override
  String get areaTitle => 'Area';

  @override
  String get searchCity => 'Search City';

  @override
  String get searchArea => 'Search Area';

  @override
  String get ownerDetails => 'OWNER DETAILS';

  @override
  String get stepPersonal => 'PERSONAL';

  @override
  String get stepSalon => 'SALON';

  @override
  String get stepKyc => 'KYC';

  @override
  String get stepOtp => 'OTP';

  @override
  String get otpResentSuccessfully => 'OTP resent successfully';

  @override
  String get failedToResendOtp => 'Failed to resend OTP: ';

  @override
  String get enterFull6DigitOtp => 'Please enter full 6-digit OTP';

  @override
  String get registrationSuccessful => 'Registration Successful';

  @override
  String get accountCreatedPleaseLogin =>
      'Your account has been created. Please login.';

  @override
  String get loginNow => 'LOGIN NOW';

  @override
  String get verificationFailed => 'Verification Failed: ';

  @override
  String get verifyOtpTitle => 'VERIFY OTP';

  @override
  String get sentVerificationCodeTo =>
      'We sent a verification code to your\nmobile number ';

  @override
  String get verifyBtn => 'VERIFY';

  @override
  String get uploadingRegistrationPhotosPleaseWait =>
      'Uploading photos and setting up your salon account, please wait...';

  @override
  String get didntReceiveOtp => 'Didn\'t receive OTP? ';

  @override
  String get resendOtpBtn => 'Resend OTP';

  @override
  String get resendIn => 'Resend in ';

  @override
  String get failedToLoadPlans => 'Failed to load plans: ';

  @override
  String get failedToOpenPricingPortal => 'Failed to open pricing portal: ';

  @override
  String get skipForNow => 'Skip For Now';

  @override
  String get whatYouCanGet => 'What You Can Get?';

  @override
  String get staffManagement => 'Staff Management';

  @override
  String get inventoryManagement => 'Inventory Management';

  @override
  String get subscribeOnWebsite => 'SUBSCRIBE ON WEBSITE';

  @override
  String get appointmentRescheduled => 'Appointment rescheduled successfully';

  @override
  String get cancelAppointmentTitle => 'Cancel Appointment';

  @override
  String get enterCancelReason => 'Enter cancellation reason...';

  @override
  String get appointmentCancelled => 'Appointment cancelled successfully';

  @override
  String get selectStaff => 'Select Staff';

  @override
  String get noStaffAvailable => 'No staff available';

  @override
  String get staffAssignedSuccessfully => 'Staff assigned successfully';

  @override
  String get welcomePrefix => 'WELCOME ';

  @override
  String get ownerDefaultName => 'Owner';

  @override
  String get todayOverview => 'TODAY OVERVIEW';

  @override
  String get weeklyOverview => 'WEEKLY OVERVIEW';

  @override
  String get monthlyOverview => 'MONTHLY OVERVIEW';

  @override
  String get yearlyOverview => 'YEARLY OVERVIEW';

  @override
  String get filterToday => 'Today';

  @override
  String get filterWeekly => 'Weekly';

  @override
  String get filterMonthly => 'Monthly';

  @override
  String get filterYearly => 'Yearly';

  @override
  String get statRevenue => 'Revenue';

  @override
  String get statBookings => 'Bookings';

  @override
  String get statOfferUsage => 'Offer Usage';

  @override
  String get statCompleted => 'Completed';

  @override
  String get statCancelled => 'Cancelled';

  @override
  String get statRescheduled => 'Rescheduled';

  @override
  String get totalFor => 'Total for ';

  @override
  String get countFor => 'Count for ';

  @override
  String get usedPeriod => 'Used ';

  @override
  String get totalPeriod => 'Total ';

  @override
  String get upcomingAppointments => 'UPCOMING APPOINTMENTS';

  @override
  String get noUpcomingAppointments => 'No upcoming appointments';

  @override
  String get staffPrefix => 'Staff: ';

  @override
  String get viewDetails => 'View details';

  @override
  String get cancelReasonPrefix => 'Cancel Reason: ';

  @override
  String get ownerRescheduleReasonPrefix => 'Owner Reschedule Reason: ';

  @override
  String get customerRescheduleReasonPrefix => 'Customer Reschedule Reason: ';

  @override
  String get rescheduleBtn => 'RESCHEDULE';

  @override
  String get cancelBtn => 'CANCEL';

  @override
  String get assignStaffBtn => 'ASSIGN STAFF';

  @override
  String get splashOneTop => 'Your';

  @override
  String get splashOneMid => 'EXCLUSIVE SALON';

  @override
  String get splashOneBottom => 'Management App';

  @override
  String get splashTwoTop => 'Your';

  @override
  String get splashTwoMid => 'PARLOUR';

  @override
  String get splashTwoBottom => 'Platter';

  @override
  String get splashThreeTop => 'Smart Salon';

  @override
  String get splashThreeMid => 'SEAMLESS';

  @override
  String get splashThreeBottom => 'Experience';

  @override
  String get skipSplash => 'Skip';

  @override
  String get changeMobileNumber => 'Change Mobile Number';

  @override
  String get versionFooter => 'Version 1.0.0 | Powered By Neopaceinfotech LLP';

  @override
  String get maintenanceInProgressToast =>
      'Server maintenance is still in progress. Please check again in a few minutes.';

  @override
  String get maintenanceNoInternetToast =>
      'Unable to reach server. Please check your internet connection.';

  @override
  String get maintenanceTitle => 'Partner Portal Under Maintenance';

  @override
  String get maintenanceSafeMessage =>
      'Your salon records, appointment schedules, and staff data are safe and secure.';

  @override
  String get maintenanceEstimatedCompletion => 'Estimated Completion: ';

  @override
  String get checkingStatus => 'Checking Status...';

  @override
  String get checkSystemStatus => 'Check System Status';

  @override
  String get drawerProfile => 'Profile';

  @override
  String get drawerAboutUs => 'About Us';

  @override
  String get drawerSupport => 'Support';

  @override
  String get drawerMyBookings => 'My Bookings';

  @override
  String get drawerSubscription => 'Subscription';

  @override
  String get drawerChangePassword => 'Change Password';

  @override
  String get drawerLogout => 'LOGOUT';

  @override
  String get drawerPoweredBy => 'Powered By Neopaceinfotech LLP';

  @override
  String get navAnalytics => 'ANALYTICS';

  @override
  String get navManage => 'MANAGE';

  @override
  String get navNotification => 'NOTIFICATION';

  @override
  String get navSetting => 'SETTING';

  @override
  String get manageTitle => 'MANAGE';

  @override
  String get manageSchedule => 'Schedule';

  @override
  String get manageService => 'Service';

  @override
  String get manageInventory => 'Inventory';

  @override
  String get manageStaff => 'Staff';

  @override
  String get manageFeedback => 'Feedback';

  @override
  String get manageHomeServices => 'Home Services';

  @override
  String get manageSubscription => 'Subscription';

  @override
  String get manageAddOffers => 'Add Offers';

  @override
  String get manageAddProducts => 'Add Products';

  @override
  String get manageAddPackages => 'Add Packages';

  @override
  String get drawerMyReferrals => 'My Referrals';

  @override
  String get drawerLeaveRequest => 'Leave Request';

  @override
  String get drawerInventory => 'Inventory';

  @override
  String get changePasswordTitle => 'CHANGE PASSWORD';

  @override
  String get pleaseEnterNewPassword => 'Please Enter A New Password';

  @override
  String get enterCurrentPassword => 'Enter Current Password';

  @override
  String get createNewPassword => 'Create New Password';

  @override
  String get submitBtn => 'SUBMIT';

  @override
  String get editProfileTitle => 'EDIT PROFILE';

  @override
  String get editBtn => 'EDIT';

  @override
  String get ownerProfileTab => 'OWNER PROFILE';

  @override
  String get staffProfileTab => 'STAFF PROFILE';

  @override
  String get salonProfileTab => 'SALON PROFILE';

  @override
  String get personalDetails => 'Personal Details';

  @override
  String get fullName => 'Full Name';

  @override
  String get dob => 'Date Of Birth';

  @override
  String get contactInfo => 'Contact Info';

  @override
  String get salonDetails => 'Salon Details';

  @override
  String get salonCode => 'Salon Code';

  @override
  String get salonPhone => 'Salon Phone';

  @override
  String get businessHours => 'Business Hours & Fees';

  @override
  String get homeServiceCharges => 'Home Service Charges (₹)';

  @override
  String get salonQrCodeTitle => 'SALON QR CODE';

  @override
  String get downloadQr => 'DOWNLOAD QR';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get saveChanges => 'SAVE CHANGES';

  @override
  String get selectGender => 'Select Gender';

  @override
  String get mySubscriptionsTitle => 'MY SUBSCRIPTIONS';

  @override
  String get noSubscriptionsFound => 'No subscriptions found.';

  @override
  String get planLabel => 'Plan:';

  @override
  String get startDateLabel => 'Start Date';

  @override
  String get endDateLabel => 'End Date';

  @override
  String get paymentIdLabel => 'Payment ID:';

  @override
  String get downloadInvoiceBtn => 'DOWNLOAD INVOICE';

  @override
  String get downloadingInvoiceMsg => 'Downloading invoice...';

  @override
  String get invoiceDownloadedMsg => 'Invoice downloaded successfully!';

  @override
  String get failedDownloadInvoiceMsg => 'Failed to download invoice:';

  @override
  String get aboutUsTitle => 'ABOUT US';

  @override
  String get aboutNeoParlour => 'About Neo Parlour';

  @override
  String get aboutNeoParlourP1 =>
      'Neo Parlour is a smart salon management application built to simplify the way salons operate. We understand that managing a salon involves juggling multiple tasks—appointment bookings, inventory tracking, and staff coordination—all at the same time. These everyday challenges can create confusion and take focus away from what truly matters: growing your business and serving your customers.';

  @override
  String get aboutNeoParlourP2 => 'That’s where Neo Parlour comes in.';

  @override
  String get aboutNeoParlourP3 =>
      'Our platform brings everything together in one place, allowing salon owners to efficiently manage appointments, monitor inventory, and organize staff schedules with ease. By reducing manual work and minimizing errors, Neo Parlour helps bring clarity, structure, and control to your daily operations.';

  @override
  String get notificationsTab => 'Notifications';

  @override
  String get birthdaysTab => 'Birthdays';

  @override
  String get requestsTab => 'Requests';

  @override
  String get ordersTab => 'Orders';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get noBirthdaysFound => 'No Birthdays found !';

  @override
  String get noPendingRequests => 'No pending requests';

  @override
  String get swapRequestsHeader => 'SWAP REQUESTS';

  @override
  String get leaveRequestsHeader => 'LEAVE REQUESTS';

  @override
  String get approveBtn => 'APPROVE';

  @override
  String get rejectBtn => 'REJECT';

  @override
  String get searchByNameOrMobile => 'Search by Name or Mobile...';

  @override
  String get filterAll => 'All';

  @override
  String get filterOrdered => 'Ordered';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get filterCancelled => 'Cancelled';

  @override
  String get noProductRequestsFound => 'No product requests found';

  @override
  String get totalAmountLabel => 'Total Amount';

  @override
  String get serviceListTab => 'Service List';

  @override
  String get addServiceTab => 'Add Service';

  @override
  String get servicesTitle => 'Services';

  @override
  String get servicesSubtitle =>
      'Manage your salon services and preview how customers see them.';

  @override
  String get editingServiceTitle => 'EDITING SERVICE';

  @override
  String get addNewServiceTitle => 'ADD NEW SERVICE';

  @override
  String get cancelEditBtn => 'Cancel Edit';

  @override
  String get categoryLabel => 'Category';

  @override
  String get typeCustomCategory => 'Type Custom Category';

  @override
  String get selectPreloadedBtn => 'Select Preloaded';

  @override
  String get selectServiceNameLabel => 'Select Service Name';

  @override
  String get serviceNameLabel => 'Service Name';

  @override
  String get selectCategoryFirst => 'Select a category first';

  @override
  String get genderLabel => 'Gender';

  @override
  String get priceLabel => 'Price';

  @override
  String get durationMinLabel => 'Duration (min)';

  @override
  String get updateBtn => 'UPDATE';

  @override
  String get saveBtn => 'SAVE';

  @override
  String get serviceListPreviewTitle => 'Service List (Customer Preview)';

  @override
  String get serviceListPreviewSubtitle =>
      'Preview how customers will see your services.';

  @override
  String get manageServicesTitle => 'Manage Services';

  @override
  String get reorderBtn => 'Reorder';

  @override
  String get reorderHint => 'Hold and drag services to change display order.';

  @override
  String get noServicesFound => 'No services found.';

  @override
  String get addProductTab => 'ADD PRODUCT';

  @override
  String get productListTab => 'PRODUCT LIST';

  @override
  String get productsTitle => 'PRODUCTS';

  @override
  String get editingProductTitle => 'EDITING PRODUCT';

  @override
  String get addProductsTitle => 'ADD PRODUCTS';

  @override
  String get mainProductImage => 'Main Product Image';

  @override
  String get additionalImages => 'Additional Images';

  @override
  String get cameraBtn => 'Camera';

  @override
  String get galleryBtn => 'Gallery';

  @override
  String get productNameLabel => 'Product Name';

  @override
  String get productTypeLabel => 'Product Type';

  @override
  String get productDescriptionLabel => 'Product Description';

  @override
  String get stockLabel => 'Stock';

  @override
  String get restockLevelLabel => 'Restock Level';

  @override
  String get discountPriceLabel => 'Discount Price';

  @override
  String get productUpdatedMsg => 'Product updated successfully!';

  @override
  String get productAddedMsg => 'Product added successfully!';

  @override
  String get noProductsFound => 'No products found.';

  @override
  String get activeBadge => 'ACTIVE';

  @override
  String get inactiveBadge => 'INACTIVE';

  @override
  String get addPackageTab => 'ADD PACKAGE';

  @override
  String get packageListTab => 'PACKAGE LIST';

  @override
  String get packagesTitle => 'PACKAGES';

  @override
  String get editingPackageTitle => 'EDITING PACKAGE';

  @override
  String get addNewPackageTitle => 'ADD NEW PACKAGE';

  @override
  String get packageNameLabel => 'Package Name';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get packagePriceLabel => 'Package Price';

  @override
  String get usageLimitPerCustomerLabel => 'Usage Limit Per Customer';

  @override
  String get totalUsageLimitLabel => 'Total Usage Limit';

  @override
  String get selectServicesLabel => 'SELECT SERVICES';

  @override
  String get tapToAddServices => 'Tap to add services';

  @override
  String servicesSelectedCount(int count) {
    return '$count services selected';
  }

  @override
  String get savePackageBtn => 'SAVE PACKAGE';

  @override
  String get selectServicesTitle => 'Select Services';

  @override
  String get noPackagesFound => 'No packages found.';

  @override
  String get perCustLabel => 'Per Cust: ';

  @override
  String get limitLabel => 'Limit: ';

  @override
  String get claimedOfferTitle => 'Claimed Offer';

  @override
  String get offerRevenueTitle => 'Offer Revenue';

  @override
  String get bookingViaOffersTitle => 'Booking Via Offers';

  @override
  String get newCustomersViaOffersTitle => 'New Customers Via Offers';

  @override
  String get viewDetailsBtn => 'View Details';

  @override
  String get allBookingsTitle => 'ALL BOOKINGS';

  @override
  String get offerTitle => 'OFFER';

  @override
  String get offersTitle => 'OFFERS';

  @override
  String get editingOfferTitle => 'EDITING OFFER';

  @override
  String get createNewOfferTitle => 'CREATE NEW OFFER';

  @override
  String get offerNameLabel => 'Offer Name';

  @override
  String get descriptionOptionalLabel => 'Description (Optional)';

  @override
  String get percentageOffLabel => 'Percentage Off (%)';

  @override
  String get fixedDiscountLabel => 'Fixed Discount Amount';

  @override
  String get limitPerCustomerLabel => 'Limit Per Customer';

  @override
  String get validFromLabel => 'Valid From';

  @override
  String get validToLabel => 'Valid To';

  @override
  String get applicableServicesLabel => 'Applicable Services';

  @override
  String get createOfferBtn => 'CREATE OFFER';

  @override
  String get existingOffersTitle => 'EXISTING OFFERS';

  @override
  String get noOffersFound => 'No offers created yet.';

  @override
  String get totalLimitLabel => 'Total Limit: ';

  @override
  String get addStaffTab => 'ADD STAFF';

  @override
  String get staffListTab => 'STAFF LIST';

  @override
  String get staffTitle => 'STAFF';

  @override
  String get selectImageSourceTitle => 'Select Image Source';

  @override
  String get cameraLabel => 'Camera';

  @override
  String get galleryLabel => 'Gallery';

  @override
  String get editingStaffTitle => 'EDITING STAFF';

  @override
  String get addNewStaffTitle => 'ADD NEW STAFF';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get phoneNumberLabel => 'Phone Number';

  @override
  String get emailAddressLabel => 'Email Address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get addressLabel => 'Address';

  @override
  String get birthdateLabel => 'Birthdate';

  @override
  String get manageStaffTitle => 'MANAGE STAFF';

  @override
  String get noStaffFound => 'No staff members found.';

  @override
  String get genderMale => 'MALE';

  @override
  String get genderFemale => 'FEMALE';

  @override
  String get genderOther => 'OTHER';

  @override
  String get addItemsTab => 'ADD ITEMS';

  @override
  String get inventoryDetailsTab => 'INVENTORY DETAILS';

  @override
  String get inventoryTitle => 'INVENTORY';

  @override
  String get itemNameLabel => 'Item Name';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get costLabel => 'Cost';

  @override
  String get categoriesLabel => 'Categories';

  @override
  String get unitTypeLabel => 'Unit Type';

  @override
  String get retryBtn => 'Retry';

  @override
  String get noInventoryItemsFound => 'No inventory items found';

  @override
  String get allCategoriesLabel => 'All Categories';

  @override
  String get qtyLabel => 'Qty - ';

  @override
  String get categoryPrefix => 'Category : ';

  @override
  String get unitPrefix => 'Unit : ';

  @override
  String get costPrefix => 'Cost : ₹';

  @override
  String get reorderPrefix => 'Reorder : ';

  @override
  String get viewAssignedStaffBtn => 'View Assigned Staff';

  @override
  String get assignPrefix => 'Assign ';

  @override
  String get selectStaffMemberTitle => 'Select Staff Member';

  @override
  String get chooseStaffHint => 'Choose Staff';

  @override
  String get allocatedQuantityLabel => 'Allocated Quantity';

  @override
  String get enterQuantityHint => 'Enter quantity';

  @override
  String get notesOptionalLabel => 'Notes (Optional)';

  @override
  String get addNotesHint => 'Add notes...';

  @override
  String get assignActionBtn => 'ASSIGN';

  @override
  String get revenueTab => 'REVENUE';

  @override
  String get offerTab => 'OFFER';

  @override
  String get analyticsTitle => 'ANALYTICS';

  @override
  String get filterCustomRange => 'Custom Range';

  @override
  String get totalRevenueLabel => 'Total Revenue';

  @override
  String get customLabel => 'Custom';

  @override
  String get selectDateHint => 'Select Date';

  @override
  String get revenueTrendsTitle => 'REVENUE TRENDS';

  @override
  String get claimedOfferCard => 'Claimed Offer';

  @override
  String get offerRevenueCard => 'Offer Revenue';

  @override
  String get allOffersTitle => 'ALL OFFERS';

  @override
  String get appointmentsPerStaffCard => 'Appointments Per Staff';

  @override
  String get staffRevenueCard => 'Staff Revenue';

  @override
  String get staffAttendanceTitle => 'STAFF ATTENDANCE';

  @override
  String get noAttendanceRecords => 'No attendance records found.';

  @override
  String get comingSoonLabel => 'Coming Soon';

  @override
  String get revenueLabel => 'Revenue';

  @override
  String get dateLabel => 'Date';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get fromLabel => 'From';

  @override
  String get toLabel => 'To';

  @override
  String get staffIdPrefix => 'Staff ID: ';

  @override
  String get offerRevenueDetailsTitle => 'Offer Revenue Details';

  @override
  String get noDescriptionAvailable => 'No description available';

  @override
  String get offerClaimDetailsTitle => 'Offer Claim Details';

  @override
  String get noUsageDataFound => 'No usage data found';

  @override
  String get unlimitedLabel => 'Unlimited';

  @override
  String get usedLabel => 'Used';

  @override
  String get staffRevenueTitle => 'Staff Revenue';

  @override
  String get staffAppointmentDetailsTitle => 'Staff Appointment Details';

  @override
  String get appsLabel => 'Apps';

  @override
  String get totalClientsTitle => 'Total Clients';

  @override
  String get totalServicesTitle => 'Total Services';

  @override
  String get employeesTitle => 'Employees';

  @override
  String get appointmentTitle => 'Appointment';

  @override
  String get noBookingsFound => 'No bookings found';

  @override
  String get scheduledTab => 'SCHEDULED';

  @override
  String get cancelledTab => 'CANCELLED';

  @override
  String get completedTab => 'COMPLETED';

  @override
  String get markAppointmentCompleteHint =>
      'To Mark appointment as complete connect with the staff';

  @override
  String get noAppointmentsFound => 'No appointments found';

  @override
  String get scheduleTitle => 'SCHEDULE';

  @override
  String get cancellationReasonTitle => 'Cancellation Reason';

  @override
  String get enterCancellationReasonHint => 'Enter reason for cancellation';

  @override
  String get cancelAppointmentBtn => 'CANCEL APPOINTMENT';

  @override
  String get appointmentCancelledSuccess => 'Appointment cancelled!';

  @override
  String get assignNewStaffTitle => 'Assign New Staff';

  @override
  String get staffAssignedToPrefix => 'Staff assigned to ';

  @override
  String get successfullySuffix => ' successfully';

  @override
  String get billToOptionalTitle => 'BILL TO (OPTIONAL)';

  @override
  String get searchByNameNumberHint => 'Search By Name, Number';

  @override
  String get amountHint => 'Amount';

  @override
  String get discountHint => 'Discount';

  @override
  String get taxesHint => 'Taxes';

  @override
  String get invoiceNoteTitle => 'INVOICE NOTE';

  @override
  String get noteHint => 'Note';

  @override
  String get createInvoiceTitle => 'CREATE INVOICE';

  @override
  String get amountPayableTitle => 'AMOUNT PAYABLE';

  @override
  String get invoiceGeneratedSuccess => 'Invoice generated Successful';

  @override
  String get shareInvoiceHint => 'Share this with your customer';

  @override
  String get selectServiceHint => 'Select Service';

  @override
  String get presentEmployeesTitle => 'Present Employees';

  @override
  String get totalEmployeeTitle => 'Total Employee';

  @override
  String get onLeaveTitle => 'On Leave';

  @override
  String get attendanceTitle => 'ATTENDANCE';

  @override
  String get totalAttendanceTitle => 'Total Attendance';

  @override
  String get staffNameHint => 'Staff Name';

  @override
  String get dateTitle => 'DATE';

  @override
  String get monShort => 'Mon';

  @override
  String get tueShort => 'Tue';

  @override
  String get wedShort => 'Wed';

  @override
  String get thuShort => 'Thu';

  @override
  String get friShort => 'Fri';

  @override
  String get satShort => 'Sat';

  @override
  String get sunShort => 'Sun';

  @override
  String get totalHoursLabel => 'Total Hours';

  @override
  String get presentLabel => 'Present';

  @override
  String get daysLabel => 'Days';

  @override
  String get leavesLabel => 'Leaves';

  @override
  String get paidLeaveLabel => 'Paid Leave';

  @override
  String get halfDayLabel => 'Half day';

  @override
  String get sickLeaveLabel => 'Sick Leave';

  @override
  String get casualLeaveLabel => 'Casual Leave';

  @override
  String get inventoryUsedTitle => 'Inventory Used';

  @override
  String get itemTypeLabel => 'Item type';

  @override
  String get toolsLabel => 'Tools';

  @override
  String get shampooLabel => 'Shampoo';

  @override
  String get returnLabel => 'Return';

  @override
  String get notAvailableText => 'N/A';

  @override
  String get memberSincePrefix => 'Member Since ';

  @override
  String get appointmentHistoryTitle => 'Appointment History';

  @override
  String get noHistoryAvailable => 'No history available';

  @override
  String get historyTitle => 'HISTORY';

  @override
  String get visitsLabel => 'Visits';

  @override
  String get lastVisitLabel => 'Last Visit';

  @override
  String get noServicesText => 'No Services';

  @override
  String get staffAssignmentsPrefix => 'Staff Assignments - ';

  @override
  String get noStaffAssignedItem => 'No staff assigned to this item yet';

  @override
  String get unknownDate => 'Unknown Date';

  @override
  String get unknownStaff => 'Unknown Staff';

  @override
  String get assignedByPrefix => 'Assigned by: ';

  @override
  String get systemLabel => 'System';

  @override
  String get reassignTooltip => 'Reassign / Update Usage';

  @override
  String get allocatedLabel => 'Allocated';

  @override
  String get remainingLabel => 'Remaining';

  @override
  String get appointmentsLabel => 'Appointments';

  @override
  String get unitLabel => 'Unit';

  @override
  String get notesLabel => 'Notes:';

  @override
  String get assignedPrefix => 'Assigned: ';

  @override
  String get viewUsageBtn => 'View Usage';

  @override
  String get updateAssignmentPrefix => 'Update Assignment - ';

  @override
  String get totalUsedQuantity => 'Total Used Quantity';

  @override
  String get newTotalAllocatedQuantity => 'New Total Allocated Quantity';

  @override
  String get enterTotalQuantityHint => 'Enter total quantity';

  @override
  String get notesTitle => 'Notes';

  @override
  String get updateNotesHint => 'Update notes...';

  @override
  String get assignmentUpdatedSuccess => 'Assignment updated successfully';

  @override
  String get noApprovedRequests => 'No Approved Requests';

  @override
  String get leaveRequestTitle => 'LEAVE REQUEST';

  @override
  String get pendingTab => 'PENDING';

  @override
  String get approvedTab => 'APPROVED';

  @override
  String get leaveTypePaid => 'Leave Type - Paid';

  @override
  String get durationPlaceholder => 'Duration : 01-04-2026 To 02-04-2026';

  @override
  String get emailSupportError =>
      'Could not open email client. Please email jeevan.j@neopaceinfotech.com.';

  @override
  String get dialerSupportError =>
      'Could not open dialer. Please call 9119591956 directly.';

  @override
  String get supportTitle => 'SUPPORT';

  @override
  String get supportHelpText => 'We’re here to help you every step of the way.';

  @override
  String get emailSupportTitle => 'Email Support';

  @override
  String get phoneSupportTitle => 'Phone Support';

  @override
  String get workingHoursTitle => 'Working Hours';

  @override
  String get workingHoursValue => '10 am to 7pm';

  @override
  String get supportFooterText =>
      'We aim to provide fast, reliable, and friendly support to ensure your experience with Neo Parlour is always smooth and hassle-free.';

  @override
  String get noPendingFeedback => 'No Pending Feedback Found';

  @override
  String get noApprovedFeedback => 'No Approved Feedback Found';

  @override
  String get feedbackTitle => 'FEEDBACK';

  @override
  String get customerPrefix => 'Customer #';

  @override
  String get feedbackRejectedSuccess => 'Feedback rejected successfully!';

  @override
  String get feedbackApprovedSuccess => 'Feedback approved successfully!';

  @override
  String get mainSalonImageLabel => 'MAIN SALON IMAGE';
}
