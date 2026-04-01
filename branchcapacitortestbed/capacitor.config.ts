import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.branch.capacitortestbed',
  appName: 'branchcapacitortestbed',
  webDir: 'dist',
  plugins: {
    SplashScreen: {
      launchAutoHide: false,
    },
    BranchDeepLinks: {
      ios: {
        sdkWaitTime: 9,
        anonID: 'testAnonIDValue',
        odmInfo: {
          value: 'your_odm_string_here',
          firstOpenTimestamp: Date.now() / 1000, // Current time in seconds since 1970
        },
      },
    },
  },
};

export default config;
