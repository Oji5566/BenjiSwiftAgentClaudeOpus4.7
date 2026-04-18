import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.yourname.benji',
  appName: 'Benji',
  webDir: 'www',
  android: {
    backgroundColor: '#F5F6FA'
  },
  plugins: {
    SplashScreen: {
      launchShowDuration: 700,
      launchAutoHide: true,
      backgroundColor: '#F5F6FA',
      showSpinner: false,
      androidScaleType: 'CENTER_INSIDE'
    },
    StatusBar: {
      style: 'DARK'
    }
  }
};

export default config;
