<template>
  <v-container class="px-5">
    <div class="flex-display">
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
      <v-menu v-model="filterMenuOpen" transition="scale-transition" offset-y
              min-width="290px" :close-on-content-click="false">
        <template v-slot:activator="{ on }">
          <v-btn text small color="primary" v-on="on">
            <v-icon>mdi-filter</v-icon>
          </v-btn>
        </template>
        <v-list dense class="pa-3">
          <v-list-item v-for="at in activityTypes">
            <v-list-item-content>
              <v-list-item-title>
                <v-checkbox
                  dense
                  v-model="at.show"
                  :label="at.activityType"
                />
              </v-list-item-title>
            </v-list-item-content>
          </v-list-item>
        </v-list>
      </v-menu>
    </div>
    <div>
      <div v-if="sortedFilteredActivities.length === 0">
        No available note or activities
      </div>
      <v-card v-else v-for="(a, aIdx) in sortedFilteredActivities" class="mt-2 elevation-1"
              :class="{'pinned-card': a.pinned}">
        <v-card-title>
          <v-icon small color="#FB8C00" v-if="a.pinned" class="mr-2">mdi-pin</v-icon>
          <span v-for="(ah, idx) in a.activityHashtags">
            <span v-if="idx !== 0">, </span>
            #{{ ah.hashtag }}
          </span>
          <a v-if="a.linked" @click="goToPath(a)">
            <v-icon color="primary">mdi-link</v-icon>
            {{a.linkLabel}}
          </a>
          <v-spacer></v-spacer>
          <v-menu v-model="a.menuOpen" transition="scale-transition" offset-y
                  min-width="290px" :close-on-content-click="false">
            <template v-slot:activator="{ on }">
              <v-btn text small color="primary" v-on="on">
                <v-icon>mdi-dots-horizontal</v-icon>
              </v-btn>
            </template>
            <v-list dense class="pa-3">
              <v-list-item @click="[a.menuOpen = false, editedActivity = cloneDeep(a),
                                    editedIndex = aIdx, addActivity = false,
                                    populateSelectedTopics()]">
                <v-list-item-content>
                  <v-list-item-title>Edit</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
              <v-list-item @click="[a.menuOpen = false, pinActivity(a)]">
                <v-list-item-content>
                  <v-list-item-title>{{ a.pinned ? 'Unpin' : 'Pin'}}</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
              <v-list-item @click="[a.menuOpen = false, deleteActivity(a)]">
                <v-list-item-content>
                  <v-list-item-title>Delete</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
            </v-list>
          </v-menu>

        </v-card-title>
        <v-card-text>
          {{ a.note }}
        </v-card-text>
        <v-card-actions>
          {{ a.createdBy }}, {{ a.createdByPosition }} | {{ a.dateCreated | formatDate('timestamp', 'M/D/YY h:mm a') }}
        </v-card-actions>
      </v-card>
    </div>
    <div>
      <v-divider v-if="addActivity || null != editedIndex" class="my-3"></v-divider>
      <v-btn outlined color="primary"
             v-if="!addActivity && null == editedIndex"
             :loading="topicsLoading"
             @click="[addActivity = true, selectedTopics = [] ]">
        <v-icon>mdi-plus</v-icon>
        Add note
      </v-btn>
      <div v-if="addActivity || null != editedIndex">
        <v-textarea outlined v-model="editedActivity.note"></v-textarea>
        <v-autocomplete
          v-model="selectedTopics"
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
          class="pt-5 ml-3"
          dense
          v-model="editedActivity.linked"
          @change="editedActivity.linkLabel = null"
          :label="getLinkLabel()"
        />
      </div>
      <div v-if="addActivity || null != editedIndex">
        <v-btn text color="primary"
               @click="[addActivity = false, editedActivity = {}, editedIndex = null]">
          cancel
        </v-btn>
        <v-btn color="primary"
               :loading="savingActivity"
               @click="saveActivity(null == editedActivity.id, editedIndex)"
               :disabled="!editedActivity.note">
          Save
        </v-btn>
      </div>
    </div>
  </v-container>

</template>

<script>
import {getRequest, deleteRequest, postRequest, putRequest, postRequestWithRequestParams, getSnackbar, handleHidingGlobalLoader} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from "vue2-filters"
import {getNoteHashtags} from "@/services/activityService"
import ConfirmationDialog from "@/components/ConfirmationDialog";
import orderBy from "lodash.orderby";
import cloneDeep from "lodash.clonedeep";

export default {
  name: 'ActivitySection',
  components: {ConfirmationDialog},
  mixins: [Vue2Filters.mixin],
  props: {
    contactId: Number,
    orgId: Number,
    userId: Number,
    projectId: Number,
    objectTypeId: Number
  },
  data() {
    return {
      snackbar: {},
      search: '',
      linkLabel: '',
      addActivity: false,
      blankActivity: { id: null, activityHashtags: []},
      editedActivity: {},
      editedIndex: null,
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
        { id: 1, activityType: 'Activities', show: true},
        { id: 2, activityType: 'Notes', show: true},
      ]
    }
  },
  watch: {
  },
  computed: {
    sortedFilteredActivities() {
      return orderBy(this.activities.filter(a => {
        //filter out archived
        //if search is not empty then filter that stuff here too
        //and ensure the activityTypeId is selected in the filter
        let shownActivityTypes = this.activityTypes.filter(at => at.show).map(at => at.id)

        return !a.archived && ((this.search == null || this.search === '') || this.activityContainsSearch(a))
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
    this.getActivities()
  },
  methods: {
    cloneDeep,
    // hasDirtyActivities() {
    //   return this.$refs.activities.hasUnsavedActivities()
    // },
    goToPath(activity) {
      let path = ''
      if(null !== activity.linkedPpseId) {
        path = `/project/${this.projectId}/processStep/${activity.linkedPpsId}/event/${activity.linkedPpseId}`
      } else if(null !== activity.linkedPpsId) {
        path = `/project/${this.projectId}/processStep/${activity.linkedPpsId}`
      }
      if(path !== this.$route.path) {
        this.$router.push(path)
      }
    },
    getLinkLabel() {
      return this.editedActivity.linked && null != this.editedActivity.linkLabel ? `Link ${this.editedActivity.linkLabel}` : `Link ${this.$store.state.project.linkLabel}`
    },
    activityContainsSearch(activity) {
      let lowerSearch = this.search.toLowerCase()
      return activity.note.toLowerCase().includes(lowerSearch)
        || activity.createdBy.toLowerCase().includes(lowerSearch)
        || activity.createdByPosition.toLowerCase().includes(lowerSearch)
    },
    populateSelectedTopics() {
      //i can never figure out how to do this... when the list is like: topics = [{id: 1}] but the data coming back is like [{ id: 1723, topicId: 1}]
      if(this.editedActivity?.activityHashtags?.length > 0) {
        this.selectedTopics = this.topics.filter(t => {
          return this.editedActivity?.activityHashtags?.some(ah => ah.hashtagId === t.id)
        })
      } else {
        this.selectedTopics = []
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
    saveActivity(isNew, activityIndex) {
      if(isNew) {
        this.saveNewActivity()
      } else {
        this.editActivity(activityIndex)
      }
    },
    async saveNewActivity() {
      this.savingActivity = true
      //in this case a NEW activity's hashtags are the root level ones
      let activityHashtags = this.editedActivity?.activityHashtags?.map(st => {
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
    async editActivity(index) {
      this.savingActivity = true
      //handle hashtags that existed then were removed
      this.editedActivity?.activityHashtags?.forEach(ah => {
        ah.archived = !this.selectedTopics?.some(st => st.id === ah.hashtagId)
      })

      //handle hashtags that didn't exist there were added
      this.selectedTopics.forEach(st => {
        if(!this.editedActivity?.activityHashtags?.some(ah => ah.hashtagId === st.id)) {
          this.editedActivity?.activityHashtags.push(
            { 'hashtagId': st.id}
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
        this.sortedFilteredActivities[index] = data
        //this.$set(item, 'adjustmentHistory', data)
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
    async pinActivity(activity) {
      try {
        activity.pinned = !activity.pinned
        let params = {
          pinned: activity.pinned
        }
        await postRequestWithRequestParams(`/activity/${activity.id}/pin/${this.sectionType}`, null, params)
        let msg = activity.pinned ? 'Note Pinned' : 'Note Unpinned'
        this.snackbar = getSnackbar('SUCCESS', msg)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error pinning note')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.savingActivity = false
      }
    },
    async deleteActivity(activity) {
      try {
        await deleteRequest(`/activity/${activity.id}/${this.sectionType}`)
        activity.archived = true
        this.snackbar = getSnackbar('SUCCESS', 'Note Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error deleting note')
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
</style>
