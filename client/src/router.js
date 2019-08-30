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
        path: 'users',
        name: 'users',
        component: () => import(/* webpackChunkName: "users" */ './views/Users.vue')
      }, {
        path: 'users/:id',
        name: 'user',
        component: () => import (/* webpackChunkName: "user" */ './views/User.vue')
      }, {
        path: '/orgs',
        name: 'orgs',
        component: () => import (/* webpackChunkName: "orgs" */ './views/Orgs.vue'),
      }, {
        path: '/org/:orgId?',
        name: 'org',
        props: true,
        component: () => import (/* webpackChunkName: "org" */ './views/Org.vue')
      }, {
        path: '/ahjTest',
        name: 'ahjTest',
        component: () => import (/* webpackChunkName: "ahj" */ './views/ahj/Ahj_Test.vue')
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
            path: 'process/:id?',
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
          }

        ]
      }, {
        path: '/project',
        name: 'project',
        component: () => import (/*webpackChunkName: "project" */ './views/flow/project/Project.vue'),
        children: []
      }]
    }
  ]
})
