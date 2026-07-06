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
      items: [{ type: 'link', label: 'LQ-Colligo', href: '/lqcolligo/' }],
    },
  ],
  lqcolligoSidebar: [
    {
      type: 'category',
      label: 'LQ-Colligo',
      link: { type: 'doc', id: 'lqcolligo/index' },
      items: [
        'lqcolligo/introduction',
        {
          type: 'category',
          label: 'Getting started',
          items: [
            'lqcolligo/getting-started/installation',
            'lqcolligo/getting-started/quickstart',
          ],
        },
        {
          type: 'category',
          label: 'Guides',
          items: [
            'lqcolligo/guides/filtering-collections',
            'lqcolligo/guides/projections-select',
            'lqcolligo/guides/ordering-collections',
            'lqcolligo/guides/partitioning-take-skip',
            'lqcolligo/guides/set-operations',
            'lqcolligo/guides/joins-zip',
            'lqcolligo/guides/aggregations',
            'lqcolligo/guides/grouping',
            'lqcolligo/guides/querying-database',
            'lqcolligo/guides/nullable-types',
          ],
        },
        {
          type: 'category',
          label: 'Architecture',
          items: [
            'lqcolligo/architecture/overview',
          ],
        },
        {
          type: 'category',
          label: 'Reference',
          items: [
            'lqcolligo/reference/api-enumerable',
            'lqcolligo/reference/api-queryable',
            'lqcolligo/reference/api-collections',
          ],
        },
        {
          type: 'category',
          label: 'Support',
          items: [
            'lqcolligo/troubleshooting/common-errors',
          ],
        },
      ],
    },
  ],
};

export default sidebars;
