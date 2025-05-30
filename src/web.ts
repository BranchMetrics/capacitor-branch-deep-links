import { WebPlugin, PluginListenerHandle } from '@capacitor/core';

import {
  BranchDeepLinksPlugin,
  BranchLoggedOutResponse,
  BranchReferringParamsResponse,
  BranchUrlParams,
  BranchShortUrlParams,
  BranchShortUrlResponse,
  BranchShowShareSheetParams,
  BranchTrackingResponse,
  BranchQRCodeParams,
  BranchQRCodeResponse,
  BranchDMAParams,
  BranchInitEvent,
} from './definitions';

export class BranchDeepLinksWeb extends WebPlugin implements BranchDeepLinksPlugin {
  constructor() {
    super();
  }

  handleUrl(_: BranchUrlParams): Promise<void> {
    return Promise.reject(new Error('BranchDeepLinks does not have web implementation'));
  }

  generateShortUrl(_: BranchShortUrlParams): Promise<BranchShortUrlResponse> {
    return Promise.reject(new Error('BranchDeepLinks does not have web implementation'));
  }

  showShareSheet(_: BranchShowShareSheetParams): Promise<void> {
    return Promise.reject(new Error('BranchDeepLinks does not have web implementation'));
  }

  getStandardEvents(): Promise<{ [index: number]: string }> {
    return Promise.reject(new Error('BranchDeepLinks does not have web implementation'));
  }

  sendBranchEvent(_: { eventName: string; metaData: { [key: string]: any } }): Promise<void> {
    return Promise.reject(new Error('BranchDeepLinks does not have web implementation'));
  }

  handleATTAuthorizationStatus(_: { status: number }): Promise<void> {
    return Promise.reject(new Error('BranchDeepLinks does not have web implementation'));
  }

  disableTracking(_: { isEnabled: false }): Promise<BranchTrackingResponse> {
    return Promise.reject(new Error('BranchDeepLinks does not have web implementation'));
  }

  setIdentity(_: { newIdentity: string }): Promise<BranchReferringParamsResponse> {
    return Promise.reject(new Error('BranchDeepLinks does not have web implementation'));
  }

  logout(): Promise<BranchLoggedOutResponse> {
    return Promise.reject(new Error('BranchDeepLinks does not have web implementation'));
  }

  getBranchQRCode(_: BranchQRCodeParams): Promise<BranchQRCodeResponse> {
    return Promise.reject(new Error('BranchDeepLinks does not have web implementation'));
  }

  getLatestReferringParams(): Promise<BranchReferringParamsResponse> {
    return Promise.reject(new Error('BranchDeepLinks does not have web implementation'));
  }

  getFirstReferringParams(): Promise<BranchReferringParamsResponse> {
    return Promise.reject(new Error('BranchDeepLinks does not have web implementation'));
  }

  setDMAParamsForEEA(_: BranchDMAParams): Promise<void> {
    return Promise.reject(new Error('BranchDeepLinks does not have web implementation'));
  }

  setConsumerProtectionAttributionLevel(_: { level: string }): Promise<void> {
    return Promise.reject(new Error('BranchDeepLinks does not have web implementation'));
  }

  addListener(_eventName: 'init', _listenerFunc: (event: BranchInitEvent) => void): Promise<PluginListenerHandle>;
  addListener(_eventName: 'initError', _listenerFunc: (error: any) => void): Promise<PluginListenerHandle>;
  addListener(_eventName: string, _listenerFunc: (event: any) => void): Promise<PluginListenerHandle> {
    return Promise.reject(new Error('BranchDeepLinks does not have web implementation'));
  }
}
