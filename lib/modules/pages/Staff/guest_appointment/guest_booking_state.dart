import 'package:neo_parlour_owner/data/models/service_model.dart';
import 'package:neo_parlour_owner/data/models/available_slot.dart';
import 'package:neo_parlour_owner/data/models/staff_model.dart';

class GuestBookingState {
  final int salonId;
  double weekdayDiscountPercent = 0.0;
  List<NeoService> selectedServices = [];
  DateTime selectedDate = DateTime.now();
  AvailableSlot? selectedSlot;
  Staff? selectedStaff;
  String customerName = '';
  String customerNumber = '';

  GuestBookingState({required this.salonId});

  int get totalDuration => selectedServices.fold(0, (sum, s) => sum + s.duration);
  double get totalPrice => selectedServices.fold(0.0, (sum, s) => sum + s.price);

  double get weekdayDiscountAmount {
    // Weekday is Monday to Friday (1 to 5)
    final isWeekday = selectedDate.weekday >= 1 && selectedDate.weekday <= 5;
    if (isWeekday) {
      return totalPrice * (weekdayDiscountPercent / 100.0);
    }
    return 0.0;
  }

  double get finalAmount => totalPrice - weekdayDiscountAmount;

  void fromAppointment(dynamic appointment) {
    // Expects an Appointment object
    customerName = appointment.customerName;
    customerNumber = appointment.customerMobile ?? '';
    selectedDate = appointment.appointmentAt;

    if (appointment.services != null) {
      selectedServices = appointment.services!.map<NeoService>((s) => NeoService(
        id: int.tryParse(s.serviceId) ?? s.id,
        name: s.serviceName,
        price: s.price,
        duration: s.duration,
        category: 'Unknown',
      )).toList();
    }

    if (appointment.staffId != null) {
      selectedStaff = Staff(
        id: appointment.staffId!,
        name: appointment.staffName,
        phone: '',
        email: '',
      );
    } else {
      selectedStaff = null;
    }
  }
}
