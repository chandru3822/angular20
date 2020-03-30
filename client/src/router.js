import Vue from 'vue'
import Router from 'vue-router'
import Login from './views/Login.vue'
import store from './store'
import { UserMutations } from './stores/UserStore'
import { getRequest } from '@/helpers/helpers'

Vue.use(Router)

export default new Router({
  mode: 'history',
  base: process.env.BASE_URL,
  routes: [
    {
      path: '/login',
      name: 'login',
      component: Login,
      props: true
    },
    {
      path: '/',
      name: 'home',
      component: () => {
        if(store.getters.userHasAnyFeature) {
          return import(/* webpackChunkName: "home" */ './views/Home.vue')
        } else  {
          return accessDenied()
        }
      },
      beforeEnter: async (to, from, next) => {
        if (!store.state.user.authorized) {
          next('/login')
        } else if (to.path === '/') {
          next('/users')
        } else {
          if(from.name !== 'login') {
            try {
              const {data} = await getUser()
              store.commit(UserMutations.SET_DETAILS, data)
              next()
            } catch (e) {
              next('/login')
            }
          } else {
            next()
          }
        }
      },
      children: [{
        path: 'serverError',
        name: 'serverError',
        component: () => import(/* webpackChunkName: "serverError" */ './views/ServerError.vue')
      }, {
        path: 'accessDenied',
        name: 'accessDenied',
        component: () => import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
      }, {
        path: 'schedule',
        name: 'schedule',
        props: true,
        component: () => {
          if(store.getters.userHasFeature('SCHEDULE')) {
            return import(/* webpackChunkName: "schedule" */ './views/flow/schedule/Schedule.vue')
          } else  {
            return accessDenied()
          }
        }
      }, {
        path: 'users',
        name: 'users',
        component: () => {
          if(store.getters.userHasFeature('USERS')) {
            return import(/* webpackChunkName: "users" */ './views/flow/users/Users.vue')
          } else  {
            return accessDenied()
          }
        }
      }, {
        path: '/user/:id',
        name: 'user',
        props: true,
        component: () => {
          if(store.getters.userHasFeature('USERS')) {
            return import (/*webpackChunkName: "user" */ './views/flow/users/User.vue')
          } else  {
            return accessDenied()
          }
        },
        children: [
          {
            path: 'details',
            name: 'userDetails',
            component: () => import (/* webpackChunkName: "userDetails" */ './views/flow/users/UserDetails.vue'),
          }, {
            path: 'positions',
            component: () => import (/* webpackChunkName: "userDetails" */ './views/flow/users/UserPositions.vue'),
          }, {
            path: 'access',
            component: () => import (/* webpackChunkName: "userDetails" */ './views/flow/users/UserAccess.vue'),
          }
        ]
      }, {
        path: '/newUser',
        name: 'newUser',
        component: () => {
          if(store.getters.userHasFeatureAccessLevel('USERS', 'ADD')) {
            return import (/*webpackChunkName: "newUser" */ './views/flow/users/NewUser.vue')
          } else  {
            return accessDenied()
          }
        },
        children: []
      }, {
          path: '/ahj',
          name: 'ahj',
          component: () => {
            if(store.getters.userHasFeature('AHJ_DATABASE')) {
              return import (/* webpackChunkName: "ahj" */ './views/ahj/Ahj.vue')
            } else  {
              return accessDenied()
            }
          },
      }, {
        path: '/ahj/:ahjId',
        name: 'ahjDetails',
        props: true,
        component: () => {
          if(store.getters.userHasFeature('AHJ_DATABASE')) {
            return import (/* webpackChunkName: "ahjDetails" */ './views/ahj/AhjDetails.vue')
          } else  {
            return accessDenied()
          }
        },
        children: [
          {
            path: 'permit',
            component: () => import (/* webpackChunkName: "permit" */ './views/ahj/AhjPermit.vue')
          },
          {
            path: 'inspection',
            component: () => import (/* webpackChunkName: "inspection" */ './views/ahj/AhjInspection.vue')
          },
          {
            path: 'design',
            component: () => import (/* webpackChunkName: "design" */ './views/ahj/AhjDesign.vue')
          }
        ]
      }, {
        path: '/ahjUtility',
        name: 'ahjUtilities',
        component: () => {
          if(store.getters.userHasFeature('AHJ_DATABASE')) {
            return import (/* webpackChunkName: "ahj" */ './views/ahj/utility/AhjUtility.vue')
          } else  {
            return accessDenied()
          }
        },
      }, {
        path: '/ahjUtility/:ahjUtilityId/details',
        name: 'ahjUtilityDetails',
        props: true,
        component: () => {
          if(store.getters.userHasFeature('AHJ_DATABASE')) {
            return import (/* webpackChunkName: "ahjUtilityDetails" */ './views/ahj/utility/AhjUtilityDetails.vue')
          } else  {
            return accessDenied()
          }
        },
      }, {
        path: '/settings',
        name: 'settings',
        component: () => import(/* webpackChunkName: "settings" */ './views/flow/settings/Settings.vue'),
        children: [
          {
            path: 'userProfile',
            component: () => import (/* webpackChunkName: "userProfile" */ './views/flow/settings/UserProfile.vue'),
          }, {
            path: 'company',
            component: () => {
              if(store.getters.userHasFeature('SETTINGS')) {
                return import (/* webpackChunkName: "company" */ './views/flow/settings/Company.vue')
              } else  {
                return accessDenied()
              }
            },
          }, {
            path: 'orgTypes',
            component: () => {
              if(store.getters.userHasFeature('SETTINGS')) {
                return import (/* webpackChunkName: "orgTypes" */ './views/flow/settings/OrgTypes.vue')
              } else  {
                return accessDenied()
              }
            },
          }, {
            path: 'eventTypes',
            component: () => {
              if(store.getters.userHasFeature('SETTINGS')) {
                return import (/* webpackChunkName: "eventTypes" */ './views/flow/settings/EventTypes.vue')
              } else  {
                return accessDenied()
              }
            },
          }, {
            path: 'workQueue',
            component: () => {
              if(store.getters.userHasFeature('SETTINGS')) {
                return import (/* webpackChunkName: "workQueueAdmin" */ './views/flow/settings/WorkQueue.vue')
              } else  {
                return accessDenied()
              }
            },
            children: [
              {
                path: 'types',
                component: () => import (/* webpackChunkName: "workQueueTypes" */ './views/flow/settings/WorkQueueTypes.vue'),
              }, {
                path: 'categories',
                component: () => import (/* webpackChunkName: "workQueueCategories" */ './views/flow/settings/WorkQueueCategories.vue'),
              }
            ]
          }, {
            path: 'customFields',
            component: () => {
              if(store.getters.userHasFeature('SETTINGS')) {
                return import (/* webpackChunkName: "customFields" */ './views/flow/settings/CustomFields.vue')
              } else  {
                return accessDenied()
              }
            },
          }, {
            path: 'customFieldGroup/:id',
            props: true,
            component: () => {
              if(store.getters.userHasFeature('SETTINGS')) {
                return import (/* webpackChunkName: "customFieldGroup" */ './views/flow/settings/CustomFieldGroup.vue')
              } else  {
                return accessDenied()
              }
            },
          }, {
            path: 'attachments',
            component: () => {
              if(store.getters.userHasFeature('SETTINGS')) {
                return import (/* webpackChunkName: "attachments" */ './views/flow/settings/Attachments.vue')
              } else  {
                return accessDenied()
              }
            },
          }, {
            path: 'links',
            component: () => {
              if(store.getters.userHasFeature('SETTINGS')) {
                return import (/* webpackChunkName: "links" */ './views/flow/settings/Links.vue')
              } else  {
                return accessDenied()
              }
            },
          }, {
            path: 'processes',
            component: () => {
              if(store.getters.userHasFeature('SETTINGS')) {
                return import (/* webpackChunkName: "processes" */ './views/flow/settings/Processes.vue')
              } else  {
                return accessDenied()
              }
            },
          }, {
            path: 'processes/:id?',
            name: 'process',
            props: true,
            component: () => {
              if(store.getters.userHasFeature('SETTINGS')) {
                return import (/* webpackChunkName: "process" */ './views/flow/settings/Process.vue')
              } else  {
                return accessDenied()
              }
            },
          }, {
            path: 'processSteps',
            component: () => {
              if(store.getters.userHasFeature('SETTINGS')) {
                return import (/* webpackChunkName: "processSteps" */ './views/flow/settings/ProcessSteps.vue')
              } else  {
                return accessDenied()
              }
            },
          }, {
            path: 'processStep/:id',
            name: 'processStep',
            props: true,
            component: () => {
              if(store.getters.userHasFeature('SETTINGS')) {
                return import (/* webpackChunkName: "processStep" */ './views/flow/settings/ProcessStep.vue')
              } else  {
                return accessDenied()
              }
            },
            children: [
              {
                path: 'components',
                component: () => import (/* webpackChunkName: "processStepComponents" */ './views/flow/settings/ProcessStepComponents.vue'),
              }, {
                path: 'actions',
                component: () => import (/* webpackChunkName: "processStepActions" */ './views/flow/settings/ProcessStepActions.vue'),
              }
            ]
          }, {
            path: 'statuses',
            component: () => {
              if(store.getters.userHasFeature('SETTINGS')) {
                return import (/* webpackChunkName: "statuses" */ './views/flow/settings/Statuses.vue')
              } else  {
                return accessDenied()
              }
            },
          }, {
            path: 'functions',
            component: () => {
              if(store.getters.userHasFeature('SETTINGS')) {
                return import (/* webpackChunkName: "functions" */ './views/flow/settings/Functions.vue')
              } else  {
                return accessDenied()
              }
            },
          }, {
            path: 'function/:id',
            component: () => {
              if(store.getters.userHasFeature('SETTINGS')) {
                return import (/* webpackChunkName: "function" */ './views/flow/settings/Function.vue')
              } else  {
                return accessDenied()
              }
            },
          }, {
            path: 'positions',
            component: () => {
              if(store.getters.userHasFeature('SETTINGS')) {
                return import (/* webpackChunkName: "positions" */ './views/flow/settings/Positions.vue')
              } else  {
                return accessDenied()
              }
            },
          },  {
            path: 'position/:id?',
            name: 'position',
            component: () => {
              if(store.getters.userHasFeature('SETTINGS')) {
                return import (/* webpackChunkName: "position" */ './views/flow/settings/Position.vue')
              } else  {
                return accessDenied()
              }
            },
          },  {
            path: 'roles',
            component: () => {
              if(store.getters.userHasFeature('SETTINGS')) {
                return import (/* webpackChunkName: "roles" */ './views/flow/settings/Roles.vue')
              } else  {
                return accessDenied()
              }
            },
          },  {
            path: 'role/:id?',
            name: 'role',
            component: () => {
              if(store.getters.userHasFeature('SETTINGS')) {
                return import (/* webpackChunkName: "role" */ './views/flow/settings/Role.vue')
              } else  {
                return accessDenied()
              }
            },
          },
        ]
      }, {
        path: '/workQueue',
        name: 'workQueue',
        component: () => {
          if(store.getters.userHasFeature('WORK_QUEUE')) {
            return import (/*webpackChunkName: "workQueue" */ './views/flow/workQueue/WorkQueue.vue')
          } else  {
            return accessDenied()
          }
        },
      }, {
        path: '/workQueue/:id',
        name: 'workQueueDrilldown',
        component: () => {
          if(store.getters.userHasFeature('WORK_QUEUE')) {
            return import (/*webpackChunkName: "workQueueDrilldown" */ './views/flow/workQueue/WorkQueueDrilldown.vue')
          } else  {
            return accessDenied()
          }
        },
      }, {
        path: '/project',
        name: 'project',
        component: () => {
          if(store.getters.userHasFeature('PROJECTS')) {
            return import (/*webpackChunkName: "project" */ './views/flow/project/Project.vue')
          } else  {
            return accessDenied()
          }
        },
        children: [{
            path: 'search',
            name: 'projects',
            component: () => import (/*webpackChunkName: "projectOverview" */ './views/flow/project/Projects.vue')
          }, {
            path: ':projectId',
            name: 'projectOverview',
            component: () => import (/*webpackChunkName: "projectOverview" */ './views/flow/project/ProjectOverview.vue')
          }, {
            name: 'projectProcessStep',
            path: ':projectId/processStep/:processStepId',
            component: () => import (/*webpackChunkName: "projectProcessStep" */ './views/flow/project/ProjectProcessStep.vue')
          }, {
            name: 'projectAdmin',
            path: ':projectId/admin',
            component: () => {
              if (store.getters.userHasFeatureAccessLevel('PROJECTS', 'ADMIN')) {
                return import (/*webpackChunkName: "projectAdmin" */ './views/flow/project/ProjectAdmin.vue')
              } else {
                return accessDenied()
              }
            }
        }
        ]
      }, {
        path: '/contacts',
        name: 'contacts',
        component: () => {
          if(store.getters.userHasFeature('CONTACTS')) {
            return import (/*webpackChunkName: "contacts" */ './views/flow/contacts/Contacts.vue')
          } else  {
            return accessDenied()
          }
        },
        children: []
      }, {
        path: '/contact/:id',
        name: 'contact',
        props: true,
        component: () => {
          if(store.getters.userHasFeature('CONTACTS')) {
            return import (/*webpackChunkName: "contact" */ './views/flow/contacts/Contact.vue')
          } else  {
            return accessDenied()
          }
        },
        children: []
      }, {
        path: '/newContact',
        name: 'newContact',
        component: () => {
          if(store.getters.userHasFeature('CONTACTS')) {
            return import (/*webpackChunkName: "contact" */ './views/flow/contacts/NewContact.vue')
          } else  {
            return accessDenied()
          }
        },
        children: []
      }, {
        path: '/orgs/:orgFilter?',
        name: 'orgs',
        component: () => {
          if(store.getters.userHasFeature('ORGS')) {
            return import (/*webpackChunkName: "orgs" */ './views/flow/orgs/Orgs.vue')
          } else  {
            return accessDenied()
          }
        },
        children: []
      }, {
        path: '/org/:id',
        name: 'org',
        props: true,
        component: () => {
          if(store.getters.userHasFeature('ORGS')) {
            return import (/*webpackChunkName: "org" */ './views/flow/orgs/Org.vue')
          } else  {
            return accessDenied()
          }
        },
        children: []
      }, {
        path: '/newOrg',
        name: 'newOrg',
        component: () => {
          if(store.getters.userHasFeature('ORGS')) {
            return import (/*webpackChunkName: "newOrg" */ './views/flow/orgs/NewOrg.vue')
          } else  {
            return accessDenied()
          }
        },
        children: []
      }, {
        path: '/admin',
        name: 'admin',
        component: () => {
          if(store.getters.userHasFeature('SYSTEM')) {
            return import (/* webpackChunkName: "admin" */ './views/flow/admin/Admin.vue')
          } else  {
            return accessDenied()
          }
        },
        children: [
          {
            path: 'orgFilters',
            component: () => import (/* webpackChunkName: "orgFilters" */ './views/flow/admin/OrgFilters.vue'),
          }, {
            path: 'orgLevels',
            component: () => import (/* webpackChunkName: "orgLevels" */ './views/flow/admin/OrgLevels.vue'),
          }, {
            path: 'states',
            component: () => import (/* webpackChunkName: "states" */ './views/flow/admin/States.vue'),
          }, {
            path: 'features',
            component: () => import (/* webpackChunkName: "features" */ './views/flow/admin/Features.vue'),
          }
        ]
      },
      {
        path: '/propToolAdmin',
        name: 'propToolAdmin',
        component: () => {
          if(store.getters.userHasFeature('PROP_TOOL')) {
            return import (/* webpackChunkName: "propToolAdmin" */ './views/flow/propToolAdmin/PropToolAdmin.vue')
          } else  {
            return accessDenied()
          }
        },
        children: [
          {
            path: 'utilities',
            component: () => import (/* webpackChunkName: "propToolAdminUtilites" */ './views/flow/propToolAdmin/Utilities.vue'),
          }, {
            path: 'financiers',
            component: () => import (/* webpackChunkName: "propToolAdminFinanciers" */ './views/flow/propToolAdmin/Financiers.vue'),
          }, {
            path: 'products',
            component: () => import (/* webpackChunkName: "propToolAdminProducts" */ './views/flow/propToolAdmin/Products.vue'),
          }, {
            path: 'pricing',
            component: () => import (/* webpackChunkName: "propToolAdminPricing" */ './views/flow/propToolAdmin/Pricing.vue'),
          }, {
            path: 'panels',
            component: () => import (/* webpackChunkName: "propToolAdminPanels" */ './views/flow/propToolAdmin/Panels.vue'),
          }, {
            path: 'inverters',
            component: () => import (/* webpackChunkName: "propToolAdminInverters" */ './views/flow/propToolAdmin/Inverters.vue'),
          }, {
            path: 'adders',
            component: () => import (/* webpackChunkName: "propToolAdminAdders" */ './views/flow/propToolAdmin/Adders.vue'),
          }, {
            path: 'incentives',
            component: () => import (/* webpackChunkName: "propToolAdminIncentives" */ './views/flow/propToolAdmin/Incentives.vue'),
          }, {
            path: 'zipCodes',
            component: () => import (/* webpackChunkName: "propToolAdminZipCodes" */ './views/flow/propToolAdmin/ZipCodes.vue'),
          },

        ]
      }, {
          path: '/commissionManagement',
          name: 'commissionManagement',
          component: () => {
            if(store.getters.userHasFeature('COMMISSIONS')) {
              return import (/* webpackChunkName: "commissionManagement" */ './views/commissionManagement/CommissionManagement.vue')
            } else  {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'closers',
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/commissionManagement/Closers.vue'),
            }, {
              path: 'closers/:id',
              name: 'closer',
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/commissionManagement/Closer.vue'),
            }, {
              path: 'commissions',
              name: 'commissions',
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/commissionManagement/Commissions.vue'),
            }, {
              path: 'commissions/:id',
              name: 'commission',
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/commissionManagement/Commission.vue'),
            }, {
              path: 'overrides',
              name: 'overrides',
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/commissionManagement/Overrides.vue'),
            }, {
              path: 'overrides/:id',
              name: 'override',
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/commissionManagement/Override.vue'),
            }, {
              path: 'accounting',
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/commissionManagement/Accounting.vue'),
            }, {
              path: 'payroll',
              name: 'payrolls',
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/commissionManagement/Payrolls.vue'),
            }, {
              path: 'payroll/:id',
              name: 'payroll',
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/commissionManagement/Payroll.vue'),
            }, {
              path: 'admin',
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/commissionManagement/Admin.vue'),
            },
          ]
        }, {
          path: '/smartlist',
          component: () => {
            if(store.getters.userHasFeature('SMARTLIST')) {
              return import (/* webpackChunkName: "smartlist" */ './views/flow/smartlist/SmartlistHome.vue')
            } else  {
              return accessDenied()
            }
          },
          children: [{
              path: '',
              name: 'smartlist',
              component: () => {
                if(store.getters.userHasFeature('SMARTLIST')) {
                  return import (/* webpackChunkName: "smartlist" */ './views/flow/smartlist/Smartlists.vue')
                } else  {
                  return accessDenied()
                }
              }
            }, {
              path: ':smartlistId',
              name: 'smartlistEditor',
              component: () => {
                if(store.getters.userHasFeature('SMARTLIST')) {
                  return import (/* webpackChunkName: "smartlist" */ './views/flow/smartlist/Smartlist.vue')
                } else  {
                  return accessDenied()
                }
              }
            }
          ]
        }
    ],

    }
  ]
})

async function getUser() {
  const {data} = await getRequest(`/user/current`)
  return {data}
}

function accessDenied() {
  return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
}
