import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUpdateService {
  static final AppUpdateService _instance = AppUpdateService._internal();
  factory AppUpdateService() => _instance;
  AppUpdateService._internal();

  static const String _lastUpdateCheckKey = 'last_update_check';
  static const int _checkIntervalHours = 24; // Check for updates once per day

  /// Check if an update is available and show appropriate dialog
  Future<void> checkForUpdate(BuildContext context, {bool forceCheck = false}) async {
    try {
      // Check if we should perform update check based on time interval
      if (!forceCheck && !await _shouldCheckForUpdate()) {
        print('AppUpdate: Skipping update check (checked recently)');
        return;
      }

      print('AppUpdate: Checking for updates...');
      
      // Check for updates
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      
      // Save the last check time
      await _saveLastUpdateCheck();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        print('AppUpdate: Update available!');
        
        // Check if immediate update is allowed
        if (updateInfo.immediateUpdateAllowed) {
          print('AppUpdate: Immediate update allowed');
          await _showUpdateDialog(context, updateInfo, immediate: true);
        } 
        // Check if flexible update is allowed
        else if (updateInfo.flexibleUpdateAllowed) {
          print('AppUpdate: Flexible update allowed');
          await _showUpdateDialog(context, updateInfo, immediate: false);
        }
      } else {
        print('AppUpdate: No update available');
      }
    } catch (e) {
      print('AppUpdate: Error checking for update: $e');
      // Don't show error to user, fail silently
    }
  }

  /// Show update dialog to user
  Future<void> _showUpdateDialog(
    BuildContext context, 
    AppUpdateInfo updateInfo,
    {required bool immediate}
  ) async {
    if (!context.mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: !immediate, // Can't dismiss if immediate update
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.system_update, color: Theme.of(context).colorScheme.primary),
              SizedBox(width: 12),
              Text('Update Available'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A new version of Zikr app is available on Google Play Store.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              if (immediate)
                Text(
                  'This update is required to continue using the app.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                )
              else
                Text(
                  'Update now to get the latest features and improvements.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
            ],
          ),
          actions: [
            if (!immediate)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Later'),
              ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performUpdate(immediate: immediate);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Update Now',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Perform the update
  Future<void> _performUpdate({required bool immediate}) async {
    try {
      if (immediate) {
        // Immediate update - blocks user until update is complete
        print('AppUpdate: Starting immediate update');
        await InAppUpdate.performImmediateUpdate();
      } else {
        // Flexible update - downloads in background
        print('AppUpdate: Starting flexible update');
        await InAppUpdate.startFlexibleUpdate();
        
        // Complete the flexible update when download finishes
        await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (e) {
      print('AppUpdate: Error performing update: $e');
    }
  }

  /// Check if enough time has passed since last update check
  Future<bool> _shouldCheckForUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheckString = prefs.getString(_lastUpdateCheckKey);
      
      if (lastCheckString == null) {
        return true; // Never checked before
      }

      final lastCheck = DateTime.parse(lastCheckString);
      final now = DateTime.now();
      final difference = now.difference(lastCheck);

      return difference.inHours >= _checkIntervalHours;
    } catch (e) {
      print('AppUpdate: Error checking last update time: $e');
      return true; // If error, allow check
    }
  }

  /// Save the last update check timestamp
  Future<void> _saveLastUpdateCheck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastUpdateCheckKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('AppUpdate: Error saving last update check time: $e');
    }
  }

  /// Clear update check timestamp (useful for testing)
  Future<void> clearUpdateCheckTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastUpdateCheckKey);
      print('AppUpdate: Cleared update check timestamp');
    } catch (e) {
      print('AppUpdate: Error clearing update check timestamp: $e');
    }
  }
}
