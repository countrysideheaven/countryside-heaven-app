import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/property_models.dart';
import '../../models/app_user.dart';

class AdminCalendarScreen extends StatefulWidget {
  const AdminCalendarScreen({Key? key}) : super(key: key);

  @override
  State<AdminCalendarScreen> createState() => _AdminCalendarScreenState();
}

class _AdminCalendarScreenState extends State<AdminCalendarScreen> {
  static const Color textDark = Color(0xFF111111);
  static const Color livingColor = Color(0xFF6366F1); // Indigo
  static const Color rentingColor = Color(0xFFF59E0B); // Amber

  Property? _selectedProperty;
  Unit? _selectedUnit;

  final List<String> _monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  final List<String> _weekDays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  bool _isDateInBooking(DateTime date, Booking booking) {
    DateTime d = DateTime(date.year, date.month, date.day);
    DateTime s = DateTime(booking.startDate.year, booking.startDate.month, booking.startDate.day);
    DateTime e = DateTime(booking.endDate.year, booking.endDate.month, booking.endDate.day);
    return (d.isAtSameMomentAs(s) || d.isAfter(s)) && (d.isAtSameMomentAs(e) || d.isBefore(e));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PropertyProvider>(context);
    final properties = provider.properties;

    if (properties.isNotEmpty) {
      if (_selectedProperty == null) {
        _selectedProperty = properties.first;
        _selectedUnit = _selectedProperty!.units.isNotEmpty ? _selectedProperty!.units.first : null;
      } else {
        try {
          _selectedProperty = properties.firstWhere((p) => p.id == _selectedProperty!.id);
          if (_selectedUnit != null) {
            _selectedUnit = _selectedProperty!.units.firstWhere((u) => u.id == _selectedUnit!.id);
          }
        } catch (e) {
          _selectedProperty = properties.first;
          _selectedUnit = _selectedProperty!.units.isNotEmpty ? _selectedProperty!.units.first : null;
        }
      }
    } else {
      _selectedProperty = null;
      _selectedUnit = null;
    }

    final now = DateTime.now();
    final List<DateTime> nextThreeMonths = [
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month + 1, 1),
      DateTime(now.year, now.month + 2, 1),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Availability 📅', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1)),
                    ElevatedButton.icon(
                      onPressed: () => _showAddBookingDialog(context, null),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('Book'),
                      style: ElevatedButton.styleFrom(backgroundColor: textDark, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                
                if (properties.isEmpty)
                  const Text('No properties available to manage.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                else
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Property>(
                          isExpanded: true,
                          decoration: InputDecoration(labelText: 'Property', contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                          value: _selectedProperty,
                          items: properties.map((p) => DropdownMenuItem(value: p, child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                          onChanged: (p) => setState(() { _selectedProperty = p; _selectedUnit = p?.units.isNotEmpty == true ? p!.units.first : null; }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<Unit>(
                          isExpanded: true,
                          decoration: InputDecoration(labelText: 'Unit / Room', contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                          value: _selectedUnit,
                          items: _selectedProperty?.units.map((u) => DropdownMenuItem(value: u, child: Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold)))).toList() ?? [],
                          onChanged: (u) => setState(() => _selectedUnit = u),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          Expanded(
            child: _selectedUnit == null
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.meeting_room_rounded, size: 64, color: Colors.grey.shade300), const SizedBox(height: 16), Text('Select a unit to view its calendar.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.bold))]))
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: nextThreeMonths.length + 1,
                    itemBuilder: (context, index) {
                      if (index == nextThreeMonths.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 24, bottom: 100),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegendItem('Investor Living', livingColor),
                              const SizedBox(width: 24),
                              _buildLegendItem('Rented Out', rentingColor),
                            ],
                          ),
                        );
                      }
                      return _buildMonthSection(nextThreeMonths[index], provider.bookings);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSection(DateTime monthDate, List<Booking> allBookings) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_monthNames[monthDate.month - 1]} ${monthDate.year}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textDark)),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: _weekDays.map((day) => SizedBox(width: 40, child: Center(child: Text(day, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey.shade400))))).toList()),
          const SizedBox(height: 16),
          _buildMonthGrid(monthDate, allBookings),
        ],
      ),
    );
  }

  Widget _buildMonthGrid(DateTime monthDate, List<Booking> allBookings) {
    int daysInMonth = DateUtils.getDaysInMonth(monthDate.year, monthDate.month);
    int firstWeekdayOffset = DateTime(monthDate.year, monthDate.month, 1).weekday % 7; 
    int totalSlots = daysInMonth + firstWeekdayOffset;
    int rows = (totalSlots / 7).ceil();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows * 7,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.0),
      itemBuilder: (context, index) {
        if (index < firstWeekdayOffset || index >= totalSlots) return const SizedBox.shrink();

        int dayNumber = index - firstWeekdayOffset + 1;
        DateTime cellDate = DateTime(monthDate.year, monthDate.month, dayNumber);
        
        Booking? activeBooking;
        try {
          activeBooking = allBookings.firstWhere((b) => b.unitId == _selectedUnit!.id && _isDateInBooking(cellDate, b));
        } catch (e) { activeBooking = null; }

        bool isBooked = activeBooking != null;
        bool isLiving = isBooked && activeBooking.type == 'living';
        Color cellColor = Colors.transparent;
        Color textColor = textDark;

        if (isBooked) {
          cellColor = isLiving ? livingColor : rentingColor;
          textColor = Colors.white;
        } else if (cellDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
          textColor = Colors.grey.shade300;
        }

        return GestureDetector(
          onTap: () {
            if (isBooked) {
              _showBookingDetailsSheet(context, activeBooking!);
            } else {
              _showAddBookingDialog(context, cellDate);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(color: cellColor, borderRadius: BorderRadius.circular(12), border: isBooked ? null : Border.all(color: Colors.grey.shade200)),
            child: Center(child: Text('$dayNumber', style: TextStyle(fontSize: 16, fontWeight: isBooked ? FontWeight.w900 : FontWeight.w600, color: textColor))),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))), const SizedBox(width: 8), Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700))]);
  }

  void _showBookingDetailsSheet(BuildContext context, Booking booking) {
    final isLiving = booking.type == 'living';
    final typeColor = isLiving ? livingColor : rentingColor;
    bool isCancelling = false; // Loading state

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(isLiving ? 'INVESTOR LIVING' : 'RENTING OUT', style: TextStyle(color: typeColor, fontWeight: FontWeight.w900, fontSize: 12))),
                    Text('${booking.startDate.day}/${booking.startDate.month} - ${booking.endDate.day}/${booking.endDate.month}', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 14))
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF7F7F9), borderRadius: BorderRadius.circular(16)), child: Icon(isLiving ? Icons.home_rounded : Icons.key_rounded, color: textDark, size: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking.unitName ?? 'Unknown Unit', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: textDark)),
                          const SizedBox(height: 4),
                          Text(booking.fractionName ?? 'Unknown Fraction', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider()),
                Row(
                  children: [
                    CircleAvatar(radius: 20, backgroundColor: textDark.withOpacity(0.1), child: const Icon(Icons.person, size: 20, color: textDark)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking.isOutsideBooking ? 'Outside Guest' : 'Booked by Investor', style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(booking.isOutsideBooking ? (booking.guestName ?? 'Unknown') : (booking.userName ?? 'Unknown'), style: const TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 18)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isCancelling ? null : () async {
                      setState(() => isCancelling = true);
                      try {
                        await Provider.of<PropertyProvider>(context, listen: false).deleteBooking(booking.id);
                        if (context.mounted) {
                          Navigator.pop(context); 
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking Cancelled.'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
                        }
                      } catch (e) {
                        setState(() => isCancelling = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
                        }
                      }
                    },
                    icon: isCancelling ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2)) : const Icon(Icons.cancel_rounded, color: Colors.red),
                    label: Text(isCancelling ? 'Cancelling...' : 'Cancel Booking', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        }
      ),
    );
  }

  bool _isPeak1(DateTime d) => (d.month == 4 && d.day >= 20) || (d.month > 4 && d.month < 7) || (d.month == 7 && d.day <= 15);
  bool _isPeak2(DateTime d) => (d.month == 12 && d.day >= 16) || (d.month == 1 && d.day <= 5);
  int _getPeak2SeasonYear(DateTime d) => d.month == 12 ? d.year + 1 : d.year;

  void _showAddBookingDialog(BuildContext context, DateTime? prefillDate) {
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final properties = propertyProvider.properties;
    final investors = [authProvider.currentUser!, ...authProvider.getDownline('ADMIN123')];

    if (properties.isEmpty) return;

    Property? selectedProp = _selectedProperty ?? properties.first;
    Unit? selectedUnit = _selectedUnit ?? (selectedProp.units.isNotEmpty ? selectedProp.units.first : null);
    Fraction? selectedFraction = selectedUnit?.fractions.isNotEmpty == true ? selectedUnit!.fractions.first : null;

    DateTimeRange? dateRange;
    if (prefillDate != null) dateRange = DateTimeRange(start: prefillDate, end: prefillDate.add(const Duration(days: 1)));

    String bookingType = 'living';
    bool isOutside = false;
    AppUser? selectedInvestor = investors.isNotEmpty ? investors.first : null;
    final guestNameCtrl = TextEditingController();
    
    String? errorMessage;
    bool isSubmitting = false; // Loading state

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Book a Slot 📅', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textDark)),
                    const SizedBox(height: 24),
                    
                    DropdownButtonFormField<Property>(
                      isExpanded: true,
                      decoration: InputDecoration(labelText: 'Property', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                      value: selectedProp,
                      items: properties.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                      onChanged: (p) => setState(() { selectedProp = p; selectedUnit = p?.units.isNotEmpty == true ? p!.units.first : null; selectedFraction = selectedUnit?.fractions.isNotEmpty == true ? selectedUnit!.fractions.first : null; errorMessage = null; }),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Unit>(
                            isExpanded: true,
                            decoration: InputDecoration(labelText: 'Unit', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                            value: selectedUnit,
                            items: selectedProp?.units.map((u) => DropdownMenuItem(value: u, child: Text(u.name))).toList() ?? [],
                            onChanged: (u) => setState(() { selectedUnit = u; selectedFraction = u?.fractions.isNotEmpty == true ? u!.fractions.first : null; errorMessage = null; }),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<Fraction>(
                            isExpanded: true,
                            decoration: InputDecoration(labelText: 'Fraction', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                            value: selectedFraction,
                            items: selectedUnit?.fractions.asMap().entries.map((e) => DropdownMenuItem(value: e.value, child: Text('Fraction ${e.key + 1}'))).toList() ?? [],
                            onChanged: (f) => setState(() { selectedFraction = f; errorMessage = null; }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    InkWell(
                      onTap: () async {
                        final range = await showDateRangePicker(
                          context: context,
                          initialDateRange: dateRange,
                          firstDate: DateTime.now().subtract(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: textDark)), child: child!),
                        );
                        if (range != null) setState(() { dateRange = range; errorMessage = null; });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, color: Colors.grey),
                            const SizedBox(width: 12),
                            Text(
                              dateRange == null ? 'Select Date Range' : '${dateRange!.start.day}/${dateRange!.start.month} - ${dateRange!.end.day}/${dateRange!.end.month}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: dateRange == null ? Colors.grey : textDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text('Booking Type', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: RadioListTile<String>(title: const Text('Living', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), value: 'living', groupValue: bookingType, onChanged: (v) => setState(() { bookingType = v!; errorMessage = null; }), contentPadding: EdgeInsets.zero, activeColor: livingColor)),
                        Expanded(child: RadioListTile<String>(title: const Text('Renting', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), value: 'renting', groupValue: bookingType, onChanged: (v) => setState(() { bookingType = v!; errorMessage = null; }), contentPadding: EdgeInsets.zero, activeColor: rentingColor)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const Text('Booking Source', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: RadioListTile<bool>(title: const Text('Investor', style: TextStyle(fontSize: 14)), value: false, groupValue: isOutside, onChanged: (v) => setState(() { isOutside = v!; errorMessage = null; }), contentPadding: EdgeInsets.zero, activeColor: textDark)),
                        Expanded(child: RadioListTile<bool>(title: const Text('Outside Guest', style: TextStyle(fontSize: 14)), value: true, groupValue: isOutside, onChanged: (v) => setState(() { isOutside = v!; errorMessage = null; }), contentPadding: EdgeInsets.zero, activeColor: textDark)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (isOutside)
                      TextField(controller: guestNameCtrl, onChanged: (_) => setState(() => errorMessage = null), decoration: InputDecoration(labelText: 'External Guest Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), prefixIcon: const Icon(Icons.person_outline)))
                    else
                      DropdownButtonFormField<AppUser>(
                        isExpanded: true,
                        decoration: InputDecoration(labelText: 'Select Investor', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                        value: selectedInvestor,
                        items: investors.map((i) => DropdownMenuItem(value: i, child: Text(i.name))).toList(),
                        onChanged: (i) => setState(() { selectedInvestor = i; errorMessage = null; }),
                      ),

                    const SizedBox(height: 32),

                    if (errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13))),
                          ],
                        ),
                      ),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: textDark, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        onPressed: isSubmitting ? null : () async {
                          setState(() => errorMessage = null);

                          if (dateRange == null || selectedUnit == null || selectedFraction == null) {
                             setState(() => errorMessage = 'Please select property, unit, fraction, and dates.');
                             return;
                          }
                          if (isOutside && guestNameCtrl.text.isEmpty) {
                             setState(() => errorMessage = 'Please enter guest name.');
                             return;
                          }

                          bool isOverlapping = propertyProvider.bookings.any((b) => 
                            b.unitId == selectedUnit!.id && (dateRange!.start.isBefore(b.endDate) && dateRange!.end.isAfter(b.startDate))
                          );
                          if (isOverlapping) {
                            setState(() => errorMessage = 'Overbooking! This unit is already occupied on these dates.');
                            return;
                          }

                          if (!isOutside) {
                            int bookingDays = dateRange!.end.difference(dateRange!.start).inDays + 1;

                            if (bookingDays > 7) {
                              setState(() => errorMessage = 'Limit Reached: Maximum 7 days allowed per single booking. You selected $bookingDays days.');
                              return;
                            }

                            List<DateTime> requestedDates = [];
                            for (int i = 0; i < bookingDays; i++) {
                              requestedDates.add(dateRange!.start.add(Duration(days: i)));
                            }

                            List<Booking> existing = propertyProvider.bookings.where((b) => b.userId == selectedInvestor!.id && b.fractionId == selectedFraction!.id).toList();
                            List<DateTime> allBookedDates = [];
                            
                            for (var b in existing) {
                              int pastBookingDays = b.endDate.difference(b.startDate).inDays + 1;
                              for (int i = 0; i < pastBookingDays; i++) {
                                allBookedDates.add(b.startDate.add(Duration(days: i)));
                              }
                            }

                            Map<int, int> yearCounts = {};
                            Map<int, int> peak1Yearly = {};
                            Map<int, int> peak2Yearly = {};

                            for (var d in allBookedDates) {
                              yearCounts[d.year] = (yearCounts[d.year] ?? 0) + 1;
                              if (_isPeak1(d)) peak1Yearly[d.year] = (peak1Yearly[d.year] ?? 0) + 1;
                              if (_isPeak2(d)) {
                                int seasonYear = _getPeak2SeasonYear(d);
                                peak2Yearly[seasonYear] = (peak2Yearly[seasonYear] ?? 0) + 1;
                              }
                            }

                            for (var d in requestedDates) {
                              yearCounts[d.year] = (yearCounts[d.year] ?? 0) + 1;
                              if (_isPeak1(d)) peak1Yearly[d.year] = (peak1Yearly[d.year] ?? 0) + 1;
                              if (_isPeak2(d)) {
                                int seasonYear = _getPeak2SeasonYear(d);
                                peak2Yearly[seasonYear] = (peak2Yearly[seasonYear] ?? 0) + 1;
                              }
                            }

                            for (var year in peak1Yearly.keys) {
                              if (peak1Yearly[year]! > 4) {
                                setState(() => errorMessage = 'Limit Reached: Max 4 peak days allowed. You are trying to book ${peak1Yearly[year]} days in Peak 1.');
                                return;
                              }
                            }

                            for (var year in peak2Yearly.keys) {
                              if (peak2Yearly[year]! > 4) {
                                setState(() => errorMessage = 'Limit Reached: Max 4 peak days allowed. You are trying to book ${peak2Yearly[year]} days in Peak 2.');
                                return;
                              }
                            }

                            for (var year in yearCounts.keys) {
                              if (yearCounts[year]! > 28) {
                                setState(() => errorMessage = 'Limit Reached: Max 28 total days allowed per year. This pushes you to ${yearCounts[year]}.');
                                return;
                              }
                            }
                          }

                          setState(() => isSubmitting = true);

                          final newBooking = Booking(
                            id: '', // Supabase auto-generates the UUID
                            unitId: selectedUnit!.id, 
                            fractionId: selectedFraction!.id, 
                            userId: isOutside ? 'Outside Guest' : selectedInvestor!.id,
                            startDate: dateRange!.start,
                            endDate: dateRange!.end,
                            type: bookingType,
                            isOutsideBooking: isOutside,
                            guestName: isOutside ? guestNameCtrl.text : null,
                          );

                          try {
                            await propertyProvider.addBooking(newBooking);
                            if (context.mounted) {
                              Navigator.pop(context); 
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking Confirmed! 🎉'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
                            }
                          } catch (e) {
                            setState(() => isSubmitting = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
                            }
                          }
                        },
                        child: isSubmitting
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : const Text('Confirm Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }
}