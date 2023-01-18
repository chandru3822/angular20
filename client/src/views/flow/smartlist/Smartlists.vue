<template>
  <v-container id="smartlists-container" class="fill-height align-start">
    <v-row class="align-content-start">
      <v-col cols="12">
        <v-toolbar color="white" class="elevation-0">
          <v-toolbar-title class="app-title">Smartlists</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text to="/smartlist/null" color="primary">
              <span>Add Smartlist</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-tabs>
          <v-tab :to="'/smartlist/mine'">My Smartlists</v-tab>
          <v-tab :to="'/smartlist/shared'">Shared with Me</v-tab>
          <v-tab :to="'/smartlist/public'">Public Smartlists</v-tab>
          <v-tab :to="'/smartlist/all'">All Smartlists</v-tab>
        </v-tabs>
      </v-col>
      <v-col cols="12">
        <router-view></router-view>
      </v-col>
    </v-row>
  </v-container>


</template>

<script setup>

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