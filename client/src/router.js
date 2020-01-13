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
      component: () => import(/* webpackChunkName: "home" */ './views/Home.vue'),
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
        path: 'schedule',
        name: 'schedule',
        props: true,
        component: () => import(/* webpackChunkName: "schedule" */ './views/flow/schedule/Schedule.vue')
      }, {
        path: 'users',
        name: 'users',
        component: () => import(/* webpackChunkName: "users" */ './views/flow/users/Users.vue')
      }, {
        path: '/user/:id',
        name: 'user',
        props: true,
        component: () => import (/*webpackChunkName: "user" */ './views/flow/users/User.vue'),
        children: []
      }, {
        path: '/newUser',
        name: 'newUser',
        component: () => import (/*webpackChunkName: "newUser" */ './views/flow/users/NewUser.vue'),
        children: []
      }, {
          path: '/ahj',
          name: 'ahj',
          component: () => import (/* webpackChunkName: "ahj" */ './views/ahj/Ahj.vue')
      }, {
        path: '/ahj/:ahjId',
        name: 'ahjDetails',
        props: true,
        component: () => import (/* webpackChunkName: "ahjDetails" */ './views/ahj/AhjDetails.vue'),
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
        component: () => import (/* webpackChunkName: "ahj" */ './views/ahj/utility/AhjUtility.vue')
      }, {
        path: '/ahjUtility/:ahjUtilityId/details',
        name: 'ahjUtilityDetails',
        props: true,
        component: () => import (/* webpackChunkName: "ahjUtilityDetails" */ './views/ahj/utility/AhjUtilityDetails.vue')
      }, {
        path: '/settings',
        name: 'settings',
        component: () => import (/* webpackChunkName: "settings" */ './views/flow/settings/Settings.vue'),
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
            path: 'workQueueTypes',
            component: () => import (/* webpackChunkName: "orgTypes" */ './views/flow/settings/WorkQueueTypes.vue'),
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
            path: 'permissions',
            component: () => import (/* webpackChunkName: "permissions" */ './views/flow/settings/Permissions.vue')
          },  {
            path: 'positions',
            component: () => import (/* webpackChunkName: "permissions" */ './views/flow/settings/Positions.vue')
          },  {
            path: 'roles',
            component: () => import (/* webpackChunkName: "permissions" */ './views/flow/settings/Roles.vue')
          },
        ]
      }, {
        path: '/project',
        name: 'project',
        component: () => import (/*webpackChunkName: "project" */ './views/flow/project/Project.vue'),
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
        path: '/leads',
        name: 'leads',
        component: () => import (/*webpackChunkName: "leads" */ './views/flow/leads/Leads.vue'),
        children: []
      }, {
        path: '/lead/:id',
        name: 'lead',
        props: true,
        component: () => import (/*webpackChunkName: "leads" */ './views/flow/leads/Lead.vue'),
        children: []
      }, {
        path: '/newLead',
        name: 'newLead',
        component: () => import (/*webpackChunkName: "leads" */ './views/flow/leads/NewLead.vue'),
        children: []
      }, {
        path: '/orgs/:orgFilter?',
        name: 'orgs',
        component: () => import (/*webpackChunkName: "orgs" */ './views/flow/orgs/Orgs.vue'),
        children: []
      }, {
        path: '/org/:id',
        name: 'org',
        props: true,
        component: () => import (/*webpackChunkName: "org" */ './views/flow/orgs/Org.vue'),
        children: []
      }, {
        path: '/newOrg',
        name: 'newOrg',
        component: () => import (/*webpackChunkName: "newOrg" */ './views/flow/orgs/NewOrg.vue'),
        children: []
      }
      ]
    }
  ]
})
