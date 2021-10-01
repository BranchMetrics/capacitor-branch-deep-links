import { registerPlugin } from '@capacitor/core';

import type { BranchDeepLinksPlugin } from './definitions';

const BranchDeepLinks = registerPlugin<BranchDeepLinksPlugin>(
  'BranchDeepLinks',
);

export * from './definitions';
export { BranchDeepLinks };
