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
      items: [{ type: 'link', label: 'Colligo', href: '/colligo/' }],
    },
  ],
  colligoSidebar: [
    {
      type: 'category',
      label: 'Colligo',
      link: { type: 'doc', id: 'colligo/index' },
      items: [
        'colligo/introduction',
        {
          type: 'category',
          label: 'Getting started',
          items: [
            'colligo/getting-started/installation',
            'colligo/getting-started/quickstart',
          ],
        },
        {
          type: 'category',
          label: 'Guides',
          items: [
            'colligo/guides/filtering-collections',
            'colligo/guides/projections-select',
            'colligo/guides/ordering-collections',
            'colligo/guides/partitioning-take-skip',
            'colligo/guides/set-operations',
            'colligo/guides/joins-zip',
            'colligo/guides/aggregations',
            'colligo/guides/grouping',
            'colligo/guides/querying-database',
            'colligo/guides/nullable-types',
          ],
        },
        {
          type: 'category',
          label: 'Architecture',
          items: [
            'colligo/architecture/overview',
          ],
        },
        {
          type: 'category',
          label: 'Reference',
          items: [
            'colligo/reference/api-enumerable',
            'colligo/reference/api-queryable',
            'colligo/reference/api-collections',
          ],
        },
        {
          type: 'category',
          label: 'Support',
          items: [
            'colligo/troubleshooting/common-errors',
          ],
        },
      ],
    },
  ],
};

export default sidebars;
