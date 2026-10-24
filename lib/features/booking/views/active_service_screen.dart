import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/booking/models/booking_model.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/providers/mock_state_providers.dart' as shared_state;

class ActiveServiceScreen extends ConsumerWidget {
  final String bookingId;
  const ActiveServiceScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLang = ref.watch(shared_state.languageProvider);
    final activeRole = ref.watch(shared_state.currentRoleProvider);
    final booking = ref.watch(shared_state.bookingByIdProvider(bookingId));

    if (booking == null) {
      return Scaffold(
        backgroundColor: AppTheme.bgBase,
        appBar: AppBar(
          backgroundColor: AppTheme.bgBase,
          elevation: 0,
          title: Text(activeLang == 'am' ? 'ብቁ አገልግሎት' : 'Active Service', style: TextStyle(color: AppTheme.textPrimary)),
          centerTitle: true,
        ),
        body: Center(
          child: Text(
            activeLang == 'am' ? 'ይቅርታ፣ የትዕዛዝ መረጃ አልተገኘም።' : 'Sorry, active booking was not found.',
            style: TextStyle(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
        bottomNavigationBar: ShukBottomNavBar(
          currentIndex: 1,
          activeRole: activeRole,
          activeLang: activeLang,
        ),
      );
    }

    Widget buildActionButton() {
      if (booking.status == BookingStatus.pending) {
        return ElevatedButton.icon(
          onPressed: () {
            ref.read(shared_state.bookingsListProvider.notifier).updateBookingStatus(booking.id, BookingStatus.accepted);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(activeLang == 'am' ? 'ጥያቄው ተቀብላል። የሥራ ሂደት ይቀጥላል።' : 'Booking accepted. Proceed to start service.'),
                backgroundColor: AppTheme.success,
              ),
            );
          },
          icon: const Icon(Icons.check_circle_outline),
          label: Text(activeLang == 'am' ? 'ተቀበል' : 'Accept Request'),
        );
      }

      if (booking.status == BookingStatus.accepted) {
        return ElevatedButton.icon(
          onPressed: () {
            ref.read(shared_state.bookingsListProvider.notifier).updateBookingStatus(booking.id, BookingStatus.inService);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(activeLang == 'am' ? 'አገልግሎት ጀምሯል።' : 'Service started.'),
                backgroundColor: AppTheme.primary,
              ),
            );
          },
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(activeLang == 'am' ? 'ስራ ጀምር' : 'Start Service'),
        );
      }

      if (booking.status == BookingStatus.inService) {
        return ElevatedButton.icon(
          onPressed: () {
            ref.read(shared_state.bookingsListProvider.notifier).updateBookingStatus(booking.id, BookingStatus.completed);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(activeLang == 'am' ? 'ስራው ተጠናቋል።' : 'Service completed successfully.'),
                backgroundColor: AppTheme.success,
              ),
            );
          },
          icon: const Icon(Icons.check_rounded),
          label: Text(activeLang == 'am' ? 'ስራ ጨርስ' : 'Complete Service'),
        );
      }

      return OutlinedButton(
        onPressed: null,
        child: Text(activeLang == 'am' ? 'ስራ ተጠናቋል' : 'Service Completed'),
      );
    }

    final statusLabel = booking.status == BookingStatus.pending
        ? (activeLang == 'am' ? 'በጥበቃ ላይ' : 'Pending')
        : booking.status == BookingStatus.accepted
            ? (activeLang == 'am' ? 'ተቀባይነት አግኝቷል' : 'Accepted')
            : booking.status == BookingStatus.inService
                ? (activeLang == 'am' ? 'በሥራ ላይ' : 'In Service')
                : booking.status == BookingStatus.completed
                    ? (activeLang == 'am' ? 'ተጠናቅቋል' : 'Completed')
                    : booking.status.name;

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      appBar: AppBar(
        backgroundColor: AppTheme.bgBase,
        elevation: 0,
        title: Text(activeLang == 'am' ? 'ብቁ አገልግሎት' : 'Active Service', style: TextStyle(color: AppTheme.textPrimary)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(activeLang == 'am' ? 'የትዕዛዝ ID: ${booking.id}' : 'Booking ID: ${booking.id}', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 20),
            _ServiceInfoRow(label: activeLang == 'am' ? 'አገልግሎት' : 'Service', value: booking.serviceType),
            _ServiceInfoRow(label: activeLang == 'am' ? 'ዋጋ' : 'Price', value: 'ETB ${booking.priceEtb.toStringAsFixed(0)}'),
            _ServiceInfoRow(label: activeLang == 'am' ? 'ሁኔታ' : 'Status', value: statusLabel),
            const SizedBox(height: 20),
            Text(activeLang == 'am' ? 'የጥያቄ ዝርዝር' : 'Request Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text(booking.description, style: TextStyle(color: AppTheme.textSecondary, height: 1.5)),
            const SizedBox(height: 24),
            buildActionButton(),
          ],
        ),
      ),
      bottomNavigationBar: ShukBottomNavBar(
        currentIndex: 1,
        activeRole: activeRole,
        activeLang: activeLang,
      ),
    );
  }
}

class _ServiceInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _ServiceInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
