import Vue from 'vue'
import Router from 'vue-router'
import Login from './views/Login.vue'
import store from './store'

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
        if(store.getters.userHasAnyFeatureAccess) {
          return import(/* webpackChunkName: "home" */ './views/Home.vue')
        } else  {
          return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
        }
      },
      beforeEnter: (to, from, next) => {
        if (!store.state.user.authorized) {
          next('/login')
        } else if (to.path === '/') {
          next('/users')
        } else {
          next()
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
          if(store.getters.userHasFeatureAccess('SCHEDULE')) {
            return import(/* webpackChunkName: "schedule" */ './views/flow/schedule/Schedule.vue')
          } else  {
            return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
          }
        }
      }, {
        path: 'users',
        name: 'users',
        component: () => {
          if(store.getters.userHasFeatureAccess('USERS')) {
            return import(/* webpackChunkName: "users" */ './views/flow/users/Users.vue')
          } else  {
            return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
          }
        }
      }, {
        path: '/user/:id',
        name: 'user',
        props: true,
        component: () => {
          if(store.getters.userHasFeatureAccess('USERS')) {
            return import (/*webpackChunkName: "user" */ './views/flow/users/User.vue')
          } else  {
            return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
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
          if(store.getters.userHasFeatureAccess('USERS')) {
            return import (/*webpackChunkName: "newUser" */ './views/flow/users/NewUser.vue')
          } else  {
            return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
          }
        },
        children: []
      }, {
          path: '/ahj',
          name: 'ahj',
          component: () => {
            if(store.getters.userHasFeatureAccess('AHJ_DATABASE')) {
              return import (/* webpackChunkName: "ahj" */ './views/ahj/Ahj.vue')
            } else  {
              return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
            }
          },
      }, {
        path: '/ahj/:ahjId',
        name: 'ahjDetails',
        props: true,
        component: () => {
          if(store.getters.userHasFeatureAccess('AHJ_DATABASE')) {
            return import (/* webpackChunkName: "ahjDetails" */ './views/ahj/AhjDetails.vue')
          } else  {
            return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
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
          if(store.getters.userHasFeatureAccess('AHJ_DATABASE')) {
            return import (/* webpackChunkName: "ahj" */ './views/ahj/utility/AhjUtility.vue')
          } else  {
            return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
          }
        },
      }, {
        path: '/ahjUtility/:ahjUtilityId/details',
        name: 'ahjUtilityDetails',
        props: true,
        component: () => {
          if(store.getters.userHasFeatureAccess('AHJ_DATABASE')) {
            return import (/* webpackChunkName: "ahjUtilityDetails" */ './views/ahj/utility/AhjUtilityDetails.vue')
          } else  {
            return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
          }
        },
      }, {
        path: '/settings',
        name: 'settings',
        component: () => {
          if(store.getters.userHasFeatureAccess('SETTINGS')) {
            return import (/* webpackChunkName: "settings" */ './views/flow/settings/Settings.vue')
          } else  {
            return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
          }
        },
        children: [
          {
            path: 'userProfile',
            component: () => import (/* webpackChunkName: "userProfile" */ './views/flow/settings/UserProfile.vue'),
          }, {
            path: 'company',
            component: () => import (/* webpackChunkName: "company" */ './views/flow/settings/Company.vue'),
          }, {
            path: 'orgTypes',
            component: () => import (/* webpackChunkName: "orgTypes" */ './views/flow/settings/OrgTypes.vue'),
          }, {
            path: 'eventTypes',
            component: () => import (/* webpackChunkName: "orgTypes" */ './views/flow/settings/EventTypes.vue'),
          }, {
            path: 'workQueue',
            component: () => import (/* webpackChunkName: "workQueueAdmin" */ './views/flow/settings/WorkQueue.vue'),
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
            component: () => import (/* webpackChunkName: "customFields" */ './views/flow/settings/CustomFields.vue'),
          }, {
            path: 'customFieldGroup/:id',
            props: true,
            component: () => import (/* webpackChunkName: "customFieldGroup" */ './views/flow/settings/CustomFieldGroup.vue'),
          }, {
            path: 'attachments',
            component: () => import (/* webpackChunkName: "attachments" */ './views/flow/settings/Attachments.vue')
          }, {
            path: 'links',
            component: () => import (/* webpackChunkName: "links" */ './views/flow/settings/Links.vue')
          }, {
            path: 'processes',
            component: () => import (/* webpackChunkName: "processes" */ './views/flow/settings/Processes.vue')
          }, {
            path: 'processes/:id?',
            name: 'process',
            props: true,
            component: () => import (/* webpackChunkName: "process" */ './views/flow/settings/Process.vue')
          }, {
            path: 'processSteps',
            component: () => import (/* webpackChunkName: "processSteps" */ './views/flow/settings/ProcessSteps.vue')
          }, {
            path: 'processStep/:id',
            name: 'processStep',
            props: true,
            component: () => import (/* webpackChunkName: "processStep" */ './views/flow/settings/ProcessStep.vue'),
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
            component: () => import (/* webpackChunkName: "statuses" */ './views/flow/settings/Statuses.vue')
          }, {
            path: 'functions',
            component: () => import (/* webpackChunkName: "functions" */ './views/flow/settings/Functions.vue')
          }, {
            path: 'function/:id',
            component: () => import (/* webpackChunkName: "function" */ './views/flow/settings/Function.vue')
          }, {
            path: 'positions',
            component: () => import (/* webpackChunkName: "positions" */ './views/flow/settings/Positions.vue')
          },  {
            path: 'position/:id?',
            name: 'position',
            component: () => import (/* webpackChunkName: "role" */ './views/flow/settings/Position.vue')
          },  {
            path: 'roles',
            component: () => import (/* webpackChunkName: "roles" */ './views/flow/settings/Roles.vue')
          },  {
            path: 'role/:id?',
            name: 'role',
            component: () => import (/* webpackChunkName: "role" */ './views/flow/settings/Role.vue')
          },
        ]
      }, {
        path: '/workQueue',
        name: 'workQueue',
        component: () => {
          if(store.getters.userHasFeatureAccess('WORK_QUEUE')) {
            return import (/*webpackChunkName: "workQueue" */ './views/flow/workQueue/WorkQueue.vue')
          } else  {
            return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
          }
        },
      }, {
        path: '/workQueue/:id',
        name: 'workQueueDrilldown',
        component: () => {
          if(store.getters.userHasFeatureAccess('WORK_QUEUE')) {
            return import (/*webpackChunkName: "workQueueDrilldown" */ './views/flow/workQueue/WorkQueueDrilldown.vue')
          } else  {
            return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
          }
        },
      }, {
        path: '/project',
        name: 'project',
        component: () => {
          if(store.getters.userHasFeatureAccess('PROJECTS')) {
            return import (/*webpackChunkName: "project" */ './views/flow/project/Project.vue')
          } else  {
            return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
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
          }
        ]
      }, {
        path: '/customers',
        name: 'customers',
        component: () => {
          if(store.getters.userHasFeatureAccess('CUSTOMERS')) {
            return import (/*webpackChunkName: "customers" */ './views/flow/customers/Customers.vue')
          } else  {
            return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
          }
        },
        children: []
      }, {
        path: '/customer/:id',
        name: 'customer',
        props: true,
        component: () => {
          if(store.getters.userHasFeatureAccess('CUSTOMERS')) {
            return import (/*webpackChunkName: "customer" */ './views/flow/customers/Customer.vue')
          } else  {
            return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
          }
        },
        children: []
      }, {
        path: '/newCustomer',
        name: 'newCustomer',
        component: () => {
          if(store.getters.userHasFeatureAccess('CUSTOMERS')) {
            return import (/*webpackChunkName: "customer" */ './views/flow/customers/NewCustomer.vue')
          } else  {
            return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
          }
        },
        children: []
      }, {
        path: '/orgs/:orgFilter?',
        name: 'orgs',
        component: () => {
          if(store.getters.userHasFeatureAccess('ORGS')) {
            return import (/*webpackChunkName: "orgs" */ './views/flow/orgs/Orgs.vue')
          } else  {
            return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
          }
        },
        children: []
      }, {
        path: '/org/:id',
        name: 'org',
        props: true,
        component: () => {
          if(store.getters.userHasFeatureAccess('ORGS')) {
            return import (/*webpackChunkName: "org" */ './views/flow/orgs/Org.vue')
          } else  {
            return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
          }
        },
        children: []
      }, {
        path: '/newOrg',
        name: 'newOrg',
        component: () => {
          if(store.getters.userHasFeatureAccess('ORGS')) {
            return import (/*webpackChunkName: "newOrg" */ './views/flow/orgs/NewOrg.vue')
          } else  {
            return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
          }
        },
        children: []
      }, {
        path: '/admin',
        name: 'admin',
        component: () => {
          if(store.getters.userHasFeatureAccess('SYSTEM')) {
            return import (/* webpackChunkName: "admin" */ './views/flow/admin/Admin.vue')
          } else  {
            return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
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
      }
    ],

    }
  ]
})
