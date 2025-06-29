# LinkedIn OAuth Setup Guide

## Current Issue

You're getting the error: **"The redirect_uri does not match the registered value"**

This happens because the redirect URI in your app doesn't match what's configured in your LinkedIn Developer Console.

## Current Configuration

- **Client ID**: `86bopv1tq3q75r`
- **Web Redirect URI**: `http://localhost:3000/auth/linkedin/callback`
- **Mobile Redirect URI**: `circleup://auth/linkedin/callback`

## Solution

### Step 1: Access LinkedIn Developer Console

1. Go to [LinkedIn Developer Console](https://www.linkedin.com/developers/apps)
2. Sign in with your LinkedIn account
3. Find your app with Client ID: `86bopv1tq3q75r`

### Step 2: Update Redirect URIs

1. Click on your app
2. Go to the **Auth** tab
3. In the **"Authorized redirect URLs for your app"** section, add these URLs:

   **For Development:**
   ```
   http://localhost:3000/auth/linkedin/callback
   http://localhost:8080/auth/linkedin/callback
   ```

   **For Production (when you deploy):**
   ```
   https://yourdomain.com/auth/linkedin/callback
   ```

   **For Mobile App:**
   ```
   circleup://auth/linkedin/callback
   ```

4. Click **Update** to save changes

### Step 3: Test the Configuration

1. In your Flutter app, tap the debug icon (🐛) in the top-right corner of the login screen
2. This opens the LinkedIn OAuth Debug Screen
3. Use the "Test Selected URI" button to generate test URLs
4. Copy and paste the test URL in a browser to verify it works

## Debug Tools

The app now includes a debug screen (`LinkedInDebugScreen`) that helps you:

- View current OAuth configuration
- Test different redirect URIs
- Generate test URLs for manual verification
- Copy redirect URIs to clipboard for easy pasting
- **Test actual access token**: Uses your real LinkedIn access token to verify API connectivity
- **Test user creation**: Simulates creating a user profile from LinkedIn data

Access it by tapping the bug icon in the login screen (only visible in debug mode).

### New Testing Features

1. **Test Access Token**: Tests the actual LinkedIn API with your access token
2. **Test User Creation**: Shows how user data would be processed from LinkedIn
3. **Enhanced Logging**: Detailed console output for debugging authentication flow

## Common Redirect URI Patterns

| Environment | Redirect URI Pattern |
|-------------|---------------------|
| Local Web Dev | `http://localhost:PORT/auth/linkedin/callback` |
| Production Web | `https://yourdomain.com/auth/linkedin/callback` |
| Mobile App | `your-app-scheme://auth/linkedin/callback` |

## Troubleshooting

### If you still get redirect URI errors:

1. **Double-check the exact URI**: Make sure there are no typos, extra spaces, or incorrect protocols
2. **Wait for propagation**: LinkedIn changes can take a few minutes to propagate
3. **Clear browser cache**: Sometimes cached OAuth flows can cause issues
4. **Check URL encoding**: The debug screen shows both encoded and decoded versions

### If authentication still fails:

1. Verify your Client Secret is correct
2. Check that your LinkedIn app has the required permissions:
   - `openid`
   - `profile`
   - `email`
3. Ensure your LinkedIn app is not in "Development" mode if you're testing with users outside your organization

## Authentication Flow Improvements

The authentication system has been updated to:

1. **Skip Firebase Auth for LinkedIn users**: No longer creates Firebase accounts with synthetic passwords
2. **Use LinkedIn ID for user identification**: Creates user IDs like `linkedin_12345` 
3. **Enhanced error handling**: Better logging and fallback mechanisms
4. **Improved debugging**: Detailed console output for troubleshooting

## Next Steps

After fixing the redirect URI:

1. Test the authentication flow using the debug screen
2. Use the "Test Access Token" button to verify API connectivity
3. Update your production redirect URIs when deploying
4. Consider implementing proper callback handling for web (currently using demo mode)
5. Add error handling for different OAuth failure scenarios

## Web OAuth Implementation Note

Currently, the web OAuth flow uses a demo implementation. For production, you'll need to:

1. Set up a proper callback endpoint
2. Handle the authorization code exchange server-side
3. Implement secure token storage

The mobile OAuth flow using WebView should work correctly once the redirect URIs are configured properly. 