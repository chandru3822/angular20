<template>
  <v-row class="fill-height" align="center" justify="start">
    <v-col class="shrink" cols="12">
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">
          Organizations
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-tabs>
            <v-tab :to="`/settings/orgs/list`">
              Orgs
            </v-tab>
            <v-tab :to="`/settings/orgs/hierarchy`">
              Hierarchy
            </v-tab>
          </v-tabs>
        </v-toolbar-items>
      </v-toolbar>
      <router-view/>
    </v-col>
  </v-row>
</template>

<script>
  export default {
    name: 'Orgs',
    data () {
      return {}
    },
    computed: {},
    methods: {},
    async created () {}
  }
</script>

<style lang="scss" scoped>

</style>
