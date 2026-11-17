/// <reference types="@capacitor/cli" />

import { PluginListenerHandle } from '@capacitor/core';

declare module '@capacitor/cli' {
  export interface PluginsConfig {
    BranchDeepLinks?: {
      /**
       * iOS only. Forward links received through Capacitor's UIScene support
       * (Capacitor 8.5+) to Branch. Set to `false` if your SceneDelegate already
       * passes links to `BranchScene` itself.
       *
       * @default true
       * @since 10.1.0
       */
      handleSceneLinks?: boolean;
    };
  }
}

export interface BranchReferringParams {
  '+clicked_branch_link': boolean;
  '+is_first_session': boolean;
  [key: string]: any;
}

export interface BranchReferringParamsResponse {
  referringParams: BranchReferringParams;
}

export interface BranchUrlParams {
  branch: string;
}

export interface BranchShortUrlAnalytics {
  alias?: string;
  campaign?: string;
  channel?: string;
  duration?: number;
  feature?: string;
  stage?: string;
  tags?: Array<string>;
}

export interface BranchShortUrlProperties {
  $desktop_url?: string;
  $android_url?: string;
  $ios_url?: string;
  $ipad_url?: string;
  $match_duration?: number;
  custom_string?: string;
  custom_integer?: number;
  custom_boolean?: boolean;
}

export interface BranchShortUrlParams {
  analytics?: BranchShortUrlAnalytics;
  properties?: BranchShortUrlProperties;
}

export interface BranchShowShareSheetParams extends BranchShortUrlParams {
  shareText?: string;
}

export interface BranchShortUrlResponse {
  url: string;
}

export interface BranchTrackingResponse {
  is_enabled: boolean;
}

export interface BranchLoggedOutResponse {
  logged_out: boolean;
}

export interface BranchQRCodeParams {
  analytics?: BranchShortUrlAnalytics;
  properties?: BranchShortUrlProperties;
  settings?: BranchQRCodeSettings;
}

export interface BranchQRCodeSettings {
  codeColor?: string;
  backgroundColor?: string;
  centerLogo?: string;
  width?: number;
  margin?: number;
  imageFormat?: string;
}

export interface BranchQRCodeResponse {
  qrCode: String;
}

export interface BranchDMAParams {
  eeaRegion: boolean;
  adPersonalizationConsent: boolean;
  adUserDataUsageConsent: boolean;
}

export interface BranchInitEvent extends BranchReferringParamsResponse {}

export type BranchATTAuthorizationStatus = 0 | 1 | 2 | 3;

export type BranchConsumerProtectionAttributionLevel = 'FULL' | 'REDUCED' | 'MINIMAL' | 'NONE';

export interface BranchDeepLinksPlugin {
  addListener(eventName: 'init', listenerFunc: (event: BranchInitEvent) => void): Promise<PluginListenerHandle>;
  addListener(eventName: 'initError', listenerFunc: (error: any) => void): Promise<PluginListenerHandle>;
  handleUrl(options: BranchUrlParams): Promise<void>;
  generateShortUrl(options: BranchShortUrlParams): Promise<BranchShortUrlResponse>;
  showShareSheet(options: BranchShowShareSheetParams): Promise<void>;
  getStandardEvents(): Promise<{ [index: number]: string }>;
  sendBranchEvent(options: { eventName: string; metaData: { [key: string]: any } }): Promise<void>;
  handleATTAuthorizationStatus(options: { status: BranchATTAuthorizationStatus }): Promise<void>;
  disableTracking(options: { isEnabled: false }): Promise<BranchTrackingResponse>;
  setIdentity(options: { newIdentity: string }): Promise<BranchReferringParamsResponse>;
  logout(): Promise<BranchLoggedOutResponse>;
  getBranchQRCode(options: BranchQRCodeParams): Promise<BranchQRCodeResponse>;
  getLatestReferringParams(): Promise<BranchReferringParamsResponse>;
  getFirstReferringParams(): Promise<BranchReferringParamsResponse>;
  setDMAParamsForEEA: (options: BranchDMAParams) => void;
  setConsumerProtectionAttributionLevel(options: { level: BranchConsumerProtectionAttributionLevel }): Promise<void>;
}
