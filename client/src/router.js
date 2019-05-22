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
            component: () => import (/* webpackChunkName: "permit" */ './views/ahj/components/AhjPermit.vue')
          },
          {
            path: 'inspection',
            component: () => import (/* webpackChunkName: "inspection" */ './views/ahj/components/AhjInspection.vue')
          },
          {
            path: 'design',
            component: () => import (/* webpackChunkName: "design" */ './views/ahj/components/AhjDesign.vue')
          }
        ]
      }, {
        path: '/ahj/utility/:ahjUtilityId/details',
        name: 'ahjUtilityDetails',
        props: true,
        component: () => import (/* webpackChunkName: "ahjUtilityDetails" */ './views/ahj/utility/AhjUtilityDetails.vue')
      }, {
        path: '/settings',
        name: 'settings',
        component: () => import (/* webpackChunkName: "settings" */ './views/flow/settings/Settings.vue'),
        children: [
          {
            path: 'customFields',
            component: () => import (/* webpackChunkName: "customFields" */ './views/flow/settings/CustomFields.vue'),
            children: [
              {
                path: 'project',
                component: () => import (/* webpackChunkName: "project" */ './views/flow/settings/customFields/Project.vue')
              }, {
                path: 'customer',
                component: () => import (/* webpackChunkName: "project" */ './views/flow/settings/customFields/Customer.vue')
              }, {
                path: 'processSteps',
                component: () => import (/* webpackChunkName: "project" */ './views/flow/settings/customFields/ProcessSteps.vue')
              }, {
                path: 'user',
                component: () => import (/* webpackChunkName: "project" */ './views/flow/settings/customFields/User.vue')
              }

              ]
          }, {
            path: 'attachments',
            component: () => import (/* webpackChunkName: "attachments" */ './views/flow/settings/Attachments.vue')
          }, {
            path: 'links',
            component: () => import (/* webpackChunkName: "links" */ './views/flow/settings/Links.vue')
          }
        ]
      }]
    }
  ]
})
