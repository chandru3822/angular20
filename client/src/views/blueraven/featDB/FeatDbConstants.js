export const CollapseExpandEnum = Object.freeze({
    COLLAPSED: 0,
    MIXED: 1,
    EXPANDED:2
})

export const FEAT_DB_TABS = [
  {
    label: 'AHJ',
    featureCode: 'AHJ',
    path: '/database/ahj',
    pathMatches: ['/list', '/permit', '/inspection', '/design'],
    display: true
  },
  {
    label: 'Utility',
    featureCode: 'UTILITY',
    path: '/database/utility',
    pathMatches: ['/utility'],
    display: true
  },
  {
    label: 'HOA',
    featureCode: 'HOA',
    path: '/database/hoa',
    pathMatches: ['/hoa'],
    display: true
  },
  {
    label: 'Suppliers',
    featureCode: 'SUPPLIERS',
    path: '/database/supplier',
    pathMatches: ['/supplier'],
    display: true
  },
  {
      label: 'Incentives',
      featureCode: 'INCENTIVE',
      path: '/database/incentive',
      pathMatches: ['/incentive'],
      display: true
  }
]

export const FILTER_DEFAULTS = {
    name: {value: '', type: 'text', model: 'name'},
    metroArea: {value: '', type: 'text', model: 'metroArea'},
    state: {value: [], type: 'select', model: 'state'}
}

export const UtilityDocumentTypes = [
    {
        attachmentType: "Utility Rate Documents",
        attachmentTypeId: 7,
        readOnly: false
    },{
        attachmentType: "Submission Detail Documents",
        attachmentTypeId: 6,
        readOnly: false
    },{
        attachmentType: "Approval Detail Documents",
        attachmentTypeId: 25,
        readOnly: false
    },
    ]
