import { PluginListenerHandle } from '@capacitor/core';

declare module '@capacitor/core' {
  interface PluginRegistry {
    BranchDeepLinks: BranchDeepLinksPlugin;
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

export interface BranchShortUrlAnalytics {
  alias?: string;
  campaign?: string;
  channel?: string;
  duration?: number;
  feature?: string;
  stage?: string;
  tags?: array<string>;
}

export interface BranchShortUrlProperties {
  '$desktop_url'?: string;
  '$android_url'?: string;
  '$ios_url'?: string;
  '$ipad_url'?: string;
  '$match_duration'?: number;
  'custom_string'?: string;
  'custom_integer'?: number;
  'custom_boolean'?: boolean;
}

export interface BranchShortUrlParams {
  analytics?: BranchShortUrlAnalytics;
  properties?: BranchShortUrlProperties;
}

export interface BranchShortUrlResponse {
  url: string
}

export interface BranchTrackingResponse {
  is_enabled: boolean;
}

export interface BranchLoggedOutResponse {
  logged_out: boolean;
}

export interface BranchInitEvent extends BranchReferringParamsResponse;

export interface BranchDeepLinksPlugin {
  addListener(eventName: 'init', listenerFunc: (event: BranchInitEvent) => void): PluginListenerHandle;
  addListener(eventName: 'initError', listenerFunc: (error: any) => void): PluginListenerHandle;
  generateShortUrl(options: BranchShortUrlParams): Promise<BranchShortUrlResponse>;
  getStandardEvents(): Promise<{ [index: number]: string }>;
  sendBranchEvent(options: { eventName: string, metaData: { [key: string]: any } }): Promise;
  disableTracking(options: { isEnabled: false }): Promise<BranchTrackingResponse>;
  setIdentity(options: { newIdentity: string }): Promise<BranchReferringParamsResponse>;
  logout(): Promise<BranchLoggedOutResponse>;
}
