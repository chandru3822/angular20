<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar color="white" flat>
          <v-breadcrumbs :items="breadcrumbs"></v-breadcrumbs>
        </v-toolbar>
        <v-toolbar flat class="app-toolbar">
          <h3>Projects</h3>
          <v-spacer></v-spacer>
          <v-toolbar-items :slot="constants.IS_MOBILE ? 'extension' : 'default'">
            <v-tabs>
              <v-tab :to="`/settings/project/customFieldGroups?companyObjectTypeId=${companyObjectTypeId}`">
                Custom Field Groups
              </v-tab>
              <v-tab :to="`/settings/project/tabs?companyObjectTypeId=${companyObjectTypeId}`">
                Tabs
              </v-tab>
              <v-tab :to="`/settings/project/attachments?companyObjectTypeId=${companyObjectTypeId}`">
                Attachment Types
              </v-tab>
            </v-tabs>
          </v-toolbar-items>
        </v-toolbar>
        <router-view/>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
  import Vue2Filters from 'vue2-filters'

  import constants from '@/helpers/constants'

  export default {
    name: 'ProcessStep',
    mixins: [Vue2Filters.mixin],

    data () {
      return {
        snackbar: {},
        constants,
        processStepId: this.$route.params.id,
        companyId: this.$store.state.user.details.companyId,
        companyObjectTypeId: this.$route.query.companyObjectTypeId,
        breadcrumbs: [
          {
            text: 'Back',
            disabled: false,
            exact: true,
            to: `/settings`
          },
        ]
      }
    },
    computed: {
    },
    async created () {
    },
    methods: {}

  }
</script>

<style scoped lang="scss">
.name-container {
  background-color: var(--v-rowShadeCustom-base) !important;
  border-radius: 5px;
}
</style>
