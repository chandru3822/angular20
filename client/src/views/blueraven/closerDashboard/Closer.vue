<template>
  <v-container id="closer-dash-container">
    <v-row id="closer-dash-toolbar-container">
      <v-col cols="12" id="closer-dash-toolbar" class="pt-0 pb-2">
        <v-toolbar id="closer-dash-title-container" class="elevation-1">
          <v-toolbar-title>Closer Dashboard</v-toolbar-title>
        </v-toolbar>
      </v-col>
    </v-row>

    <v-row id="closer-dash-tabs" class="mb-2" justify="center" no-gutters>
      <v-col cols="12">
        <span class="clickable" :class="{'font-weight-bold': $route.path.includes('funnel')}" @click="goToRoute('closerFunnel')">
          Funnel
        </span>
        <div class="tab-separator mx-2"></div>
        <span class="clickable" :class="{'font-weight-bold': $route.path.includes('dashboard')}" @click="goToRoute('closerDashboard')">
          Dashboard
        </span>
        <div class="tab-separator mx-2"></div>
        <span class="clickable" :class="{'font-weight-bold': $route.path.includes('incentive')}" @click="goToRoute('closerIncentive')">
          Incentive
        </span>
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
      }
    },
    computed: {},
    watch: {},
    methods: {
      goToRoute(name) {
        this.$router.push({name})
      },
    },
  }
</script>

<style lang="scss" scoped>
  #closer-dash-container {
    font-family: 'Roboto Condensed', sans-serif !important;
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
