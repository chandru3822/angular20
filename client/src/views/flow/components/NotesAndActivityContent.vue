<template>
  <div :class="{'elevation-1': bordered}">
    <v-toolbar flat dense color="white" class="elevation-0">
      <v-toolbar-title class="body-large">Leave a note:</v-toolbar-title>
    </v-toolbar>
    <v-divider></v-divider>
    <v-card class="px-3 elevation-0 square-card overflow-y-auto">
      <Mentionable
          :keys="['@']"
          :items="users"
          offset="6"
          insert-space
      >
        <a-textarea class="body-medium"
                    hide-details
                    auto-grow
                    rows="4"
                    @change="dirtyNote = true"
                    bg-color="grey lighten-4"
                    variant="filled"
                    v-model="note.note">
        </a-textarea>

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
      <div class="follow-up-reminder" v-if="isPsWqtNote || isEventWqtNote">
        <label class="mr-3">Set follow-up reminder for: </label>
        <DatetimePickerInput
            v-model="note.followUpDate"
            :timezone="timezone"
            :type="'date'"
            :outlined="'outlined'"
            :format="'MM/DD/YYYY'"
            placeholder="Choose Date"
            :hide-details="true"
            :show-append-icon="true"
            :hide-prepend-icon="true"
        />
      </div>
      <div class="text-left mb-2 mt-5">
        <a-btn
            color="primary"
            :disabled="!note.note || savingNote"
            @click="saveNote(note);"
            text="Save"
        ></a-btn>
        <a-btn
            variant="text"
            color="primary"
            v-if="note.note"
            @click="[note={}, dirtyNote = false]"
            text="Cancel"
        ></a-btn>
      </div>
    </v-card>
    <v-divider></v-divider>

    <v-spacer></v-spacer>
    <v-data-table
        :headers="displayedHeaders"
        :items="filteredNotes"
        :items-per-page="-1"
        single-expand
        item-key="id"
        disable-sort
        :expanded.sync="expanded"
        hide-default-footer
        class="elevation-0 mt-1 label-small"
    >

      <template #no-data>
        <span class="default-text-color">There are no notes to display</span>
      </template>
      <template #no-results>
        <span class="default-text-color">There are no notes to display</span>
      </template>

      <template #item="{ item, index }">
        <tr class="text-left" :class="{'shaded-row': index % 2}" v-if="item.edit">
          <td class="py-2 pl-5" colspan="3">
            <Mentionable
                :keys="['@']"
                :items="users"
                offset="6"
                insert-space
            >
              <a-textarea class="py-2" hide-details
                          auto-grow
                          rows="4"
                          @change="dirtyNote = true"
                          bg-color="transparent"
                          variant="filled"
                          v-model="item.note"></a-textarea>

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
            <div class="follow-up-reminder" v-if="isPsWqtNote || isEventWqtNote">
              <label class="mr-3">Set follow-up reminder for: </label>
              <DatetimePickerInput
                  v-model="item.followUpDate"
                  :timezone="timezone"
                  :type="'date'"
                  :outlined="'outlined'"
                  :format="'MM/DD/YYYY'"
                  placeholder="Choose Date"
                  :hide-details="true"
                  :show-append-icon="true"
                  :hide-prepend-icon="true"
              />
            </div>
            <div class="text-left mb-2">
              <a-btn
                  color="primary"
                  :disabled="!item.note"
                  @click="[item.edit = false, item.noteMenu = false, saveNote(item)]"
                  text="Save"
              ></a-btn>
              <a-btn
                  variant="text"
                  color="primary"
                  @click="[dirtyNote = false, item.note = item.oldNote, item.edit = false, item.noteMenu = false]"
                  text="cancel"
              ></a-btn>
            </div>
          </td>
        </tr>
        <tr class="text-left" :class="{'shaded-row': index % 2}" v-else>
          <td class="py-2 note-column left-column-mobile">
            <pre class="app-pre-wrapper">{{ item.note }}</pre>
            <div v-if="item.childNotes && item.childNotes.length > 0 && !expanded.includes(item)"
                 @click="expanded=[item];" class="pl-4 note-see-comments clickable label-small">
              See {{ item.childNotes.length }} comment{{ item.childNotes.length > 1 ? 's' : '' }}...
            </div>
            <div v-else-if="item.childNotes && item.childNotes.length > 0 && expanded.includes(item)"
                 @click="expanded=[]" class="label-small pl-4 note-see-comments clickable">
              Hide comments...
            </div>
          </td>
          <td class="note-created-by center-column-mobile">
            {{ item.createdBy }} {{ item.dateCreated | formatDate('timestamp') }}
          </td>
          <td class="note-follow-up-date center-column-mobile" v-if="isPsWqtNote || isEventWqtNote">
            {{ item.followUpDate | formatDate('date') }}
          </td>
          <td class="text-right right-column-mobile" style="width: 50px;">
            <v-menu v-model="item.noteMenu"
                    :close-on-content-click="true"
                    min-width="290px">
              <template v-slot:activator="{ on }">
                <a-btn
                    :activation-handler="on"
                    variant="text"
                    color="primary"
                    prepend-icon="mdi-dots-horizontal"
                ></a-btn>
              </template>
              <v-list>
                <v-list-item @click="[item.showReply = true, expanded=[item]];">
                  <v-list-item-title>Add Comment</v-list-item-title>
                </v-list-item>
                <v-list-item v-if="item.createdById === userId || userStore.isSystemAdmin"
                             @click="[item.oldNote = item.note, item.edit = true]">
                  <v-list-item-title>Edit Note</v-list-item-title>
                </v-list-item>
                <v-list-item v-if="item.createdById === userId || userStore.isSystemAdmin" @click="startNoteDelete(item, false)">
                  <v-list-item-title>Delete Note</v-list-item-title>
                </v-list-item>

              </v-list>
            </v-menu>
          </td>
        </tr>
      </template>

      <template #expanded-item="{ headers, item }">
        <td :colspan="headers.length" class="py-4 px-10">
          <div v-if="item.showReply">
            <Mentionable
                :keys="['@']"
                :items="users"
                offset="6"
                insert-space
            >
              <a-textarea variant="solo"
                          v-model="item.reply"
                          hide-details
                          auto-grow
                          @change="dirtyNote = true"
                          rows="1"
                          placeholder="Add a comment..."
                          class="mt-1"></a-textarea>

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
            <div class="text-left py-2">
              <a-btn
                  color="primary "
                  @click="saveNote(item);"
                  :disabled="!item.reply"
                  text="Save"
              ></a-btn>
              <a-btn
                  variant="text"
                  color="primary"
                  class="ml-2"
                  v-if="item.reply"
                  @click="[item.reply=null, item.showReply = false, !item.childNotes || item.childNotes.length === 0 ? expanded=[] : null]"
                  text="cancel"
              ></a-btn>
            </div>
          </div>
          <div v-for="(cn, index) in item.childNotes.filter(cn => !cn.archived)" :key="index">
            <div v-if="cn.edit">
              <Mentionable
                  :keys="['@']"
                  :items="users"
                  offset="6"
                  insert-space
              >
                <a-textarea class="py-2" hide-details
                            auto-grow
                            @change="dirtyNote = true"
                            rows="4"
                            bg-color="grey lighten-4"
                            variant="filled"
                            v-model="cn.note"></a-textarea>

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

              <div class="text-left mb-2">
                <a-btn
                    color="primary"
                    class="body-medium"
                    :disabled="!cn.note"
                    @click="[cn.edit = false, cn.noteMenu = false, saveNote(cn)]"
                    text="Save"
                ></a-btn>
                <a-btn
                    variant="text"
                    color="primary body-medium"
                    @click="[dirtyNote = false, cn.note = cn.oldNote, cn.edit = false, cn.noteMenu = false]"
                    text="cancel"
                ></a-btn>
              </div>
            </div>
            <v-row v-else class="px-0">
              <v-col cols="11" class="pr-0">
                <v-card color="grey lighten-5 label-small" class="py-0">
                  <v-card-title class="reply-note-creator pt-1 pb-0">
                    {{ cn.createdBy }}
                    <v-spacer></v-spacer>
                    {{ cn.dateCreated | formatDate('timestamp') }}
                  </v-card-title>
                  <v-card-text class="reply-note pb-1 default-text-color body-large">
                    <pre class="app-pre-wrapper">{{ cn.note }}</pre>
                  </v-card-text>
                </v-card>
              </v-col>
              <v-col cols="1" class="reply-button-dots pl-0">
                <v-menu v-model="cn.noteMenu"
                        :close-on-content-click="true"
                        min-width="290px">
                  <template v-slot:activator="{ on }">
                    <a-btn
                        :activation-handler="on"
                        variant="text"
                        color="unset"
                        prepend-icon="mdi-dots-horizontal"
                    ></a-btn>
                  </template>
                  <v-list>
                    <v-list-item v-if="cn.createdById === userId || userStore.isSystemAdmin"
                                 @click="[cn.oldNote = cn.note, cn.edit = true]">
                      <v-list-item-title>Edit Comment</v-list-item-title>
                    </v-list-item>
                    <v-list-item v-if="cn.createdById === userId || userStore.isSystemAdmin" @click="startNoteDelete(cn, true, item)">
                      <v-list-item-title>Delete Comment</v-list-item-title>
                    </v-list-item>
                  </v-list>
                </v-menu>

              </v-col>
            </v-row>
          </div>
        </td>
      </template>
    </v-data-table>
    <ConfirmationDialog
        :open-dialog="showDeleteNoteDialog"
        @confirm="deleteNote"
        @close-dialog="closeNoteDelete"
    >{{ deleteDialogBody }}</ConfirmationDialog>
  </div>
</template>

<script setup>
import {getRequest, deleteRequest, postRequest, } from '@/helpers/helpers'


import {Mentionable} from 'vue-mention'
import DatetimePickerInput from "@/components/DatetimePickerInput"
import ConfirmationDialog from "@/components/ConfirmationDialog";

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const props = defineProps({
  showNotes: Boolean,
  showActivity: Boolean,
  bordered: Boolean,
  primaryId: Number,
  secondaryId: Number,
  installDashTile: String,
  isPsWqtNote: Boolean,
  isEventWqtNote: Boolean,
  notes: Array,
  type: String,
  callback: Function
})
const { showNotes, showActivity, bordered, primaryId, secondaryId, installDashTile,
  isPsWqtNote, isEventWqtNote, notes, type } = toRefs(props)

const addNote = ref(false)
const note = ref({})
const dirtyNote = ref(false)
const savingNote = ref(false)
const noteOptions = ref([
  {label: 'Add Comment'},
  {label: 'Edit Note'},
  {label: 'Delete Note'},
])
const selectedParent = ref({})
const headers = ref([
  {text: 'Notes Feed', value: 'note', show: true},
  {text: 'Note Created', value: 'createdBy', show: true},
  {text: 'Next Follow-up Date', value: 'followUpDate', show: isPsWqtNote.value || isEventWqtNote.value},
  {text: null, value: 'icons', show: true, width: '50px'}
])
const expanded = ref([])
const users = ref([])
const showDeleteNoteDialog = ref(false)
const noteToDelete = ref({})
const parentOfNoteToDelete = ref({})
const deleteDialogBody = ref('')

const userId = computed(() => {
  return userStore.details.id
})
const timezone = computed(() => {
  return userStore.timezone.value
})
const displayedHeaders = computed(() => {
  return headers.value.filter(header => header.show)
})
const filteredNotes = computed(() => {
  return notes.value?.filter(n => {
    return !n.archived
  })
})

onMounted(() => {
  getUsers()
})

const startNoteDelete = (n, isChildNote, item) => {
  deleteDialogBody.value = isChildNote ? "Are you sure you want to delete this comment?" : "Deleting this note will remove all comments. Are you sure you want to delete?"
  showDeleteNoteDialog.value = true
  noteToDelete.value = n
  parentOfNoteToDelete.value = item
}
const closeNoteDelete = () => {
  showDeleteNoteDialog.value = false
  noteToDelete.value = null
  parentOfNoteToDelete.value = null
}
const hasUnsavedNotes = ()  => {
  return dirtyNote.value
}
const deleteNote = async() => {
  const n = noteToDelete.value
  const isChildNote = !!parentOfNoteToDelete.value
  let url = installDashTile.value != null ? `/note/prodStat/${n.id}` :
      isPsWqtNote.value ? `/note/processStepWorkQueue/${n.id}` :
          isEventWqtNote.value ? `/note/eventWorkQueue/${n.id}` : ``
  try {
    // @randa: Probably should create an object type enum on the frontend that mimics the backend?
    await deleteRequest(url)
    n.archived = true
    if (isChildNote) {
      parentOfNoteToDelete.value.childNotes = parentOfNoteToDelete.value.childNotes.filter(cn => !cn.archived)
    }
    appStore.showSnack('SUCCESS', 'Note Deleted')

  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Deleting Note')

  }
  closeNoteDelete()
}
const saveNote = async(n) => {
  try {
    savingNote.value = true
    let url = '';
    let body = {};
    if (installDashTile.value != null) {
      url = `/note/saveProjectProdStatsNote`
      body = {
        primaryId: primaryId.value,
        id: n.reply ? null : n.id,
        note: n.reply ? n.reply : n.note,
        parentId: n.reply ? n.id : null,
        installDashTile: installDashTile.value
      }
    } else {
      // @randa: Probably should create an object type enum on the frontend that mimics the backend?
      url = isPsWqtNote.value ? `/note/saveProjectProcessStepWorkQueueNote` :
          isEventWqtNote.value ? `/note/saveProjectProcessStepEventWorkQueueNote` : `/note/save${type.value}Note`
      body = {
        primaryId: primaryId.value,
        id: n.reply ? null : n.id,
        note: n.reply ? n.reply : n.note,
        parentId: n.reply ? n.id : null,
        //these 2 fields are for pps pswqt notes which require 2 keys to save/get
        projectProcessStepId: primaryId.value,
        processStepWorkQueueTypeId: secondaryId.value,
        //these 2 params are used for event wqs. the endpoint will handle which one to use
        projectProcessStepEventId: primaryId.value,
        processStepEventWorkQueueTypeId: secondaryId.value,
        followUpDate: n.followUpDate
      }
    }

    const {data} = await postRequest(url, body)
    // notes.value.unshift(data)
    if (n.reply) {
      n.reply = null
      n.showReply = false
      n.childNotes == null ? n.childNotes = [data] : n.childNotes.push(data)
    } else if (!n.id) {
      note.value = {}
    }
    if((isPsWqtNote.value || isEventWqtNote.value) && (!n.id || notes.value.findIndex(i => i.id === n.id) === 0)) {
      //if it is a new (non-child) note or edit to the first note, send the note back in the callback so the wq ui can be updated
      props.callback(data, n.id === null)
    }
    appStore.showSnack('SUCCESS', n.id === null ? 'Note Added' : 'Note Saved')

    dirtyNote.value = false
    savingNote.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Saving Note')

    savingNote.value = false
  }
}
const getUsers = async () => {
  try {
    const {data} = await getRequest('/user/mentionableUsers', null, [])
    users.value = data;
    users.value?.forEach(u => {
      u.value = u.fullName
    })

  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Users')

    appStore.loading = false
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.note-created-by {
  font-size: 11px;
  font-style: italic;
}

.note-column {
  //maybe?
  min-width: 200px;
}

.note-see-comments {
  font-size: 11px;
  font-style: italic;
  color: var(--v-primary-base);
}

.reply-note-item {
  background-color: var(-v--primary-lighten9);
  padding: 5px 15px;
  border-radius: 10px;
}

.reply-note-creator {
  font-weight: 600;
  font-size: 12px;
}

.reply-note {
  font-size: 0.875rem;
  font-style: italic;
}

.reply-button-dots {
  display: flex;
  align-items: center;
}

.dim:hover {
  color: var(--v-primary-base);
  font-weight: bold;
}

.follow-up-reminder {
  margin-top: 15px;
  display: flex;
  align-items: center;
  width: 500px !important;
}

@media (max-width: 600px) {
  .center-column-mobile {
    width: 33%;
  }

  .left-column-mobile {
    width: 33%;
  }

  .right-column-mobile {
    width: 33%;
  }

}
</style>
