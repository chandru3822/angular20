<template>
  <v-container id="smartlists-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Smartlists</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text to="/smartlist/null" color="primary">
              <span>Add Smartlist</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-tabs>
          <v-tab :to="'/smartlistv2/mine'">My Smartlists</v-tab>
          <v-tab :to="'/smartlistv2/shared'">Shared with Me</v-tab>
          <v-tab :to="'/smartlistv2/public'">Public Smartlists</v-tab>
          <v-tab>All Smartlists</v-tab>
        </v-tabs>
      </v-col>
    </v-row>
    <router-view></router-view>
  </v-container>


</template>

<script setup>

</script>

<style scoped lang="scss">

</style>