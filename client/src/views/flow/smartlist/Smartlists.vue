<template>
<v-container id="smartlists-container" class="fill-height align-start">
  <v-row class="align-content-start">
    <v-col cols="12">
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">Smartlists</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <a-btn
              variant="text"
              to="/smartlist/editor"
              color="primary"
              v-if="userCanAdd"
              text="Add Smartlist"
              prepend-icon="add"
          ></a-btn>
        </v-toolbar-items>
      </v-toolbar>
      <v-tabs class="elevation-1">
        <v-tab :to="'/smartlist/mine'">My Smartlists</v-tab>
        <v-tab :to="'/smartlist/shared'">Shared with Me</v-tab>
        <v-tab
          v-if="userCanViewAll || userIsSmartlistAdmin"
          :to="'/smartlist/public'"
        >
          Public Smartlists
        </v-tab>
        <v-tab
          v-if="userIsSmartlistAdmin"
          :to="'/smartlist/all'"
        >
          All Smartlists
        </v-tab>
      </v-tabs>
    </v-col>
    <v-col cols="12">
      <router-view></router-view>
    </v-col>
  </v-row>
</v-container>
</template>

<script setup>
import { getCurrentInstance } from 'vue'
import { useUserStore } from '@/stores/UserStorePinia.js'


const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()
const userCanAdd = userStore.userHasFeatureAccessLevel('SMARTLIST', 'ADD')
const userCanViewAll = userStore.userHasFeatureAccessLevel('SMARTLIST', 'VIEW_ALL')
const userIsSmartlistAdmin = userStore.userHasFeatureAccessLevel('SMARTLIST', 'ADMIN')
</script>

<style scoped lang="scss">
@import "@/styles/main.scss";


// Putting styling here in the parent which affects child components to keep it DRY.
// Will probably move to children when they each move to use a unified table component
:deep(.v-data-table__wrapper) {
  height: calc(100vh - 305px);
}

:deep(.v-data-footer) {
  position: fixed;
  bottom: 0;
  left: 0;
  width: 100%;
  background-color: white;
}

:deep(tr:nth-of-type(even)) {
  @extend .shaded-row;
}

:deep(.td-action) {
  width: 8%;
}

:deep(.td-name) {
  width: 37%;
}
</style>
