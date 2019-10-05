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

export interface BranchInitEvent {
  referringParams: BranchReferringParams;
}

export interface BranchDeepLinksPlugin {
  addListener(eventName: 'init', listenerFunc: (event: BranchInitEvent) => void): PluginListenerHandle;
  addListener(eventName: 'initError', listenerFunc: (error: any) => void): PluginListenerHandle;
}
