<template>
  <div>
      <v-toolbar flat dense color="white" class="elevation-0">
        <v-toolbar-title class="app-title">Leave a note:</v-toolbar-title>
      </v-toolbar>
      <v-divider></v-divider>
      <v-card class="px-3 elevation-0 square-card overflow-y-auto">
        <Mentionable
            :keys="['@']"
            :items="users"
            offset="6"
            insert-space
        >
          <v-textarea class="py-2" hide-details
                      auto-grow
                      rows="4"
                      @change="dirtyNote = true"
                      background-color="#F2F6F8"
                      filled v-model="note.note">
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
        <div class="follow-up-reminder" v-if="isWqtNote">
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
          <v-btn color="primaryCustom" class="white--text"
                 :disabled="!note.note || savingNote"
                 @click="saveNote(note)">Save
          </v-btn>
          <v-btn text v-if="note.note" @click="[note={}, dirtyNote = false]">
            <span>cancel</span>
          </v-btn>
        </div>
      </v-card>
      <v-divider></v-divider>

      <v-spacer></v-spacer>
      <v-data-table
          :headers="displayedHeaders"
          :items="filterNotes()"
          :items-per-page="-1"
          single-expand
          item-key="id"
          disable-sort
          :expanded.sync="expanded"
          hide-default-footer
          class="elevation-0 mt-1"
      >

        <template #no-data>
          There are no notes to display
        </template>
        <template #no-results>
          There are no notes to display
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
                <v-textarea class="py-2" hide-details
                            auto-grow
                            rows="4"
                            @change="dirtyNote = true"
                            background-color="#F2F6F8"
                            filled v-model="item.note"></v-textarea>

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
              <div class="follow-up-reminder" v-if="isWqtNote">
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
                <v-btn color="primaryCustom" class="white--text"
                       :disabled="!item.note"
                       @click="[item.edit = false, item.noteMenu = false, saveNote(item)]">Save
                </v-btn>
                <v-btn text
                       @click="[dirtyNote = false, item.note = item.oldNote, item.edit = false, item.noteMenu = false]">
                  <span>cancel</span>
                </v-btn>
              </div>
            </td>
          </tr>
          <tr class="text-left" :class="{'shaded-row': index % 2}" v-else>
            <td class="py-2 pl-5">
              <pre class="app-pre-wrapper">{{ item.note }}</pre>
              <div v-if="item.childNotes && item.childNotes.length > 0 && !expanded.includes(item)"
                   @click="expanded=[item]" class="pl-4 note-see-comments clickable">
                See {{ item.childNotes.length }} comment{{ item.childNotes.length > 1 ? 's' : '' }}...
              </div>
              <div v-else-if="item.childNotes && item.childNotes.length > 0 && expanded.includes(item)"
                   @click="expanded=[]" class="pl-4 note-see-comments clickable">
                Hide comments...
              </div>
            </td>
            <td class="note-created-by">
              {{ item.createdBy }} {{ item.dateCreated | formatDate('timestamp') }}
            </td>
            <td class="note-follow-up-date" v-if="isWqtNote">
              {{ item.followUpDate | formatDate('date') }}
            </td>
            <td class="text-right" style="width: 50px;">
              <v-menu v-model="item.noteMenu"
                      :close-on-content-click="true"
                      min-width="290px">
                <template v-slot:activator="{ on }">
                  <v-btn v-on="on" text>
                    <v-icon>mdi-dots-horizontal</v-icon>
                  </v-btn>
                </template>
                <v-list>
                  <v-list-item @click="[item.showReply = true, expanded=[item]]">
                    <v-list-item-title>Add Comment</v-list-item-title>
                  </v-list-item>
                  <v-list-item v-if="item.createdById === userId || $store.getters.isFullAdmin"
                               @click="[item.oldNote = item.note, item.edit = true]">
                    <v-list-item-title>Edit Note</v-list-item-title>
                  </v-list-item>
                  <v-dialog
                      v-if="item.createdById === userId || $store.getters.isFullAdmin"
                      v-model="item.deleteConfirm"
                      width="500">
                    <template #activator="{ on }">
                      <v-list-item v-on="on">
                        <v-list-item-title>Delete Note</v-list-item-title>
                      </v-list-item>
                    </template>
                    <v-card>
                      <v-card-title
                          class="text-h5 grey lighten-2"
                          primary-title>
                        Confirm
                      </v-card-title>

                      <v-card-text class="pt-4">
                        Deleting this note will remove all comments. Are you sure you want to delete?
                      </v-card-text>

                      <v-divider></v-divider>

                      <v-card-actions>
                        <v-spacer></v-spacer>
                        <v-btn
                            @click="item.deleteConfirm = false">
                          No
                        </v-btn>
                        <v-btn
                            color="primaryCustom"
                            text
                            @click="deleteNote(item, false)">
                          Yes
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>

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
                <v-textarea solo v-model="item.reply"
                            hide-details
                            auto-grow
                            @change="dirtyNote = true"
                            rows="1"
                            placeholder="Add a comment..." class="mt-1"></v-textarea>

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
                <v-btn color="primaryCustom white--text" @click="saveNote(item)"
                       :disabled="!item.reply"
                >
                  Save
                </v-btn>
                <v-btn class="ml-2" v-if="item.reply"
                       @click="[item.reply=null, item.showReply = false, !item.childNotes || item.childNotes.length === 0 ? expanded=[] : null]">
                  cancel
                </v-btn>
              </div>
            </div>
            <div v-for="(cn, index) in filterBy(item.childNotes, false, 'archived')" :key="index">
              <div v-if="cn.edit">
                <Mentionable
                    :keys="['@']"
                    :items="users"
                    offset="6"
                    insert-space
                >
                  <v-textarea class="py-2" hide-details
                              auto-grow
                              @change="dirtyNote = true"
                              rows="4"
                              background-color="#F2F6F8"
                              filled v-model="cn.note"></v-textarea>

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
                  <v-btn color="primaryCustom" class="white--text"
                         :disabled="!cn.note"
                         @click="[cn.edit = false, cn.noteMenu = false, saveNote(cn)]">Save
                  </v-btn>
                  <v-btn text @click="[dirtyNote = false, cn.note = cn.oldNote, cn.edit = false, cn.noteMenu = false]">
                    <span>cancel</span>
                  </v-btn>
                </div>
              </div>
              <v-row v-else class="px-0">
                <v-col cols="11" class="pr-0">
                  <v-card color="#F2F6F8" class="py-0">
                    <v-card-title class="reply-note-creator pt-1 pb-0">
                      {{ cn.createdBy }}
                      <v-spacer></v-spacer>
                      {{ cn.dateCreated | formatDate('timestamp') }}
                    </v-card-title>
                    <v-card-text class="reply-note pb-1">
                      <pre class="app-pre-wrapper">{{ cn.note }}</pre>
                    </v-card-text>
                  </v-card>
                </v-col>
                <v-col cols="1" class="reply-button-dots pl-0">
                  <v-menu v-model="cn.noteMenu"
                          :close-on-content-click="true"
                          min-width="290px">
                    <template v-slot:activator="{ on }">
                      <v-btn v-on="on" text>
                        <v-icon>mdi-dots-horizontal</v-icon>
                      </v-btn>
                    </template>
                    <v-list>
                      <v-list-item v-if="cn.createdById === userId || $store.getters.isFullAdmin"
                                   @click="[cn.oldNote = cn.note, cn.edit = true]">
                        <v-list-item-title>Edit Comment</v-list-item-title>
                      </v-list-item>
                      <v-dialog
                          v-if="cn.createdById === userId || $store.getters.isFullAdmin"
                          v-model="cn.deleteConfirm"
                          width="500">
                        <template #activator="{ on }">
                          <v-list-item v-on="on">
                            <v-list-item-title>Delete Comment</v-list-item-title>
                          </v-list-item>
                        </template>
                        <v-card>
                          <v-card-title
                              class="text-h5 grey lighten-2"
                              primary-title>
                            Confirm
                          </v-card-title>

                          <v-card-text class="pt-4">
                            Are you sure you want to delete this comment?
                          </v-card-text>

                          <v-divider></v-divider>

                          <v-card-actions>
                            <v-spacer></v-spacer>
                            <v-btn
                                @click="cn.deleteConfirm = false">
                              No
                            </v-btn>
                            <v-btn
                                color="primaryCustom"
                                text
                                @click="deleteNote(cn, true, item)">
                              Yes
                            </v-btn>
                          </v-card-actions>
                        </v-card>
                      </v-dialog>

                    </v-list>
                  </v-menu>

                </v-col>
              </v-row>
            </div>
          </td>
        </template>
      </v-data-table>
  </div>
</template>

<script>
import {getRequest, deleteRequest, postRequest, getSnackbar} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from "vue2-filters"
import {Mentionable} from 'vue-mention'
import DatetimePickerInput from "@/components/DatetimePickerInput"

export default {
  name: 'NotesAndActivityContent',
  components: {Mentionable, DatetimePickerInput},
  mixins: [Vue2Filters.mixin],
  props: {
    showNotes: Boolean,
    showActivity: Boolean,
    primaryId: Number,
    secondaryId: Number,
    installDashTile: String,
    isWqtNote: Boolean,
    notes: Array,
    type: String,
    callback: Function
  },
  data() {
    return {
      snackbar: {},
      addNote: false,
      note: {},
      dirtyNote: false,
      savingNote: false,
      userId: this.$store.state.user.details.id,
      timezone: this.$store.state.user.details.timezone.value,
      noteOptions: [
        {label: 'Add Comment'},
        {label: 'Edit Note'},
        {label: 'Delete Note'},
      ],
      selectedParent: {},
      headers: [
        {text: 'Notes Feed', value: 'note', show: true},
        {text: 'Note Created', value: 'createdBy', show: true},
        {text: 'Next Follow-up Date', value: 'followUpDate', show: this.isWqtNote},
        {text: null, value: 'icons', show: true, width: '50px'}
      ],
      expanded: [],
      users: []
    }
  },
  computed: {
    displayedHeaders() {
      return this.headers.filter(header => header.show)
    },
  },
  created() {
    this.getUsers()
  },
  methods: {
    hasUnsavedNotes() {
      return this.dirtyNote
    },
    async deleteNote(n, isChildNote, item) {
      try {
        // @randa: Probably should create an object type enum on the frontend that mimics the backend?
        await deleteRequest(`/note/${n.id}`)
        n.archived = true
        if (isChildNote) {
          item.childNotes = item.childNotes.filter(cn => !cn.archived)
        }
        this.snackbar = getSnackbar('SUCCESS', 'Note Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Note')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async saveNote(n) {
      try {
        this.savingNote = true
        let url = '';
        let body = {};
        if (this.installDashTile != null) {
          url = `/note/saveProjectProdStatsNote`
          body = {
            primaryId: this.primaryId,
            id: n.reply ? null : n.id,
            note: n.reply ? n.reply : n.note,
            parentId: n.reply ? n.id : null,
            installDashTile: this.installDashTile
          }
        } else {
          // @randa: Probably should create an object type enum on the frontend that mimics the backend?
          url = this.isWqtNote ? `/note/saveProjectProcessStepWorkQueueNote` : `/note/save${this.$props.type}Note`
          body = {
            primaryId: this.primaryId,
            id: n.reply ? null : n.id,
            note: n.reply ? n.reply : n.note,
            parentId: n.reply ? n.id : null,
            //these 2 fields are for pps pswqt notes which require 2 keys to save/get
            projectProcessStepId: this.primaryId,
            processStepWorkQueueTypeId: this.secondaryId,
            followUpDate: n.followUpDate
          }
        }

        const {data} = await postRequest(url, body)
        // this.notes.unshift(data)
        if (n.reply) {
          n.reply = null
          n.showReply = false
          n.childNotes == null ? n.childNotes = [data] : n.childNotes.push(data)
        } else if (!n.id) {
          this.$props.notes.unshift(data)
          this.note = {}
        }
        if(this.isWqtNote && (!n.id || this.$props.notes.findIndex(i => i.id === n.id) === 0)) {
          //if it is a new (non-child) note or edit to the first note, send the note back in the callback so the wq ui can be updated
          this.callback(data)
        }
        this.snackbar = getSnackbar('SUCCESS', 'Note Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.dirtyNote = false
        this.savingNote = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Note')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.savingNote = false
      }
    },
    filterNotes() {
      return this.notes?.filter(n => {
        return !n.archived
      })
    },
    getUsers: async function () {
      try {
        const {data} = await getRequest('/user/mentionableUsers', null, [])
        this.users = data;
        this.users.forEach(u => {
          u.value = u.fullName
        })

      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Users')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.note-created-by {
  font-size: 11px;
  font-style: italic;
}

.note-see-comments {
  font-size: 11px;
  font-style: italic;
  color: #6B777D;
}

.reply-note-item {
  background-color: #F2F6F8;
  padding: 5px 15px;
  border-radius: 10px;
}

.reply-note-creator {
  color: var(--v-primaryCustom-base) !important;
  font-weight: 600;
  font-size: 12px;
}

.reply-note {
  color: var(--v-primaryCustom-base) !important;
  font-size: 12px;
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
</style>
