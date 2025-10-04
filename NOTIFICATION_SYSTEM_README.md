# HealthVault Notification System

## Overview
The HealthVault app now includes a comprehensive notification system with three types of notifications that can be toggled on/off by users in the Settings page.

## Notification Types

### 1. Session Expiring Notifications
- **Purpose**: Alert users when their session with a doctor is about to expire
- **Trigger**: Last 15 seconds of a session
- **Icon**: Timer icon (orange)
- **Description**: "Get notified when your session with doctor is about to expire (last 15 seconds)"

### 2. Reminders
- **Purpose**: Appointment reminders and other important notifications
- **Examples**: 
  - Appointment reminders
  - General reminders
- **Icon**: Notifications icon (blue)
- **Description**: "Receive appointment reminders and other important notifications"

### 3. System Notifications
- **Purpose**: System updates, advertisements, and instruction notifications
- **Examples**:
  - System updates
  - Advertisements
  - Instructions
  - General system messages
- **Icon**: Info icon (green)
- **Description**: "Get system updates, advertisements, and instruction notifications"

## Features

### Responsive UI
- Beautiful, modern notification toggle switches
- Color-coded icons and borders
- Visual feedback when toggles are enabled/disabled
- Loading states during settings updates

### Persistent Settings
- Settings are saved to SharedPreferences
- Settings persist across app restarts
- Default values: All notifications enabled

### Test Functionality
- Built-in notification demo page
- Test buttons for each notification type
- Session timer for testing expiring notifications
- Real-time notification preview

## Files Created/Modified

### New Files
1. `notification_settings_service.dart` - Manages notification preferences
2. `notification_manager.dart` - Handles notification display logic
3. `notification_demo.dart` - Demo page for testing notifications
4. `session_timer.dart` - Manages session timing and warnings

### Modified Files
1. `Settings.dart` - Updated with new notification UI and logic
2. `fcm_service.dart` - Integrated with notification settings

## Usage

### For Users
1. Go to Settings page
2. Scroll to "Notifications" section
3. Toggle the desired notification types on/off
4. Test notifications using the "Test Notifications" option

### For Developers
1. Use `NotificationManager` to show notifications:
   ```dart
   final notificationManager = NotificationManager();
   await notificationManager.showSessionExpiringNotification(context);
   ```

2. Check notification settings:
   ```dart
   final settingsService = NotificationSettingsService();
   final isEnabled = await settingsService.isNotificationEnabled('sessionExpiring');
   ```

3. Start a session with timer:
   ```dart
   final sessionTimer = SessionTimer();
   sessionTimer.startSession(300); // 5 minutes
   ```

## Notification Display
- Notifications appear as floating SnackBars
- Color-coded based on notification type
- Include dismiss action
- 4-second duration by default
- Responsive design for different screen sizes

## Integration with FCM
- FCM messages are filtered based on user settings
- Different notification types are handled appropriately
- Background and foreground message handling
- Settings are checked before displaying notifications

## Testing
1. Open the app
2. Navigate to Settings
3. Tap "Test Notifications"
4. Try different notification types
5. Test session timer functionality
6. Verify settings persistence

## Future Enhancements
- Push notification support
- Notification history
- Custom notification sounds
- Notification scheduling
- Advanced filtering options
