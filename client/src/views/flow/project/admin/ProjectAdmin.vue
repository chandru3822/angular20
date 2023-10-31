<template>
  <div id="project-admin-container">
    <v-toolbar flat color="#E3E3E3" class="project-header">
      <div class="app-title albatross-header-1">
        <router-link :to="`/project/${projectId}/status`">{{ project.projectName }}</router-link>
      </div>
      <v-spacer></v-spacer>
      <v-btn color="primary" dark class=" float-right white--text" @click="deleteProjectConfirm=true">
        Delete Project
      </v-btn>
    </v-toolbar>
    <ConfirmationDialog
        :open-dialog="deleteProjectConfirm"
        @confirm="deleteProject"
        @close-dialog="deleteProjectConfirm = false"
    >
      <span class="error--text">WARNING:</span>
      This cannot be undone. Are you sure you want to delete this project?
    </ConfirmationDialog>
    <v-row>
      <v-col cols="12" class="relative">
        <v-btn text class="pl-1 pr-2 anchor" :to="`/project/${projectId}/status`">
          <v-icon>arrow_left</v-icon>
          <span>Back to Project</span>
        </v-btn>
        <v-tabs class="tabs-bar" v-model="activeTab">
          <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path"
                 class="text-capitalize ma-0"
                 :style="{'margin-left': index === 0 ? '12px !important' : '0'}">
            {{ tab.label }}
          </v-tab>
        </v-tabs>
        <router-view :process-id="project.processId">
        </router-view>
      </v-col>

    </v-row>
  </div>
</template>

<script>

import ConfirmationDialog from "@/components/ConfirmationDialog.vue";
import {deleteRequest, getRequest, getSnackbar, logError} from "@/helpers/helpers";
import {AppMutations} from "@/stores/AppStore";

export default {
  name: 'ProjectAdmin',
  components: {ConfirmationDialog},

  data () {
    return {
      projectId: parseInt(this.$route.params.projectId),
      project: {},
      deleteProjectConfirm: false,
    }
  },
  computed: {
    //this should not be so hard
    activeTab: {
      get: function() {
        return this.$route?.path?.includes('/attachmentType') ? `/settings/event/${this.eventId}/attachmentTypes` : null
      },
      set: function(val) {
        return val
      }
    },
    tabs() {
      return [
        {
          id: 1,
          label: 'Process Steps',
          path: `/projectAdmin/${this.projectId}/processSteps`,
        },
        {
          id: 2,
          label: 'Tags',
          path: `/projectAdmin/${this.projectId}/tags`,
        }
      ]
    }
  },
  async created () {
    await this.getProject()
  },
  methods: {
    getProject: async function () {
      try {
        const {data} = await getRequest(`/project/${this.projectId}`)
        this.project = data
        window.document.title = `${this.project.projectName} - Admin`
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching project')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async deleteProject() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await deleteRequest(`/project/${this.projectId}`)
        this.snackbar = getSnackbar('SUCCESS', 'Project Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$router.push('/projects')
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error deleting project')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
  }

  }
</script>

<style scoped lang="scss">
#project-admin-container {
  width: 100%;
  height: 100%;
  max-height: 100% !important;
  padding: 0 !important;
}

.tabs-bar {
  top: -12px;
  border-top: 1px solid #E6E6E6;
  border-bottom: 1px solid #E6E6E6;
  .v-tab:hover {
    color: var(--v-primary-base);
  }
}
</style>
