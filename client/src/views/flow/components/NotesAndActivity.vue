<template>
  <div>
    <v-toolbar color="transparent" class="elevation-0">
      <v-toolbar-title>Notes & Activity Feed</v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
      </v-toolbar-items>
    </v-toolbar>
    <v-card class="pa-4">
      <v-toolbar flat color="white" class="elevation-0">
        <v-toolbar-title class="app-title">Leave a note:</v-toolbar-title>
      </v-toolbar>
      <v-card class="pa-3 elevation-0 square-card">
        <v-textarea solo v-model="note.note"></v-textarea>
        <div class="text-right">
          <v-btn color="primary" class="white--text"
                 :disabled="!note.note"
                 @click="saveNote(note)">Save</v-btn>
          <v-btn text v-if="note.note" @click="note={}">
            <span>cancel</span>
          </v-btn>
        </div>
      </v-card>

      <v-spacer></v-spacer>
      <v-data-table
        :headers="headers"
        :items="notes"
        :items-per-page="-1"
        single-expand
        item-key="id"
        :expanded.sync="expanded"
        hide-default-footer
        hide-default-header
        class="elevation-1 mt-1"
        >

        <template #no-data>
          There are no notes to display
        </template>
        <template #no-results>
          There are no notes to display
        </template>

        <template #item="{ item, index }">
          <tr class="text-left" :class="{'shaded-row': index % 2}">
            <td class="py-2">
              {{item.note}}
              <div class="mt-2 note-created-by">
                Created by: {{item.createdBy}}<br/>
                Created at: {{item.dateCreated | formatDate('timestamp', $store.state.user.details.timezone.value)}}
              </div>
            </td>
            <td class="text-right">
              <v-btn text @click="item.showReply = true; expanded=[item]">
                <v-icon>reply</v-icon>
              </v-btn>
              <v-btn text v-if="item.childNotes && item.childNotes.length > 0 && !expanded.includes(item)" @click="expanded=[item]">
                <v-icon>expand_more</v-icon>
              </v-btn>
              <v-btn text v-if="item.childNotes && item.childNotes.length > 0 && expanded.includes(item)" @click="expanded=[]">
                <v-icon>expand_less</v-icon>
              </v-btn>
            </td>
          </tr>
        </template>

        <template #expanded-item="{ headers, item }">
          <td :colspan="headers.length" class="pa-4">
            <div v-if="item.showReply">
              <label>Leave a reply:</label>
              <v-textarea solo v-model="item.reply" class="mt-1"></v-textarea>
              <div class="text-right">
                <v-btn color="primary white--text" @click="saveNote(item)"
                       :disabled="!item.reply"
                >
                  Save
                </v-btn>
                <v-btn class="ml-2" v-if="item.reply"
                       @click="item.reply=null; item.showReply = false">
                  cancel</v-btn>
              </div>
            </div>
            <h4>Replies:</h4>
            <v-list>
              <v-list-item v-for="(cn, index) in item.childNotes" :key="index" dense>
                <v-list-item-content>
                  <v-list-item-title>{{cn.note}}</v-list-item-title>
                  <v-list-item-subtitle>Left by: {{cn.createdBy}}</v-list-item-subtitle>
                  <v-list-item-subtitle>Left at: {{cn.dateCreated | formatDate('timestamp', $store.state.user.details.timezone.value)}}</v-list-item-subtitle>
                </v-list-item-content>
              </v-list-item>
            </v-list>

          </td>
        </template>

      </v-data-table>


    </v-card>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </div>
</template>

<script>
import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
import Snackbar from '@/components/Snackbar.vue'

export default {
  name: 'CustomValueInput',
  props: {
    showNotes: Boolean,
    showActivity: Boolean,
    primaryId: Number,
    notes: Array,
    type: String
  },
  components: {
    Snackbar
  },
  data () {
    return {
      snackbar: {},
      addNote: false,
      note: {},
      selectedParent: {},
      headers: [
        { text: 'note', value: 'note', show: true },
        { text: null, value: 'icons', show: true }
      ],
      expanded: [],
    }
  },
  methods: {
    async saveNote(n) {
      try {
        const {data} = await postRequest(`/note/save${this.$props.type}Note`, {
          primaryId: this.primaryId,
          note: n.reply ? n.reply : n.note,
          parentId: n.reply ? n.id : null
        })
        // this.notes.unshift(data)
        if(n.reply) {
          n.reply = null
          n.showReply = false
          n.childNotes.push(data)
        } else {
          this.$props.notes.push(data)
          this.note = {}
        }
        this.snackbar = getSnackbar('SUCCESS', 'Note Added')
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Note')
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
</style>
<style lang="scss">

</style>
