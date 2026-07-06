import type { Config } from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'LQ-Colligo',
  tagline: 'LINQ-style fluent collections and DB query library for Delphi and Lazarus',
  favicon: 'img/favicon.svg',

  // Build output directory is set via CLI (`npm run build` → `docusaurus build --out-dir ../docs`)
  // so it stays compatible with Docusaurus 3 schema validation (top-level `outDir` is not allowed).

  url: 'https://moderndelphiworks.github.io',
  baseUrl: '/LQ-Colligo/',
  organizationName: 'ModernDelphiWorks',
  projectName: 'LQ-Colligo',

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          routeBasePath: '/',
          editUrl: undefined,
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    navbar: {
      title: 'LQ-Colligo',
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'docsSidebar',
          position: 'left',
          label: 'Home',
        },
        {
          type: 'dropdown',
          label: 'Projects',
          position: 'left',
          items: [{ to: '/lqcolligo/', label: 'LQ-Colligo' }],
        },
      ],
    },
    footer: {
      style: 'dark',
      copyright: `© ${new Date().getFullYear()} LQ-Colligo — ModernDelphiWorks.`,
    },
    prism: {
      additionalLanguages: ['bash', 'json', 'powershell', 'pascal'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
