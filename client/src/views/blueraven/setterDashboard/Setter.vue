<template>
  <v-container id="setter-dash-container">
    <v-row id="setter-dash-toolbar-container" v-if="!hideHeader">
      <v-col cols="12" id="setter-dash-toolbar">
        <v-toolbar id="setter-dash-title-container" class="elevation-1">
          <v-toolbar-title class="title-large">Setter Dashboard</v-toolbar-title>
        </v-toolbar>
        <v-tabs class="tabs-bar">
          <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path"
                 class="text-capitalize body-medium tab-bar text-center"
                 :style="{'margin-left': index === 0 ? '12px !important' : '0'}">
            {{ tab.label }}
          </v-tab>
        </v-tabs>
      </v-col>
    </v-row>
    <router-view></router-view>
  </v-container>
</template>

<script setup>
import {useRouter, useRoute} from "vue-router/composables";
import {ref} from "vue";
import { useUserStore } from '@/stores/UserStore.js'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const hideHeader = ref(userStore.hideHeader || false)

const tabs = [
  {
    id: 1,
    label: 'FUNNEL',
    path: `/setter/funnel`,
  },
  {
    id: 2,
    label: 'PERFORMANCE',
    path: `/setter/dashboard`,
  },
  {
    id: 3,
    label: 'INCENTIVE',
    path: `/setter/incentive`,
  }
]
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
        border-right: 1px solid var(--v-primary-base);
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
