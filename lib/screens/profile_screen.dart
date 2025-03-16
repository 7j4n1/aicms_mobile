import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isChangingPassword = false;
  bool _biometricEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Light';
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _promoNotifications = false;
  
  // Controllers for editable fields
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Form keys for validation
  final _accountFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  
  // Expansion controllers
  final Map<String, bool> _expandedSections = {
    'account': false,
    'notifications': false,
    'preferences': false,
    'security': false,
    'about': false,
  };

  // Mock user data - would come from API in real app
  final Map<String, dynamic> _userData = {
    'name': 'John Doe',
    'membership_id': 'COOP-12345',
    'email': 'john.doe@example.com',
    'phone': '+1 (555) 123-4567',
    'profileImage': null,
  };

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Fetch user data from API
  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // In a real app, you would make an API call here:
    // final response = await http.get(Uri.parse('api/auth/me'));
    // final userData = json.decode(response.body);
    
    setState(() {
      // Set controllers with user data
      _emailController.text = _userData['email'];
      _phoneController.text = _userData['phone'];
      _isLoading = false;
    });
  }

  // Update user profile
  Future<void> _updateProfile() async {
    if (!_accountFormKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    // Update user data locally
    _userData['email'] = _emailController.text;
    _userData['phone'] = _phoneController.text;
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, you would make an API call here:
    // final response = await http.put(
    //   Uri.parse('api/update-profile'),
    //   body: {
    //     'email': _emailController.text,
    //     'phone': _phoneController.text,
    //   }
    // );
    
    setState(() {
      _isSaving = false;
      _expandedSections['account'] = false;
    });
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  // Change password
  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isChangingPassword = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, you would make an API call here:
    // final response = await http.post(
    //   Uri.parse('api/change-password'),
    //   body: {
    //     'current_password': _currentPasswordController.text,
    //     'new_password': _newPasswordController.text,
    //   }
    // );
    
    // Clear password fields
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    
    setState(() {
      _isChangingPassword = false;
      _expandedSections['security'] = false;
    });
    
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password changed successfully')),
    );
  }

  // Upload profile picture
  Future<void> _uploadProfilePicture() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        setState(() {
          _userData['profileImage'] = image.path;
        });
        
        // In a real app, you would upload the image to your server:
        // final request = http.MultipartRequest('POST', Uri.parse('api/update-profile-image'));
        // request.files.add(await http.MultipartFile.fromPath('profile_image', image.path));
        // await request.send();
        
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated')),
        );
      }
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
      debugPrint('Image picker error: $e');
    }
  }

  // Logout
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // In a real app, you would clear auth tokens and navigate to login
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // Toggle section expanded state with animation
  void _toggleSection(String section) {
    setState(() {
      _expandedSections[section] = !_expandedSections[section]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                _buildProfileHeader(),
                
                const SizedBox(height: 24),
                
                // Settings Sections
                _buildSettingsSection(
                  'Account Settings',
                  'account',
                  _buildAccountSettings(),
                  Icons.person_outline,
                ),
                
                _buildSettingsSection(
                  'Notification Preferences',
                  'notifications',
                  _buildNotificationSettings(),
                  Icons.notifications_none,
                ),
                
                _buildSettingsSection(
                  'App Preferences',
                  'preferences',
                  _buildAppPreferences(),
                  Icons.settings_outlined,
                ),
                
                _buildSettingsSection(
                  'Security',
                  'security',
                  _buildSecuritySettings(),
                  Icons.security_outlined,
                ),
                
                _buildSettingsSection(
                  'About',
                  'about',
                  _buildAboutSection(),
                  Icons.info_outline,
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _uploadProfilePicture,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _userData['profileImage'] != null
                      ? FileImage(File(_userData['profileImage']))
                      : null,
                  child: _userData['profileImage'] == null
                      ? Text(
                          _userData['name'].substring(0, 1),
                          style: AppTheme.heading1.copyWith(color: Colors.white),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userData['name'],
            style: AppTheme.heading1,
          ),
          const SizedBox(height: 8),
          Text(
            'Membership ID: ${_userData['membership_id']}',
            style: AppTheme.subtitle,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppTheme.textLight),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProfileInfoRow(Icons.email_outlined, 'Email', _userData['email']),
                  const Divider(height: 24),
                  _buildProfileInfoRow(Icons.phone_outlined, 'Phone', _userData['phone']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTheme.caption),
            const SizedBox(height: 4),
            Text(value, style: AppTheme.bodyText),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsSection(String title, String sectionKey, Widget content, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: AppTheme.primaryColor),
            title: Text(title, style: AppTheme.subtitle),
            trailing: Icon(
              _expandedSections[sectionKey]! ? Icons.expand_less : Icons.expand_more,
              color: AppTheme.textSecondary,
            ),
            onTap: () => _toggleSection(sectionKey),
          ),
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: content,
            crossFadeState: _expandedSections[sectionKey]!
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _accountFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.length < 10) {
                  return 'Phone number must be at least 10 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _updateProfile,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSwitchTile(
            'Push Notifications',
            'Receive push notifications for updates and activities',
            _pushNotifications,
            (value) {
              setState(() {
                _pushNotifications = value;
              });
            },
          ),
          _buildSwitchTile(
            'Email Notifications',
            'Receive email notifications for account updates',
            _emailNotifications,
            (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
          ),
          _buildSwitchTile(
            'SMS Notifications',
            'Receive SMS for important alerts',
            _smsNotifications,
            (value) {
              setState(() {
                _smsNotifications = value;
              });
            },
          ),
          _buildSwitchTile(
            'Promotional Notifications',
            'Receive notifications about promotions and offers',
            _promoNotifications,
            (value) {
              setState(() {
                _promoNotifications = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppPreferences() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Language', style: AppTheme.subtitle),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedLanguage,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.language),
            ),
            items: ['English', 'Spanish', 'French', 'German']
                .map((lang) => DropdownMenuItem(
                      value: lang,
                      child: Text(lang),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedLanguage = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          Text('Theme', style: AppTheme.subtitle),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedTheme,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.color_lens),
            ),
            items: ['Light', 'Dark', 'System Default']
                .map((theme) => DropdownMenuItem(
                      value: theme,
                      child: Text(theme),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedTheme = value;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preferences saved')),
                );
              },
              child: const Text('Apply Changes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Biometric login toggle
          _buildSwitchTile(
            'Enable Biometric Login',
            'Use fingerprint or face recognition to login',
            _biometricEnabled,
            (value) {
              setState(() {
                _biometricEnabled = value;
              });
            },
          ),
          const SizedBox(height: 24),
          // Change password form
          Text('Change Password', style: AppTheme.subtitle),
          const SizedBox(height: 16),
          Form(
            key: _passwordFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _currentPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isChangingPassword ? null : _changePassword,
                    child: _isChangingPassword
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Update Password'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text('App Version'),
            subtitle: const Text('1.0.0 (Build 101)'),
            leading: const Icon(Icons.info_outline),
          ),
          const Divider(),
          ListTile(
            title: const Text('Terms of Service'),
            leading: const Icon(Icons.description_outlined),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to Terms of Service
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Privacy Policy'),
            leading: const Icon(Icons.privacy_tip_outlined),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to Privacy Policy
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Open Source Licenses'),
            leading: const Icon(Icons.code),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to Licenses page
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: AppTheme.caption),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }
}
