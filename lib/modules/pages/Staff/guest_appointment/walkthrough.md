# Walkthrough - Guest Appointments Booking Flow for Staff

We have successfully implemented the **Guest Appointments** booking flow for the staff flow in the NeoParlour Business application. This multi-screen flow allows staff members to book walk-in appointments for guest customers.

## Changes Made

### Core Models

#### [NEW] [available_slot.dart](file:///Users/pratikghodke/Desktop/NeoParlour/neo_parlour_owner%205/lib/data/models/available_slot.dart)
- Created the `AvailableSlot` class representing a time slot with `startTime` and `displayTime`.

### Guest Appointment Workflow Screens

All files are placed under the subdirectory `lib/modules/pages/Staff/guest_appointment/`:

#### [NEW] [guest_booking_state.dart](file:///Users/pratikghodke/Desktop/NeoParlour/neo_parlour_owner%205/lib/modules/pages/Staff/guest_appointment/guest_booking_state.dart)
- Model/State manager tracking selections (selected services, date, slot, staff, customer info, weekday discounts) throughout the screens.

#### [NEW] [guest_select_services_screen.dart](file:///Users/pratikghodke/Desktop/NeoParlour/neo_parlour_owner%205/lib/modules/pages/Staff/guest_appointment/guest_select_services_screen.dart)
- Multi-select services grouped under categories (e.g. Hair, Skin Care, Grooming, Nails) with chips. Shows selection summary inside a bottom bar.

#### [NEW] [guest_select_date_time_screen.dart](file:///Users/pratikghodke/Desktop/NeoParlour/neo_parlour_owner%205/lib/modules/pages/Staff/guest_appointment/guest_select_date_time_screen.dart)
- Horizontal calendar date selector for the next 7 days. Fetches available slots for the selected date from `appointments/salon-slots` and renders them in a grid.
- **Staff Bypass**: When the user selects a slot and taps "Next", it navigates directly to the review and confirmation screen, automatically assigning the logged-in staff member to the appointment.

#### [NEW] [guest_review_confirm_screen.dart](file:///Users/pratikghodke/Desktop/NeoParlour/neo_parlour_owner%205/lib/modules/pages/Staff/guest_appointment/guest_review_confirm_screen.dart)
- Finalizes booking details. Includes input text fields for Customer Name and Mobile Number with 10-digit validation.
- Formats the `appointmentAt` date-time field to include the timezone offset (e.g. `+05:30`) to match backend expectations and prevent 400 Bad Request errors.
- Computes prices dynamically (Subtotal, Weekday Discount if Monday-Friday, and Final Amount).
- Sends the POST request to `/api/appointments/walk-in` containing the logged-in staff member's ID and name.

### Global IST Timezone Serialization Updates
- **[offer_model.dart](file:///Users/pratikghodke/Desktop/NeoParlour/neo_parlour_owner%205/lib/data/models/offer_model.dart)**: Updated `validFrom` and `validTo` serialization to use `DateTimeUtils.toIstIsoString(...)` instead of converting to UTC before sending.
- **[owner_home_screen.dart](file:///Users/pratikghodke/Desktop/NeoParlour/neo_parlour_owner%205/lib/modules/pages/Owner/owner_home_screen.dart)**: Formatted appointment time using `DateTimeUtils.toIstIsoString(...)` for fetching available staff.
- **[schedule_screen.dart](file:///Users/pratikghodke/Desktop/NeoParlour/neo_parlour_owner%205/lib/modules/pages/Owner/schedule_screen.dart)**: Formatted appointment time using `DateTimeUtils.toIstIsoString(...)` in staff assignment dialog.
- **[attendance_model.dart](file:///Users/pratikghodke/Desktop/NeoParlour/neo_parlour_owner%205/lib/data/models/attendance_model.dart)**: Updated check-in, check-out, attendance date, and leave request start/end date serialization to use `DateTimeUtils.toIstIsoString(...)`.
- **[appointment_response.dart](file:///Users/pratikghodke/Desktop/NeoParlour/neo_parlour_owner%205/lib/data/models/appointment_response.dart)**: Standardized appointment dates (appointmentAt, createdAt, updatedAt) to serialize using `DateTimeUtils.toIstIsoString(...)`.

#### [NEW] [guest_appointment_success_screen.dart](file:///Users/pratikghodke/Desktop/NeoParlour/neo_parlour_owner%205/lib/modules/pages/Staff/guest_appointment/guest_appointment_success_screen.dart)
- Shows confirmation and a "Back to Home" button that uses `pushAndRemoveUntil` to navigate back to the `HomeStaffScreen` session directly, preventing it from showing the login or splash screen.

### Navigation integration

#### [MODIFY] [staff_home_screen.dart](file:///Users/pratikghodke/Desktop/NeoParlour/neo_parlour_owner%205/lib/modules/pages/Staff/staff_home_screen.dart)
- Added the "Guest Appointments" button (Rectangle 3227) in the staff home screen before "Leave Request" and "Inventory".
- Added a navigation handler that fetches the salon profile first to obtain `weekdayDiscountPercent`, initializes `GuestBookingState` with the logged-in staff member's ID and name, and pushes the select services screen.
- Added a row of **"Start Appointment"** and **"End Appointment"** buttons (Rectangle 3224 figma spec) inside a light pink container right below the Attendance Check In/Out section.
- **Start Appointment**: Styled in solid green (`#4CAF50`). If an appointment is already started (`STARTED` or `IN_PROGRESS`), the button is disabled and greyed out to prevent starting multiple appointments concurrently. On tap, triggers the PUT `appointments/{id}/start` API for the first booked/rescheduled appointment. Debounced using `_isStarting` state variable.
- **End Appointment**: Styled in solid red (`#FF0B01`). Disabled and greyed out unless an appointment has been started (`STARTED` or `IN_PROGRESS`). On tap, opens the Complete Appointment inventory dialog.
- Standardized appointment card actions to display cancellation and completion options when in `STARTED` or `IN_PROGRESS` status.

#### [MODIFY] [appointment_service.dart](file:///Users/pratikghodke/Desktop/NeoParlour/neo_parlour_owner%205/lib/data/services/appointment_service.dart)
- Added `startAppointment(int appointmentId)` sending a PUT request to `appointments/$appointmentId/start`.

- Added `startAppointment({required int appointmentId, int? staffId})` to trigger the start service and refresh upcoming appointments locally.
- Updated `fetchUpcomingAppointments`, `fetchMoreUpcomingAppointments`, and `goToPage` to use the start of today as `fromDate` instead of the current exact time, preventing active/started appointments from being filtered out because their start time has passed.
- Implemented parallel fetching for both `booked` and `in_progress` statuses when the requested status is `null`, merging and sorting the results. This overrides the backend's default behavior of only returning `booked` appointments when no status is requested. Changed the query status parameter value from `started` to `in_progress` to match the exact enum values supported by the backend, resolving `400 Bad Request` errors.

#### [MODIFY] [staff_home_screen.dart](file:///Users/pratikghodke/Desktop/NeoParlour/neo_parlour_owner%205/lib/modules/pages/Staff/staff_home_screen.dart)
- Updated `PaginationWidget` `onPageSelected` callback to pass `status: null` explicitly, preventing pagination queries from defaulting to booked-only filters.
- Added data refresh capability inside the completion dialog on success.
- Updated all `salonId` extractions across guest bookings, check-in, checkout, reschedule, and cancellation handlers to attempt retrieving `authProvider.user.salonId` first with a fallback to `int.tryParse(authProvider.user.tenantName)`. This resolves the `404 Salon not found` lookup error during staff sessions, where `tenantName` contains the salon's name string rather than its ID.

#### [MODIFY] [appointment_staff_screen.dart](file:///Users/pratikghodke/Desktop/NeoParlour/neo_parlour_owner%205/lib/modules/pages/Staff/appointment_staff_screen.dart)
- Updated `salonId` extractions across completion, reschedule, and cancellation handlers to use `authProvider.user.salonId` first with fallback to `tenantName` parsing.

#### [MODIFY] [staff_notification_screen.dart](file:///Users/pratikghodke/Desktop/NeoParlour/neo_parlour_owner%205/lib/modules/pages/Staff/staff_notification_screen.dart)
- Updated `salonId` extractions across initialization and pagination fetching to use `authProvider.user.salonId` first.

---

## Verification Results

### Automated Verification
We verified syntax correctness using:
```bash
flutter analyze
```

**Output**:
```text
Analyzing neo_parlour_owner 5...
No issues found!
```
The codebase compiles cleanly with zero warnings or errors.
