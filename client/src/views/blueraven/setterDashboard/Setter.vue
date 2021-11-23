<template>
  <v-container id="setter-dash-container">
    <v-row id="setter-dash-toolbar-container">
      <v-col cols="12" id="setter-dash-toolbar" class="pt-0 pb-2">
        <v-toolbar id="setter-dash-title-container" class="elevation-1">
          <v-toolbar-title>Setter Dashboard</v-toolbar-title>
        </v-toolbar>
      </v-col>
    </v-row>

    <v-row id="setter-dash-tabs" class="mb-2" justify="center" no-gutters>
      <v-col cols="12">
        <span class="clickable" :class="{'font-weight-bold': $route.path.includes('funnel')}" @click="goToRoute('setterFunnel')">
          Funnel
        </span>
        <div class="tab-separator mx-2"></div>
        <span class="clickable" :class="{'font-weight-bold': $route.path.includes('dashboard')}" @click="goToRoute('setterDashboard')">
          Dashboard
        </span>
        <div class="tab-separator mx-2"></div>
        <span class="clickable" :class="{'font-weight-bold': $route.path.includes('incentive')}" @click="goToRoute('setterIncentive')">
          Incentive
        </span>
      </v-col>
    </v-row>
    <router-view></router-view>
  </v-container>
</template>

<script>
  export default {
    name: 'Setter',
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
  #setter-dash-container {
    font-family: 'Roboto Condensed', sans-serif !important;
    letter-spacing: 0.02em !important;
    overflow: auto;
  }

  #setter-dash-toolbar-container {
    #setter-dash-toolbar {
      header {
        background-color: #fff !important;
      }

      #setter-dash-title-container ::v-deep .v-toolbar__content {
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
          border: 1px solid var(--v-primaryCustom-base) !important;
          font-size: 11px;
          letter-spacing: 0.02em !important;
          height: 25px;

          &:not(:last-child) {
            border-right: none !important;
          }

          &:hover {
            background-color: var(--v-primaryCustom-base);
            color: #fff !important;
          }
        }

        .v-btn--active {
          background-color: var(--v-primaryCustom-base);
          color: #fff !important;
        }
      }
    }
  }

  #setter-dash-tabs {
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
        border-right: 1px solid var(--v-primaryCustom-base);
      }
    }
  }

  @media (min-width: 500px) {
    #setter-dash-toolbar-container #setter-dash-toolbar .v-toolbar .v-toolbar__content .v-toolbar__title {
      font-size: 16px;
    }
  }

  @media (min-width: 737px) {
    #setter-dash-toolbar-container {
      #setter-dash-toolbar {
        #setter-dash-title-container {
          ::v-deep .v-toolbar__content {
            .v-toolbar__title {
              font-size: 18px;
            }
          }
        }
      }
    }

    #setter-dash-tabs {
      margin: 0 auto;

      .col-12 span {
        font-size: 12px;
      }
    }
  }

  @media (min-width: 1070px) {
    #setter-dash-toolbar-container {
      #setter-dash-toolbar {
        #setter-dash-title-container {
          ::v-deep .v-toolbar__content {
            .v-toolbar__title {
              font-size: 20px;
            }
          }
        }
      }
    }

    #setter-dash-tabs .col-12 span {
      font-size: 13px;
    }
  }
</style>
