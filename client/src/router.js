import Vue from 'vue'
import Router from 'vue-router'
import Login from './views/Login.vue'
import ForgotPassword from './views/ForgotPassword.vue'
import PasswordReset from './views/PasswordReset.vue'
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
      path: '/forgotPassword',
      name: 'forgotPassword',
      component: ForgotPassword,
      props: true
    },
    {
      path: '/passwordReset/:uuid?',
      // path: 'passwordReset',
      name: 'passwordReset',
      component: PasswordReset,
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
      }
    }, {
      path: '/serverError',
      name: 'serverError',
      component: () => import(/* webpackChunkName: "serverError" */ './views/ServerError.vue')
    }, {
      path: '/accessDenied',
      name: 'accessDenied',
      component: () => import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
    }, {
      path: '/schedule',
      name: 'schedule',
      meta: { title: 'Albatross - Schedule'},
      props: true,
      component: () => {
        if(store.getters.userHasFeature('SCHEDULE')) {
          return import(/* webpackChunkName: "schedule" */ './views/flow/schedule/Schedule.vue')
        } else  {
          return accessDenied()
        }
      }
    }, {
      path: '/errorLog',
      name: 'errorLog',
      meta: { title: 'Albatross - Errors'},
      component: () => {
        if(store.getters.userHasFeature('ERROR_LOG')) {
          return import(/* webpackChunkName: "errors" */ './views/flow/ErrorLog.vue')
        } else  {
          return accessDenied()
        }
      }
    }, {
      path: '/users',
      name: 'users',
      meta: { title: 'Albatross - Users'},
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
      meta: { title: 'Albatross - User'},
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
          meta: { title: 'Albatross - User'},
          component: () => import (/* webpackChunkName: "userDetails" */ './views/flow/users/UserDetails.vue'),
        }, {
          path: 'positions',
          meta: { title: 'Albatross - User'},
          component: () => import (/* webpackChunkName: "userDetails" */ './views/flow/users/UserPositions.vue'),
        }, {
          path: 'access',
          meta: { title: 'Albatross - User'},
          component: () => {
            if(store.getters.userHasFeatureAccessLevel('ACCESS_CONTROL', 'VIEW')) {
              return import (/* webpackChunkName: "userDetails" */ './views/flow/users/UserAccess.vue')
            } else  {
              return accessDenied()
            }
          }
        }
      ]
    }, {
      path: '/newUser',
      name: 'newUser',
      meta: { title: 'Albatross - New User'},
      component: () => {
        if(store.getters.userHasFeatureAccessLevel('USERS', 'ADD')) {
          return import (/*webpackChunkName: "newUser" */ './views/flow/users/NewUser.vue')
        } else  {
          return accessDenied()
        }
      },
      children: []
    }, {
      path: '/closerDashboard',
      name: 'closerDashboard',
      meta: { title: 'Albatross - Closer Dashboard'},
      component: () => {
        if(store.getters.userHasFeature('CLOSER_DASHBOARD')) {
          return import (/* webpackChunkName: "closerDashboard" */ './views/blueraven/closerDashboard/CloserDashboard.vue')
        } else {
          return accessDenied()
        }
      }
    }, {
      path: '/setterDashboard',
      name: 'setterDashboard',
      meta: { title: 'Albatross - Setter Dashboard'},
      component: () => {
        if(store.getters.userHasFeature('SETTER_DASHBOARD')) {
          return import (/* webpackChunkName: "setterDashboard" */ './views/blueraven/setterDashboard/SetterDashboard.vue')
        } else {
          return accessDenied()
        }
      }
    },{
      path: '/closerAvailability',
      name: 'closerAvailability',
      meta: { title: 'Albatross - Closer Availability'},
      props: true,
      component: () => {
        if(store.getters.userHasFeature('CLOSER_AVAILABILITY')) {
          return import(/* webpackChunkName: "schedule" */ './views/blueraven/closerAvailability/CloserAvailability.vue')
        } else  {
          return accessDenied()
        }
      }
    }, {
      path: '/ahj',
      name: 'ahj',
      meta: { title: 'Albatross - AHJ'},
      component: () => {
        if(store.getters.userHasFeature('AHJ_DATABASE')) {
          return import (/* webpackChunkName: "ahj" */ './views/blueraven/ahj/Ahj.vue')
        } else  {
          return accessDenied()
        }
      },
    }, {
      path: '/ahj/:ahjId',
      name: 'ahjDetails',
      meta: { title: 'Albatross - AHJ'},
      props: true,
      component: () => {
        if(store.getters.userHasFeature('AHJ_DATABASE')) {
          return import (/* webpackChunkName: "ahjDetails" */ './views/blueraven/ahj/AhjDetails.vue')
        } else  {
          return accessDenied()
        }
      },
      children: [
        {
          path: 'permit',
          meta: { title: 'Albatross - AHJ'},
          component: () => import (/* webpackChunkName: "permit" */ './views/blueraven/ahj/AhjPermit.vue')
        },
        {
          path: 'inspection',
          meta: { title: 'Albatross - AHJ'},
          component: () => import (/* webpackChunkName: "inspection" */ './views/blueraven/ahj/AhjInspection.vue')
        },
        {
          path: 'design',
          meta: { title: 'Albatross - AHJ'},
          component: () => import (/* webpackChunkName: "design" */ './views/blueraven/ahj/AhjDesign.vue')
        }
      ]
    }, {
      path: '/ahjUtility',
      name: 'ahjUtilities',
      meta: { title: 'Albatross - AHJ'},
      component: () => {
        if(store.getters.userHasFeature('AHJ_DATABASE')) {
          return import (/* webpackChunkName: "ahj" */ './views/blueraven/ahj/utility/AhjUtility.vue')
        } else  {
          return accessDenied()
        }
      },
    }, {
      path: '/ahjUtility/:ahjUtilityId/details',
      name: 'ahjUtilityDetails',
      meta: { title: 'Albatross - AHJ'},
      props: true,
      component: () => {
        if(store.getters.userHasFeature('AHJ_DATABASE')) {
          return import (/* webpackChunkName: "ahjUtilityDetails" */ './views/blueraven/ahj/utility/AhjUtilityDetails.vue')
        } else  {
          return accessDenied()
        }
      },
    }, {
      path: '/settings',
      name: 'settings',
      meta: { title: 'Albatross - Settings'},
      component: () => import(/* webpackChunkName: "settings" */ './views/flow/settings/Settings.vue'),
      children: [
        {
          path: 'userProfile',
          meta: { title: 'Albatross - Settings'},
          component: () => import (/* webpackChunkName: "userProfile" */ './views/flow/settings/UserProfile.vue'),
        }, {
          path: 'company',
          meta: { title: 'Albatross - Settings'},
          component: () => {
            if(store.getters.userHasFeature('SETTINGS')) {
              return import (/* webpackChunkName: "company" */ './views/flow/settings/Company.vue')
            } else  {
              return accessDenied()
            }
          },
        }, {
          path: 'postalCodes',
          meta: { title: 'Albatross - Settings'},
          component: () => {
            if(store.getters.userHasFeature('SETTINGS')) {
              return import (/* webpackChunkName: "postalCodes" */ './views/flow/settings/PostalCodes.vue')
            } else  {
              return accessDenied()
            }
          },
        }, {
          path: 'postalCode/:id',
          meta: { title: 'Albatross - Settings'},
          component: () => {
            if(store.getters.userHasFeature('SETTINGS')) {
              return import (/* webpackChunkName: "postalCodes" */ './views/flow/settings/PostalCode.vue')
            } else  {
              return accessDenied()
            }
          },
        },{
          path: 'orgTypes',
          meta: { title: 'Albatross - Settings'},
          component: () => {
            if(store.getters.userHasFeature('SETTINGS')) {
              return import (/* webpackChunkName: "orgTypes" */ './views/flow/settings/OrgTypes.vue')
            } else  {
              return accessDenied()
            }
          },
        }, {
          path: 'eventTypes',
          meta: { title: 'Albatross - Settings'},
          component: () => {
            if(store.getters.userHasFeature('SETTINGS')) {
              return import (/* webpackChunkName: "eventTypes" */ './views/flow/settings/EventTypes.vue')
            } else  {
              return accessDenied()
            }
          },
        }, {
          path: 'workQueue',
          meta: { title: 'Albatross - Settings'},
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
              meta: { title: 'Albatross - Settings'},
              component: () => import (/* webpackChunkName: "workQueueTypes" */ './views/flow/settings/WorkQueueTypes.vue'),
            }, {
              path: 'categories',
              component: () => import (/* webpackChunkName: "workQueueCategories" */ './views/flow/settings/WorkQueueCategories.vue'),
            }
          ]
        }, {
          path: 'customFields',
          meta: { title: 'Albatross - Settings'},
          component: () => {
            if(store.getters.userHasFeature('SETTINGS')) {
              return import (/* webpackChunkName: "customFields" */ './views/flow/settings/CustomFields.vue')
            } else  {
              return accessDenied()
            }
          },
        }, {
          path: 'customFieldGroup/:id',
          meta: { title: 'Albatross - Settings'},
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
          meta: { title: 'Albatross - Settings'},
          component: () => {
            if(store.getters.userHasFeature('SETTINGS')) {
              return import (/* webpackChunkName: "attachments" */ './views/flow/settings/Attachments.vue')
            } else  {
              return accessDenied()
            }
          },
        }, {
          path: 'links',
          meta: { title: 'Albatross - Settings'},
          component: () => {
            if(store.getters.userHasFeature('SETTINGS')) {
              return import (/* webpackChunkName: "links" */ './views/flow/settings/Links.vue')
            } else  {
              return accessDenied()
            }
          },
        }, {
          path: 'processes',
          meta: { title: 'Albatross - Settings'},
          component: () => {
            if(store.getters.userHasFeature('SETTINGS')) {
              return import (/* webpackChunkName: "processes" */ './views/flow/settings/Processes.vue')
            } else  {
              return accessDenied()
            }
          },
        }, {
          path: 'processes/:id?',
          meta: { title: 'Albatross - Settings'},
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
          meta: { title: 'Albatross - Settings'},
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
          meta: { title: 'Albatross - Settings'},
          props: true,
          component: () => {
            if(store.getters.userHasFeature('SETTINGS')) {
              return import (/* webpackChunkName: "processStep" */ './views/flow/settings/processStep/ProcessStep.vue')
            } else  {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'components',
              meta: { title: 'Albatross - Settings'},
              component: () => import (/* webpackChunkName: "processStepComponents" */ './views/flow/settings/processStep/ProcessStepComponents.vue'),
            }, {
              path: 'customFieldGroups',
              props: true,
              meta: { title: 'Albatross - Settings'},
              component: () => import (/* webpackChunkName: "processStepComponents" */ './views/flow/settings/processStep/ProcessStepCFG.vue'),
            }, {
              path: 'actions',
              meta: { title: 'Albatross - Settings'},
              component: () => import (/* webpackChunkName: "processStepActions" */ './views/flow/settings/processStep/ProcessStepActions.vue'),
            }
          ]
        }, {
          path: 'statuses',
          meta: { title: 'Albatross - Settings'},
          component: () => {
            if(store.getters.userHasFeature('SETTINGS')) {
              return import (/* webpackChunkName: "statuses" */ './views/flow/settings/Statuses.vue')
            } else  {
              return accessDenied()
            }
          },
        }, {
          path: 'project',
          name: 'ProjectSettings',
          meta: {title: 'Albatross - Settings'},
          props: true,
          component: () => {
            if (store.getters.userHasFeature('SETTINGS')) {
              return import (/* webpackChunkName: "projectSettings" */ './views/flow/settings/project/Project.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'customFieldGroups',
              meta: {title: 'Albatross - Settings'},
              component: () => import (/* webpackChunkName: "projectSettings" */ './views/flow/settings/project/ProjectCustomFieldGroups.vue'),
            },
            {
              path: 'tabs',
              meta: {title: 'Albatross - Settings'},
              component: () => import (/* webpackChunkName: "projectSettings" */ './views/flow/settings/project/ProjectTabs.vue'),
            },
            {
              path: 'attachments',
              meta: {title: 'Albatross - Settings'},
              component: () => import (/* webpackChunkName: "projectSettings" */ './views/flow/settings/project/ProjectAttachments.vue'),
            }
          ]
        }, {
          path: 'functions',
          meta: { title: 'Albatross - Settings'},
          component: () => {
            if(store.getters.userHasFeature('SETTINGS')) {
              return import (/* webpackChunkName: "functions" */ './views/flow/settings/Functions.vue')
            } else  {
              return accessDenied()
            }
          },
        }, {
          path: 'function/:id',
          meta: { title: 'Albatross - Settings'},
          component: () => {
            if(store.getters.userHasFeature('SETTINGS')) {
              return import (/* webpackChunkName: "function" */ './views/flow/settings/Function.vue')
            } else  {
              return accessDenied()
            }
          },
        }, {
          path: 'availability',
          name: 'availability',
          meta: { title: 'Albatross - Settings'},
          redirect: "availability/schedule",
          props: true,
          component: () => {
            if(store.getters.userHasFeature('AVAILABILITY')) {
              return import (/* webpackChunkName: "availability" */ './views/flow/settings/availability/Availability.vue')
            } else  {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'schedule',
              meta: { title: 'Albatross - Settings'},
              props: true,
              component: () => import (/* webpackChunkName: "availability" */ './views/flow/settings/availability/Schedule.vue')
            }, {
              path: 'appointments',
              props: true,
              meta: { title: 'Albatross - Settings'},
              component: () => import (/* webpackChunkName: "availability" */ './views/flow/settings/availability/Appointments.vue')
            }
          ]
        }, {
          path: 'positions',
          meta: { title: 'Albatross - Settings'},
          component: () => {
            if(store.getters.userHasFeature('SETTINGS')) {
              return import (/* webpackChunkName: "positions" */ './views/flow/settings/Positions.vue')
            } else  {
              return accessDenied()
            }
          },
        },  {
          path: 'position/:id?',
          meta: { title: 'Albatross - Settings'},
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
          meta: { title: 'Albatross - Settings'},
          component: () => {
            if(store.getters.userHasFeature('SETTINGS')) {
              return import (/* webpackChunkName: "roles" */ './views/flow/settings/Roles.vue')
            } else  {
              return accessDenied()
            }
          },
        },  {
          path: 'role/:id?',
          meta: { title: 'Albatross - Settings'},
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
      meta: { title: 'Albatross - Work Queue'},
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
      meta: { title: 'Albatross - Work Queue'},
      component: () => {
        if(store.getters.userHasFeature('WORK_QUEUE')) {
          return import (/*webpackChunkName: "workQueueDrilldown" */ './views/flow/workQueue/WorkQueueDrilldown.vue')
        } else  {
          return accessDenied()
        }
      },
    }, {
      path: '/projects',
      name: 'projects',
      meta: { title: 'Albatross - Projects'},
      component: () => {
        if (store.getters.userHasFeature('PROJECTS')) {
          return import (/*webpackChunkName: "projects" */ './views/flow/project/Projects.vue')
        } else {
          return accessDenied()
        }
      },
    }, {
      name: 'projectAdmin',
      path: '/projectAdmin/:projectId',
      meta: { title: 'Albatross - Projects'},
      component: () => {
        if (store.getters.userHasFeatureAccessLevel('PROJECTS', 'ADMIN')) {
          return import (/*webpackChunkName: "projectAdmin" */ './views/flow/project/ProjectAdmin.vue')
        } else {
          return accessDenied()
        }
      }
    }, {
      name: 'projectProcessStep',
      path: '/project/:projectId/processStep/:processStepId',
      component: () => {
        if (store.getters.userHasFeature('PROCESS_STEPS')) {
          return import (/*webpackChunkName: "projectAdmin" */ './views/flow/project/ProjectProcessStep.vue')
        } else {
          return accessDenied()
        }
      }
    }, {
      path: '/project/:projectId',
      name: 'project',
      meta: { title: 'Albatross - Project'},
      component: () => {
        if(store.getters.userHasFeature('PROJECTS')) {
          return import (/*webpackChunkName: "project" */ './views/flow/project/Project.vue')
        } else  {
          return accessDenied()
        }
      },
      children: [{
        path: 'details',
        name: 'projectDetails',
        meta: { title: 'Albatross - Project Details'},
        // component: () => import (/*webpackChunkName: "projectDetails" */ './views/flow/project/ProjectDetails.vue')
        components: {
          default: () => import (/*webpackChunkName: "projectDetails" */ './views/flow/project/ProjectDetails.vue'),
          tabs: () => import (/*webpackChunkName: "projectDetails" */ './views/flow/project/ProjectDetails.vue'),
        }
      }, {
        path: 'notes',
        name: 'projectNotes',
        meta: { title: 'Albatross - Project Notes'},
        component: () => import (/*webpackChunkName: "projectNotes" */ './views/flow/project/ProjectNotes.vue')
      }
      ]
    }, {
      path: '/contacts',
      name: 'contacts',
      meta: { title: 'Albatross - Contacts'},
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
      meta: { title: 'Albatross - Contact'},
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
      props: true,
      component: () => {
        if(store.getters.userHasFeatureAccessLevel('CONTACTS', 'ADD')) {
          return import (/*webpackChunkName: "contact" */ './views/flow/contacts/NewContact.vue')
        } else  {
          return accessDenied()
        }
      },
      children: []
    }, {
      path: '/orgs/:orgFilter?',
      name: 'orgs',
      meta: { title: 'Albatross - Orgs'},
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
      meta: { title: 'Albatross - Org'},
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
      meta: { title: 'Albatross - New Org'},
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
      meta: { title: 'Albatross - Commissions'},
      component: () => {
        if(store.getters.userHasFeature('COMMISSIONS')) {
          return import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/CommissionManagement.vue')
        } else  {
          return accessDenied()
        }
      },
      children: [
        {
          path: 'closers',
          meta: { title: 'Albatross - Commissions'},
          component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/Closers.vue'),
        }, {
          path: 'closers/:id',
          meta: { title: 'Albatross - Commissions'},
          name: 'closer',
          component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/Closer.vue'),
        }, {
          path: 'commissions',
          name: 'commissions',
          meta: { title: 'Albatross - Commissions'},
          component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/Commissions.vue'),
        }, {
          path: 'commission/:id?',
          name: 'commission',
          meta: { title: 'Albatross - Commissions'},
          component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/Commission.vue'),
        }, {
          path: 'overrides',
          name: 'overrides',
          meta: { title: 'Albatross - Commissions'},
          component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/Overrides.vue'),
        }, {
          path: 'override/:id?',
          name: 'override',
          meta: { title: 'Albatross - Commissions'},
          component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/Override.vue'),
        }, {
          path: 'accounting',
          meta: { title: 'Albatross - Commissions'},
          component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/Accounting.vue'),
          children: [
            {
              path: 'current',
              meta: { title: 'Albatross - Commissions'},
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/CurrentPayroll.vue'),
            }, {
              path: 'summary',
              meta: { title: 'Albatross - Commissions'},
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/Summary.vue'),
            }
          ]
        }, {
          path: 'payroll',
          meta: { title: 'Albatross - Commissions'},
          name: 'payrolls',
          component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/Payrolls.vue'),
        }, {
          path: 'payroll/:id',
          name: 'payroll',
          meta: { title: 'Albatross - Commissions'},
          component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/Payroll.vue'),
          children: [
            {
              path: 'review',
              meta: { title: 'Albatross - Commissions'},
              name: 'payrollReview',
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/PayrollReview.vue'),
            }, {
              path: 'summary',
              name: 'payrollSummary',
              meta: { title: 'Albatross - Commissions'},
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/PayrollSummary.vue'),
            }
          ]
        },  {
          path: 'residualPlans',
          name: 'residualPlans',
          meta: { title: 'Albatross - Commissions'},
          component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/ResidualPlans.vue'),
        }, {
          path: 'residualPlan/:id?',
          name: 'residualPlan',
          meta: { title: 'Albatross - Commissions'},
          component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/ResidualPlan.vue'),
        }, {
          path: 'residuals',
          meta: { title: 'Albatross - Commissions'},
          component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/Residuals.vue'),
        },
      ]
    }, {
      path: '/finances',
      name: 'finances',
      meta: { title: 'Albatross - Finances'},
      component: () => import (/* webpackChunkName: "finances" */ './views/blueraven/finances/rebate/Rebate.vue'),
      children: [
        {
          path: 'rebate/batches',
          meta: { title: 'Albatross - Finances'},
          component: () => import (/* webpackChunkName: "finances" */ './views/blueraven/finances/rebate/Batches.vue')
        },{
          path: 'rebate/viewPayments',
          meta: { title: 'Albatross - Finances'},
          component: () => import (/* webpackChunkName: "finances" */ './views/blueraven/finances/rebate/ViewPayments.vue'),
        },{
          path: 'rebate/batches/:id',
          name: 'rebateDetails',
          meta: { title: 'Albatross - Finances'},
          component: () => import (/* webpackChunkName: "finances" */ './views/blueraven/finances/rebate/RebateDetails.vue'),
        }
      ]
    }, {
      path: '/installation-agreements',
      name: 'installation-agreements',
      meta: { title: 'Albatross - Installation Agreements'},
      component: () => import (/* webpackChunkName: "finances" */ './views/blueraven/installationAgreements/InstallationAgreements.vue'),
      children: [
        {
          path: 'request',
          component: () => import (/* webpackChunkName: "request" */ './views/blueraven/installationAgreements/Request.vue')
        }
      ]
    }, {
      path: '/smartlist',
      meta: { title: 'Albatross - Smartlists'},
      component: () => {
        if(store.getters.userHasFeature('SMARTLIST')) {
          return import (/* webpackChunkName: "smartlist" */ './views/flow/smartlist/SmartlistHome.vue')
        } else  {
          return accessDenied()
        }
      },
      children: [{
        path: '',
        meta: { title: 'Albatross - Smartlists'},
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
        meta: { title: 'Albatross - Smartlists'},
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
    },{
      path: '/proposal',
      name: 'proposal',
      meta: { title: 'Albatross - Proposals'},
      component: () => {
        if(store.getters.userHasFeature('PROPOSALS')) {
          return import (/* webpackChunkName: "admin" */ './views/flow/proposal/Menu.vue')
        } else  {
          return accessDenied()
        }
      },
      children: [
        {
          path: 'create',
          name: 'create',
          meta: { title: 'Albatross - Proposals'},
          component: () => {
            if(store.getters.userHasFeatureAccessLevel('PROPOSALS', 'CREATE')) {
              return import (/* webpackChunkName: "proposal" */ './views/flow/proposal/Create.vue')
            } else  {
              return accessDenied()
            }
          }
        },
        {
          path: 'search',
          name: 'search',
          meta: { title: 'Albatross - Proposals'},
          component: () => import (/* webpackChunkName: "proposal" */ './views/flow/proposal/Search.vue'),
        }, {
          path: 'export',
          name: 'export',
          meta: { title: 'Albatross - Proposals'},
          component: () => import (/* webpackChunkName: "proposal" */ './views/flow/proposal/Export.vue'),
        }, {
          path: 'recreate',
          name: 'recreate',
          meta: { title: 'Albatross - Proposals'},
          component: () => import (/* webpackChunkName: "proposal" */ './views/flow/proposal/Search.vue'),
        }, {
          path: ':proposalId',
          name: 'modify',
          meta: { title: 'Albatross - Proposals'},
          component: () => import (/* webpackChunkName: "proposal" */ './views/flow/proposal/Create.vue'),
        }
      ]
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
