import nodeResolve from '@rollup/plugin-node-resolve';

export default {
  input: 'dist/esm/index.js',
  output: {
    file: 'dist/plugin.js',
    format: 'iife',
    name: 'capacitorBranchDeepLinks', // TODO: change this
    globals: {
      '@capacitor/core': 'capacitorExports',
    },
    sourcemap: true,
    inlineDynamicImports: true,
  },
  plugins: [
    nodeResolve(),
    // nodeResolve({
    //   // allowlist of dependencies to bundle in
    //   // @see https://github.com/rollup/plugins/tree/master/packages/node-resolve#resolveonly
    //   resolveOnly: ['lodash'],
    // }),
  ],
};
