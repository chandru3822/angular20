<template>
  <SidePanelExpansionPanel header="Details">
    <template v-if="!hideAdminBtn" v-slot:tool-btn>
      <v-btn
          text color="primary" class="px-0" small
          v-if="$store.getters.userHasFeatureAccessLevel('PROJECTS', 'ADMIN') || $store.getters.userHasFeatureAccessLevel('PROJECTS', 'DELETE')"
          :to="`/projectAdmin/${projectId}/processSteps`"
      >
        <v-icon>mdi-cog</v-icon>
      </v-btn>
    </template>
    <template v-slot:expanded-content>
      <v-card outlined v-for="tab in tabs"
              class="mb-2 pa-2 elevation-0 body-large"
              :class="{'active-tab': tabIsActive(tab)}"
              @click="changeTabs(tab, true)">
        {{ tab.tabName }}
      </v-card>
    </template>
  </SidePanelExpansionPanel>
</template>
<script>

import {getRequestWithParams, logError} from '@/helpers/helpers'
import SidePanelExpansionPanel from "@/components/SidePanelExpansionPanel.vue";

export default {
  name: 'ProjectTabs',
  components: {
    SidePanelExpansionPanel
  },
  props: {
    project: Object,
    tabChangeCallback: Function,
    hideAdminBtn: Boolean,
  },
  watch: {},
  data() {
    return {
      projectId: parseInt(this.$route.params.projectId),
      tabsLoading: true,
      selectedTab: {},
      sectionExpanded: false,
      tabs: [],
    }
  },
  created() {
    this.getProjectTabs()
  },
  computed: {
    isMobile(){
      return this.$vuetify.breakpoint.smAndDown
    },
  },
  methods: {
    changeTabs(tab, buttonClicked) {
      if(tab.customPath) {
        this.$router.push(tab.customPath)
      } else {
        this.selectedTab = tab
        this.tabChangeCallback(this.selectedTab, buttonClicked)
      }
    },
    tabIsActive(tab) {
      if(tab.customPath) {
        return this.$route.path === tab.customPath
      } else {
        return tab.id === this.selectedTab.id && this.$route.name === 'projectDetails'
      }
    },
    getProjectTabs: async function () {
      this.tabsLoading = true
      try {
        let params = {
          projectId: parseInt(this.projectId)
        }
        const {data} = await getRequestWithParams(`/objectTypeTab/project`, {params})
        this.tabs = data
        this.tabs.push({
          archived: false,
          companyObjectTypeId: 1,
          displayOrder: this.tabs.length,
          id: -1,
          tabName: 'Uploaded and Linked Documents',
          uniqueIdentifier: 'tab_documents'
        })
        this.tabs.push({
          archived: false,
          companyObjectTypeId: 1,
          displayOrder: this.tabs.length + 1,
          id: -2,
          customPath: `/project/${ this.projectId }/workQueues`,
          tabName: 'Current Work Queues',
          uniqueIdentifier: 'tab_work_queues'
        })
        this.selectedTab = this.tabs?.length > 0 ? data[0] : {}
        this.tabChangeCallback(this.selectedTab)
        // use this line to preselect the docs tab for testing purposes
        // this.selectedTab = this.tabs?.length > 0 ? data[this.tabs?.length - 1] : {}
      } catch (e) {
        logError(e)
      } finally {
        this.tabsLoading = false
      }
    },
  }
}
</script>

<style lang="scss" scoped>
//removes the blue-ish effect after you click one of these
.active-tab:focus::before {
  opacity: 0;
}

.active-tab {
  background-color: var(--v-active-base) ;
}

.active-tab-button {
  border: solid 1px var(--v-grey-lighten1);
  padding: 10px;
  margin-bottom: 10px;
}

</style>

<style lang="scss">
#project-details-container div.v-expansion-panel-content__wrap{
  padding:0;
}
</style>
