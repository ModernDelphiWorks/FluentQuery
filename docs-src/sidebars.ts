import type { SidebarsConfig } from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docsSidebar: [
    {
      type: 'doc',
      id: 'intro',
      label: 'Documentation portal',
    },
    {
      type: 'category',
      label: 'Projects',
      items: [{ type: 'link', label: 'FluentQuery', href: '/fluentquery/' }],
    },
  ],
  fluentquerySidebar: [
    {
      type: 'category',
      label: 'FluentQuery',
      link: { type: 'doc', id: 'fluentquery/index' },
      items: [
        'fluentquery/introduction',
        {
          type: 'category',
          label: 'Getting started',
          items: [
            'fluentquery/getting-started/installation',
            'fluentquery/getting-started/quickstart',
          ],
        },
        {
          type: 'category',
          label: 'Guides',
          items: [
            'fluentquery/guides/filtering-collections',
            'fluentquery/guides/projections-select',
            'fluentquery/guides/ordering-collections',
            'fluentquery/guides/partitioning-take-skip',
            'fluentquery/guides/set-operations',
            'fluentquery/guides/joins-zip',
            'fluentquery/guides/aggregations',
            'fluentquery/guides/grouping',
            'fluentquery/guides/querying-database',
            'fluentquery/guides/nullable-types',
          ],
        },
        {
          type: 'category',
          label: 'Architecture',
          items: [
            'fluentquery/architecture/overview',
          ],
        },
        {
          type: 'category',
          label: 'Reference',
          items: [
            'fluentquery/reference/api-enumerable',
            'fluentquery/reference/api-queryable',
            'fluentquery/reference/api-collections',
          ],
        },
        {
          type: 'category',
          label: 'Support',
          items: [
            'fluentquery/troubleshooting/common-errors',
          ],
        },
      ],
    },
  ],
};

export default sidebars;
