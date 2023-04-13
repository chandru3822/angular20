<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar" id="project-settings-toolbar">
          <h3>Projects</h3>
          <v-spacer></v-spacer>
          <v-toolbar-items :slot="isMobile ? 'extension' : 'default'">
            <v-tabs class="tabs-bar" v-model="activeTab" id="projects-settings-tabs">
              <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path"
                     class="text-capitalize ma-0"
                     :style="{'margin-left': (index === 0 && $vuetify.breakpoint.smAndDown) ? '12px !important' : '0'}">
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
      },
      isMobile(){
        return this.$vuetify.breakpoint.smAndDown
      },
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
<style lang="scss">
@media (max-width: 959px) {
  #projects-settings-tabs > div > div.v-slide-group__wrapper > div {
    justify-content: center;
  }
  #projects-settings-tabs > div > div.v-slide-group__prev.v-slide-group__prev--disabled {
    display: none;
  }
  #project-settings-toolbar > div.v-toolbar__extension {
    padding-bottom: 0.75rem;
  }
}
</style>
