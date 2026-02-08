import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/employee.dart';
import '../../config/theme.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch employees and attendance status
      context.read<AttendanceProvider>().fetchEmployees();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final provider = context.read<AttendanceProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      provider.setSelectedDate(picked);
    }
  }

  void _showMarkAttendanceDialog(BuildContext context, Employee employee) {
    final provider = context.read<AttendanceProvider>();
    final currentStatus = provider.getAttendanceStatus(employee.id);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mark Attendance',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              employee.name,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            Text(
              DateFormat('EEEE, MMM dd, yyyy').format(provider.selectedDate),
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 24),
            _buildStatusOption(
              ctx,
              employee,
              'PRESENT',
              Icons.check_circle,
              AppTheme.accentColor,
              currentStatus,
            ),
            _buildStatusOption(
              ctx,
              employee,
              'ABSENT',
              Icons.cancel,
              AppTheme.errorColor,
              currentStatus,
            ),
            _buildStatusOption(
              ctx,
              employee,
              'HALF_DAY',
              Icons.timelapse,
              AppTheme.warningColor,
              currentStatus,
            ),
            _buildStatusOption(
              ctx,
              employee,
              'LEAVE',
              Icons.event_busy,
              Colors.purple,
              currentStatus,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(
    BuildContext context,
    Employee employee,
    String status,
    IconData icon,
    Color color,
    String? currentStatus,
  ) {
    final isSelected = currentStatus == status;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? color : null,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: color) : null,
      onTap: () async {
        final provider = context.read<AttendanceProvider>();
        final success = await provider.markAttendance(
          employeeId: employee.id,
          status: status,
        );
        if (success && context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Marked ${employee.name} as $status'),
              backgroundColor: color,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.user?.role ?? '';
    final isAdmin = role == 'ADMIN' || role == 'HR';

    // Parse arguments primarily for Initial Filter, but we can change filter in UI ideally
    // For now, assume simple list view filtered by argument
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final filter = args?['filter'] ?? 'TOTAL';

    String title = 'Employee Attendance';
    if (filter != 'TOTAL') {
      title = '${filter.toString().replaceAll('_', ' ')} Employees';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: isAdmin
            ? [
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          // Filter info / Date info
          Consumer<AttendanceProvider>(
            builder: (context, provider, _) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppTheme.primaryColor.withAlpha(25),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat(
                            'EEEE, MMMM dd, yyyy',
                          ).format(provider.selectedDate),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (filter != 'TOTAL')
                          Text(
                            'Showing: $filter',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isAdmin)
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: const Text('Change Date'),
                    ),
                ],
              ),
            ),
          ),
          // Employee list
          Expanded(
            child: Consumer<AttendanceProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(child: Text(provider.error!));
                }

                // Filter Logic
                final filteredEmployees = provider.employees.where((e) {
                  final status = provider.getAttendanceStatus(e.id);

                  // For UNMARKED, we typically care about ACTIVE employees only
                  if (filter == 'UNMARKED' && e.status != 'ACTIVE')
                    return false;

                  switch (filter) {
                    case 'PRESENT':
                      return status == 'PRESENT' || status == 'HALF_DAY';
                    case 'ON_LEAVE':
                      return status == 'ABSENT' || status == 'LEAVE';
                    case 'UNMARKED':
                      return status == null;
                    default:
                      return true;
                  }
                }).toList();

                if (filteredEmployees.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No employees found',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchEmployees(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final employee = filteredEmployees[index];
                      final status = provider.getAttendanceStatus(employee.id);
                      return _buildEmployeeAttendanceCard(
                        context,
                        employee,
                        status,
                        isAdmin, // Helper to control editability
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeAttendanceCard(
    BuildContext context,
    Employee employee,
    String? status,
    bool canEdit,
  ) {
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;

    switch (status) {
      case 'PRESENT':
        statusColor = AppTheme.accentColor;
        statusIcon = Icons.check_circle;
        break;
      case 'ABSENT':
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.cancel;
        break;
      case 'HALF_DAY':
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.timelapse;
        break;
      case 'LEAVE':
        statusColor = Colors.purple;
        statusIcon = Icons.event_busy;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            employee.name.isNotEmpty
                ? employee.name.substring(0, 1).toUpperCase()
                : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          employee.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${employee.department} • ${employee.designation}',
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        // If status exists, show it.
        // If Admin, show Edit/Mark. If Employee, just show status or "Unmarked".
        trailing: status != null
            ? canEdit
                  ? InkWell(
                      // Admin can click to edit
                      onTap: () => _showMarkAttendanceDialog(context, employee),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 16, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              status.replaceAll('_', ' '),
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      // Employee view (Read Only)
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 16, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            status.replaceAll('_', ' '),
                            style: TextStyle(
                              fontSize: 12,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
            : canEdit
            ? OutlinedButton(
                // Admin can mark
                onPressed: () => _showMarkAttendanceDialog(context, employee),
                child: const Text('Mark'),
              )
            : const Text(
                'Unmarked',
                style: TextStyle(color: Colors.grey),
              ), // Employee sees 'Unmarked'
        onTap: canEdit
            ? () => _showMarkAttendanceDialog(context, employee)
            : null,
      ),
    );
  }
}
