import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/employee.dart';
import '../../models/attendance.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employee_provider.dart';
import '../../services/attendance_service.dart';
import '../../config/theme.dart';

class EmployeeDetailScreen extends StatefulWidget {
  const EmployeeDetailScreen({super.key});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  void _showEditDialog(BuildContext context, Employee employee) {
    final nameController = TextEditingController(text: employee.name);
    final departmentController = TextEditingController(
      text: employee.department,
    );
    final designationController = TextEditingController(
      text: employee.designation,
    );
    final salaryController = TextEditingController(
      text: employee.salary.toString(),
    );
    String status = employee.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Employee'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: departmentController,
                  decoration: const InputDecoration(labelText: 'Department'),
                ),
                TextField(
                  controller: designationController,
                  decoration: const InputDecoration(labelText: 'Designation'),
                ),
                TextField(
                  controller: salaryController,
                  decoration: const InputDecoration(labelText: 'Salary'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Status'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: status,
                      isDense: true,
                      onChanged: (val) => setState(() => status = val!),
                      items: ['ACTIVE', 'INACTIVE', 'TERMINATED']
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final provider = ctx.read<EmployeeProvider>();
                final navigator = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(ctx);

                final success = await provider.updateEmployee(employee.id, {
                  'name': nameController.text,
                  'department': departmentController.text,
                  'designation': designationController.text,
                  'salary': double.tryParse(salaryController.text) ?? 0,
                  'status': status,
                });

                if (success) {
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Employee updated successfully'),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Employee) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No employee selected')),
      );
    }
    final argEmployee = args;

    return Consumer2<AuthProvider, EmployeeProvider>(
      builder: (context, auth, employeeProvider, _) {
        final employee = employeeProvider.employees.firstWhere(
          (e) => e.id == argEmployee.id,
          orElse: () => argEmployee,
        );

        final role = auth.user?.role ?? '';
        final canEdit = role == 'ADMIN' || role == 'HR';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Employee Details'),
            actions: canEdit
                ? [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditDialog(context, employee),
                    ),
                  ]
                : null,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.primaryColor,
                          child: Text(
                            employee.name.isNotEmpty
                                ? employee.name.substring(0, 1).toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          employee.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          employee.designation,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: employee.status == 'ACTIVE'
                                ? AppTheme.accentColor.withAlpha(25)
                                : Colors.grey.withAlpha(25),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            employee.status,
                            style: TextStyle(
                              color: employee.status == 'ACTIVE'
                                  ? AppTheme.accentColor
                                  : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Today's Attendance Status from Service
                        FutureBuilder<List<Attendance>>(
                          future: AttendanceService.getEmployeeAttendance(
                            employee.id,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                              final latest = snapshot.data!.first;
                              final now = DateTime.now();
                              // Convert to local time to verify 'today' logic
                              final localDate = latest.date.toLocal();
                              final isToday =
                                  localDate.year == now.year &&
                                  localDate.month == now.month &&
                                  localDate.day == now.day;

                              if (isToday) {
                                Color color;
                                switch (latest.status) {
                                  case 'PRESENT':
                                    color = AppTheme.accentColor;
                                    break;
                                  case 'ABSENT':
                                    color = AppTheme.errorColor;
                                    break;
                                  case 'HALF_DAY':
                                    color = AppTheme.warningColor;
                                    break;
                                  case 'LEAVE':
                                    color = Colors.purple;
                                    break;
                                  default:
                                    color = Colors.grey;
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withAlpha(25),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: color.withAlpha(50),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: color,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Today: ${latest.status}',
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Info cards
                _buildInfoCard(context, 'Personal Information', [
                  _buildInfoRow('Email', employee.email, Icons.email_outlined),
                ]),
                const SizedBox(height: 12),
                _buildInfoCard(context, 'Employment Details', [
                  _buildInfoRow(
                    'Department',
                    employee.department,
                    Icons.business,
                  ),
                  _buildInfoRow(
                    'Designation',
                    employee.designation,
                    Icons.work_outline,
                  ),
                  _buildInfoRow(
                    'Joining Date',
                    DateFormat('MMM dd, yyyy').format(employee.joiningDate),
                    Icons.calendar_today,
                  ),
                ]),
                const SizedBox(height: 12),
                _buildInfoCard(context, 'Salary Information', [
                  _buildInfoRow(
                    'Monthly Salary',
                    '₹${NumberFormat('#,##,###').format(employee.salary)}',
                    Icons.payments_outlined,
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
