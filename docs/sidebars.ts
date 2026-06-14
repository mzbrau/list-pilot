import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docsSidebar: [
    'intro',
    {
      type: 'category',
      label: 'Getting started',
      items: [
        'getting-started/install-android',
        'getting-started/first-list',
      ],
    },
    {
      type: 'category',
      label: 'Features',
      items: [
        'features/multiple-lists',
        'features/adding-items',
        'features/categories-and-progress',
        'features/smart-ordering',
        'features/in-your-cart',
        'features/item-details',
        'features/settings-and-export',
      ],
    },
    'upgrading',
    'privacy',
    'developer-setup',
  ],
};

export default sidebars;
