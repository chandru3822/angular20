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
        },
        {
          path: '/ahj/utility/:ahjUtilityId/details',
          name: 'ahjUtilityDetails',
          props: true,
          component: () => import (/* webpackChunkName: "ahjUtilityDetails" */ './views/ahj/utility/AhjUtilityDetails.vue')
        }]
    }
  ]
})
