import Vue from 'vue'
import Router from 'vue-router'
import Login from './views/Login.vue'
import ForgotPasswordReset from './views/ForgotPasswordReset.vue'
import { getRequest } from '@/helpers/helpers'
import ProposalVersionSettingsRoutes from '@/views/blueraven/settings/proposals/routes'
import PartsMasterVersionSettingsRoutes from '@/views/blueraven/settings/partsMaster/routes'
import ProposalDesignerRoutes from '@/views/blueraven/settings/proposalDesigner/routes'
import pinia from '@/store'
import { useUserStore } from '@/stores/UserStore.js'
import { useAppStore } from '@/stores/AppStore.js'
import { useFileStore } from '@/stores/FileStore.js'
import { useScheduleStore } from '@/stores/ScheduleStore.js'

Vue.use(Router)
const nonRedirectPaths = ['/', '/home']
const userStore = useUserStore(pinia)
const appStore = useAppStore(pinia)
const fileStore = useFileStore(pinia)
const scheduleStore = useScheduleStore(pinia)

const router = new Router({
  mode: 'history',
  base: import.meta.env.BASE_URL,
  routes: [
    {
      path: '/login',
      name: 'login',
      component: Login,
      props: true
    },
    {
      path: '/vue3',
      name: 'vue3',
      alias: '/tempButtonHandler',
      redirect: '/vue3/vbtn',
      component: () => import('./views/vue3/Vue3.vue'),
      children: [
        {
          path: 'vbtn',
          name: 'vbtn',
          component: () => import('./views/vue3/VButtonHandler.vue')
        },
        {
          path: 'data',
          name: 'data',
          component: () => import('./views/vue3/Data.vue')
        },
        {
          path: 'file',
          name: 'file',
          component: () => import('./views/vue3/File.vue')
        }
      ]
    },
    {
      path: '/forgotPassword',
      name: 'forgotPassword',
      component: () => import('./views/ForgotPassword.vue')
    },
    {
      path: '/stripeSuccess',
      name: 'stripeSuccess',
      component: () => import('./views/StripeSuccessLanding.vue')
    },
    {
      path: '/siteUnderMaintenance',
      name: 'siteUnderMaintenance',
      component: () => import('./views/SiteUnderMaintenance.vue')
    },
    {
      path: '/passwordReset/:uuid?',
      name: 'forgotPasswordReset',
      component: ForgotPasswordReset,
      props: true
    },
    {
      path: '/resetPassword',
      name: 'resetPassword',
      component: () => import('./views/ResetPassword.vue'),
      props: true
    },
    {
      path: '/',
      name: 'root',
      redirect: 'home',
      component: () => {
        if (userStore.userHasAnyFeature) {
          return import('./views/Root.vue')
        } else {
          return accessDenied()
        }
      },
      beforeEnter: async (to, from, next) => {
        if (!userStore.authorized && from.name !== 'login') {
          //only re-route back to login if not already on login
          let rt = {
            path: '/login'
          }
          //this code handles redirecting them back to the page they were trying to get to after they login
          if (!nonRedirectPaths.includes(to.path)) {
            rt.query = { redirect: to.path }
          }
          next(rt)
        } else {
          if (from.name !== 'login') {
            try {
              //this sets the redirect url in case the getUser request returns a 401
              appStore.redirectUrl = nonRedirectPaths.includes(to.path)
                ? null
                : to.path

              const { data } = await getUser()
              userStore.details = data
              scheduleStore.timezone = data.timezone
              next()
            } catch (e) {
              next('/login')
            }
          } else {
            //had to do the matching or it just does a continuous loop if the user has a homepagepath
            if (
              userStore?.details?.homePagePath &&
              to.path !== userStore?.details?.homePagePath
            ) {
              router.push({ path: userStore.details.homePagePath })
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
            if (userStore.userHasAnyFeature) {
              return import('./views/Home.vue')
            } else {
              return accessDenied()
            }
          }
        },
        {
          path: '/serverError',
          name: 'serverError',
          component: () => import('./views/ServerError.vue')
        },
        {
          path: '/dataNotFound',
          name: 'dataNotFound',
          component: () => import('./views/DataNotFound.vue')
        },
        {
          path: '/accessDenied',
          name: 'accessDenied',
          component: () => import('./views/AccessDenied.vue')
        },
        {
          path: '/schedule',
          name: 'schedule',
          meta: { title: 'Albatross - Schedule' },
          props: true,
          component: () => {
            if (userStore.userHasFeature('SCHEDULE')) {
              return import('./views/flow/schedule/Schedule.vue')
            } else {
              return accessDenied()
            }
          }
        },
        {
          path: '/apps',
          name: 'appDownloads',
          meta: { title: 'Albatross - App Download' },
          props: true,
          component: () => {
            if (userStore.userHasFeature('APP_DOWNLOADS')) {
              return import('./views/flow/appDownloads/AppDownloads.vue')
            } else {
              return accessDenied()
            }
          }
        },
        {
          path: '/errorLog',
          name: 'errorLog',
          meta: { title: 'Albatross - Errors' },
          component: () => {
            if (userStore.userHasFeature('ERROR_LOG')) {
              return import('./views/flow/ErrorLog.vue')
            } else {
              return accessDenied()
            }
          }
        },
        {
          path: '/roadmap',
          name: 'roadmap',
          meta: { title: 'Albatross - Road Map' },
          props: true,
          component: () => {
            if (userStore.userHasFeature('ROAD_MAP')) {
              return import('./views/blueraven/RoadMap.vue')
            } else {
              return accessDenied()
            }
          }
        },{
          path: '/capacityCalendar',
          name: 'capacityCalendar',
          meta: { title: 'Albatross - Scheduling Capacity Calendar' },
          props: true,
          component: () => {
            if (userStore.userHasFeature('SCHEDULING_CAPACITY_CALENDAR')) {
              return import('./views/blueraven/capacityCalendar/CapacityCalendar.vue')
            } else {
              return accessDenied()
            }
          }
        },
        {
          path: '/users',
          name: 'users',
          meta: { title: 'Albatross - Users' },
          component: () => {
            if (userStore.userHasFeature('USERS')) {
              return import('./views/flow/users/Users.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: '/userImages',
              name: 'userImages',
              meta: { title: 'Albatross - Users' },
              component: () => import('./views/flow/users/UserImages.vue')
            }
          ]
        },
        {
          path: '/user/:id',
          name: 'user',
          meta: { title: 'Albatross - User' },
          props: true,
          component: () => {
            if (userStore.userHasFeature('USERS')) {
              return import('./views/flow/users/User.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'details',
              name: 'userDetails',
              meta: { title: 'Albatross - User' },
              component: () => import('./views/flow/users/UserDetails.vue')
            },
            {
              path: 'positions',
              meta: { title: 'Albatross - User' },
              component: () => import('./views/flow/users/UserPositions.vue')
            },
            {
              path: 'access',
              meta: { title: 'Albatross - User' },
              component: () => {
                if (
                  userStore.userHasFeatureAccessLevel('ACCESS_CONTROL', 'VIEW')
                ) {
                  return import('./views/flow/users/UserAccess.vue')
                } else {
                  return accessDenied()
                }
              }
            }
          ]
        },
        {
          path: '/newUser',
          name: 'newUser',
          meta: { title: 'Albatross - New User' },
          component: () => {
            if (userStore.userHasFeatureAccessLevel('USERS', 'ADD')) {
              return import('./views/flow/users/NewUser.vue')
            } else {
              return accessDenied()
            }
          },
          children: []
        },
        {
          path: '/reimbursement',
          name: 'reimbursement',
          meta: { title: 'Albatross - Reimbursement' },
          component: () => {
            if (userStore.userHasFeature('REIMBURSEMENT')) {
              return import('./views/blueraven/expenses/Reimbursement.vue')
            } else {
              return accessDenied()
            }
          }
        },
        {
          path: '/expenses',
          name: 'expenses',
          alias: '/expenses/manage',
          meta: { title: 'Albatross - Expenses' },
          component: () => {
            if (userStore.userHasFeature('EXPENSES')) {
              return import('./views/blueraven/expenses/Expenses.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'reimbursementRequests',
              name: 'reimbursementRequests',
              meta: { title: 'Albatross - Reimbursement Requests' },
              component: () =>
                import('./views/blueraven/expenses/ReimbursementRequests.vue')
            },
            {
              path: 'submittedExpenses',
              name: 'submittedExpenses',
              meta: { title: 'Albatross - Submitted Expenses' },
              component: () =>
                import('./views/blueraven/expenses/SubmittedExpenses.vue')
            },
            {
              path: 'glCodes',
              name: 'glCodes',
              meta: { title: 'Albatross - GL Codes' },
              component: () => {
                if (
                  userStore.userHasFeatureAccessLevel('EXPENSES', 'ADMIN') ||
                  userStore.userHasFeatureAccessLevel('EXPENSES', 'MANAGE')
                ) {
                  return import('./views/blueraven/expenses/GlCodes.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'monthlyBudgets',
              name: 'monthlyBudgets',
              meta: { title: 'Albatross - Expense Budgets' },
              component: () => {
                if (
                  userStore.userHasFeatureAccessLevel('EXPENSES', 'ADMIN') ||
                  userStore.userHasFeatureAccessLevel('EXPENSES', 'MANAGE')
                ) {
                  return import('./views/blueraven/expenses/MonthlyBudgets.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'budgetTemplates',
              name: 'budgetTemplates',
              meta: { title: 'Albatross - Expense Budgets' },
              component: () => {
                if (
                  userStore.userHasFeatureAccessLevel('EXPENSES', 'ADMIN') ||
                  userStore.userHasFeatureAccessLevel('EXPENSES', 'MANAGE')
                ) {
                  return import(
                    './views/blueraven/expenses/BudgetTemplates.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'budgetTypes',
              name: 'expenseBudgetTypes',
              meta: { title: 'Albatross - Budget Types' },
              component: () => {
                if (
                  userStore.userHasFeatureAccessLevel('EXPENSES', 'ADMIN') ||
                  userStore.userHasFeatureAccessLevel('EXPENSES', 'MANAGE')
                ) {
                  return import('./views/blueraven/expenses/BudgetTypes.vue')
                } else {
                  return accessDenied()
                }
              }
            }
          ]
        },
        {
          path: '/closer',
          name: 'closer',
          meta: { title: 'Albatross - Closer Dashboard' },
          component: () => {
            if (userStore.userHasFeature('CLOSER_DASHBOARD')) {
              return import('./views/blueraven/closerDashboard/Closer.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'dashboard',
              name: 'closerDashboard',
              meta: { title: 'Albatross - Closer Dashboard' },
              component: () =>
                import('./views/blueraven/closerDashboard/CloserRanking.vue')
            },
            {
              path: 'funnel',
              alias: '/closerDashboard',
              name: 'closerFunnel',
              meta: { title: 'Albatross - Closer Dashboard' },
              component: () =>
                import('./views/blueraven/closerDashboard/CloserFunnel.vue')
            },
            {
              path: 'incentive',
              name: 'closerIncentive',
              meta: { title: 'Albatross - Closer Dashboard' },
              component: () =>
                import('./views/blueraven/closerDashboard/CloserIncentive.vue')
            },
            {
              path: 'leaderboard',
              name: 'closerLeaderboard',
              meta: { title: 'Albatross - Closer Dashboard' },
              component: () =>
                import(
                  './views/blueraven/closerDashboard/CloserLeaderboard.vue'
                )
            },
            {
              path: 'residuals',
              name: 'closerResiduals',
              props: { isAdmin: false },
              meta: { title: 'Albatross - Closer Dashboard' },
              component: () =>
                import('./views/blueraven/closerDashboard/CloserResiduals.vue')
            }
          ]
        },
        {
          path: 'setter',
          name: 'setter',
          meta: { title: 'Albatross - Setter Dashboard' },
          component: () => {
            if (userStore.userHasFeature('SETTER_DASHBOARD')) {
              return import('./views/blueraven/setterDashboard/Setter.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'dashboard',
              name: 'setterDashboard',
              meta: { title: 'Albatross - Setter Dashboard' },
              component: () =>
                import(
                  './views/blueraven/setterDashboard/SetterPerformance.vue'
                )
            },
            {
              path: 'funnel',
              alias: '/setterDashboard',
              name: 'setterFunnel',
              meta: { title: 'Albatross - Setter Dashboard' },
              component: () =>
                import('./views/blueraven/setterDashboard/SetterFunnel.vue')
            },
            {
              path: 'incentive',
              name: 'setterIncentive',
              meta: { title: 'Albatross - Setter Dashboard' },
              component: () =>
                import('./views/blueraven/setterDashboard/SetterIncentive.vue')
            }
          ]
        },
        {
          path: '/companyDashboard',
          name: 'companyDashboard',
          meta: { title: 'Albatross - Company Dashboard' },
          component: () => {
            if (userStore.userHasFeature('COMPANY_DASHBOARD')) {
              return import(
                './views/blueraven/companyDashboard/CompanyDashboard.vue'
              )
            } else {
              return accessDenied()
            }
          }
        },
        {
          path: '/closerAvailability',
          name: 'closerAvailability',
          meta: { title: 'Albatross - Closer Availability' },
          props: true,
          component: () => {
            if (
              userStore.userHasFeatureAccessLevel(
                'CLOSER_AVAILABILITY',
                'VIEW'
              ) ||
              userStore.userHasFeatureAccessLevel(
                'CLOSER_AVAILABILITY',
                'VIEW_CUSTOM'
              ) ||
              userStore.userHasFeatureAccessLevel(
                'CLOSER_AVAILABILITY',
                'VIEW_ALL'
              )
            ) {
              return import(
                './views/blueraven/closerAvailability/CloserAvailability.vue'
              )
            } else {
              return accessDenied()
            }
          }
        },
        {
          path: '/database',
          name: 'featDbContainer',
          meta: { title: 'Databases' },
          component: () => {
            if (
              userStore.userHasFeature('AHJ') ||
              userStore.userHasFeature('UTILITY') ||
              userStore.userHasFeature('HOA')
            ) {
              return import('./views/blueraven/featDB/FeatDbContainer.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'ahj',
              name: 'ahjs',
              meta: { title: 'Databases - AHJ' },
              component: () => {
                if (userStore.userHasFeature('AHJ')) {
                  return import('./views/blueraven/featDB/ahj/Ahjs.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'ahj/:ahjId',
              name: 'ahjDetails',
              meta: { title: 'Databases - AHJ' },
              props: true,
              component: () => {
                if (userStore.userHasFeature('AHJ')) {
                  return import(
                    './views/blueraven/featDB/ahj/details/AhjDetails.vue'
                  )
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'permit',
                  meta: { title: 'Databases - AHJ' },
                  component: () =>
                    import('./views/blueraven/featDB/ahj/details/AhjPermit.vue')
                },
                {
                  path: 'inspection',
                  meta: { title: 'Databases - AHJ' },
                  component: () =>
                    import(
                      './views/blueraven/featDB/ahj/details/AhjInspection.vue'
                    )
                },
                {
                  path: 'design',
                  meta: { title: 'Databases - AHJ' },
                  component: () =>
                    import('./views/blueraven/featDB/ahj/details/AhjDesign.vue')
                },
                {
                  path: 'newHome',
                  meta: { title: 'Databases - AHJ' },
                  component: () =>
                    import('./views/blueraven/featDB/ahj/details/AhjNewHome.vue')
                },
              ]
            },
            {
              path: 'utility',
              name: 'utilities',
              meta: { title: 'Databases - Utility' },
              component: () => {
                if (userStore.userHasFeature('UTILITY')) {
                  return import(
                    './views/blueraven/featDB/utility/Utilities.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'utility/:utilityId/details',
              name: 'utilityDetails',
              meta: { title: 'Databases - Utility' },
              props: true,
              component: () => {
                if (userStore.userHasFeature('UTILITY')) {
                  return import(
                    './views/blueraven/featDB/utility/UtilityDetails.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'hoa',
              name: 'hoa',
              meta: { title: 'Albatross - HOA' },
              component: () => {
                if (userStore.userHasFeature('HOA')) {
                  return import('./views/blueraven/featDB/hoa/Hoas.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'hoa/:hoaId/details',
              name: 'hoaDetails',
              meta: { title: 'Databases - HOA' },
              props: true,
              component: () => {
                if (userStore.userHasFeature('HOA')) {
                  return import('./views/blueraven/featDB/hoa/HoaDetails.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'supplier',
              name: 'supplier',
              meta: { title: 'Albatross - Suppliers' },
              component: () => {
                if (userStore.userHasFeature('SUPPLIERS')) {
                  return import(
                    './views/blueraven/featDB/suppliers/Suppliers.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'supplier/:supplierId/details',
              name: 'supplierDetails',
              meta: { title: 'Databases - Supplier' },
              props: true,
              component: () => {
                if (userStore.userHasFeature('SUPPLIERS')) {
                  return import(
                    './views/blueraven/featDB/suppliers/SupplierDetails.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'incentive',
              name: 'incentive',
              meta: { title: 'Albatross - Incentive' },
              component: () => {
                if (userStore.userHasFeature('INCENTIVE')) {
                  return import(
                    './views/blueraven/featDB/incentive/Incentives.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'incentive/:incentiveId/details',
              name: 'incentiveDetails',
              meta: { title: 'Databases - Incentive' },
              props: true,
              component: () => {
                if (userStore.userHasFeature('INCENTIVE')) {
                  return import(
                    './views/blueraven/featDB/incentive/IncentiveDetails.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            }
          ]
        },
        //TOURNAMENT STUFF
        {
          path: '/tournament/:id',
          name: 'tournament',
          props: true,
          component: () => {
            if (userStore.userHasFeature('TOURNAMENTS')) {
              return import('./views/blueraven/tournament/Tournament.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'qualifying',
              name: 'tournamentQualifying',
              component: () =>
                import('./views/blueraven/tournament/Qualifying.vue')
            },
            {
              path: 'bracket',
              name: 'tournamentBracket',
              component: () =>
                import('./views/blueraven/tournament/Bracket.vue')
            },
            {
              path: 'lastChance',
              name: 'tournamentLastChance',
              component: () =>
                import('./views/blueraven/tournament/LastChance.vue')
            },
            {
              path: 'winners',
              name: 'tournamentWinners',
              component: () =>
                import('./views/blueraven/tournament/Winners.vue')
            }
          ]
        },
        //END TOURNAMENT STUFF

        ProposalDesignerRoutes,

        {
          path: '/settings',
          name: 'settings',
          meta: { title: 'Albatross - Settings' },
          component: () => import('./views/flow/settings/Settings.vue'),
          children: [
            ProposalVersionSettingsRoutes,
            PartsMasterVersionSettingsRoutes,
            {
              path: 'pushNotifications',
              component: () =>
                import('./views/flow/pushNotifications/Admin.vue')
            },
            {
              path: 'statusCheck',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/StatusCheck.vue')
                } else {
                  return accessDenied()
                }
              }
            }, {
              path: 'apiManagement',
              meta: {title: 'Albatross - Settings'},
              component: () => {
                if (userStore.userHasFeatureAccessLevel('API_MANAGEMENT', 'ADMIN')) {
                  return import('./views/flow/settings/ApiManagement.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'attachments',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/Attachments.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'attachment/:id',
              name: 'AttachmentSettings',
              meta: { title: 'Albatross - Settings' },
              props: true,
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import(
                    './views/flow/settings/attachments/AttachmentType.vue'
                  )
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'customFieldGroups',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/attachments/AttachmentTypeCustomFieldGroups.vue'
                    )
                }
              ]
            },
            {
              path: 'companyCustomFields',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import(
                    './views/flow/settings/customFields/CompanyCustomFields.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'companyCustomField/:id?',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import(
                    './views/flow/settings/customFields/CompanyCustomField.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'companyObjectTypes',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import(
                    './views/flow/settings/companyObjectType/CompanyObjectTypes.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'companyObjectTypes/:id',
              name: 'companyObjectTypes',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import(
                    './views/flow/settings/companyObjectType/CompanyObjectType.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'releases',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeatureAccessLevel('RELEASES', 'VIEW')) {
                  return import('./views/flow/settings/releases/Releases.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'tournaments',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (
                  userStore.userHasFeatureAccessLevel('TOURNAMENTS', 'ADMIN')
                ) {
                  return import(
                    './views/flow/settings/tournaments/Tournaments.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'tournaments/:id',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (
                  userStore.userHasFeatureAccessLevel('TOURNAMENTS', 'ADMIN')
                ) {
                  return import(
                    './views/flow/settings/tournaments/Tournament.vue'
                  )
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'details',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/tournaments/TournamentDetails.vue'
                    )
                },
                {
                  path: 'brackets',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import('./views/flow/settings/tournaments/Bracket.vue')
                },
                {
                  path: 'pool/:poolTypeId',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import('./views/flow/settings/tournaments/Pool.vue')
                }
              ]
            },
            {
              path: 'states',
              meta: { title: 'Albatross - Settings' },
              component: () => import('./views/flow/settings/States.vue')
            },
            {
              path: 'userProfile',
              meta: { title: 'Albatross - Settings' },
              component: () => import('./views/flow/settings/UserProfile.vue')
            },
            {
              path: 'userProfileAdmin',
              meta: { title: 'Albatross - Settings' },
              component: () =>
                import('./views/flow/settings/UserProfileAdmin.vue')
            },
            {
              path: 'company',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/defaults/Defaults.vue')
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'settings',
                  meta: { title: 'Albatross - Settings' },
                  component: () => {
                    if (userStore.userHasFeature('SETTINGS')) {
                      return import(
                        './views/flow/settings/defaults/CompanySettings.vue'
                      )
                    } else {
                      return accessDenied()
                    }
                  }
                },
                {
                  path: 'configurations',
                  meta: { title: 'Albatross - Settings' },
                  component: () => {
                    if (
                      userStore.userHasFeatureAccessLevel('SETTINGS', 'ADMIN')
                    ) {
                      return import(
                        './views/flow/settings/defaults/Configurations.vue'
                      )
                    } else {
                      return accessDenied()
                    }
                  }
                },
                {
                  path: 'email',
                  meta: { title: 'Albatross - Settings' },
                  component: () => {
                    if (
                      userStore.userHasFeatureAccessLevel('SETTINGS', 'ADMIN')
                    ) {
                      return import(
                        './views/flow/settings/defaults/EmailSettings.vue'
                      )
                    } else {
                      return accessDenied()
                    }
                  }
                },
                {
                  path: 'messageTypes',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import('./views/flow/settings/MessageTypes.vue')
                },
                {
                  path: 'closerDashboard',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/defaults/CloserDashboardSettings.vue'
                    )
                }
              ]
            },
            {
              path: 'roundRobins',
              meta: { title: 'Albatross - Round Robin' },
              component: () => {
                if (userStore.userHasFeature('ROUND_ROBIN')) {
                  return import(
                    './views/flow/settings/roundRobins/RoundRobins.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'zip',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('POSTAL_CODE')) {
                  return import(
                    './views/flow/settings/postalCode/ZipContainer.vue'
                  )
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'postalCodes',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import('./views/flow/settings/postalCode/PostalCodes.vue')
                },
                {
                  path: 'postalCode/:id',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import('./views/flow/settings/postalCode/PostalCode.vue')
                },
                {
                  path: 'zones',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/postalCode/PostalCodeZones.vue'
                    )
                },
                {
                  path: 'zone/:id',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/postalCode/PostalCodeZone.vue'
                    )
                }
              ]
            },
            {
              path: 'roundRobin/:id',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('ROUND_ROBIN')) {
                  return import(
                    './views/flow/settings/roundRobins/RoundRobin.vue'
                  )
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'scheduleTo',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import('./views/flow/settings/roundRobins/ScheduleTo.vue')
                },
                {
                  path: 'scheduleBy',
                  component: () =>
                    import('./views/flow/settings/roundRobins/ScheduleBy.vue')
                },
                {
                  path: 'codes',
                  component: () =>
                    import('./views/flow/settings/roundRobins/PostalCodes.vue')
                }
              ]
            },
            {
              path: 'callGroups',
              meta: { title: 'Albatross - Call Groups' },
              component: () => {
                if (userStore.userHasFeature('CALL_GROUPS')) {
                  return import(
                    './views/flow/settings/callGroups/CallGroups.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'callGroup/:id',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import(
                    './views/flow/settings/callGroups/PostalCode.vue'
                  )
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'codes',
                  component: () =>
                    import('./views/flow/settings/callGroups/Codes.vue')
                },
                {
                  path: 'numbers',
                  component: () =>
                    import('./views/flow/settings/callGroups/Numbers.vue')
                }
              ]
            },
            {
              path: 'orgTypes',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/OrgTypes.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'messageTemplates',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/MessageTemplate.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'announcements/current',
              alias: 'announcements/past',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/Announcements.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'announcement/:id?',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/Announcement.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'hashtags',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/Hashtags.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'dataViews',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeatureAccessLevel('DATA_VIEW', 'ADMIN')) {
                  return import('./views/flow/settings/DataViews.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'dataView/:id',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeatureAccessLevel('DATA_VIEW', 'ADMIN')) {
                  return import('./views/flow/settings/DataView.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'workQueue',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (
                  userStore.userHasFeature('SETTINGS') ||
                  userStore.userHasFeatureAccessLevel('WORK_QUEUE', 'ADMIN')
                ) {
                  return import('./views/flow/settings/WorkQueue.vue')
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'types',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import('./views/flow/settings/WorkQueueTypes.vue')
                },
                {
                  path: 'type/:id',
                  name: 'workQueueType',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import('./views/flow/settings/WorkQueueType.vue')
                },
                {
                  path: 'categories',
                  component: () =>
                    import('./views/flow/settings/WorkQueueCategories.vue')
                }
              ]
            },
            {
              path: 'customFields',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import(
                    './views/flow/settings/customFields/FlowCustomFields.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'customField/:id?',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import(
                    './views/flow/settings/customFields/FlowCustomField.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'objectType/:id',
              meta: { title: 'Albatross - Settings' },
              props: true,
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import(
                    './views/flow/settings/objectType/ObjectType.vue'
                  )
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'customFieldGroups',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/objectType/CustomFieldGroup.vue'
                    )
                },
                {
                  path: 'attachmentTypes',
                  meta: { title: 'Albatross - Settings' },
                  props: true,
                  component: () =>
                    import(
                      './views/flow/settings/objectType/ObjectTypeAttachments.vue'
                    )
                },
                {
                  path: 'attachmentType/:attachmentTypeId',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/objectType/ObjectTypeAttachment.vue'
                    )
                }
              ]
            },
            {
              path: 'tags',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/Tags.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'links',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/Links.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'processes',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/Processes.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'processes/:id?',
              meta: { title: 'Albatross - Settings' },
              name: 'process',
              props: true,
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/Process.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'processSteps',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/ProcessSteps.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'processStep/:id',
              name: 'processStep',
              meta: { title: 'Albatross - Settings' },
              props: true,
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import(
                    './views/flow/settings/processStep/ProcessStep.vue'
                  )
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'components',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/processStep/ProcessStepComponents.vue'
                    )
                },
                {
                  path: 'customFieldGroups',
                  props: true,
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/processStep/ProcessStepCFG.vue'
                    )
                },
                {
                  path: 'actions',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/processStep/ProcessStepActions.vue'
                    )
                },
                {
                  path: 'events',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/processStep/ProcessStepEvents.vue'
                    )
                },
                {
                  path: 'event/:eventId',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/processStep/ProcessStepEvent.vue'
                    )
                },
                {
                  path: 'attachmentTypes',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/processStep/ProcessStepAttachmentTypes.vue'
                    )
                },
                {
                  path: 'attachmentType/:attachmentTypeId',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/processStep/ProcessStepAttachmentType.vue'
                    )
                }
              ]
            },
            {
              path: 'eventStatuses',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/EventStatuses.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'eventStatuses',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/EventStatuses.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'processStepStatuses',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/ProcessStepStatuses.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'projectStatuses',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import(
                    './views/flow/settings/projectStatus/ProjectStatuses.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'projectStatus/:id',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import(
                    './views/flow/settings/projectStatus/ProjectStatus.vue'
                  )
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'components',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/projectStatus/ProjectStatusComponents.vue'
                    )
                },
                {
                  path: 'fields',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/projectStatus/ProjectStatusFields.vue'
                    )
                }
              ]
            },
            {
              path: 'project',
              name: 'ProjectSettings',
              meta: { title: 'Albatross - Settings' },
              props: true,
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/project/Project.vue')
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'customFieldGroups',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/project/ProjectCustomFieldGroups.vue'
                    )
                },
                {
                  path: 'tabs',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import('./views/flow/settings/project/ProjectTabs.vue')
                },
                {
                  path: 'attachmentTypes',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/project/ProjectAttachmentTypes.vue'
                    )
                },
                {
                  path: 'attachmentType/:attachmentTypeId',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/project/ProjectAttachmentType.vue'
                    )
                },
                {
                  path: 'system',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import('./views/flow/settings/project/ProjectSystem.vue')
                }
              ]
            },
            {
              path: 'events',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/Events.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'event/:id',
              name: 'EventSettings',
              meta: { title: 'Albatross - Settings' },
              props: true,
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/event/Event.vue')
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'customFieldGroups',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/event/EventCustomFieldGroups.vue'
                    )
                },
                {
                  path: 'components',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import('./views/flow/settings/event/EventComponents.vue')
                },
                {
                  path: 'attachmentTypes',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/event/EventAttachmentTypes.vue'
                    )
                },
                {
                  path: 'attachmentType/:attachmentTypeId',
                  meta: { title: 'Albatross - Settings' },
                  component: () =>
                    import(
                      './views/flow/settings/event/EventAttachmentType.vue'
                    )
                }
              ]
            },
            {
              path: 'smsTeams',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/SmsTeam.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'functions',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/Functions.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'function/:id',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/Function.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'availability',
              name: 'availabilityHeader',
              meta: { title: 'Albatross - Settings' },
              props: true,
              component: () => {
                if (userStore.userHasFeature('AVAILABILITY')) {
                  return import(
                    './views/flow/settings/availability/AvailabilityHeader.vue'
                  )
                } else {
                  return accessDenied()
                }
              },
              children: [
                {
                  path: 'main',
                  name: 'availability',
                  meta: { title: 'Albatross - Settings' },
                  // redirect: "availability/main/schedule",
                  props: true,
                  component: () => {
                    if (userStore.userHasFeature('AVAILABILITY')) {
                      return import(
                        './views/flow/settings/availability/Availability.vue'
                      )
                    } else {
                      return accessDenied()
                    }
                  },
                  children: [
                    {
                      path: 'schedule',
                      meta: { title: 'Albatross - Settings' },
                      props: true,
                      component: () =>
                        import(
                          './views/flow/settings/availability/Schedule.vue'
                        )
                    },
                    {
                      path: 'appointments',
                      props: true,
                      meta: { title: 'Albatross - Settings' },
                      component: () =>
                        import(
                          './views/flow/settings/availability/Appointments.vue'
                        )
                    }
                  ]
                },
                {
                  path: 'slots',
                  name: 'slotSchedules',
                  meta: { title: 'Albatross - Settings' },
                  props: true,
                  component: () => {
                    if (
                      userStore.userHasFeatureAccessLevel(
                        'AVAILABILITY',
                        'ADMIN'
                      )
                    ) {
                      return import(
                        './views/flow/settings/availability/SlotSchedules.vue'
                      )
                    } else {
                      return accessDenied()
                    }
                  }
                },
                {
                  path: 'holidays',
                  props: true,
                  meta: { title: 'Albatross - Settings' },
                  component: () => {
                    if (
                      userStore.userHasFeatureAccessLevel(
                        'AVAILABILITY',
                        'ADMIN'
                      )
                    ) {
                      return import(
                        './views/flow/settings/availability/Holidays.vue'
                      )
                    } else {
                      return accessDenied()
                    }
                  }
                }
              ]
            },
            {
              path: 'positions',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/Positions.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'position/:id?',
              meta: { title: 'Albatross - Settings' },
              name: 'position',
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/Position.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'roles',
              meta: { title: 'Albatross - Settings' },
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/Roles.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'role/:id?',
              meta: { title: 'Albatross - Settings' },
              name: 'role',
              component: () => {
                if (userStore.userHasFeature('SETTINGS')) {
                  return import('./views/flow/settings/Role.vue')
                } else {
                  return accessDenied()
                }
              }
            }
          ]
        },
        {
          path: '/workQueue',
          name: 'workQueue',
          meta: { title: 'Albatross - Work Queue' },
          component: () => {
            if (userStore.userHasFeature('WORK_QUEUE')) {
              return import('./views/flow/workQueue/WorkQueue.vue')
            } else {
              return accessDenied()
            }
          }
        },
        {
          path: '/workQueue/:id',
          name: 'workQueueDrilldown',
          meta: { title: 'Albatross - Work Queue' },
          component: () => {
            if (userStore.userHasFeature('WORK_QUEUE')) {
              return import('./views/flow/workQueue/WorkQueueDrilldown.vue')
            } else {
              return accessDenied()
            }
          }
        },
        {
          path: '/smsQueue',
          name: 'smsQueue',
          meta: { title: 'Albatross - SMS Queue' },
          component: () => {
            if (userStore.userHasFeature('SMS_QUEUE')) {
              return import('./views/flow/smsQueue/SmsQueue.vue')
            } else {
              return accessDenied()
            }
          }
        },
        {
          path: '/installerDashboard',
          name: 'installerDashboard',
          meta: { title: 'Albatross - Installer Dashboard' },
          component: () => {
            if (userStore.userHasFeature('INSTALLER_DASHBOARD')) {
              return import(
                './views/blueraven/installerDashboard/InstallerDashboard.vue'
              )
            } else {
              return accessDenied()
            }
          }
        },
        {
          path: '/projects',
          name: 'projects',
          meta: { title: 'Albatross - Projects' },
          component: () => {
            if (userStore.userHasFeature('PROJECTS')) {
              return import('./views/flow/project/Projects.vue')
            } else {
              return accessDenied()
            }
          }
        },
        {
          path: '/project/:projectId',
          name: 'project',
          component: () => {
            if (userStore.userHasFeature('PROJECTS')) {
              return import('./views/flow/project/Project.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'details',
              name: 'projectDetails',
              components: {
                default: () =>
                  import('./views/flow/project/ProjectDetails.vue'),
                tabs: () => import('./views/flow/project/ProjectDetails.vue')
              }
            },
            {
              name: 'projectProcessStep',
              path: 'processStep/:processStepId',
              component: () => {
                if (userStore.userHasFeature('PROCESS_STEPS')) {
                  return import('./views/flow/project/ProjectProcessStep.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              name: 'ppsEvent',
              path: 'processStep/:processStepId/event/:ppsEventId',
              component: () => {
                if (userStore.userHasFeature('PROCESS_STEPS')) {
                  return import(
                    './views/flow/project/ProjectProcessStepEvent.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'workQueues',
              component: () => {
                if (userStore.userHasFeature('PROCESS_STEPS')) {
                  return import('./views/flow/project/AllWorkQueues.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'projectOverview',
              component: () => {
                if (userStore.userHasFeature('PROJECTS')) {
                  return import('./views/flow/PageOverview.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'processSteps',
              component: () => {
                if (userStore.userHasFeature('PROCESS_STEPS')) {
                  return import('./views/flow/project/AllProcessSteps.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'children',
              component: () => {
                if (userStore.userHasFeature('PROJECTS')) {
                  return import ( './views/flow/project/AllChildProjects.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'activeprocessSteps',
              component: () => {
                if (userStore.userHasFeature('PROCESS_STEPS')) {
                  return import('./views/flow/project/ActiveProcessSteps.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'events',
              component: () => {
                if (userStore.userHasFeature('PROCESS_STEPS')) {
                  return import('./views/flow/project/AllEvents.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'activeevents', //should only be used on mobile
              component: () => {
                if (userStore.userHasFeature('PROCESS_STEPS')) {
                  return import('./views/flow/project/ActiveEvents.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'projectActivity',
              component: () => {
                if (userStore.userHasFeature('PROCESS_STEPS')) {
                  return import('./views/flow/project/ProjectActivity.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              name: 'projectStatus',
              path: 'status',
              component: () => {
                if (userStore.userHasFeature('PROJECTS')) {
                  return import('./views/flow/project/StatusTracker.vue')
                } else {
                  return accessDenied()
                }
              }
            }
          ]
        },
        {
          name: 'projectAdmin',
          path: '/projectAdmin/:projectId',
          component: () => {
            //dont change this permission unless double checking with rn and cj. we have been back and forth on this 100 times
            if (
              userStore.userHasFeatureAccessLevel('PROJECTS', 'ADMIN') ||
              userStore.userHasFeatureAccessLevel('PROJECTS', 'DELETE')
            ) {
              return import('./views/flow/project/admin/ProjectAdmin.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'processSteps',
              component: () =>
                import('./views/flow/project/admin/ProcessSteps.vue')
            },
            {
              path: 'tags',
              component: () => import('./views/flow/project/admin/Tags.vue')
            }
          ]
        },
        {
          path: 'contacts',
          name: 'contacts',
          meta: { title: 'Albatross - Contacts' },
          component: () => {
            if (userStore.userHasFeature('CONTACTS')) {
              return import('./views/flow/contacts/Contacts.vue')
            } else {
              return accessDenied()
            }
          },
          children: []
        },
        {
          path: '/contact/:contactId',
          name: 'contact',
          props: true,
          meta: { title: 'Albatross - Contact' },
          component: () => {
            if (userStore.userHasFeature('CONTACTS')) {
              return import('./views/flow/contacts/Contact.vue')
            } else {
              return accessDenied()
            }
          },
          children: []
        },
        {
          path: '/newContact',
          name: 'newContact',
          props: true,
          component: () => {
            if (userStore.userHasFeatureAccessLevel('CONTACTS', 'ADD')) {
              return import('./views/flow/contacts/NewContact.vue')
            } else {
              return accessDenied()
            }
          },
          children: []
        },
        {
          path: '/orgs/:orgFilter?',
          name: 'orgs',
          meta: { title: 'Albatross - Orgs' },
          component: () => {
            if (userStore.userHasFeature('ORGS')) {
              return import('./views/flow/orgs/Orgs.vue')
            } else {
              return accessDenied()
            }
          },
          children: []
        },
        {
          path: '/org/:id',
          name: 'org',
          meta: { title: 'Albatross - Org' },
          component: () => {
            if (userStore.userHasFeature('ORGS')) {
              return import('./views/flow/orgs/Org.vue')
            } else {
              return accessDenied()
            }
          },
          children: []
        },
        {
          path: '/newOrg',
          name: 'newOrg',
          meta: { title: 'Albatross - New Org' },
          component: () => {
            if (userStore.userHasFeature('ORGS')) {
              return import('./views/flow/orgs/NewOrg.vue')
            } else {
              return accessDenied()
            }
          },
          children: []
        },
        {
          path: '/admin',
          name: 'admin',
          component: () => {
            if (userStore.userHasFeature('SYSTEM')) {
              return import('./views/flow/admin/Admin.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'orgFilters',
              component: () => import('./views/flow/admin/OrgFilters.vue')
            },
            {
              path: 'orgLevels',
              component: () => import('./views/flow/admin/OrgLevels.vue')
            },
            {
              path: 'features',
              component: () => import('./views/flow/admin/Features.vue')
            },
            {
              path: 'certs',
              component: () => import('./views/flow/admin/Certs.vue')
            },
            {
              path: 'statusTypes',
              component: () =>
                import('./views/flow/admin/CompanyUserStatus.vue')
            },
            {
              path: 'functions',
              component: () =>
                import('./views/flow/admin/functions/Functions.vue')
            },
            {
              path: 'function/:id',
              component: () =>
                import('./views/flow/admin/functions/Function.vue')
            },
            {
              path: 'uploads',
              component: () => import('./views/flow/admin/Uploads.vue')
            }
          ]
        },
        {
          path: '/commissionManagement',
          name: 'commissionManagement',
          meta: { title: 'Albatross - Commissions' },
          component: () => {
            if (userStore.userHasFeature('COMMISSIONS')) {
              return import(
                './views/blueraven/commissionManagement/CommissionManagement.vue'
              )
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'users',
              meta: { title: 'Albatross - Commissions' },
              component: () =>
                import('./views/blueraven/commissionManagement/Users.vue')
            },
            {
              path: 'users/:id',
              meta: { title: 'Albatross - Commissions' },
              name: 'commissionUser',
              component: () =>
                import('./views/blueraven/commissionManagement/User.vue')
            },
            {
              path: 'commissions',
              name: 'commissions',
              meta: { title: 'Albatross - Commissions' },
              component: () =>
                import('./views/blueraven/commissionManagement/Commissions.vue')
            },
            {
              path: 'commission/:id?',
              name: 'commission',
              meta: { title: 'Albatross - Commissions' },
              component: () =>
                import('./views/blueraven/commissionManagement/Commission.vue')
            },
            {
              path: 'overrides',
              name: 'overrides',
              meta: { title: 'Albatross - Commissions' },
              component: () =>
                import('./views/blueraven/commissionManagement/Overrides.vue')
            },
            {
              path: 'override/:id?',
              name: 'override',
              meta: { title: 'Albatross - Commissions' },
              component: () =>
                import('./views/blueraven/commissionManagement/Override.vue')
            },
            {
              path: 'accounting',
              meta: { title: 'Albatross - Commissions' },
              component: () =>
                import('./views/blueraven/commissionManagement/Accounting.vue'),
              children: [
                {
                  path: 'current',
                  meta: { title: 'Albatross - Commissions' },
                  component: () =>
                    import(
                      './views/blueraven/commissionManagement/CurrentPayroll.vue'
                    )
                },
                {
                  path: 'summary',
                  meta: { title: 'Albatross - Commissions' },
                  component: () =>
                    import('./views/blueraven/commissionManagement/Summary.vue')
                }
              ]
            },
            {
              path: 'payroll',
              meta: { title: 'Albatross - Commissions' },
              name: 'payrolls',
              component: () =>
                import('./views/blueraven/commissionManagement/Payrolls.vue')
            },
            {
              path: 'payroll/:id',
              name: 'payroll',
              meta: { title: 'Albatross - Commissions' },
              component: () =>
                import('./views/blueraven/commissionManagement/Payroll.vue'),
              children: [
                {
                  path: 'review',
                  meta: { title: 'Albatross - Commissions' },
                  name: 'payrollReview',
                  component: () =>
                    import(
                      './views/blueraven/commissionManagement/PayrollReview.vue'
                    )
                },
                {
                  path: 'summary',
                  name: 'payrollSummary',
                  meta: { title: 'Albatross - Commissions' },
                  component: () =>
                    import(
                      './views/blueraven/commissionManagement/PayrollSummary.vue'
                    )
                }
              ]
            },
            {
              path: 'residualPlans',
              name: 'residualPlans',
              meta: { title: 'Albatross - Commissions' },
              component: () =>
                import(
                  './views/blueraven/commissionManagement/ResidualPlans.vue'
                )
            },
            {
              path: 'residualPlan/:id?',
              name: 'residualPlan',
              meta: { title: 'Albatross - Commissions' },
              component: () =>
                import(
                  './views/blueraven/commissionManagement/ResidualPlan.vue'
                )
            },
            {
              path: 'residuals',
              meta: { title: 'Albatross - Commissions' },
              component: () =>
                import('./views/blueraven/commissionManagement/Residuals.vue')
            },
            {
              path: 'closerResiduals',
              name: 'closerResidualsAdmin',
              props: { isAdmin: true },
              meta: { title: 'Albatross - Commissions' },
              // component: () => import ( './views/blueraven/closerDashboard/CloserResiduals.vue')
              component: () => {
                if (
                  userStore.userHasFeatureAccessLevel('COMMISSIONS', 'ADMIN')
                ) {
                  return import(
                    './views/blueraven/closerDashboard/CloserResiduals.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'residualSearch',
              meta: { title: 'Albatross - Commissions' },
              name: 'residualSearch',
              component: () =>
                import(
                  './views/blueraven/commissionManagement/ResidualSearch.vue'
                )
            },
            {
              path: 'residual/:id',
              name: 'residual',
              meta: { title: 'Albatross - Commissions' },
              component: () =>
                import(
                  './views/blueraven/commissionManagement/ResidualReview.vue'
                )
            }
          ]
        },
        {
          path: '/finances',
          name: 'finances',
          meta: { title: 'Albatross - Finances' },
          component: () => {
            if (userStore.userHasFeature('REBATES')) {
              return import('./views/blueraven/finances/rebate/Rebate.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'rebate/batches',
              meta: { title: 'Albatross - Finances' },
              component: () => {
                if (userStore.userHasFeature('REBATES')) {
                  return import('./views/blueraven/finances/rebate/Batches.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'rebate/viewPayments',
              meta: { title: 'Albatross - Finances' },
              component: () => {
                if (userStore.userHasFeature('REBATES')) {
                  return import(
                    './views/blueraven/finances/rebate/ViewPayments.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'rebate/viewPayments/:id',
              name: 'rebateDetails',
              meta: { title: 'Albatross - Finances' },
              component: () => {
                if (userStore.userHasFeature('REBATES')) {
                  return import(
                    './views/blueraven/finances/rebate/RebateDetails.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            }
          ]
        },
        {
          path: '/electronicDocuments',
          name: 'electronicDocuments',
          meta: { title: 'Albatross - Electronic Documents' },
          component: () => {
            if (userStore.userHasFeature('ELECTRONIC_DOCUMENTS')) {
              return import(
                './views/blueraven/electronicDocuments/ElectronicDocuments.vue'
              )
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'request',
              component: () => {
                if (userStore.userHasFeature('ELECTRONIC_DOCUMENTS')) {
                  return import(
                    './views/blueraven/electronicDocuments/Request.vue'
                  )
                } else {
                  return accessDenied()
                }
              }
            }
          ]
        },
        {
          path: '/installation-agreements',
          name: 'installation-agreements',
          meta: { title: 'Albatross - Installation Agreements' },
          component: () =>
            import(
              './views/blueraven/installationAgreements/InstallationAgreements.vue'
            ),
          children: [
            {
              path: 'request',
              component: () =>
                import('./views/blueraven/installationAgreements/Request.vue')
            }
          ]
        },
        {
          path: '/smartlistv1',
          meta: { title: 'Albatross - Smartlists V1' },
          component: () => {
            if (userStore.userHasFeature('SMARTLIST')) {
              return import('./views/flow/smartlistv1/SmartlistHome.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: '',
              meta: { title: 'Albatross - Smartlists V1' },
              name: 'smartlist',
              component: () => {
                if (userStore.userHasFeature('SMARTLIST')) {
                  return import('./views/flow/smartlistv1/Smartlists.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: ':smartlistId',
              meta: { title: 'Albatross - Smartlists V1' },
              name: 'smartlistEditor',
              component: () => {
                if (userStore.userHasFeature('SMARTLIST')) {
                  return import('./views/flow/smartlistv1/Smartlist.vue')
                } else {
                  return accessDenied()
                }
              }
            }
          ]
        },
        {
          path: '/smartlist',
          meta: { title: 'Albatross - Smartlists' },
          redirect: '/smartlist/mine',
          component: () => {
            if (userStore.userHasFeature('SMARTLIST')) {
              return import('./views/flow/smartlist/Smartlists.vue')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'mine',
              meta: { title: 'Albatross - Smartlists' },
              name: 'mySmartlists',
              component: () => {
                if (userStore.userHasFeature('SMARTLIST')) {
                  return import('./views/flow/smartlist/MySmartlists.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'shared',
              meta: { title: 'Albatross - Smartlists' },
              name: 'sharedSmartlists',
              component: () => {
                if (userStore.userHasFeature('SMARTLIST')) {
                  return import('./views/flow/smartlist/SharedSmartlists.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'public',
              meta: { title: 'Albatross - Smartlists' },
              name: 'publicSmartlists',
              component: () => {
                if (userStore.userHasFeature('SMARTLIST')) {
                  return import('./views/flow/smartlist/PublicSmartlists.vue')
                } else {
                  return accessDenied()
                }
              }
            },
            {
              path: 'all',
              meta: { title: 'Albatross - Smartlists' },
              name: 'allSmartlists',
              component: () => {
                if (userStore.userHasFeatureAccessLevel('SMARTLIST', 'ADMIN')) {
                  return import('./views/flow/smartlist/AllSmartlists.vue')
                } else {
                  return accessDenied()
                }
              }
            }
          ]
        },
        {
          path: '/smartlist/editor/:reportId?',
          meta: { title: 'Albatross - Smartlist Editor' },
          name: 'reportEditor',
          component: () => {
            if (userStore.userHasFeature('SMARTLIST')) {
              return import('./views/flow/smartlist/editor/ReportEditor.vue')
            } else {
              return accessDenied()
            }
          }
        },
        {
          path: '/proposals',
          name: 'proposals',
          meta: { title: 'Albatross - Proposals' },
          component: () => {
            if (userStore.userHasFeature('PROPOSALS')) {
              return import('./views/blueraven/proposals/Proposals.vue')
            } else {
              return accessDenied()
            }
          }
        },
        {
          path: '/proposal/:proposalId',
          name: 'proposal',
          meta: { title: 'Albatross - Proposals' },
          component: () => {
            if (userStore.userHasFeature('PROPOSALS')) {
              return import('./views/blueraven/proposals/Proposal.vue')
            } else {
              return accessDenied()
            }
          }
        },
        {
          path: '/proposalDesigns/:projectId',
          name: 'proposalDesigns',
          meta: { title: 'Albatross - Proposals' },
          component: () => {
            if (userStore.userHasFeature('PROPOSALS')) {
              return import('./views/blueraven/proposals/ProposalDesigns.vue')
            } else {
              return accessDenied()
            }
          }
        },
        {
          path: 'inbox',
          name: 'inbox',
          alias: '/outbox',
          meta: { title: 'Albatross - Inbox' },
          component: () => {
            if (userStore.userHasFeature('SMS_INBOX')) {
              return import('./views/flow/settings/inbox/MainInbox')
            } else {
              return accessDenied()
            }
          },
          children: [
            {
              path: 'conversation/sms/:smsThreadId',
              meta: { title: 'Albatross - Inbox Conversation' },
              component: () => {
                if (userStore.userHasFeature('SMS_INBOX')) {
                  return import('./views/flow/settings/inbox/MainInbox')
                } else {
                  return accessDenied()
                }
              }
            }
          ]
        }
      ]
    }
  ]
})

router.beforeEach((to, from, next) => {
  document.title = to.meta.title || 'Albatross'
  //if the global spinner is on and the request takes a while, then you move to a different page that doesn't toggle the global
  //spinner then it stays on the screen until the previous request finishes.  this fixes that.
  appStore.loading = false
  //cancel all pending axios requests when route change
  fileStore.cancelPendingRequests()
  next()
})

export default router

async function getUser() {
  const { data } = await getRequest(`/user/current`)
  return { data }
}

function accessDenied() {
  let maintenanceMode =
    import.meta.env.VITE_MAINTENANCE_MODE?.toLowerCase() === 'true'
  if (maintenanceMode) {
    return import('./views/SiteUnderMaintenance.vue')
  } else {
    return import('./views/AccessDenied.vue')
  }
}
