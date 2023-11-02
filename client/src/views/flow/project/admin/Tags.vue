<template>
  <div id="project-tag-admin">

    <v-row v-if="userIsAdmin">

        <v-col cols="12" class="pt-0">

          <v-toolbar flat class="project-header">
            <v-toolbar-title>Assigned Project Tags</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <v-menu
                  v-model="displayDropdown"
                  bottom
                  offset-y
                  min-width="350"
                  :close-on-content-click="false"
              >
                <template #activator="{on}">
                  <v-btn text color="primary" class="" small v-on="on" @click="[ getAllTags() ]">
                    <v-icon>add</v-icon>
                    <span v-if="!isMobile">Add Project Tag</span>
                  </v-btn>
                </template>

                <v-card class="pa-5">
                  <v-select
                      v-model="selectedTag"
                      :items="availableTags"
                      @input="addTagToProject"
                      :loading="tagsLoading"
                      return-object
                      label="Select an Available Tag"
                      item-text="tagName"
                      item-value="id"
                  ></v-select>
                </v-card>
              </v-menu>
            </v-toolbar-items>
          </v-toolbar>

          <v-divider></v-divider>

          <v-row class="pl-4">
            <v-col cols="12">
              <v-list>
                <v-list-item v-for="(tag, index) in filteredProjectTags"
                             :key="index">
                  <v-list-item-title>
                    {{ tag.tagName }}
                    <v-btn small text color="primary" @click="removeTagFromProject(tag)"><v-icon>delete</v-icon></v-btn>
                  </v-list-item-title>
                </v-list-item>
              </v-list>
            </v-col>
          </v-row>
        </v-col>
    </v-row>

  </div>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {
  handleHidingGlobalLoader,
  getRequest,
  getRequestWithParams,
  postRequest,
  deleteRequest,
  getSnackbar,
  logError
} from '@/helpers/helpers'
import {getCompanyAssignedToProcessStep, getCancelledCompanyStatusTypes} from '@/services/processStepStatusTypeService'
import orderBy from "lodash.orderby";

export default {
  name: 'ProjectTags.vue',
  props: {
  },
  data() {
    return {
      projectId: parseInt(this.$route.params.projectId),
      userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('PROJECTS', 'ADMIN'),
      projectTags: [],
      displayDropdown: false,
      tagsLoading: false,
      allTags: [],
      selectedTag: {}
    }
  },
  components: {
  },
  computed: {
    filteredProjectTags() {
      return this.projectTags.filter(pt => !pt.archived)
    },
    availableTags() {
      return this.allTags.filter(t => {
        return !this.filteredProjectTags.map(pt => pt.tagId).includes(t.id)
      })
    },
    isMobile(){
      return this.$vuetify.breakpoint.smAndDown
    }
  },
  async created() {
    await this.getProjectTags()
  },
  methods: {
    async getAllTags() {
      if(this.allTags?.length === 0) {
        this.tagsLoading = true
        try {
          //for now this is just hardcoded to show project tags
          const {data, status} = await getRequest(`/tag/byType/1`)
          this.allTags = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } finally {
          this.tagsLoading = false
        }
      }
    },
    getProjectTags: async function () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequestWithParams(`/tag/project/${this.projectId}`,
            {skipCancel: true}, null, [])
        this.projectTags = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Loading Project Tags')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async addTagToProject() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.displayDropdown = false
        const {data, status} = await postRequest(`/tag/project/${this.projectId}`, this.selectedTag)
        this.projectTags.push(data)
        this.selectedTag = {}
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Tag to Project')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async removeTagFromProject(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await deleteRequest(`/tag/project/${this.projectId}/${item.id}`)
        item.archived = true
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Removing Tag From Project')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
  }
}
</script>

<style scoped lang="scss">
#project-tag-admin {
  background: #ffffff;
  height: calc(100vh - 250px)
}
</style>
