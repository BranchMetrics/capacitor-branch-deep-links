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
        sdkWaitTime: 5,
        anonID: 'finalTestAnonIDValue',
        odmInfo: {
          value: 'your_odm_string_here_final_test',
          firstOpenTimestamp: Date.now() / 1000, // Current time in seconds since 1970
        },
      },
    },
  },
};

export default config;
