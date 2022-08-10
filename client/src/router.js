import Vue from "vue"
import Router from 'vue-router'
import Login from './views/Login.vue'
import ForgotPasswordReset from './views/ForgotPasswordReset.vue'
import store from './store'
import {UserMutations} from './stores/UserStore'
import {getRequest} from '@/helpers/helpers'
import ProposalVersionSettingsRoutes from '@/views/blueraven/settings/proposals/routes'
import ProposalDesignerRoutes from '@/views/blueraven/settings/proposalDesigner/routes'
import {AppMutations} from "@/stores/AppStore";

Vue.use(Router)

const router = new Router({
  mode: 'history',
  base:  import.meta.env.BASE_URL,
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
      component: () => import(/* webpackChunkName: "forgotPassword" */'./views/ForgotPassword.vue')
    },
    {
      path: '/siteUnderMaintenance',
      name: 'siteUnderMaintenance',
      component: () => import(/* webpackChunkName: "forgotPassword" */'./views/SiteUnderMaintenance.vue')
    },
    {
      path: '/passwordReset/:uuid?',
      name: 'forgotPasswordReset',
      component: ForgotPasswordReset,
      // component: () => import(/* webpackChunkName: "passwordReset" */ './views/ForgotPasswordReset.vue'),
      props: true
    },
    {
      path: '/resetPassword',
      name: 'resetPassword',
      component: () => import(/* webpackChunkName: "resetPassword" */ './views/ResetPassword.vue'),
      props: true
    },
    {
      path: '/',
      name: 'root',
      redirect: 'home',
      component: () => {
        if (store.getters.userHasAnyFeature) {
          return import(/* webpackChunkName: "home" */ './views/Root.vue')
        } else {
          return accessDenied()
        }
      },
      beforeEnter: async (to, from, next) => {
        if (!store.state.user.authorized && from.name !== 'login') {
          //only re-route back to login if not already on login
          next('/login')
        } else {
          if (from.name !== 'login') {
            try {
              const {data} = await getUser()
              store.commit(UserMutations.SET_DETAILS, data)
              next()
            } catch (e) {
              next('/login')
            }
          } else {
            //had to do the matching or it just does a continuous loop if the user has a homepagepath
            if (store.state.user.details.homePagePath && to.path !== store.state.user.details.homePagePath) {
              router.push({path: store.state.user.details.homePagePath})
            } else {
              next()
            }
          }
        }
      },
      children: [
        {
          path: 'home',
          name: 'home',
          component: () => {
            if (store.getters.userHasAnyFeature) {
              return import(/* webpackChunkName: "home" */ './views/Home.vue')
            } else {
              return accessDenied()
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
          meta: {title: 'Albatross - Schedule'},
          props: true,
          component: () => {
            if (store.getters.userHasFeature('SCHEDULE')) {
              return import(/* webpackChunkName: "schedule" */ './views/flow/schedule/Schedule.vue')
            } else {
              return accessDenied()
            }
          }
        }, {
          path: '/apps',
          name: 'appDownloads',
          meta: {title: 'Albatross - App Download'},
          props: true,
          component: () => {
            if (store.getters.userHasFeature('APP_DOWNLOADS')) {
              return import(/* webpackChunkName: "appDownloads" */ './views/flow/appDownloads/AppDownloads.vue')
            } else {
              return accessDenied()
            }
          }
        }, {
          path: '/errorLog',
          name: 'errorLog',
          meta: {title: 'Albatross - Errors'},
          component: () => {
            if (store.getters.userHasFeature('ERROR_LOG')) {
              return import(/* webpackChunkName: "errors" */ './views/flow/ErrorLog.vue')
            } else {
              return accessDenied()
            }
          }
        }, {
          path: '/users',
          name: 'users',
          meta: {title: 'Albatross - Users'},
          component: () => {
            if (store.getters.userHasFeature('USERS')) {
              return import(/* webpackChunkName: "users" */ './views/flow/users/Users.vue')
            } else {
              return accessDenied()
            }
          }
        }, {
          path: '/user/:id',
          name: 'user',
          meta: {title: 'Albatross - User'},
          props: true,
          component: () => {
            if (store.getters.userHasFeature('USERS')) {
              return import (/* webpackChunkName: "userDetails" */ './views/flow/users/User.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'details',
              name: 'userDetails',
              meta: {title: 'Albatross - User'},
              component: () => import (/* webpackChunkName: "userDetails" */ './views/flow/users/UserDetails.vue'),
            }, {
              path: 'positions',
              meta: {title: 'Albatross - User'},
              component: () => import (/* webpackChunkName: "userDetails" */ './views/flow/users/UserPositions.vue'),
            }, {
              path: 'access',
              meta: {title: 'Albatross - User'},
              component: () => {
                if (store.getters.userHasFeatureAccessLevel('ACCESS_CONTROL', 'VIEW')) {
                  return import (/* webpackChunkName: "userDetails" */ './views/flow/users/UserAccess.vue')
                } else {
                  return accessDenied()
                }
              }
            }
          ]
        }, {
          path: '/newUser',
          name: 'newUser',
          meta: {title: 'Albatross - New User'},
          component: () => {
            if (store.getters.userHasFeatureAccessLevel('USERS', 'ADD')) {
              return import (/* webpackChunkName: "newUser" */ './views/flow/users/NewUser.vue')
            } else {
              return accessDenied()
            }
          },
          children: []
        }, {
          path: '/reimbursement',
          name: 'reimbursement',
          meta: {title: 'Albatross - Reimbursement'},
          component: () => {
            if (store.getters.userHasFeature('REIMBURSEMENT')) {
              return import (/* webpackChunkName: "reimbursement" */ './views/blueraven/expenses/Reimbursement.vue')
            } else {
              return accessDenied()
            }
          },
        }, {
          path: '/expenses',
          name: 'expenses',
          meta: {title: 'Albatross - Expenses'},
          component: () => {
            if (store.getters.userHasFeature('EXPENSES')) {
              return import (/* webpackChunkName: "expenses" */ './views/blueraven/expenses/Expenses.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'reimbursementRequests',
              name: 'reimbursementRequests',
              meta: {title: 'Albatross - Reimbursement Requests'},
              component: () => {
                if (store.getters.userHasFeatureAccessLevel('EXPENSES', 'ADMIN')) {
                  return import (/* webpackChunkName: "expenses" */ './views/blueraven/expenses/ReimbursementRequests.vue')
                } else {
                  return accessDenied()
                }
              },
            },
            {
              path: 'submittedExpenses',
              name: 'submittedExpenses',
              meta: {title: 'Albatross - Submitted Expenses'},
              component: () => {
                if (store.getters.userHasFeatureAccessLevel('EXPENSES', 'ADMIN')) {
                  return import (/* webpackChunkName: "expenses" */ './views/blueraven/expenses/SubmittedExpenses.vue')
                } else {
                  return accessDenied()
                }
              },
            },
            {
              path: 'glCodes',
              name: 'glCodes',
              meta: {title: 'Albatross - GL Codes'},
              component: () => {
                if (store.getters.userHasFeatureAccessLevel('EXPENSES', 'ADMIN')) {
                  return import (/* webpackChunkName: "expenses" */ './views/blueraven/expenses/GlCodes.vue')
                } else {
                  return accessDenied()
                }
              },
            },
            {
              path: 'monthlyBudgets',
              name: 'monthlyBudgets',
              meta: {title: 'Albatross - Expense Budgets'},
              component: () => {
                if (store.getters.userHasFeatureAccessLevel('EXPENSES', 'ADMIN')) {
                  return import (/* webpackChunkName: "expenses" */ './views/blueraven/expenses/MonthlyBudgets.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'budgetTypes',
              name: 'expenseBudgetTypes',
              meta: {title: 'Albatross - Budget Types'},
              component: () => {
                if (store.getters.userHasFeatureAccessLevel('EXPENSES', 'ADMIN')) {
                  return import (/* webpackChunkName: "expenses" */ './views/blueraven/expenses/BudgetTypes.vue')
                } else {
                  return accessDenied()
                }
              },
            }
          ]
        }, {
          path: '/closer',
          name: 'closer',
          meta: {title: 'Albatross - Closer Dashboard'},
          component: () => {
            if (store.getters.userHasFeature('CLOSER_DASHBOARD')) {
              return import (/* webpackChunkName: "closerDashboard" */ './views/blueraven/closerDashboard/Closer.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'dashboard',
              name: 'closerDashboard',
              meta: {title: 'Albatross - Closer Dashboard'},
              component: () => import (/* webpackChunkName: "closerDashboard" */ './views/blueraven/closerDashboard/CloserDashboard.vue')
            }, {
              path: 'funnel',
              alias: '/closerDashboard',
              name: 'closerFunnel',
              meta: {title: 'Albatross - Closer Dashboard'},
              component: () => import (/* webpackChunkName: "closerDashboard" */ './views/blueraven/closerDashboard/CloserFunnel.vue')
            }, {
              path: 'incentive',
              name: 'closerIncentive',
              meta: {title: 'Albatross - Closer Dashboard'},
              component: () => import (/* webpackChunkName: "closerDashboard" */ './views/blueraven/closerDashboard/CloserIncentive.vue')
            }
          ]
        }, {
          path: 'setter',
          name: 'setter',
          meta: {title: 'Albatross - Setter Dashboard'},
          component: () => {
            if (store.getters.userHasFeature('SETTER_DASHBOARD')) {
              return import (/* webpackChunkName: "setterDashboard" */ './views/blueraven/setterDashboard/Setter.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'dashboard',
              name: 'setterDashboard',
              meta: {title: 'Albatross - Setter Dashboard'},
              component: () => import (/* webpackChunkName: "setterDashboard" */ './views/blueraven/setterDashboard/SetterDashboard.vue')
            }, {
              path: 'funnel',
              alias: '/setterDashboard',
              name: 'setterFunnel',
              meta: {title: 'Albatross - Setter Dashboard'},
              component: () => import (/* webpackChunkName: "setterDashboard" */ './views/blueraven/setterDashboard/SetterFunnel.vue')
            }, {
              path: 'incentive',
              name: 'setterIncentive',
              meta: {title: 'Albatross - Setter Dashboard'},
              component: () => import (/* webpackChunkName: "setterDashboard" */ './views/blueraven/setterDashboard/SetterIncentive.vue')
            }
          ]
        }, {
          path: '/companyDashboard',
          name: 'companyDashboard',
          meta: {title: 'Albatross - Company Dashboard'},
          component: () => {
            if (store.getters.userHasFeature('COMPANY_DASHBOARD')) {
              return import (/* webpackChunkName: "companyDashboard" */ './views/blueraven/companyDashboard/CompanyDashboard.vue')
            } else {
              return accessDenied()
            }
          }
        }, {
          path: '/companyDashboardTargets',
          name: 'companyDashboardTargets',
          meta: {title: 'Albatross - Company Dashboard Targets'},
          component: () => {
            if (store.getters.userHasFeatureAccessLevel('COMPANY_DASHBOARD', 'ADMIN')) {
              return import (/* webpackChunkName: "companyDashboardTargets" */ './views/blueraven/companyDashboard/CompanyDashboardTargets.vue')
            } else {
              return accessDenied()
            }
          }
        }, {
          path: '/closerAvailability',
          name: 'closerAvailability',
          meta: {title: 'Albatross - Closer Availability'},
          props: true,
          component: () => {
            if (store.getters.userHasFeatureAccessLevel('CLOSER_AVAILABILITY', 'VIEW') || store.getters.userHasFeatureAccessLevel('CLOSER_AVAILABILITY', 'VIEW_DOWNLINE') || store.getters.userHasFeatureAccessLevel('CLOSER_AVAILABILITY', 'VIEW_ALL')) {
              return import(/* webpackChunkName: "closerAvailability" */ './views/blueraven/closerAvailability/CloserAvailability.vue')
            } else {
              return accessDenied()
            }
          }
        }, {
          path: '/ahj',
          name: 'ahj',
          meta: {title: 'Albatross - AHJ'},
          component: () => {
            if (store.getters.userHasFeature('AHJ_DATABASE')) {
              return import (/* webpackChunkName: "ahj" */ './views/blueraven/ahj/Ahj.vue')
            } else {
              return accessDenied()
            }
          },
        }, {
          path: '/ahj/:ahjId',
          name: 'ahjDetails',
          meta: {title: 'Albatross - AHJ'},
          props: true,
          component: () => {
            if (store.getters.userHasFeature('AHJ_DATABASE')) {
              return import (/* webpackChunkName: "ahjDetails" */ './views/blueraven/ahj/AhjDetails.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'permit',
              meta: {title: 'Albatross - AHJ'},
              component: () => import (/* webpackChunkName: "ahjDetails" */ './views/blueraven/ahj/AhjPermit.vue')
            },
            {
              path: 'inspection',
              meta: {title: 'Albatross - AHJ'},
              component: () => import (/* webpackChunkName: "ahjDetails" */ './views/blueraven/ahj/AhjInspection.vue')
            },
            {
              path: 'design',
              meta: {title: 'Albatross - AHJ'},
              component: () => import (/* webpackChunkName: "ahjDetails" */ './views/blueraven/ahj/AhjDesign.vue')
            }
          ]
        }, {
          path: '/ahjUtility',
          name: 'ahjUtilities',
          meta: {title: 'Albatross - AHJ'},
          component: () => {
            if (store.getters.userHasFeature('AHJ_DATABASE')) {
              return import (/* webpackChunkName: "ahjUtilities" */ './views/blueraven/ahj/utility/AhjUtility.vue')
            } else {
              return accessDenied()
            }
          },
        }, {
          path: '/ahjUtility/:ahjUtilityId/details',
          name: 'ahjUtilityDetails',
          meta: {title: 'Albatross - AHJ'},
          props: true,
          component: () => {
            if (store.getters.userHasFeature('AHJ_DATABASE')) {
              return import (/* webpackChunkName: "ahjUtilityDetails" */ './views/blueraven/ahj/utility/AhjUtilityDetails.vue')
            } else {
              return accessDenied()
            }
          },
        },
        //TOURNAMENT STUFF
        {
          path: '/tournament/:id',
          name: 'tournament',
          props: true,
          component: () => {
            if (store.getters.userHasFeature('TOURNAMENTS')) {
              return import (/* webpackChunkName: "tournaments" */ './views/blueraven/tournament/Tournament.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'qualifying',
              name: 'tournamentQualifying',
              component: () => import (/* webpackChunkName: "tournaments" */ './views/blueraven/tournament/Qualifying.vue')
            },
            {
              path: 'bracket',
              name: 'tournamentBracket',
              component: () => import (/* webpackChunkName: "tournaments" */ './views/blueraven/tournament/Bracket.vue')
            },
            {
              path: 'lastChance',
              name: 'tournamentLastChance',
              component: () => import (/* webpackChunkName: "tournaments" */ './views/blueraven/tournament/LastChance.vue')
            },
            {
              path: 'winners',
              name: 'tournamentWinners',
              component: () => import (/* webpackChunkName: "tournaments" */ './views/blueraven/tournament/Winners.vue')
            }
          ]
        },
        //END TOURNAMENT STUFF

        {
          path: '/settings',
          name: 'settings',
          meta: {title: 'Albatross - Settings'},
          component: () => import(/* webpackChunkName: "settings" */ './views/flow/settings/Settings.vue'),
          children: [
            ProposalVersionSettingsRoutes,
            ProposalDesignerRoutes,
            {
              path: 'attachments',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "attachments" */ './views/flow/settings/Attachments.vue')
                } else {
                  return accessDenied()
                }
              }
            }, {
              path: 'companyCustomFields',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "companyCustomFields" */ './views/flow/settings/CompanyCustomFields.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'companyObjectTypes',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "companyObjectTypes" */ './views/flow/settings/companyObjectType/CompanyObjectTypes.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'companyObjectTypes/:id',
              name: 'companyObjectTypes',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "companyObjectTypes" */ './views/flow/settings/companyObjectType/CompanyObjectType.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'tournaments',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeatureAccessLevel('TOURNAMENTS', 'ADMIN') ) {
                  return import (/* webpackChunkName: "tournamentSettings" */ './views/flow/settings/tournaments/Tournaments.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'tournaments/:id',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeatureAccessLevel('TOURNAMENTS', 'ADMIN') ) {
                  return import (/* webpackChunkName: "tournamentSettings" */ './views/flow/settings/tournaments/Tournament.vue')
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'details',
                  meta: {title: 'Albatross - Settings'},
                  component: () => import (/* webpackChunkName: "tournamentSettings" */ './views/flow/settings/tournaments/TournamentDetails.vue'),
                },
                {
                  path: 'brackets',
                  meta: {title: 'Albatross - Settings'},
                  component: () => import (/* webpackChunkName: "tournamentSettings" */ './views/flow/settings/tournaments/Bracket.vue'),
                },
                {
                  path: 'pool/:poolTypeId',
                  meta: {title: 'Albatross - Settings'},
                  component: () => import (/* webpackChunkName: "tournamentSettings" */ './views/flow/settings/tournaments/Pool.vue'),
                },
              ]
            },
            {
              path: 'states',
              meta: {title: 'Albatross - Settings'},
              component: () => import (/* webpackChunkName: "states" */ './views/flow/settings/States.vue'),
            },
            {
              path: 'userProfile',
              meta: {title: 'Albatross - Settings'},
              component: () => import (/* webpackChunkName: "userProfile" */ './views/flow/settings/UserProfile.vue'),
            }, {
              path: 'userProfileAdmin',
              meta: {title: 'Albatross - Settings'},
              component: () => import (/* webpackChunkName: "userProfileAdmin" */ './views/flow/settings/UserProfileAdmin.vue'),
            }, {
              path: 'company',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "company" */ './views/flow/settings/defaults/Defaults.vue')
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'settings',
                  meta: {title: 'Albatross - Settings'},
                  component: () => {
                    if (store.getters.userHasFeature('SETTINGS')) {
                      return import (/* webpackChunkName: "company" */ './views/flow/settings/defaults/CompanySettings.vue')
                    } else {
                      return accessDenied()
                    }
                  },
                }, {
                  path: 'configurations',
                  meta: {title: 'Albatross - Settings'},
                  component: () => {
                    if (store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADMIN')) {
                      return import (/* webpackChunkName: "company" */ './views/flow/settings/defaults/Configurations.vue')
                    } else {
                      return accessDenied()
                    }
                  },
                },
          {
                  path: 'email',
                  meta: {title: 'Albatross - Settings'},
                  component: () => {
                    if (store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADMIN')) {
                      return import (/* webpackChunkName: "company" */ './views/flow/settings/defaults/EmailSettings.vue')
                    } else {
                      return accessDenied()
                    }
                  },
                }
              ]
            }, {
              path: 'postalCodes',
              meta: {title: 'Albatross - Round Robin'},
              component: () => {
                if (store.getters.userHasFeature('ROUND_ROBIN')) {
                  return import (/* webpackChunkName: "postalCodes" */ './views/flow/settings/postalCodeZones/PostalCodes.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'postalCode/:id',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "postalCodes" */ './views/flow/settings/postalCodeZones/PostalCode.vue')
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'scheduleTo',
                  meta: {title: 'Albatross - Settings'},
                  component: () => import (/* webpackChunkName: "postalCodes" */ './views/flow/settings/postalCodeZones/ScheduleTo.vue'),
                }, {
                  path: 'scheduleBy',
                  component: () => import (/* webpackChunkName: "postalCodes" */ './views/flow/settings/postalCodeZones/ScheduleBy.vue'),
                }, {
                  path: 'codes',
                  component: () => import (/* webpackChunkName: "postalCodes" */ './views/flow/settings/postalCodeZones/Codes.vue'),
                }
              ]
            }, {
              path: 'callGroups',
              meta: {title: 'Albatross - Call Groups'},
              component: () => {
                if (store.getters.userHasFeature('CALL_GROUPS')) {
                  return import (/* webpackChunkName: "callGroups" */ './views/flow/settings/callGroups/CallGroups.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'callGroup/:id',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "callGroups" */ './views/flow/settings/callGroups/PostalCode.vue')
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'codes',
                  component: () => import (/* webpackChunkName: "callGroups" */ './views/flow/settings/callGroups/Codes.vue'),
                },
                {
                  path: 'numbers',
                  component: () => import (/* webpackChunkName: "callGroups" */ './views/flow/settings/callGroups/Numbers.vue'),
                }
              ]
            }, {
              path: 'orgTypes',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "orgTypes" */ './views/flow/settings/OrgTypes.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'messageTemplates',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "orgTypes" */ './views/flow/settings/MessageTemplate.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'dataViews',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeatureAccessLevel('DATA_VIEW', 'ADMIN')) {
                  return import (/* webpackChunkName: "dataViews" */ './views/flow/settings/DataViews.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'dataView/:id',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeatureAccessLevel('DATA_VIEW', 'ADMIN')) {
                  return import (/* webpackChunkName: "dataViews" */ './views/flow/settings/DataView.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'workQueue',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS') || store.getters.userHasFeatureAccessLevel('WORK_QUEUE', 'ADMIN')) {
                  return import (/* webpackChunkName: "workQueueAdmin" */ './views/flow/settings/WorkQueue.vue')
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'types',
                  meta: {title: 'Albatross - Settings'},
                  component: () => import (/* webpackChunkName: "workQueueAdmin" */ './views/flow/settings/WorkQueueTypes.vue'),
                }, {
                  path: 'type/:id',
                  name: 'workQueueType',
                  meta: {title: 'Albatross - Settings'},
                  component: () => import (/* webpackChunkName: "workQueueAdmin" */ './views/flow/settings/WorkQueueType.vue'),
                }, {
                  path: 'categories',
                  component: () => import (/* webpackChunkName: "workQueueAdmin" */ './views/flow/settings/WorkQueueCategories.vue'),
                }
              ]
            }, {
              path: 'customFields',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "customFields" */ './views/flow/settings/FlowCustomFields.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'objectType/:id',
              meta: {title: 'Albatross - Settings'},
              props: true,
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "objectType" */ './views/flow/settings/objectType/ObjectType.vue')
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'customFieldGroups',
                  meta: {title: 'Albatross - Settings'},
                  component: () => import (/* webpackChunkName: "objectType" */ './views/flow/settings/objectType/CustomFieldGroup.vue'),
                }, {
                  path: 'attachments',
                  meta: {title: 'Albatross - Settings'},
                  component: () => import (/* webpackChunkName: "objectType" */ './views/flow/settings/objectType/ObjectTypeAttachments.vue'),
                }
              ]
            }, {
              path: 'links',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "links" */ './views/flow/settings/Links.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'processes',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "processes" */ './views/flow/settings/Processes.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'processes/:id?',
              meta: {title: 'Albatross - Settings'},
              name: 'process',
              props: true,
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "processes" */ './views/flow/settings/Process.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'processSteps',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "processSteps" */ './views/flow/settings/ProcessSteps.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'processStep/:id',
              name: 'processStep',
              meta: {title: 'Albatross - Settings'},
              props: true,
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "processSteps" */ './views/flow/settings/processStep/ProcessStep.vue')
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'components',
                  meta: {title: 'Albatross - Settings'},
                  component: () => import (/* webpackChunkName: "processSteps" */ './views/flow/settings/processStep/ProcessStepComponents.vue'),
                }, {
                  path: 'customFieldGroups',
                  props: true,
                  meta: {title: 'Albatross - Settings'},
                  component: () => import (/* webpackChunkName: "processSteps" */ './views/flow/settings/processStep/ProcessStepCFG.vue'),
                }, {
                  path: 'actions',
                  meta: {title: 'Albatross - Settings'},
                  component: () => import (/* webpackChunkName: "processSteps" */ './views/flow/settings/processStep/ProcessStepActions.vue'),
                }, {
                  path: 'events',
                  meta: {title: 'Albatross - Settings'},
                  component: () => import (/* webpackChunkName: "processSteps" */ './views/flow/settings/processStep/ProcessStepEvents.vue'),
                  children: [
                    {
                      path: ':eventId',
                      meta: {title: 'Albatross - Settings'},
                      component: () => import (/* webpackChunkName: "processSteps" */ './views/flow/settings/processStep/ProcessStepEvent.vue'),
                    }
                  ]
                }, {
                  path: 'event/:eventId',
                  meta: {title: 'Albatross - Settings'},
                  component: () => import (/* webpackChunkName: "processSteps" */ './views/flow/settings/processStep/ProcessStepEvent.vue'),
                },
              ]
            },  {
              path: 'eventStatuses',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "eventStatuses" */ './views/flow/settings/EventStatuses.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'eventStatuses',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "eventStatuses" */ './views/flow/settings/EventStatuses.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'processStepStatuses',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "processStepStatuses" */ './views/flow/settings/ProcessStepStatuses.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'projectStatuses',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "projectStatuses" */ './views/flow/settings/ProjectStatuses.vue')
                } else {
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
                },
                {
                  path: 'system',
                  meta: {title: 'Albatross - Settings'},
                  component: () => import (/* webpackChunkName: "projectSettings" */ './views/flow/settings/project/ProjectSystem.vue'),
                }
              ]
            }, {
              path: 'events',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "eventSettings" */ './views/flow/settings/Events.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'event/:id',
              name: 'EventSettings',
              meta: {title: 'Albatross - Settings'},
              props: true,
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "eventSettings" */ './views/flow/settings/event/Event.vue')
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'customFieldGroups',
                  meta: {title: 'Albatross - Settings'},
                  component: () => import (/* webpackChunkName: "eventSettings" */ './views/flow/settings/event/EventCustomFieldGroups.vue'),
                },
                {
                  path: 'components',
                  meta: {title: 'Albatross - Settings'},
                  component: () => import (/* webpackChunkName: "eventSettings" */ './views/flow/settings/event/EventComponents.vue'),
                }
              ]
            }, {
              path: 'smsTeams',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "projectStatuses" */ './views/flow/settings/SmsTeam.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'functions',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "functions" */ './views/flow/settings/Functions.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'function/:id',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "functions" */ './views/flow/settings/Function.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'availability',
              name: 'availabilityHeader',
              meta: {title: 'Albatross - Settings'},
              props: true,
              component: () => {
                if (store.getters.userHasFeature('AVAILABILITY')) {
                  return import (/* webpackChunkName: "availability" */ './views/flow/settings/availability/AvailabilityHeader.vue')
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'main',
                  name: 'availability',
                  meta: {title: 'Albatross - Settings'},
                  // redirect: "availability/main/schedule",
                  props: true,
                  component: () => {
                    if (store.getters.userHasFeature('AVAILABILITY')) {
                      return import (/* webpackChunkName: "availability" */ './views/flow/settings/availability/Availability.vue')
                    } else {
                      return accessDenied()
                    }
                  },
                  children: [
                    {
                      path: 'schedule',
                      meta: {title: 'Albatross - Settings'},
                      props: true,
                      component: () => import (/* webpackChunkName: "availability" */ './views/flow/settings/availability/Schedule.vue')
                    }, {
                      path: 'appointments',
                      props: true,
                      meta: {title: 'Albatross - Settings'},
                      component: () => import (/* webpackChunkName: "availability" */ './views/flow/settings/availability/Appointments.vue')
                    }
                  ]
                },
                {
                  path: 'slots',
                  name: 'slotSchedules',
                  meta: {title: 'Albatross - Settings'},
                  props: true,
                  component: () => {
                    if (store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'ADMIN')) {
                      return import (/* webpackChunkName: "slotSchedules" */ './views/flow/settings/availability/SlotSchedules.vue')
                    } else {
                      return accessDenied()
                    }
                  },
                }
              ]
            }, {
              path: 'positions',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "positions" */ './views/flow/settings/Positions.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'position/:id?',
              meta: {title: 'Albatross - Settings'},
              name: 'position',
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "positions" */ './views/flow/settings/Position.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'roles',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "roles" */ './views/flow/settings/Roles.vue')
                } else {
                  return accessDenied()
                }
              },
            }, {
              path: 'role/:id?',
              meta: {title: 'Albatross - Settings'},
              name: 'role',
              component: () => {
                if (store.getters.userHasFeature('SETTINGS')) {
                  return import (/* webpackChunkName: "roles" */ './views/flow/settings/Role.vue')
                } else {
                  return accessDenied()
                }
              },
            },
          ]
        }, {
          path: '/workQueue',
          name: 'workQueue',
          meta: {title: 'Albatross - Work Queue'},
          component: () => {
            if (store.getters.userHasFeature('WORK_QUEUE')) {
              return import (/* webpackChunkName: "workQueue" */ './views/flow/workQueue/WorkQueue.vue')
            } else {
              return accessDenied()
            }
          },
        }, {
          path: '/workQueue/:id',
          name: 'workQueueDrilldown',
          meta: {title: 'Albatross - Work Queue'},
          component: () => {
            if (store.getters.userHasFeature('WORK_QUEUE')) {
              return import (/* webpackChunkName: "workQueue" */ './views/flow/workQueue/WorkQueueDrilldown.vue')
            } else {
              return accessDenied()
            }
          },
        }, {
          path: '/smsQueue',
          name: 'smsQueue',
          meta: {title: 'Albatross - SMS Queue'},
          component: () => {
            if (store.getters.userHasFeature('SMS_QUEUE')) {
              return import (/* webpackChunkName: "smsQueue" */ './views/flow/smsQueue/SmsQueue.vue')
            } else {
              return accessDenied()
            }
          },
        }, {
          path: '/installerDashboard',
          name: 'installerDashboard',
          meta: {title: 'Albatross - Installer Dashboard'},
          component: () => {
            if (store.getters.userHasFeature('INSTALLER_DASHBOARD')) {
              return import (/* webpackChunkName: "installerDashboard" */ './views/blueraven/installerDashboard/InstallerDashboard.vue')
            } else {
              return accessDenied()
            }
          },
        }, {
          path: '/projects',
          name: 'projects',
          meta: {title: 'Albatross - Projects'},
          component: () => {
            if (store.getters.userHasFeature('PROJECTS')) {
              return import (/* webpackChunkName: "projects" */ './views/flow/project/Projects.vue')
            } else {
              return accessDenied()
            }
          },
        },
        // {
        //   name: 'projectProcessStep',
        //   path: '/project/:projectId/processStep/:processStepId',
        //   component: () => {
        //     if (store.getters.userHasFeature('PROCESS_STEPS')) {
        //       return import (/* webpackChunkName: "projectAdmin" */ './views/flow/project/ProjectProcessStep.vue')
        //     } else {
        //       return accessDenied()
        //     }
        //   }
        // },
        {
          path: '/project/:projectId',
          name: 'project',
          component: () => {
            if (store.getters.userHasFeature('PROJECTS')) {
              return import (/* webpackChunkName: "project" */ './views/flow/project/Project.vue')
            } else {
              return accessDenied()
            }
          },
          children: [{
            path: 'details',
            name: 'projectDetails',
            // component: () => import (/* webpackChunkName: "project" */ './views/flow/project/ProjectDetails.vue')
            components: {
              default: () => import (/* webpackChunkName: "project" */ './views/flow/project/ProjectDetails.vue'),
              tabs: () => import (/* webpackChunkName: "project" */ './views/flow/project/ProjectDetails.vue'),
            }
          }, {
            name: 'projectProcessStep',
            path: 'processStep/:processStepId',
            component: () => {
              if (store.getters.userHasFeature('PROCESS_STEPS')) {
                return import (/* webpackChunkName: "projectAdmin" */ './views/flow/project/ProjectProcessStep.vue')
              } else {
                return accessDenied()
              }
            }
          }, {
            name: 'ppsEvent',
            path: 'processStep/:processStepId/event/:ppsEventId',
            component: () => {
              if (store.getters.userHasFeature('PROCESS_STEPS')) {
                return import (/* webpackChunkName: "projectAdmin" */ './views/flow/project/ProjectProcessStepEvent.vue')
              } else {
                return accessDenied()
              }
            }
          }, {
            path: 'processSteps',
            component: () => {
              if (store.getters.userHasFeature('PROCESS_STEPS')) {
                return import (/* webpackChunkName: "projectAdmin" */ './views/flow/project/AllProcessSteps.vue')
              } else {
                return accessDenied()
              }
            }
          } , {
              path: 'events',
              component: () => {
                if (store.getters.userHasFeature('PROCESS_STEPS')) {
                  return import (/* webpackChunkName: "projectAdmin" */ './views/flow/project/AllEvents.vue')
                } else {
                  return accessDenied()
                }
              }
            },
          ]
        },        {
          name: 'projectAdmin',
          path: '/projectAdmin/:projectId',
          component: () => {
            //dont change this permission unless double checking with rn and cj. we have been back and forth on this 100 times
            if (store.getters.userHasFeatureAccessLevel('PROJECTS', 'ADMIN') || store.getters.userHasFeatureAccessLevel('PROJECTS', 'DELETE')) {
              return import (/* webpackChunkName: "projectAdmin" */ './views/flow/project/ProjectAdmin.vue')
            } else {
              return accessDenied()
            }
          }
        }, {
          path: 'contacts',
          name: 'contacts',
          meta: {title: 'Albatross - Contacts'},
          component: () => {
            if (store.getters.userHasFeature('CONTACTS')) {
              return import (/* webpackChunkName: "contacts" */ './views/flow/contacts/Contacts.vue')
            } else {
              return accessDenied()
            }
          },
          children: []
        }, {
          path: '/contact/:contactId',
          name: 'contact',
          props: true,
          meta: {title: 'Albatross - Contact'},
          component: () => {
            if (store.getters.userHasFeature('CONTACTS')) {
              return import (/* webpackChunkName: "contacts" */ './views/flow/contacts/Contact.vue')
            } else {
              return accessDenied()
            }
          },
          children: []
        }, {
          path: '/newContact',
          name: 'newContact',
          props: true,
          component: () => {
            if (store.getters.userHasFeatureAccessLevel('CONTACTS', 'ADD')) {
              return import (/* webpackChunkName: "contacts" */ './views/flow/contacts/NewContact.vue')
            } else {
              return accessDenied()
            }
          },
          children: []
        }, {
          path: '/orgs/:orgFilter?',
          name: 'orgs',
          meta: {title: 'Albatross - Orgs'},
          component: () => {
            if (store.getters.userHasFeature('ORGS')) {
              return import (/* webpackChunkName: "orgs" */ './views/flow/orgs/Orgs.vue')
            } else {
              return accessDenied()
            }
          },
          children: []
        }, {
          path: '/org/:id',
          name: 'org',
          meta: {title: 'Albatross - Org'},
          component: () => {
            if (store.getters.userHasFeature('ORGS')) {
              return import (/* webpackChunkName: "orgs" */ './views/flow/orgs/Org.vue')
            } else {
              return accessDenied()
            }
          },
          children: []
        }, {
          path: '/newOrg',
          name: 'newOrg',
          meta: {title: 'Albatross - New Org'},
          component: () => {
            if (store.getters.userHasFeature('ORGS')) {
              return import (/* webpackChunkName: "orgs" */ './views/flow/orgs/NewOrg.vue')
            } else {
              return accessDenied()
            }
          },
          children: []
        }, {
          path: '/admin',
          name: 'admin',
          component: () => {
            if (store.getters.userHasFeature('SYSTEM')) {
              return import (/* webpackChunkName: "admin" */ './views/flow/admin/Admin.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'orgFilters',
              component: () => import (/* webpackChunkName: "admin" */ './views/flow/admin/OrgFilters.vue'),
            }, {
              path: 'orgLevels',
              component: () => import (/* webpackChunkName: "admin" */ './views/flow/admin/OrgLevels.vue'),
            }, {
              path: 'features',
              component: () => import (/* webpackChunkName: "admin" */ './views/flow/admin/Features.vue'),
            }, {
              path: 'statusTypes',
              component: () => import (/* webpackChunkName: "admin" */ './views/flow/admin/CompanyUserStatus.vue'),
            }, {
              path: 'functions',
              component: () => import (/* webpackChunkName: "admin" */ './views/flow/admin/functions/Functions.vue'),
            }, {
              path: 'function/:id',
              component: () => import (/* webpackChunkName: "admin" */ './views/flow/admin/functions/Function.vue'),
            }, {
              path: 'uploads',
              component: () => import (/* webpackChunkName: "admin" */ './views/flow/admin/Uploads.vue'),
            }
          ]
        }, {
          path: '/commissionManagement',
          name: 'commissionManagement',
          meta: {title: 'Albatross - Commissions'},
          component: () => {
            if (store.getters.userHasFeature('COMMISSIONS')) {
              return import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/CommissionManagement.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'users',
              meta: {title: 'Albatross - Commissions'},
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/Users.vue'),
            }, {
              path: 'users/:id',
              meta: {title: 'Albatross - Commissions'},
              name: 'commissionUser',
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/User.vue'),
            }, {
              path: 'commissions',
              name: 'commissions',
              meta: {title: 'Albatross - Commissions'},
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/Commissions.vue'),
            }, {
              path: 'commission/:id?',
              name: 'commission',
              meta: {title: 'Albatross - Commissions'},
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/Commission.vue'),
            }, {
              path: 'overrides',
              name: 'overrides',
              meta: {title: 'Albatross - Commissions'},
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/Overrides.vue'),
            }, {
              path: 'override/:id?',
              name: 'override',
              meta: {title: 'Albatross - Commissions'},
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/Override.vue'),
            }, {
              path: 'accounting',
              meta: {title: 'Albatross - Commissions'},
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/Accounting.vue'),
              children: [
                {
                  path: 'current',
                  meta: {title: 'Albatross - Commissions'},
                  component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/CurrentPayroll.vue'),
                }, {
                  path: 'summary',
                  meta: {title: 'Albatross - Commissions'},
                  component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/Summary.vue'),
                }
              ]
            }, {
              path: 'payroll',
              meta: {title: 'Albatross - Commissions'},
              name: 'payrolls',
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/Payrolls.vue'),
            }, {
              path: 'payroll/:id',
              name: 'payroll',
              meta: {title: 'Albatross - Commissions'},
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/Payroll.vue'),
              children: [
                {
                  path: 'review',
                  meta: {title: 'Albatross - Commissions'},
                  name: 'payrollReview',
                  component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/PayrollReview.vue'),
                }, {
                  path: 'summary',
                  name: 'payrollSummary',
                  meta: {title: 'Albatross - Commissions'},
                  component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/PayrollSummary.vue'),
                }
              ]
            }, {
              path: 'residualPlans',
              name: 'residualPlans',
              meta: {title: 'Albatross - Commissions'},
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/ResidualPlans.vue'),
            }, {
              path: 'residualPlan/:id?',
              name: 'residualPlan',
              meta: {title: 'Albatross - Commissions'},
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/ResidualPlan.vue'),
            }, {
              path: 'residuals',
              meta: {title: 'Albatross - Commissions'},
              component: () => import (/* webpackChunkName: "commissionManagement" */ './views/blueraven/commissionManagement/Residuals.vue'),
            },
          ]
        }, {
          path: '/finances',
          name: 'finances',
          meta: {title: 'Albatross - Finances'},
          component: () => import (/* webpackChunkName: "finances" */ './views/blueraven/finances/rebate/Rebate.vue'),
          children: [
            {
              path: 'rebate/batches',
              meta: {title: 'Albatross - Finances'},
              component: () => import (/* webpackChunkName: "finances" */ './views/blueraven/finances/rebate/Batches.vue')
            }, {
              path: 'rebate/viewPayments',
              meta: {title: 'Albatross - Finances'},
              component: () => import (/* webpackChunkName: "finances" */ './views/blueraven/finances/rebate/ViewPayments.vue'),
            }, {
              path: 'rebate/viewPayments/:id',
              name: 'rebateDetails',
              meta: {title: 'Albatross - Finances'},
              component: () => import (/* webpackChunkName: "finances" */ './views/blueraven/finances/rebate/RebateDetails.vue'),
            }
          ]
        }, {
          path: '/electronicDocuments',
          name: 'electronicDocuments',
          meta: {title: 'Albatross - Electronic Documents'},
          component: () => {
            if (store.getters.userHasFeature('ELECTRONIC_DOCUMENTS')) {
              return import (/* webpackChunkName: "electronicDocuments" */ './views/blueraven/electronicDocuments/ElectronicDocuments.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'request',
              component: () => {
                if (store.getters.userHasFeature('ELECTRONIC_DOCUMENTS')) {
                  return import (/* webpackChunkName: "electronicDocuments" */ './views/blueraven/electronicDocuments/Request.vue')
                } else {
                  return accessDenied()
                }
              }
            }
          ]
        }, {
          path: '/installation-agreements',
          name: 'installation-agreements',
          meta: {title: 'Albatross - Installation Agreements'},
          component: () => import (/* webpackChunkName: "installationAgreements" */ './views/blueraven/installationAgreements/InstallationAgreements.vue'),
          children: [
            {
              path: 'request',
              component: () => import (/* webpackChunkName: "installationAgreements" */ './views/blueraven/installationAgreements/Request.vue')
            }
          ]
        }, {
          path: '/smartlist',
          meta: {title: 'Albatross - Smartlists'},
          component: () => {
            if (store.getters.userHasFeature('SMARTLIST')) {
              return import (/* webpackChunkName: "smartlist" */ './views/flow/smartlist/SmartlistHome.vue')
            } else {
              return accessDenied()
            }
          },
          children: [{
            path: '',
            meta: {title: 'Albatross - Smartlists'},
            name: 'smartlist',
            component: () => {
              if (store.getters.userHasFeature('SMARTLIST')) {
                return import (/* webpackChunkName: "smartlist" */ './views/flow/smartlist/Smartlists.vue')
              } else {
                return accessDenied()
              }
            }
          }, {
            path: ':smartlistId',
            meta: {title: 'Albatross - Smartlists'},
            name: 'smartlistEditor',
            component: () => {
              if (store.getters.userHasFeature('SMARTLIST')) {
                return import (/* webpackChunkName: "smartlist" */ './views/flow/smartlist/Smartlist.vue')
              } else {
                return accessDenied()
              }
            }
          }
          ]
        }, {
          path: '/proposals',
          name: 'proposals',
          meta: {title: 'Albatross - Proposals'},
          component: () => {
            if (store.getters.userHasFeature('PROPOSALS')) {
              return import (/* webpackChunkName: "proposals" */ './views/blueraven/proposals/Proposals.vue')
            } else {
              return accessDenied()
            }
          }
        }, {
          path: '/proposal/:proposalId',
          name: 'proposal',
          meta: {title: 'Albatross - Proposals'},
          component: () => {
            if (store.getters.userHasFeature('PROPOSALS')) {
              return import (/* webpackChunkName: "proposals" */ './views/blueraven/proposals/Proposal.vue')
            } else {
              return accessDenied()
            }
          }
        },{
          path: '/proposalDesigns/:projectId',
          name: 'proposalDesigns',
          meta: {title: 'Albatross - Proposals'},
          component: () => {
            if (store.getters.userHasFeature('PROPOSALS')) {
              return import (/* webpackChunkName: "proposalDesigns" */ './views/blueraven/proposals/ProposalDesigns.vue')
            } else {
              return accessDenied()
            }
          }
        },
          {
              path: 'inbox',
              name: 'inbox',
              meta: {title: 'Albatross - Inbox'},
              component: () => import (/* webpackChunkName: "inbox" */ './views/flow/settings/inbox/MainInbox'),
              children: [
                  {
                      path: 'inboxConversation/:projectId',
                      name: 'inboxConversation',
                      meta: {title: 'Albatross - Inbox Conversation'},
                      component: () => import (/* webpackChunkName: "inboxConversation" */ './views/flow/settings/inbox/MainInbox')
                  }
              ]
          },
      ]
    }
  ]
})

router.beforeEach((to, from, next) => {
  //if the global spinner is on and the request takes a while, then you move to a different page that doesn't toggle the global
  //spinner then it stays on the screen until the previous request finishes.  this fixes that.
  store.commit(AppMutations.SET_LOADING, false)
  //cancel all pending axios requests when route change
  store.dispatch('CANCEL_PENDING_REQUESTS');
  next()
})

export default router

async function getUser() {
  const {data} = await getRequest(`/user/current`)
  return {data}
}

function accessDenied() {
  let maintenanceMode = import.meta.env.VITE_MAINTENANCE_MODE?.toLowerCase() === 'true' || process.env.VUE_APP_MAINTENANCE_MODE === true
  if(maintenanceMode) {
    return import(/* webpackChunkName: "accessDenied" */ './views/SiteUnderMaintenance.vue')
  } else {
    return import(/* webpackChunkName: "accessDenied" */ './views/AccessDenied.vue')
  }
}

