<template>
  <v-container class="px-5">
    <div class="activity-header">
      <v-text-field
        prepend-inner-icon="search"
        text
        label="Search"
        clearable
        v-model="search"
      ></v-text-field>
      <v-btn text small color="primary" @click="changeSortDirection()">
        <v-icon v-if="sortDirection === 'desc'">mdi-arrow-up</v-icon>
        <v-icon v-else>mdi-arrow-down</v-icon>
      </v-btn>
      <v-menu v-model="filterMenuOpen" transition="scale-transition" offset-y left attach
              :close-on-content-click="false">
        <template v-slot:activator="{ on }">
          <v-btn text small color="primary" v-on="on">
            <v-icon>mdi-filter</v-icon>
          </v-btn>
        </template>
        <v-list dense class="">
          <v-list-item v-for="at in activityTypes">
            <v-list-item-content>
              <v-list-item-title>
                <v-checkbox
                  dense
                  hide-details
                  v-model="at.show"
                  :label="at.activityType"
                />
              </v-list-item-title>
            </v-list-item-content>
          </v-list-item>
        </v-list>
      </v-menu>
    </div>
    <div class="activity-body">
      <div v-if="!timelineView">
        <div v-for="type in filteredTopics">
          {{ type.activityType }}
          <v-expansion-panels accordion multiple flat class=".rounded-0">
            <v-expansion-panel v-for="h in orderBy(type.activityTypeHashtags, 'lastUpdated', (sortDirection === 'asc' ? 1 : -1))" :key="h.hashtagId">
              <v-expansion-panel-header class="expansion-panel-header">
                <template v-slot:default="{ open }">
                  <v-row no-gutters class="align-center" :class="{'bold' : open}">
                    <span class="mr-2">#{{ h.hashtag }}</span>
                    <span>{{ h.activityCount }} {{ type.activityType.toLowerCase() }} |
            last updated: {{ h.lastUpdated | formatDate('timestamp', 'M/D/YY h:mm a') }}</span>
                  </v-row>
                </template>
              </v-expansion-panel-header>
              <v-expansion-panel-content>
                <ActivityList :activities="h.activities"
                              :project-id="projectId"
                              :contact-id="contactId"
                              :user-id="userId"
                              :org-id="orgId"
                              :section-type="sectionType"
                              :edit-callback="setEditedActivity"
                              :search-callback="searchByClick"
                ></ActivityList>
              </v-expansion-panel-content>
            </v-expansion-panel>
          </v-expansion-panels>
        </div>
      </div>
      <ActivityList v-else
                    :activities="sortedFilteredActivities"
                    :project-id="projectId"
                    :contact-id="contactId"
                    :user-id="userId"
                    :org-id="orgId"
                    :section-type="sectionType"
                    :edit-callback="setEditedActivity"
                    :search-callback="searchByClick"
      ></ActivityList>
    </div>
    <div class="activity-footer">
      <v-divider class="my-3 activity-hr"></v-divider>
      <v-btn outlined color="primary"
             class="one-hunned"
             v-if="!addActivity && null == editedActivity.id"
             :loading="topicsLoading"
             @click="[addActivity = true, selectedTopics = [] ]">
        <v-icon>mdi-plus</v-icon>
        Add note
      </v-btn>
      <div v-else>
<!--        <v-textarea outlined v-model="editedActivity.note"></v-textarea>-->
        <Mentionable
          :keys="['@']"
          :items="users"
          offset="6"
          insert-space
        >
          <v-textarea class="body-medium" hide-details
                      auto-grow
                      rows="2"
                      outlined
                       v-model="editedActivity.note">
          </v-textarea>

          <template #no-result>
            <div class="dim">
              No result
            </div>
          </template>

          <template #item-@="{ item }">
            <div class="user">
                <span class="dim">
                  ({{ item.value }})
                </span>
            </div>
          </template>
        </Mentionable>
        <v-autocomplete
          v-model="selectedTopics"
          class="mt-3"
          :items="topics"
          multiple
          label="Topics"
          return-object
          item-text="hashtag"
        ></v-autocomplete>
        <v-checkbox
          v-if="null != $route.params.processStepId
                || null != $route.params.ppsEventId
                || editedActivity.linked"
          class="ml-3"
          dense
          v-model="editedActivity.linked"
          @change="editedActivity.linkLabel = null"
          :label="getLinkLabel()"
        />
        <div class="d-flex">
          <v-btn text color="primary" class="text-capitalize"
                 @click="[addActivity = false, editedActivity = {}]">
            cancel
          </v-btn>
          <v-btn color="primary" class="text-capitalize flex-grow-1"
                 :loading="savingActivity"
                 @click="saveActivity(null == editedActivity.id)"
                 :disabled="!editedActivity.note">
            Save
          </v-btn>
        </div>
      </div>

    </div>
  </v-container>

</template>

<script>
import {
  getRequest,
  deleteRequest,
  postRequest,
  putRequest,
  postRequestWithRequestParams,
  getSnackbar,
  handleHidingGlobalLoader
} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from "vue2-filters"
import {getNoteHashtags} from "@/services/activityService"
import ConfirmationDialog from "@/components/ConfirmationDialog";
import ActivityList from "@/views/flow/components/ActivityList.vue";
import orderBy from "lodash.orderby";
import cloneDeep from "lodash.clonedeep";
import {Mentionable} from 'vue-mention'

export default {
  name: 'ActivitySection',
  components: {ActivityList, ConfirmationDialog, Mentionable},
  mixins: [Vue2Filters.mixin],
  props: {
    contactId: Number,
    orgId: Number,
    userId: Number,
    projectId: Number,
    objectTypeId: Number,
    timelineView: Boolean
  },
  data() {
    return {
      snackbar: {},
      search: this.$route.query.search != null ? this.$route.query.search : '',
      linkLabel: '',
      users: [],
      addActivity: false,
      blankActivity: {id: null, activityHashtags: []},
      editedActivity: {},
      editedIndex: null,
      activityTopics: [],
      selectedTopics: [],
      topics: [],
      activities: [],
      topicsLoading: false,
      savingActivity: false,
      sortDirection: 'desc',
      sectionType: '',
      primaryId: null,
      filterMenuOpen: false,
      //should probably load this but hardcoding for now
      activityTypes: [
        {id: 1, activityType: 'Activities', show: true},
        {id: 2, activityType: 'Notes', show: true},
      ]
    }
  },
  watch: {
    timelineView: function () {
      if (this.timelineView) {
        this.getActivities()
      } else {
        this.getActivityTopics()
      }
    }
  },
  computed: {
    filteredTopics() {
      let shownActivityTypes = this.activityTypes.filter(at => at.show).map(at => at.id)
      console.log('randalogger',shownActivityTypes)
      console.log('at',this.activityTopics)
      return this.activityTopics.filter(a => {
        console.log('randalogger',a.id)
        return shownActivityTypes.includes(a.id)
      })
    },
    sortedFilteredActivities() {
      return orderBy(this.activities.filter(a => {
        //filter out archived
        //if search is not empty then filter that stuff here too
        //and ensure the activityTypeId is selected in the filter
        let shownActivityTypes = this.activityTypes.filter(at => at.show).map(at => at.id)

        return !a.archived
          && ((this.search == null || this.search === '') || this.activityContainsSearch(a))
          && shownActivityTypes.includes(a.activityTypeId)

      }), ['pinned', 'dateCreated'], ['desc', this.sortDirection])
    }
  },
  created() {
    switch (this.objectTypeId) {
      case 2:
        this.primaryId = this.contactId
        this.sectionType = `contact`
        break
      case 3:
        this.primaryId = this.userId
        this.sectionType = `user`
        break
      case 5:
        this.primaryId = this.orgId
        this.sectionType = `org`
        break
      default:
        this.primaryId = this.projectId
        this.sectionType = `project`
        break
    }
    this.getTopics()
    //when this page loads for the first time it will always be on timeline view so we dont have to check here. only on watch
    this.getActivities()
    this.getUsers()
  },
  methods: {
    cloneDeep,
    getLinkLabel() {
      return this.editedActivity.linked && null != this.editedActivity.linkLabel ? `Link ${this.editedActivity.linkLabel}` : `Link ${this.$store.state.project.linkLabel}`
    },
    activityContainsSearch(activity) {
      let lowerSearch = this.search.toLowerCase()
      return activity.note.toLowerCase().includes(lowerSearch)
        || activity.createdBy.toLowerCase().includes(lowerSearch)
        || activity.createdByPosition?.toLowerCase().includes(lowerSearch)
        || (activity.activityHashtags?.length === 0 && '[uncategorized]'.includes(lowerSearch))
        || activity.activityHashtags.find(ah => ('#' + ah.hashtag.toLowerCase()).includes(lowerSearch))?.id != null
    },
    populateSelectedTopics(editedActivity) {
      //i can never figure out how to do this... when the list is like: topics = [{id: 1}] but the data coming back is like [{ id: 1723, topicId: 1}]
      if (editedActivity?.activityHashtags?.length > 0) {
        this.selectedTopics = this.topics.filter(t => {
          return editedActivity?.activityHashtags?.some(ah => ah.hashtagId === t.id)
        })
      } else {
        this.selectedTopics = []
      }
    },
    getActivityTopics: async function () {
      if (this.primaryId && this.sectionType) {
        try {
          const {data} = await getRequest(`/activity/topics/${this.sectionType}/${this.primaryId}`)
          this.activityTopics = data
        } catch {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error loading notes')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      }
    },
    getActivities: async function () {
      if (this.primaryId && this.sectionType) {
        try {
          const {data} = await getRequest(`/activity/${this.sectionType}/${this.primaryId}`)
          this.activities = data
        } catch {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error loading notes')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      }
    },
    getUsers: async function () {
      //todo: debounce and limit this shiz
      try {
        const {data} = await getRequest('/user/mentionableUsers', null, [])
        this.users = data

      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Users')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    changeSortDirection() {
      this.sortDirection = this.sortDirection === 'desc' ? 'asc' : 'desc'
    },
    async getTopics() {
      this.topicsLoading = true
      try {
        const {data, status} = await getNoteHashtags()
        this.topics = data
        this.topicsLoading = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error loading topics')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.topicsLoading = false
      }
    },
    searchByClick(newSearch) {
      this.search = newSearch
    },
    setEditedActivity(item) {
      this.editedActivity = cloneDeep(item)
      this.populateSelectedTopics(item)
    },
    saveActivity(isNew) {
      if (isNew) {
        this.saveNewActivity()
      } else {
        this.editActivity()
      }
    },
    async saveNewActivity() {
      this.savingActivity = true
      //in this case a NEW activity's hashtags are the root level ones
      let activityHashtags = this.selectedTopics.map(st => {
        return {'hashtagId': st.id}
      })
      try {
        let params = {
          note: this.editedActivity.note,
          linked: this.editedActivity.linked,
          linkedPpseId: parseInt(this.$route.params.ppsEventId),
          linkedPpsId: null == this.$route.params.ppsEventId ? parseInt(this.$route.params.processStepId) : null,
          activityHashtags
        }
        const {data, status} = await postRequest(`/activity/${this.sectionType}/${this.primaryId}`, params)
        if (this.sortDirection === 'desc') {
          //add to top of list
          this.activities.unshift(data)
        } else {
          //add to bottom of list
          this.activities.push(data)
        }
        this.addActivity = false
        this.editedActivity = {}
        this.savingActivity = false
        this.snackbar = getSnackbar('SUCCESS', 'Note Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error saving note')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.savingActivity = false
      }
    },
    async editActivity() {
      this.savingActivity = true
      //handle hashtags that existed then were removed
      this.editedActivity?.activityHashtags?.forEach(ah => {
        ah.archived = !this.selectedTopics?.some(st => st.id === ah.hashtagId)
      })

      //handle hashtags that didn't exist there were added
      this.selectedTopics.forEach(st => {
        if (!this.editedActivity?.activityHashtags?.some(ah => ah.hashtagId === st.id)) {
          this.editedActivity?.activityHashtags.push(
            {'hashtagId': st.id}
          )
        }
      })

      try {
        let params = {
          note: this.editedActivity.note,
          activityHashtags: this.editedActivity?.activityHashtags || [],
          linked: this.editedActivity.linked,
          linkedPpseId: this.editedActivity.linked ? parseInt(this.$route.params.ppsEventId) : null,
          //this has to populate even when the linked item is an event or else we can't re-load the link path correctly
          linkedPpsId: this.editedActivity.linked ? parseInt(this.$route.params.processStepId) : null,
        }
        const {data, status} = await putRequest(`/activity/${this.editedActivity.id}/${this.sectionType}`, params)
        //todo: handle this
        let editedIndex = this.sortedFilteredActivities.findIndex(a => a.id === this.editedActivity.id)
        console.log('randaLogger', editedIndex)
        this.sortedFilteredActivities[editedIndex] = data
        console.log('data', this.sortedFilteredActivities[editedIndex])

        this.editedActivity = {}
        this.editedIndex = null
        this.savingActivity = false
        this.snackbar = getSnackbar('SUCCESS', 'Note Edited')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error saving note')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.savingActivity = false
      }
    },
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.pinned-card {
  background: #FB8C0010;
}

.activity-header {
  display: flex !important;
  position: sticky;
  top: -1px;
  background-color: white;
  padding: 0 10px;
  z-index: 200;
  margin-left: -10px;
  margin-right: -10px;
  align-items: center;
}

.activity-hr {
  margin-left: -20px;
  margin-right: -20px;
  max-width: unset !important;
}

.activity-body {
  min-height: 500px;
}

.activity-footer {
  position: sticky;
  bottom: 0;
  background-color: white;
  padding: 0px 10px 15px 10px;
  z-index: 200;
  margin-left: -10px;
  margin-right: -10px;
}
</style>
