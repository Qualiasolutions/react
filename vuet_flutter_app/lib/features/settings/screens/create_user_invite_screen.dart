// lib/features/settings/screens/create_user_invite_screen.dart
// Screen to invite family members via email or phone

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_number/phone_number.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/user/providers/user_provider.dart';

// Contact picker would normally use a plugin like flutter_contacts
// This is a simplified version for demo purposes
class ContactModel {
  final String name;
  final String? email;
  final String? phoneNumber;

  ContactModel({
    required this.name,
    this.email,
    this.phoneNumber,
  });
}

// Provider for invitation state
final invitationLoadingProvider = StateProvider<bool>((ref) => false);
final invitationErrorProvider = StateProvider<String?>((ref) => null);
final invitationSuccessProvider = StateProvider<String?>((ref) => null);

class CreateUserInviteScreen extends ConsumerStatefulWidget {
  const CreateUserInviteScreen({super.key});

  @override
  ConsumerState<CreateUserInviteScreen> createState() => _CreateUserInviteScreenState();
}

class _CreateUserInviteScreenState extends ConsumerState<CreateUserInviteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneFormatter = PhoneNumberUtil();

  bool _isEmail = true; // Toggle between email and phone input
  String? _emailError;
  String? _phoneError;
  String? _selectedCountryCode = '+1'; // Default to US
  
  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(invitationLoadingProvider);
    final errorMessage = ref.watch(invitationErrorProvider);
    final successMessage = ref.watch(invitationSuccessProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Family Member'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toggle between email and phone
                    _buildToggleButtons(theme),
                    SizedBox(height: 24.h),
                    
                    // Email or phone input field
                    _isEmail
                        ? _buildEmailInput(theme)
                        : _buildPhoneInput(theme),
                    SizedBox(height: 16.h),
                    
                    // Contact picker button
                    _buildContactPickerButton(theme),
                    SizedBox(height: 32.h),
                    
                    // Error message
                    if (errorMessage != null)
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                errorMessage,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Success message
                    if (successMessage != null)
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: Colors.green.shade700),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                successMessage,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    SizedBox(height: 24.h),
                    
                    // Send invitation button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _sendInvitation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.w,
                                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                                ),
                              )
                            : Text(
                                'Send Invitation',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButtons(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _isEmail = true;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: _isEmail ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    'Email',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: _isEmail ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _isEmail = false;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: !_isEmail ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    'Phone',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: !_isEmail ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailInput(ThemeData theme) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email Address',
        hintText: 'Enter email address',
        errorText: _emailError,
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        }
        
        // Simple email validation
        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
        if (!emailRegex.hasMatch(value)) {
          return 'Enter a valid email address';
        }
        
        return null;
      },
      onChanged: (value) {
        if (_emailError != null) {
          setState(() {
            _emailError = null;
          });
        }
      },
    );
  }

  Widget _buildPhoneInput(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country code dropdown
        Container(
          width: 80.w,
          margin: EdgeInsets.only(right: 8.w),
          child: DropdownButtonFormField<String>(
            value: _selectedCountryCode,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
            ),
            items: [
              DropdownMenuItem(value: '+1', child: Text('+1')),
              DropdownMenuItem(value: '+44', child: Text('+44')),
              DropdownMenuItem(value: '+61', child: Text('+61')),
              DropdownMenuItem(value: '+91', child: Text('+91')),
              // Add more country codes as needed
            ],
            onChanged: (value) {
              setState(() {
                _selectedCountryCode = value;
              });
            },
          ),
        ),
        
        // Phone number input
        Expanded(
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter phone number',
              errorText: _phoneError,
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone number is required';
              }
              
              // Phone validation would normally use libphonenumber
              if (value.length < 7) {
                return 'Enter a valid phone number';
              }
              
              return null;
            },
            onChanged: (value) {
              if (_phoneError != null) {
                setState(() {
                  _phoneError = null;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactPickerButton(ThemeData theme) {
    return OutlinedButton.icon(
      onPressed: _pickContact,
      icon: const Icon(Icons.contacts_outlined),
      label: const Text('Choose from Contacts'),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        side: BorderSide(color: theme.colorScheme.primary),
      ),
    );
  }

  Future<void> _pickContact() async {
    // Request contacts permission
    final status = await Permission.contacts.request();
    
    if (status.isGranted) {
      try {
        // In a real app, we would use a contact picker plugin
        // For this demo, we'll simulate picking a contact
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Simulate contact selection
        final demoContact = ContactModel(
          name: 'John Smith',
          email: 'john.smith@example.com',
          phoneNumber: '5551234567',
        );
        
        // Show contact selection dialog
        _showContactSelectionDialog(demoContact);
      } catch (e) {
        Logger.error('Error picking contact: $e');
        _showErrorSnackBar('Failed to open contacts. Please try again.');
      }
    } else {
      _showPermissionDeniedDialog();
    }
  }

  void _showContactSelectionDialog(ContactModel contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Use Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${contact.name}'),
            if (contact.email != null) 
              Text('Email: ${contact.email}'),
            if (contact.phoneNumber != null) 
              Text('Phone: ${contact.phoneNumber}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          if (contact.email != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isEmail = true;
                  _emailController.text = contact.email!;
                });
              },
              child: const Text('USE EMAIL'),
            ),
          if (contact.phoneNumber != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isEmail = false;
                  _phoneController.text = contact.phoneNumber!;
                });
              },
              child: const Text('USE PHONE'),
            ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'To select contacts, you need to grant contacts permission. '
          'Please enable it in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('OPEN SETTINGS'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  Future<void> _sendInvitation() async {
    // Clear previous messages
    ref.read(invitationErrorProvider.notifier).state = null;
    ref.read(invitationSuccessProvider.notifier).state = null;
    
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Set loading state
    ref.read(invitationLoadingProvider.notifier).state = true;
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      if (_isEmail) {
        final email = _emailController.text.trim();
        
        // In a real app, we would call an API to send the invitation
        Logger.debug('Sending invitation to email: $email');
        
        // Show success message
        ref.read(invitationSuccessProvider.notifier).state = 
            'Invitation sent to $email';
      } else {
        final phoneNumber = '${_selectedCountryCode}${_phoneController.text.trim()}';
        
        // In a real app, we would validate the phone number with libphonenumber
        try {
          // Simple validation for demo purposes
          if (_phoneController.text.trim().length < 7) {
            throw Exception('Invalid phone number');
          }
          
          // In a real app, we would call an API to send the invitation
          Logger.debug('Sending invitation to phone: $phoneNumber');
          
          // Show success message
          ref.read(invitationSuccessProvider.notifier).state = 
              'Invitation sent to $phoneNumber';
        } catch (e) {
          setState(() {
            _phoneError = 'Invalid phone number';
          });
          ref.read(invitationErrorProvider.notifier).state = 
              'Please enter a valid phone number';
          return;
        }
      }
      
      // Clear form after successful invitation
      _emailController.clear();
      _phoneController.clear();
      
    } catch (e) {
      Logger.error('Error sending invitation: $e');
      ref.read(invitationErrorProvider.notifier).state = 
          'Failed to send invitation. Please try again.';
    } finally {
      ref.read(invitationLoadingProvider.notifier).state = false;
    }
  }
}
