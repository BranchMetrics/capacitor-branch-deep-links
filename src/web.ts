import { WebPlugin } from '@capacitor/core';

import {
  BranchDeepLinksPlugin,
  BranchLoggedOutResponse,
  BranchReferringParamsResponse,
  BranchTrackingResponse
} from './definitions';

export class BranchDeepLinksWeb extends WebPlugin implements BranchDeepLinksPlugin {
  constructor() {
    super({
      name: 'BranchDeepLinks',
      platforms: ['web']
    });
  }

  disableTracking(options: { isEnabled: false }): Promise<BranchTrackingResponse> {
    return Promise.reject(new Error('BranchDeepLinks does not have web implementation'));
  }

  setIdentity(options: { newIdentity: string }): Promise<BranchReferringParamsResponse> {
    return Promise.reject(new Error('BranchDeepLinks does not have web implementation'));
  }

  logout(): Promise<BranchLoggedOutResponse> {
    return Promise.reject(new Error('BranchDeepLinks does not have web implementation'));
  }
}

const BranchDeepLinks = new BranchDeepLinksWeb();

export { BranchDeepLinks };

import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(BranchDeepLinks);
