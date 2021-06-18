// export * from './definitions';
// export * from './web';

import { registerPlugin } from '@capacitor/core';

import type { BranchDeepLinksPlugin } from './definitions';

const BranchDeepLinks = registerPlugin<BranchDeepLinksPlugin>(
  'BranchDeepLinks',
  {
    web: () => import('./web').then(m => new m.BranchDeepLinksWeb()),
  },
);

export * from './definitions';
export { BranchDeepLinks };
