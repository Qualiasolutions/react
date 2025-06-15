// lib/features/settings/screens/integrations_screen.dart
// Integrations screen for managing iCal integrations, matching React Native's IntegrationsScreen.tsx

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/user/providers/user_provider.dart'; // Assuming user provider exists

// --- Mock Models and Providers (will be moved to proper data/domain layers later) ---

enum ShareType {
  off,
  busy,
  full,
}

extension ShareTypeExtension on ShareType {
  String get displayName {
    switch (this) {
      case ShareType.off:
        return "Don't share with family";
      case ShareType.busy:
        return 'Show as busy';
      case ShareType.full:
        return 'Show full details';
    }
  }
}

class ICalIntegration {
  final String id;
  final String icalName;
  final String icalUrl;
  ShareType shareType;
  final String userId;

  ICalIntegration({
    required this.id,
    required this.icalName,
    required this.icalUrl,
    required this.shareType,
    required this.userId,
  });

  ICalIntegration copyWith({
    String? id,
    String? icalName,
    String? icalUrl,
    ShareType? shareType,
    String? userId,
  }) {
    return ICalIntegration(
      id: id ?? this.id,
      icalName: icalName ?? this.icalName,
      icalUrl: icalUrl ?? this.icalUrl,
      shareType: shareType ?? this.shareType,
      userId: userId ?? this.userId,
    );
  }
}

// Mock provider for iCal integrations
final iCalIntegrationsProvider =
    StateNotifierProvider<ICalIntegrationsNotifier, List<ICalIntegration>>(
        (ref) {
  return ICalIntegrationsNotifier();
});

class ICalIntegrationsNotifier extends StateNotifier<List<ICalIntegration>> {
  ICalIntegrationsNotifier()
      : super([
          ICalIntegration(
            id: '1',
            icalName: 'Work Calendar',
            icalUrl: 'https://example.com/work.ics',
            shareType: ShareType.busy,
            userId: 'user123',
          ),
          ICalIntegration(
            id: '2',
            icalName: 'Family Events',
            icalUrl: 'https://example.com/family.ics',
            shareType: ShareType.full,
            userId: 'user123',
          ),
        ]);

  Future<void> createIntegration(ICalIntegration integration) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    state = [...state, integration];
    Logger.debug('Created integration: ${integration.icalName}');
  }

  Future<void> updateIntegration(ICalIntegration integration) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    state = [
      for (final i in state)
        if (i.id == integration.id) integration else i,
    ];
    Logger.debug('Updated integration: ${integration.icalName}');
  }

  Future<void> deleteIntegration(String id) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    state = state.where((i) => i.id != id).toList();
    Logger.debug('Deleted integration: $id');
  }
}

// --- Widgets ---

class IntegrationsScreen extends StatelessWidget {
  const IntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Integrations'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const IntegrationsList(),
                  SizedBox(height: 32.h),
                  const IntegrationForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class IntegrationsList extends ConsumerWidget {
  const IntegrationsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final integrations = ref.watch(iCalIntegrationsProvider);
    final theme = Theme.of(context);

    if (integrations.isEmpty) {
      return Center(
        child: Text(
          'No integrations found. Add one below!',
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your iCal Integrations',
          style: theme.textTheme.titleLarge,
        ),
        SizedBox(height: 12.h),
        ...integrations.map((integration) => IntegrationCard(
              integration: integration,
            )),
      ],
    );
  }
}

class IntegrationCard extends ConsumerStatefulWidget {
  final ICalIntegration integration;

  const IntegrationCard({
    super.key,
    required this.integration,
  });

  @override
  ConsumerState<IntegrationCard> createState() => _IntegrationCardState();
}

class _IntegrationCardState extends ConsumerState<IntegrationCard> {
  bool _isDeleting = false;
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 10.h),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.integration.icalName,
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: 8.h),
            InkWell(
              onTap: () async {
                final url = Uri.parse(widget.integration.icalUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  _showSnackBar(context, 'Could not launch URL', isError: true);
                }
              },
              child: Text(
                widget.integration.icalUrl,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _isUpdating
                      ? Center(
                          child: SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.w,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        )
                      : DropdownButtonFormField<ShareType>(
                          value: widget.integration.shareType,
                          decoration: InputDecoration(
                            labelText: 'Share Type',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 8.h),
                          ),
                          items: ShareType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.displayName),
                            );
                          }).toList(),
                          onChanged: (ShareType? newValue) async {
                            if (newValue != null) {
                              setState(() {
                                _isUpdating = true;
                              });
                              try {
                                await ref
                                    .read(iCalIntegrationsProvider.notifier)
                                    .updateIntegration(
                                      widget.integration.copyWith(
                                        shareType: newValue,
                                      ),
                                    );
                                _showSnackBar(context, 'Share type updated!');
                              } catch (e) {
                                Logger.error('Error updating share type: $e');
                                _showSnackBar(context,
                                    'Failed to update share type',
                                    isError: true);
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isUpdating = false;
                                  });
                                }
                              }
                            }
                          },
                        ),
                ),
                SizedBox(width: 16.w),
                _isDeleting
                    ? Center(
                        child: SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.error,
                            ),
                          ),
                        ),
                      )
                    : IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: theme.colorScheme.error),
                        onPressed: () => _confirmDelete(context),
                        tooltip: 'Delete Integration',
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Integration'),
          content: Text(
              'Are you sure you want to delete "${widget.integration.icalName}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('DELETE',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                setState(() {
                  _isDeleting = true;
                });
                try {
                  await ref
                      .read(iCalIntegrationsProvider.notifier)
                      .deleteIntegration(widget.integration.id);
                  _showSnackBar(context, 'Integration deleted!');
                } catch (e) {
                  Logger.error('Error deleting integration: $e');
                  _showSnackBar(context, 'Failed to delete integration',
                      isError: true);
                } finally {
                  if (mounted) {
                    setState(() {
                      _isDeleting = false;
                    });
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class IntegrationForm extends ConsumerStatefulWidget {
  const IntegrationForm({super.key});

  @override
  ConsumerState<IntegrationForm> createState() => _IntegrationFormState();
}

class _IntegrationFormState extends ConsumerState<IntegrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _icalUrlController = TextEditingController();
  bool _isSubmitting = false;
  String? _formError;

  @override
  void dispose() {
    _icalUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Integration',
                style: theme.textTheme.titleMedium,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _icalUrlController,
                decoration: InputDecoration(
                  labelText: 'iCal URL',
                  hintText: 'Enter iCal URL',
                  errorText: _formError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a URL';
                  }
                  
                  // Simple URL validation
                  if (!value.startsWith('http://') && !value.startsWith('https://')) {
                    return 'Please enter a valid URL starting with http:// or https://';
                  }
                  
                  return null;
                },
                onChanged: (value) {
                  if (_formError != null) {
                    setState(() {
                      _formError = null;
                    });
                  }
                },
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Text('Add Integration'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    try {
      final url = _icalUrlController.text.trim();
      final userId = ref.read(userIdProvider) ?? 'user123'; // Default for demo
      
      // Extract name from URL for demo purposes
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final name = pathSegments.isNotEmpty
          ? pathSegments.last.replaceAll('.ics', '')
          : 'Calendar';
      
      final newIntegration = ICalIntegration(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        icalName: name,
        icalUrl: url,
        shareType: ShareType.off,
        userId: userId,
      );
      
      await ref
          .read(iCalIntegrationsProvider.notifier)
          .createIntegration(newIntegration);
      
      // Clear form
      _icalUrlController.clear();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Integration added successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      Logger.error('Error adding integration: $e');
      setState(() {
        _formError = 'Failed to add integration. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
