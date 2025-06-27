<template>
  <div>
    <div v-if="activities?.length === 0" class="body-large">
      No available notes or activities
    </div>
    <!--    <div v-for="a in activities">{{a.note}} <br></div>-->
    <v-card v-else v-for="(a, aIdx) in activities" :key="aIdx" class="mt-3 pt-3 pb-2 elevation-0 card"
            :class="{'pinned-card': a.pinned && highlightPinnedActivity, 'activity-card':a.activityTypeId === 1}">
      <v-toolbar flat color="transparent" class="toolbar-z-index-override-for-menu" id="activity-card-title">
        <v-toolbar-title class="body-medium">
          <v-icon small color="#FB8C00" v-if="a.pinned && highlightPinnedActivity" class="mr-2">mdi-pin</v-icon>
          <a @click="props.searchCallback('uncategorized', -1, SearchTypeEnum.TAG)" class="uncategorized-text" v-if="!a.activityHashtags || a.activityHashtags?.length === 0" :inner-html.prop="'[uncategorized]' | searchHighlight(query)"></a>
          <span class="test" v-for="(ah, idx) in a.activityHashtags" :key="idx">
                <span v-if="idx !== 0">, </span>
                <a @click="props.searchCallback('#' + ah.hashtag)" :inner-html.prop="'#' + ah.hashtag | searchHighlight(query)"></a>
              </span>
          <a v-if="a.linked" @click="goToPath(a)" class="pl-3">
            <v-icon small color="primary">mdi-link</v-icon>
            {{a.linkLabel}}
          </a>
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-menu v-model="a.menuOpen" transition="scale-transition" origin="top right" offset-x left attach>
          <template v-slot:activator="{ on }">
            <a-btn
                variant="text"
                size="small"
                color="primary"
                :activation-handler="on"
                prepend-icon="mdi-dots-horizontal"
            ></a-btn>
          </template>
          <v-list dense class="py-1 body-large">
            <v-list-item v-if="a.activityTypeId !== 1"
                         @click="editItem(a)">
              <v-list-item-content>
                <v-list-item-title>Edit</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
            <v-list-item @click="pinActivity(a)">
              <v-list-item-content>
                <v-list-item-title>{{ a.pinned ? 'Unpin' : 'Pin'}}</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
            <v-list-item v-if="a.activityTypeId !== 1"
                         :disabled="a.createdById !== currentUserId"
                         @click="activityToDelete = a">
              <v-list-item-content>
                <v-list-item-title class="error--text" :class="{'grey--text': a.createdById !== currentUserId}">Delete</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </v-list>
        </v-menu>
      </v-toolbar>

      <v-card-text class="py-0 default-text-color">
        <div
  style="cursor: pointer;"
  @click="props.searchCallback(a.note)"
  v-html="highlightHtmlString(a.note, props.query)"
></div>

    </v-card-text>
      <v-card-actions style="display: inline-block" class="body-medium grey--text text--darken-2 px-4">
        <span class="clickable" @click="props.searchCallback(a.createdBy, a.createdById, SearchTypeEnum.USER)" :inner-html.prop="a.createdBy | searchHighlight(query)"/>
        <span v-if="a.createdByPosition" class="clickable" @click="props.searchCallback(a.createdByPosition, null, SearchTypeEnum.POSITION)" :inner-html.prop="', ' + a.createdByPosition | searchHighlight(query)"/>
        <span v-if="a.createdByPositionOrg" class = "clickable" @click="props.searchCallback(a.createdByPositionOrg, a.createdByPositionOrgId, SearchTypeEnum.TEAM)" :inner-html.prop="`(${a.createdByPositionOrg})` | searchHighlight(query)"/> | {{ a.dateCreated | formatDate('timestamp', 'M/D/YY h:mm a') }}
        <span v-if="a.dateCreated !== a.dateModified" :inner-html.prop="`| Edited by ${ a.modifiedBy }` | searchHighlight(query)"/>
        <span v-if="a.dateCreated !== a.dateModified" :inner-html.prop="a.dateModified | formatDate('timestamp', ' [on] M/D/YY [at] h:mm a')"/>
        <span v-if="a.pinned" :inner-html.prop="` | Pinned by ${ a.pinnedBy }` | searchHighlight(query)"/>
        <span v-if="!a.pinned" :inner-html.prop="` | Unpinned by ${ a.pinnedBy }` | searchHighlight(query)"/>
      </v-card-actions>
    </v-card>
    <infinite-loading v-if="useInfiniteLoader" @infinite="infiniteHandler">
      <span slot="spinner"></span>
      <span slot="no-more"></span>
      <span slot="no-results"></span>
    </infinite-loading>
    <SpinnerInline :size="20" color="primary" v-if="!props.stateLoaded && useInfiniteLoader"/>
    <ConfirmationDialog :open-dialog="activityToDelete != null" @confirm="deleteActivity(activityToDelete)" @close-dialog="activityToDelete = null">
      You won’t be able to recover this note. Are you sure you want to delete it?
    </ConfirmationDialog>
  </div>
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


import ConfirmationDialog from "@/components/ConfirmationDialog";
import AttachmentsTable from "@/views/flow/components/AttachmentsTable.vue";
import VueClamp from 'vue-clamp'
import {SearchTypeEnum} from "./ActivityListConstants";
import SpinnerInline from '@/components/SpinnerInline'
import InfiniteLoading from 'vue-infinite-loading'

import { getCurrentInstance, computed, toRefs, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const urlRegex = /\bhttps?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b[-a-zA-Z0-9()@:%_+.~#?&\/=]*\b/gi // thank you https://uibakery.io/regex-library/url
const taggedUserRegex = /@\w+(?: [\w&]+)*(?=\s*\(|\s|$)/g // thank you chat gpt

const formatQueries = ref([
  {
    name: "URL",
    regex: urlRegex
  },
  {
    name: "USER",
    regex: taggedUserRegex
  }
])

const props = defineProps({
  activities: Array,
  contactId: Number,
  orgId: Number,
  userId: Number,
  currentUserId: Number,
  projectId: Number,
  sectionType: String,
  editCallback: Function,
  searchCallback: Function,
  highlightPinnedActivity: {
    type: Boolean,
    default: true,
  },
  query: String,
  useInfiniteLoader: {
    type: Boolean,
    default: false,
  },
  stateLoaded: {
    type: Boolean,
    default: false,
  }
})

function highlightHtmlString(html, query) {
  if (!html || !query) return html;

  const parser = new DOMParser();
  const doc = parser.parseFromString(`<div>${html}</div>`, 'text/html');
  const walker = doc.createTreeWalker(doc.body, NodeFilter.SHOW_TEXT);

  const escapedQuery = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const regex = new RegExp(`(${escapedQuery})`, 'gi');

  while (walker.nextNode()) {
    const node = walker.currentNode;
    if (node.nodeValue.trim() !== '') {
      const spanWrapped = node.nodeValue.replace(regex, '<span class="highlight">$1</span>');
      const temp = document.createElement('span');
      temp.innerHTML = spanWrapped;
      node.parentNode.replaceChild(temp, node);
    }
  }

  return doc.body.innerHTML;
}

function getHighlightedNote(note, query) {
  const clean = filterFormatting(removeNoteTagEmail(escapeHtml(note)));
  return highlightHtmlString(clean, query);
}

const { contactId, orgId, userId, currentUserId,
  projectId, sectionType, highlightPinnedActivity, query, useInfiniteLoader } = toRefs(props)

const loaderState = ref(null)
const editedIndex = ref(null)
const activityToDelete = ref(null)

const emit = defineEmits(['bottomHitCount', 'reload', 'reloadtopic','remove-deleted'])

const removeNoteTagEmail = (note) => {
  const emailRegex = /\((([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))\)/g
      return note.replaceAll(emailRegex, '')
}
/**
 * Escapes special HTML characters in a string to prevent XSS (Cross-Site Scripting) attacks.
 */
const escapeHtml = (unsafe) => {
  return unsafe
    // Replace ampersand (&) with HTML entity
    ?.replace(/&/g, "&amp;")
    // Replace less-than sign (<) with HTML entity
    ?.replace(/</g, "&lt;")
    // Replace greater-than sign (>) with HTML entity
    ?.replace(/>/g, "&gt;")
    // Replace double quotes (") with HTML entity
    ?.replace(/"/g, "&quot;")
    // Replace single quotes (') with HTML entity
    ?.replace(/'/g, "&#039;");
}

const infiniteHandler = ($state) => {
  loaderState.value = $state
  infiniteStateLoaded(props.stateLoaded)
  emit('bottomHitCount')
}
const infiniteStateLoaded = (loadedState) => {
  //the counts are loaded from the parent so we have to wait to set the state here
  if (loadedState) {
    loaderState.value?.complete()
  } else {
    loaderState.value?.loaded()
  }
}

const processedNote = computed(() => {
  const cleanText = filterFormatting(removeNoteTagEmail(escapeHtml(a.note)))
  return searchHighlight(cleanText, props.query)
})

const editItem = (item) => {
  props.editCallback(item)
}
const goToPath = (activity) => {
  let path = ''
  if (null !== activity.linkedPpseId) {
    path = `/project/${projectId.value}/processStep/${activity.linkedPpsId}/event/${activity.linkedPpseId}`
  } else if (null !== activity.linkedPpsId) {
    path = `/project/${projectId.value}/processStep/${activity.linkedPpsId}`
  }
  if (path !== route.path) {
    router.push(path)
  }
}
const pinActivity = async (activity) => {
  try {
    activity.pinned = !activity.pinned
    let params = {
      pinned: activity.pinned
    }
    await postRequestWithRequestParams(`/activity/${activity.id}/pin/${sectionType.value}`, null, params)
    let msg = activity.pinned ? 'Note Pinned' : 'Note Unpinned'
    emit('reload')
    emit('reloadtopic')
    appStore.showSnack('SUCCESS', msg)

  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error pinning note')

    savingActivity.value = false
  }
}
const deleteActivity = async (activity) => {
  try {
    await deleteRequest(`/activity/${activity.id}/${sectionType.value}`)
    activity.archived = true
    //todo handle sending this back up
    appStore.showSnack('SUCCESS', 'Note Deleted')

    emit('remove-deleted', activity.id);
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error deleting note')

    savingActivity.value = false
  }
}

const openUrl = (event) => {
  const element = event.target
  const urlText = element.innerText // extractUrlText(element);
  window.open(urlText, "_blank")
}

onMounted(() => {
  window.openUrl = openUrl;
})

const filterFormatting = (value) => {
  if (value) {
    formatQueries.value.forEach((q) => {
      switch (q.name) {
        case "URL":
          if (new RegExp(q.regex).test(value)) {
            value = value.replace(
              new RegExp(q.regex),
              (v) => `<span class="al-url" onclick="window.openUrl(event)">${v}</span>`
            )
          }
          break
        case "USER":
          if (new RegExp(q.regex).test(value)) {
            value = value.replace(
              new RegExp(q.regex),
              (v) => `<span class="al-taggedUser">${v}</span>`
            )
          }
          break
        case "USERLONG":
          if (new RegExp(q.regex).test(value)) {
            value = value.replace(
              new RegExp(q.regex),
              (v) => `<span class="al-taggedUser">${v}</span>`
            )
          }
          break
        default:
          break
      }
    })
  }
  return value
}

</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.card {
  border-radius: 4px;
  border: 1px solid var(--v-grey-base);
}


.activity-card {
  background: var(--v-grey-lighten4);
  border: 0px
}

.pinned-card, .activity-card.pinned-card {
  background: #FB8C0010;
  border: 0px;
}


.test {
  white-space: pre;
}

.text-formatting {
  white-space: pre-wrap;
  display: block;
}

.see-more-btn {
  color: var(--v-primary-base)!important;
  font-weight: 600;
}

.uncategorized-text {
  font-size: 14px;
  color: var(--v-grey-darken2);
}
</style>
<style lang="scss">
#activity-card-title {
  height: unset !important;
  div {
    height: unset !important;

    .v-toolbar__title {
      white-space: unset !important;
    }
  }
}

.al-taggedUser {
  color: var(--v-primary-lighten3);
}

.al-url {
  color: var(--v-primary-lighten3);
  text-decoration: underline;
}

.al-url:hover {
  color: var(--v-primary-base);
  cursor: pointer;
}
</style>
