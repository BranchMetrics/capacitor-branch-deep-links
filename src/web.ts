import { WebPlugin } from '@capacitor/core';

import { BranchDeepLinksPlugin } from './definitions';

export class BranchDeepLinksWeb extends WebPlugin implements BranchDeepLinksPlugin {
  constructor() {
    super({
      name: 'BranchDeepLinks',
      platforms: ['web']
    });
  }
}

const BranchDeepLinks = new BranchDeepLinksWeb();

export { BranchDeepLinks };

import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(BranchDeepLinks);
