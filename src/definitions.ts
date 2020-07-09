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
  disableTracking(options: { isEnabled: false }): BranchTrackingResponse;
  setIdentity(options: { newIdentity: string }): BranchReferringParamsResponse;
  logout(): BranchLoggedOutResponse;
}
