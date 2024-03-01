<template>
  <v-container id="closer-dash-container">
    <v-row id="closer-dash-toolbar-container">
      <v-col cols="12" id="closer-dash-toolbar" class="pt-0 pb-2">
        <v-toolbar id="closer-dash-title-container" class="elevation-1">
          <v-toolbar-title>Closer Dashboard</v-toolbar-title>
        </v-toolbar>
        <v-tabs class="tabs-bar" v-model="activeTab">
          <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path"
                 class="text-capitalize body-medium tab-bar"
                 :style="{'margin-left': index === 0 ? '12px !important' : '0'}">
            {{ tab.label }}
          </v-tab>
        </v-tabs>
      </v-col>
    </v-row>
    <router-view></router-view>
  </v-container>
</template>

<script>
  export default {
    name: 'Closer',
    components: {
    },
    data () {
      return {
        snackbar: {},
        tabs: [
          {
            id: 1,
            label: 'Funnel',
            path: `/closer/funnel`,
          },
          {
            id: 2,
            label: 'Ranking',
            path: `/closer/dashboard`,
          },
          {
            id: 3,
            label: 'Incentive',
            path: `/closer/incentive`,
          },
          {
            id: 4,
            label: 'Leaderboard',
            path: `/closer/leaderboard`,
          },
          {
            id: 5,
            label: 'Residuals',
            path: `/closer/residuals`,
          }
        ]
      }
    },
    computed: {
      activeTab: {
        get: function() {
          return this.$route?.path?.includes('/event') ? `/settings/processStep/${this.$route.params.id}/events` : null
        },
        set: function(val) {
          return val
        }
      }
    },
    watch: {},
    methods: {
      goToRoute(name) {
        this.$router.push({name})
      },
    },
  }
</script>

<style lang="scss" scoped>
  .tab-bar{
    margin-left: 0px !important;
    padding-left: 0px !important;
  }

  #closer-dash-container {
    letter-spacing: 0.02em !important;
    overflow: auto;
  }

  #closer-dash-toolbar-container {
    #closer-dash-toolbar {
      header {
        background-color: #fff !important;
      }

      #closer-dash-title-container ::v-deep .v-toolbar__content {
        width: 100%;

        .v-toolbar__title {
          font-size: 13px;
        }
      }

      #date-range-btns-toolbar {
        position: fixed;
        bottom: 0;
        z-index: 3;
        height: 45px !important;

        ::v-deep .v-toolbar__content {
          display: flex;
          justify-content: flex-end;
          padding: 5px 12px;
          width: 100%;
          height: 45px !important;

          .v-toolbar__items {
            display: flex;
            flex-flow: row nowrap;
            justify-content: flex-end;
            align-items: center;
            padding-right: 0;
          }
        }

        .v-btn-toggle .v-btn {
          border: 1px solid var(--v-primary-base) !important;
          font-size: 11px;
          letter-spacing: 0.02em !important;
          height: 25px;

          &:not(:last-child) {
            border-right: none !important;
          }

          &:hover {
            background-color: var(--v-primary-base);
            color: #fff !important;
          }
        }

        .v-btn--active {
          background-color: var(--v-primary-base);
          color: #fff !important;
        }
      }
    }
  }

  #closer-dash-tabs {
    width: 100%;

    .col-12 {
      display: flex;
      flex-flow: row nowrap;
      justify-content: flex-end;

      span {
        letter-spacing: 0.02em;
        font-size: 11px;
      }

      .tab-separator {
        border-right: 1px solid var(--v-primary-base);
      }
    }
  }

  @media (min-width: 500px) {
    #closer-dash-toolbar-container #closer-dash-toolbar .v-toolbar .v-toolbar__content .v-toolbar__title {
      font-size: 16px;
    }
  }

  @media (min-width: 737px) {
    #closer-dash-toolbar-container {
      #closer-dash-toolbar {
        #closer-dash-title-container {
          ::v-deep .v-toolbar__content {
            .v-toolbar__title {
              font-size: 18px;
            }
          }
        }
      }
    }

    #closer-dash-tabs {
      margin: 0 auto;

      .col-12 span {
        font-size: 12px;
      }
    }
  }

  @media (min-width: 1070px) {
    #closer-dash-toolbar-container {
      #closer-dash-toolbar {
        #closer-dash-title-container {
          ::v-deep .v-toolbar__content {
            .v-toolbar__title {
              font-size: 20px;
            }
          }
        }
      }
    }

    #closer-dash-tabs .col-12 span {
      font-size: 13px;
    }
  }
</style>
