export const CollapseExpandEnum = Object.freeze({
    COLLAPSED: 0,
    MIXED: 1,
    EXPANDED:2
})

export const FEAT_DB_TABS = [
  {
    label: 'AHJ',
    path: '/database/ahj',
    pathMatches: ['/list', '/permit', '/inspection', '/design'],
    display: true
  },
  {
    label: 'Utility',
    path: '/database/utility',
    pathMatches: ['/utility'],
    display: true
  },
  {
    label: 'HOA',
    path: '/database/hoa',
    pathMatches: ['/hoa'],
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
