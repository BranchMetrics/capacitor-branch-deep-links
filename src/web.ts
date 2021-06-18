import { WebPlugin } from '@capacitor/core';

import {
  BranchDeepLinksPlugin,
  BranchLoggedOutResponse,
  BranchReferringParamsResponse,
  BranchUrlParams,
  BranchShortUrlParams,
  BranchShortUrlResponse,
  BranchShowShareSheetParams,
  BranchTrackingResponse,
} from './definitions';

export class BranchDeepLinksWeb extends WebPlugin
  implements BranchDeepLinksPlugin {
  constructor() {
    super({
      name: 'BranchDeepLinks',
      platforms: ['web'],
    });
  }

  handleUrl(_: BranchUrlParams): Promise<void> {
    return Promise.reject(
      new Error('BranchDeepLinks does not have web implementation'),
    );
  }

  generateShortUrl(_: BranchShortUrlParams): Promise<BranchShortUrlResponse> {
    return Promise.reject(
      new Error('BranchDeepLinks does not have web implementation'),
    );
  }

  showShareSheet(_: BranchShowShareSheetParams): Promise<void> {
    return Promise.reject(
      new Error('BranchDeepLinks does not have web implementation'),
    );
  }

  getStandardEvents(): Promise<{ [index: number]: string }> {
    return Promise.reject(
      new Error('BranchDeepLinks does not have web implementation'),
    );
  }

  sendBranchEvent(_: {
    eventName: string;
    metaData: { [key: string]: any };
  }): Promise<void> {
    return Promise.reject(
      new Error('BranchDeepLinks does not have web implementation'),
    );
  }

  disableTracking(_: { isEnabled: false }): Promise<BranchTrackingResponse> {
    return Promise.reject(
      new Error('BranchDeepLinks does not have web implementation'),
    );
  }

  setIdentity(_: {
    newIdentity: string;
  }): Promise<BranchReferringParamsResponse> {
    return Promise.reject(
      new Error('BranchDeepLinks does not have web implementation'),
    );
  }

  logout(): Promise<BranchLoggedOutResponse> {
    return Promise.reject(
      new Error('BranchDeepLinks does not have web implementation'),
    );
  }
}

// const BranchDeepLinks = new BranchDeepLinksWeb();

// export { BranchDeepLinks };

// import { registerWebPlugin } from '@capacitor/core';
// registerWebPlugin(BranchDeepLinks);
