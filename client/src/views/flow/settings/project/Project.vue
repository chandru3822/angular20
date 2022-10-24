<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <h3>Projects</h3>
          <v-spacer></v-spacer>
          <v-toolbar-items :slot="constants.IS_MOBILE ? 'extension' : 'default'">
            <v-tabs class="tabs-bar" v-model="activeTab">
              <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path"
                     class="text-capitalize ma-0"
                     :style="{'margin-left': index === 0 ? '12px !important' : '0'}">
                {{ tab.label }}
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
    name: 'ProjectSettings',
    mixins: [Vue2Filters.mixin],

    data () {
      return {
        snackbar: {},
        constants,
        processStepId: this.$route.params.id,
        companyId: this.$store.state.user.details.companyId,
        companyObjectTypeId: this.$route.query.companyObjectTypeId,
        tabs: [
          {
            id: 1,
            label: 'Custom Field Groups',
            path: `/settings/project/customFieldGroups?companyObjectTypeId=${this.$route.query.companyObjectTypeId}`,
          },
          {
            id: 2,
            label: 'Tabs',
            path: `/settings/project/tabs?companyObjectTypeId=${this.$route.query.companyObjectTypeId}`,
          },
          {
            id: 3,
            label: 'Attachment Types',
            path: `/settings/project/attachmentTypes?companyObjectTypeId=${this.$route.query.companyObjectTypeId}`,
          },
          {
            id: 4,
            label: 'System',
            path: `/settings/project/system?companyObjectTypeId=${this.$route.query.companyObjectTypeId}`,
          }
        ]
      }
    },
    computed: {
      //this should not be so hard
      activeTab: {
        get: function() {
          return this.$route?.path?.includes('/attachmentType') ? `/settings/project/attachmentTypes?companyObjectTypeId=${this.companyObjectTypeId}` : null
        },
        set: function(val) {
          return val
        }
      }
    },
    async created () {
    },
    methods: {}

  }
</script>

<style scoped lang="scss">
.name-container {
  background-color: var(--v-primary-lighten9) !important;
  border-radius: 5px;
}
</style>
