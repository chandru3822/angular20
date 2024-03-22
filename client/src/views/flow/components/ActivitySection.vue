<template>
  <v-container class="px-5 py-0">
    <div v-if="mobileView" class="headline-small pt-3">Notes</div>
    <div class="activity-header" >
      <a-text-field
          prepend-inner-icon="search"
          label="Search"
          clearable
          @click:clear="clearSearch"
          v-model="searchText"
      ></a-text-field>
      <a-btn
          variant="text"
          size="small"
          color="primary"
          @click="changeSortDirection()"
          :prepend-icon="sortDirection === 'desc' ? 'mdi-arrow-up' : 'mdi-arrow-down'"
      ></a-btn>
      <v-menu v-if="sectionType==='project'" v-model="filterMenuOpen" transition="scale-transition" offset-y left attach>
        <template v-slot:activator="{ on }">
          <a-btn
              variant="text"
              size="small"
              color="primary"
              :activation-handler="on"
              :class="{'primary-lighten-9-bkgrd': filterAltered}"
              prepend-icon="mdi-filter"
          ></a-btn>
        </template>
        <v-list dense class="">
          <v-list-item class="filterCheckbox" v-for="at in activityTypes">
            <v-list-item-content>
              <v-list-item-title>
                <v-checkbox
                    dense
                    hide-details
                    v-model="at.show"
                    :label="at.activityType"
                    :ripple="false"
                />
              </v-list-item-title>
            </v-list-item-content>
          </v-list-item>
        </v-list>
      </v-menu>
    </div>
    <div class="activity-body" :class="{'footer-closed-height': !addActivity && null == editedActivity.id}">
      <div v-if="pinnedActivitiesOnly.length > 0 && !searchText" :class="{'pb-7': !timelineView}">
        <ActivityList v-if=!savingActivity
                      :activities="pinnedActivitiesOnly"
                      :project-id="projectId"
                      :contact-id="contactId"
                      :user-id="userId"
                      :current-user-id="currentUserId"
                      :org-id="orgId"
                      :section-type="sectionType"
                      :edit-callback="setEditedActivity"
                      :search-callback="searchByClick"
                      @reload="getActivities"
                      ref="activityList"
                      :use-infinite-loader="false"
                      @remove-deleted="removeDeletedActivity"
        />
      </div>
      <!--Topic View-->
      <div v-if="!timelineView">
        <div v-if="sortedFilteredActivities?.length === 0" class="body-large">No available notes or activities</div>
        <div v-else>
          <div v-for="type in filteredTopics" class="title-medium" id="topic-activity-type-header">
            <span>{{ type.activityType }}</span><!--Activity Type (Notes or Activities) Header-->
            <div class="pt-4 body-large" v-if="!type.activityTypeHashtags || type.activityTypeHashtags.length === 0">No results found</div>
            <v-expansion-panels v-else accordion multiple flat class=".rounded-0"><!--Topic # header-->
              <v-expansion-panel v-for="h in orderBy(searchfilteredActivityTypeHashtags(type.activityTypeHashtags), 'lastUpdated', (sortDirection === 'asc' ? 1 : -1))" :key="h.hashtagId">
                <v-expansion-panel-header class="expansion-panel-header px-0">
                  <template v-slot:default="{ open }">
                    <v-row no-gutters class="align-center" :class="{'bold' : open}">
                      <span v-if="h.hashtagId === -1" class="uncategorized body-large mr-2" :class="{'label-large': open}">[{{h.hashtag}}]</span>
                      <span v-else class="mr-2" :class="{'body-large': !open, 'label-large': open}">#{{ h.hashtag }}</span>
                      <span class="body-medium grey--text darken-2">{{countedCategoryLabel(h.activities, type.id) }}
                      <span v-if="!searchText || searchText === ''"> | last updated: {{ h.lastUpdated | formatDate('timestamp', 'M/D/YY h:mm a') }}</span></span>
                      <a-btn
                          v-if="open"
                          icon
                          color="primary"
                          @click.native.stop="changeSortDirectionForTopic(h)"
                          :prepend-icon="h.sortDirection === 'desc' ? 'mdi-arrow-up' : 'mdi-arrow-down'"
                      ></a-btn>
                      <a-btn
                          v-if="open && type.id !== 1 && h.hashtagId !== -1 && !(addActivity && selectedTopics.filter(t => t.id == h.hashtagId).length > 0) && null == editedActivity.id"
                          variant="text"
                          color="primary"
                          class="text-capitalize pa-2"
                          @click.native.stop="[addActivity = true, selectedTopics = [topics.find(t => t.id === h.hashtagId)] ];"
                          text="+ Add note"
                      ></a-btn>
                    </v-row>
                  </template>
                </v-expansion-panel-header>
                <v-expansion-panel-content>
                  <ActivityList v-if="!savingActivity"
                                :activities="sortAndFilterActivities(h.activities, h.sortDirection)"
                                :project-id="projectId"
                                ref="activityList"
                                :contact-id="contactId"
                                :user-id="userId"
                                :current-user-id="currentUserId"
                                :org-id="orgId"
                                :section-type="sectionType"
                                :edit-callback="setEditedActivity"
                                :search-callback="searchByClick"
                                :highlightPinnedActivity="false"
                                :query="queryText"
                                @reload="getActivities"
                  ></ActivityList>
                </v-expansion-panel-content>
              </v-expansion-panel>
            </v-expansion-panels>
          </div>
        </div>
      </div>
      <!--Timeline View-->
      <SpinnerInline :size="20" color="primary" v-else-if="!savingActivity && activitiesLoading"/>
      <ActivityList v-else-if="!savingActivity && !activitiesLoading"
                    :activities="sortedFilteredActivities"
                    :project-id="projectId"
                    :contact-id="contactId"
                    :user-id="userId"
                    :current-user-id="currentUserId"
                    :org-id="orgId"
                    :section-type="sectionType"
                    :edit-callback="setEditedActivity"
                    :search-callback="searchByClick"
                    :highlightPinnedActivity = false
                    :query="queryText"
                    ref="activityListTopic"
                    :use-infinite-loader="true"
                    @bottomHitCount="bottomHitCallback"
                    @reload="getActivities"
      ></ActivityList>
      <!--      <div v-if="sortedFilteredActivities">-->
      <!--        sfa: {{ sortedFilteredActivities.length }}-->
      <!--        max: {{ maxInitialLoadLimit }}-->
      <!--      </div>-->
      <!--      <div class="error&#45;&#45;text py-4" v-if="timelineView && sortedFilteredActivities && sortedFilteredActivities.length >= maxInitialLoadLimit">-->
      <!--        We are currently investigating an issue with load times. Until a better solution can be implemented, only the most recent {{ maxInitialLoadLimit }} notes and activities will be displayed in the timeline view. To view the remaining notes, please navigate to the Topic view.-->
      <!--      </div>-->
      <!--        <SpinnerInline v-if="timelineView && (sortedFilteredActivities && sortedFilteredActivities.length >= maxInitialLoadLimit) && !maxSliceHit" :size="20" color="primary"/>-->
    </div>
    <div class="activity-footer">
      <v-divider class="my-3 activity-hr"></v-divider>
      <a-btn
          variant="outlined"
          color="primary"
          class="one-hunned text-capitalize"
          v-if="!addActivity && null == editedActivity.id"
          :loading="topicsLoading"
          @click="[addActivity = true, selectedTopics = [] ];"
          prepend-icon="mdi-plus"
          text="Add note"
      ></a-btn>
      <div v-else>
        <!--        <v-textarea outlined v-model="editedActivity.note"></v-textarea>-->
        <Mentionable
            :keys="['@']"
            :items="users"
            offset="6"
            insert-space
        >
          <v-textarea class="body-large note-text-area"
                      hide-details
                      auto-grow
                      autofocus
                      rows="2"
                      outlined
                      :disabled="editedActivity.createdById !== currentUserId && !addActivity"
                      v-model="editedActivity.note">
          </v-textarea>

          <template #no-result>
            No result
          </template>
          <template #item-@="{ item }">
            <div class="user">
              ({{ item.value }})
            </div>
          </template>
        </Mentionable>
        <div v-if="editedActivity.createdById !== currentUserId && !addActivity && previouslySelectedTopics.value?.length > 0" class="pt-2">
          Existing topics: {{previouslySelectedTopicNames.value}}
        </div>
        <v-autocomplete
            v-model="selectedTopics"
            class="mt-3"
            :items="editedActivity.createdById !== currentUserId && !addActivity && previouslySelectedTopics.value?.length > 0 ? topics.filter(t => {return !previouslySelectedTopics.value.find(pst => pst.id === t.id)}) : topics"
            multiple
            hide-details
            label="Topics"
            return-object
            menu-props="closeOnContentClick"
            item-text="hashtag"
        ></v-autocomplete>
        <v-checkbox
            v-if="null != $route.params.processStepId
                || null != $route.params.ppsEventId
                || editedActivity.linked"
            dense
            :disabled="editedActivity.createdById !== currentUserId && !addActivity"
            v-model="editedActivity.linked"
            @change="linkEditedActivity"
            :label="getLinkLabel()"
        />
        <div class="d-flex" :class="{'mt-6': !$route.params.processStepId && !$route.params.ppsEventId && !editedActivity.linked}">
          <a-btn
              variant="text"
              color="primary"
              class="text-capitalize"
              @click="[addActivity = false, editedActivity = {}]"
              text="cancel"
          ></a-btn>
          <a-btn
              color="primary"
              class="text-capitalize flex-grow-1"
              :loading="savingActivity"
              @click="saveActivity(null == editedActivity.id);"
              :disabled="!editedActivity.note"
              text="Save"
          ></a-btn>
        </div>
      </div>

    </div>
  </v-container>

</template>

<script setup>
import {
  getRequest,
  deleteRequest,
  postRequest,
  putRequest,
  postRequestWithRequestParams,

  handleHidingGlobalLoader
} from '@/helpers/helpers'


import {getNoteHashtags} from "@/services/activityService"
import ConfirmationDialog from "@/components/ConfirmationDialog";
import ActivityList from "@/views/flow/components/ActivityList.vue";
import orderBy from "lodash.orderby";
import cloneDeep from "lodash.clonedeep";
import {Mentionable} from 'vue-mention'
import {SearchTypeEnum} from "./ActivityListConstants";
import SpinnerInline from "@/components/SpinnerInline.vue";
import constants from "@/helpers/constants";
import { useProjectStore } from '@/stores/ProjectStorePinia.js'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const props = defineProps({
  contactId: Number,
  orgId: Number,
  userId: Number,
  projectId: Number,
  objectTypeId: Number,
  timelineView: Boolean,
  mobileView:Boolean
})
const { contactId, orgId, userId, projectId, objectTypeId, timelineView, mobileView } = toRefs(props)


const searchText = ref(route.query.search != null ? route.query.search : '')
const search = ref({userId: null,position: null,teamId: null,categoryId: null,})
const queryText = ref('')
const linkLabel = ref('')
const users = ref([])
const addActivity = ref(false)
const blankActivity = ref({id: null, activityHashtags: []})
const editedActivity = ref({})
const editedIndex = ref(null)
const activityTopics = ref([])
const selectedTopics = ref([])
const previouslySelectedTopics = ref([])
const topics = ref([])
const activities = ref([])
const activitiesLoading = ref(true)
const topicsLoading = ref(false)
const savingActivity = ref(false)
const sortDirection = ref('desc')
const sectionType = ref('')
const primaryId = ref(null)
const filterMenuOpen = ref(false)
const activityTypes = ref([
  {id: 1, activityType: 'Activities', activityTypeSingularLabel: 'Activity', show: false},
  {id: 2, activityType: 'Notes', activityTypeSingularLabel: 'Note', show: true},
])
const pinnedActivitiesOnly = ref([])
const bottomHitCount = ref(1)
const activitiesToShow = ref(constants.ACTIVITIES_SHOWN)
const activityList = ref(null)
const activityListTopic = ref(null)

const emit = defineEmits(['scrollToTop'])

watch(timelineView, () => {
  if (timelineView.value) {
    getActivities()
  } else {
    getActivityTopics()
  }
})
watch(searchText, () => {
  emit('scrollToTop')
  if(!search.value.userId && !search.value.position && !search.value.teamId && search.value.categoryId !== -1) {
    let cleanQueryText = searchText.value?.replace('[','\\[')
    queryText.value = cleanQueryText?.replace(']','\\]')
  }
})

const userIsAdmin = computed(() => {
  return userStore.userHasFeatureAccessLevel('PROJECTS', 'ADMIN')
})
const currentUserId = computed(() => {
  return userStore.details.id
})
const filteredTopics = computed(() => {
  let shownActivityTypes = activityTypes.value.filter(at => at.show).map(at => at.id)
  let result = activityTopics.value.filter(a => {
    for (let h of a.activityTypeHashtags){
      if(h.sortDirection === undefined){
        h.sortDirection = 'desc'
      }
    }
    return shownActivityTypes.includes(a.id)
  })
  return result
})
const sortedFilteredActivities = computed(() => {
  let sortedList = orderBy(activities.value.filter(a => {
    //filter out archived
    //if search is not empty then filter that stuff here too
    //and ensure the activityTypeId is selected in the filter
    let shownActivityTypes = activityTypes.value.filter(at => at.show).map(at => at.id)

    return !a.archived
        && ((search.value == null || search.value === '') || activityContainsSearch(a))
        && shownActivityTypes.includes(a.activityTypeId)

  }), ['dateCreated'], [ sortDirection.value])

  getPinnedActivitiesOnly(activities.value)
  if(sortedList.length > (activitiesToShow.value * bottomHitCount.value) ) {
    if(activityList.value) {
      activityList.value.infiniteStateLoaded(false)
    }
    return sortedList.slice(0, (activitiesToShow.value * bottomHitCount.value))
  } else {
    if(activityListTopic.value) {
      activityListTopic.value.infiniteStateLoaded(true)
    }
    const emailRegex = /\((([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))\)/g
    sortedList = sortedList.map(activity => ({...activity, note: activity.note.replaceAll(emailRegex, '')}))
    return sortedList
  }
  // return []
})
const filterAltered = computed(() => {
  return !!(activityTypes.value.find(at => !at.show))
})
const previouslySelectedTopicNames = computed(() => {
  const topicNamesList = previouslySelectedTopics.value.map(t => {
    return '#' + t.hashtag
  })
  return topicNamesList.join(', ')
})

onMounted(() => {
  switch (objectTypeId.value) {
    case 2:
      primaryId.value = contactId.value
      sectionType.value = `contact`
      break
    case 3:
      primaryId.value = userId.value
      sectionType.value = `user`
      break
    case 5:
      primaryId.value = orgId.value
      sectionType.value = `org`
      break
    default:
      primaryId.value = projectId.value
      sectionType.value = `project`
      break
  }
  getTopics()
  getActivities()
  if(!timelineView.value){
    getActivityTopics()
  }
  getUsers()
})

const bottomHitCallback = () => {
  bottomHitCount.value = bottomHitCount.value + 1
}
const getLinkLabel = () => {
  return editedActivity.value.linked && null != editedActivity.value.linkLabel ? `Link ${editedActivity.value.linkLabel}` : `Link ${projectStore.linkLabel}`
}
const sortAndFilterActivities = (activities, sortDirection)=> {
  return orderBy(activities.filter(a => {
    //filter out archived
    //if search is not empty then filter that stuff here too
    //and ensure the activityTypeId is selected in the filter
    let shownActivityTypes = activityTypes.value.filter(at => at.show).map(at => at.id)

    return !a.archived
        && (((search.value == null || search.value === {}) && (searchText.value == null || searchText.value === '')) || activityContainsSearch(a))
        && shownActivityTypes.includes(a.activityTypeId)

  }), ['dateCreated'], [ sortDirection])
}
const countSortedFilteredActivities = (activities)=> {
  return sortAndFilterActivities(activities, sortDirection.value).length
}
const searchfilteredActivityTypeHashtags = (activityTypeHashtags)=> {
  // hide the topic header if there are no search result matches in it
  return activityTypeHashtags.filter(h =>{
    const activityCount = countSortedFilteredActivities(h.activities)
    return activityCount > 0
  })
}
const getPinnedActivitiesOnly = (activities) => {
  const sortedFilteredPinnedActivities = activities.filter(a => a.pinned)
  if(pinnedActivitiesOnly.value.length === 0 || sortedFilteredPinnedActivities.length !== pinnedActivitiesOnly.value.length){
    //if-statement needed so we don't open the menu on the pinned note when we open the menu on the non-pinned copy of the note
    // but we still get the update when we pin/unpin a note
    pinnedActivitiesOnly.value = sortedFilteredPinnedActivities
  }
}
const countedCategoryLabel = (activities, activityTypeId)=> {
  const activityCount = countSortedFilteredActivities(activities)
  const typeLabel = activityCount === 1 ? activityTypes.value.find(t => t.id === activityTypeId).activityTypeSingularLabel : activityTypes.value.find(t => t.id === activityTypeId).activityType
  return `${activityCount} ${typeLabel.toLowerCase()}`
}
const activityContainsSearch = (activity) => {
  if(search.value.userId){
    return activity.createdById === search.value.userId
  }
  else if(search.value.position){
    return activity.createdByPosition === search.value.position
  }
  else if(search.value.teamId){
    return activity.createdByPositionOrgId === search.value.teamId
  }
  else if(search.value.categoryId === -1){
    return activity.activityHashtags?.length === 0
  }
  let lowerSearch = searchText.value?.toLowerCase()
  return activity.note.toLowerCase().includes(lowerSearch)
      || activity.createdBy.toLowerCase().includes(lowerSearch)
      || activity.createdByPosition?.toLowerCase().includes(lowerSearch)
      || activity.createdByPositionOrg?.toLowerCase().includes(lowerSearch)
      || activity.modifiedBy?.toLowerCase().includes(lowerSearch)
      || activity.pinnedBy?.toLowerCase().includes(lowerSearch)
      || activity.linkedPpsId?.toString().includes(lowerSearch)
      || activity.linkedPpseId?.toString().includes(lowerSearch)
      || ((!activity.activityHashtags || activity.activityHashtags?.length === 0) && '[uncategorized]'.includes(lowerSearch))
      || activity.activityHashtags?.find(ah => ('#' + ah.hashtag.toLowerCase()).includes(lowerSearch))?.id != null
      || !lowerSearch
}
const populateSelectedTopics = (editedActivity) => {
  //i can never figure out how to do ...value when the list is like: topics = [{id: 1}] but the data coming back is like [{ id: 1723, topicId: 1}]
  if (editedActivity?.activityHashtags?.length > 0) {
    selectedTopics.value = topics.value.filter(t => {
      return editedActivity?.activityHashtags?.some(ah => ah.hashtagId === t.id)
    })
  } else {
    selectedTopics.value = []
  }
  previouslySelectedTopics.value = cloneDeep(selectedTopics.value)
}
const getActivityTopics = async () => {
  if (primaryId.value && sectionType.value) {
    try {
      const {data} = await getRequest(`/activity/topics/${sectionType.value}/${primaryId.value}`)
      activityTopics.value = data
    } catch {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error loading notes')

    }
  }
}
const getActivities = async () => {
  if (primaryId.value && sectionType.value) {
    activitiesLoading.value = true
    try {
      const {data} = await getRequest(`/activity/${sectionType.value}/${primaryId.value}`)
      activities.value = data
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error loading notes')

    } finally {
      activitiesLoading.value = false
    }
  }
}
const getUsers = async () => {
  //todo: debounce and limit this shiz
  try {
    const {data} = await getRequest('/user/mentionableUsers', null, [])
    users.value = data.map(u => ({...u, value: `${u.fullName} (${u.email})`}))
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Users')

    appStore.loading = false
  }
}
const changeSortDirection = ()  => {
  sortDirection.value = sortDirection.value === 'desc' ? 'asc' : 'desc'
}
const changeSortDirectionForTopic = (hashtagObject)  => {
  hashtagObject.sortDirection = hashtagObject.sortDirection === 'desc' ? 'asc' : 'desc'
  hashtagObject.activities = orderBy(hashtagObject.activities, ['dateCreated'], [hashtagObject.sortDirection])
}
const getTopics = async() => {
  topicsLoading.value = true
  try {
    const {data, status} = await getNoteHashtags()
    topics.value = data
    topicsLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error loading topics')

    topicsLoading.value = false
  }
}
const searchByClick = (text, id, searchType) => {
  clearSearch()
  switch (searchType){
    case SearchTypeEnum.USER:
      searchText.value= `User: ${text}`
      search.value.userId = id
      break;
    case SearchTypeEnum.POSITION:
      searchText.value = `Position: ${text}`
      search.value.position = text
      break;
    case SearchTypeEnum.TEAM:
      searchText.value = `Team: ${text}`
      search.value.teamId = id
      break;
    case SearchTypeEnum.TAG:
      if(id === -1){
        searchText.value = `[${text}]`
      } else {
        searchText.value = text
      }
      break;
    default:
      searchText.value = text
  }
  queryText.value = text
}
const clearSearch = () => {
  search.value={}
}
const setEditedActivity = (item)  => {
  addActivity.value = false
  editedActivity.value = cloneDeep(item)
  populateSelectedTopics(item)
}
const linkEditedActivity = () => {
  if(editedActivity.value.linked) {
    editedActivity.value.linkedPpseId = parseInt(route.params.ppsEventId)
    //this has to populate even when the linked item is an event or else we can't re-load the link path correctly
    editedActivity.value.linkedPpsId = parseInt(route.params.processStepId)
    editedActivity.value.linkLabel = projectStore.linkLabel
  } else {
    editedActivity.value.linkLabel = null
    editedActivity.value.linkedPpseId = null
    editedActivity.value.linkedPpsId = null
  }
}
const saveActivity = (isNew)  => {
  if (isNew) {
    saveNewActivity()
  } else {
    editActivity()
  }
}
const saveNewActivity = async() => {
  savingActivity.value = true
  //in this case a NEW activity's hashtags are the root level ones
  let activityHashtags = selectedTopics.value.map(st => {
    return {'hashtagId': st.id}
  })
  try {
    let params = {
      note: editedActivity.value.note,
      linked: editedActivity.value.linked,
      linkedPpseId: editedActivity.value.linkedPpseId,
      linkedPpsId:  editedActivity.value.linkedPpsId,
      activityHashtags
    }
    const {data, status} = await postRequest(`/activity/${sectionType.value}/${primaryId.value}`, params)
    if (sortDirection.value === 'desc') {
      //add to top of list
      activities.value.unshift(data)
    } else {
      //add to bottom of list
      activities.value.push(data)
    }
    if(!timelineView.value) {
      //only reload the topics if on the topic view
      getActivityTopics();
    }
    addActivity.value = false
    editedActivity.value = {}
    savingActivity.value = false
    emit('scrollToTop')
    snackbar('SUCCESS', 'Note Added')

  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error saving note')

    savingActivity.value = false
  }
}
const editActivity = async() => {
  savingActivity.value = true
  //handle hashtags that existed then were removed
  editedActivity.value?.activityHashtags?.forEach(ah => {
    ah.archived = !selectedTopics.value?.some(st => st.id === ah.hashtagId)
  })

  //handle hashtags that didn't exist there were added
  selectedTopics.value.forEach(st => {
    if (!editedActivity.value?.activityHashtags?.some(ah => ah.hashtagId === st.id)) {
      if(!editedActivity.value?.activityHashtags){
        editedActivity.value.activityHashtags = []
      }
      editedActivity.value?.activityHashtags.push(
          {'hashtagId': st.id}
      )
    }
  })

  try {
    let params = {
      note: editedActivity.value.note,
      activityHashtags: editedActivity.value?.activityHashtags || [],
      linked: editedActivity.value.linked,
      linkedPpseId: editedActivity.value.linked ? editedActivity.value.linkedPpseId : null,
      //this has to populate even when the linked item is an event or else we can't re-load the link path correctly
      linkedPpsId: editedActivity.value.linked ? editedActivity.value.linkedPpsId : null,
    }
    const {data, status} = await putRequest(`/activity/${editedActivity.value.id}/${sectionType.value}`, params)
    //todo: handle this
    let editedIndex = sortedFilteredActivities.value.findIndex(a => a.id === editedActivity.value.id)
    let unsortedEditedIndex = activities.value.findIndex(a => a.id === editedActivity.value.id)
    let pinnedEditedIndex = pinnedActivitiesOnly.value.findIndex(a => a.id === editedActivity.value.id)
    sortedFilteredActivities.value[editedIndex] = data
    activities.value[unsortedEditedIndex] = data
    pinnedActivitiesOnly.value[pinnedEditedIndex] = data


    getActivityTopics();
    editedActivity.value = {}
    editedIndex = null
    if(!timelineView.value){
      //only reset the scroll if we're editing in the topics view
      emit('scrollToTop')
    }
    savingActivity.value = false
    snackbar('SUCCESS', 'Note Edited')

  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error saving note')

    savingActivity.value = false
  }
}
const removeDeletedActivity = (activityId) => {
  const deletedActivity = activities.value.find(a => a.id === activityId)
  if(deletedActivity) {
    deletedActivity.archived = true
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
  z-index: 10; //to make sure the filter dropdown is in front of the list of notes/activities
  margin-left: -10px;
  margin-right: -10px;
  align-items: center;
}

.activity-hr {
  margin-left: -20px;
  margin-right: -20px;
  max-width: unset !important;
  border-color: var(--v-grey-darken1);
}

.activity-body {
  //min-height: 500px;
  min-height: 100vh;
}

.activity-footer {
  position: sticky;
  bottom: 0;
  background-color: white;
  padding: 0px 10px 15px 10px;
  z-index: 10;
  margin-left: -10px;
  margin-right: -10px;
}

.activity-body {
  @media (min-width: 960px) {
    //min-height: 500px;
  }
}
.footer-closed-height {
  min-height: calc(100vh - 360px);
}
.title-medium:last-of-type {
  padding-top:16px;
}

.uncategorized {
  color: var(--v-grey-darken2);
}

.primary-lighten-9-bkgrd {
  background-color: var(--v-primary-lighten9);
}
.filterCheckbox div {
  align-self: flex-end;
}
.filterCheckbox:hover {
  background-color: var(--v-grey-lighten4) !important;
}


</style>
<style lang="scss">
.mention-selected {
  color: var(--v-primary-base);
  font-weight: bold;
}
.note-text-area {
  textarea {
    max-height: 300px;
    overflow-y: auto;
  }
}
</style>
