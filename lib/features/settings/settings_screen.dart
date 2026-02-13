import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enableNotifications = true;
  bool _enableHapticFeedback = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Preferences'),
          _buildSettingsTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Enable daily reminders',
            trailing: Switch(
              value: _enableNotifications,
              onChanged: (value) {
                setState(() => _enableNotifications = value);
                HapticFeedback.lightImpact();
              },
            ),
          ),
          _buildSettingsTile(
            icon: Icons.vibration,
            title: 'Haptic Feedback',
            subtitle: 'Feel vibrations on interactions',
            trailing: Switch(
              value: _enableHapticFeedback,
              onChanged: (value) {
                setState(() => _enableHapticFeedback = value);
                if (value) HapticFeedback.lightImpact();
              },
            ),
          ),
          _buildSettingsTile(
            icon: Icons.dark_mode,
            title: 'Dark Theme',
            subtitle: 'Use dark theme',
            trailing: Switch(
              value: _darkMode,
              onChanged: (value) {
                setState(() => _darkMode = value);
                HapticFeedback.lightImpact();
                // Note: This would need to be connected to a theme provider
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Theme will change on app restart')),
                );
              },
            ),
          ),
          
          SizedBox(height: 24),
          _buildSectionTitle('Data Management'),
          _buildSettingsTile(
            icon: Icons.backup,
            title: 'Export Data',
            subtitle: 'Export your progress to CSV',
            onTap: _exportData,
          ),
          _buildSettingsTile(
            icon: Icons.refresh,
            title: 'Reset All Progress',
            subtitle: 'Clear all Zikr and Quran data',
            onTap: _showResetDialog,
            textColor: Colors.red,
          ),
          
          SizedBox(height: 24),
          _buildSectionTitle('About'),
          _buildSettingsTile(
            icon: Icons.info,
            title: 'Version',
            subtitle: '1.0.0',
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'View our privacy policy',
            onTap: () => _showInfoDialog('Privacy Policy', 
                'This app stores your data locally on your device. No data is sent to external servers.'),
          ),
          _buildSettingsTile(
            icon: Icons.contact_support,
            title: 'Support',
            subtitle: 'Get help and support',
            onTap: () => _showInfoDialog('Support', 
                'For support, please contact us at support@zikrqurantracker.com'),
          ),
          
          SizedBox(height: 32),
          Center(
            child: Text(
              'Made with ❤️ for the Muslim Ummah',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? Theme.of(context).primaryColor),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: trailing ?? (onTap != null ? Icon(Icons.arrow_forward_ios, size: 16) : null),
        onTap: onTap,
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset All Data'),
        content: Text(
          'Are you sure you want to reset all your progress? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetAllData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllData() async {
    try {
      // This would require implementing reset methods in DatabaseService
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data reset functionality would be implemented here'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resetting data: $e')),
      );
    }
  }

  Future<void> _exportData() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export functionality would be implemented here'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting data: $e')),
      );
    }
  }
}