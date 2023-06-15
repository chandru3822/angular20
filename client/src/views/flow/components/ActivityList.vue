<template>
  <div>
      <div v-if="activities?.length === 0">
        No available notes or activities
      </div>
      <v-card v-else v-for="(a, aIdx) in activities" class="mt-2 elevation-1"
              :class="{'pinned-card': a.pinned}">
          <v-toolbar flat color="transparent">
            <v-toolbar-title>
              <v-icon small color="#FB8C00" v-if="a.pinned" class="mr-2">mdi-pin</v-icon>
              <span class="uncategorized-text" v-if="!a.activityHashtags || a.activityHashtags?.length === 0">[uncategorized]</span>
              <span class="test" v-for="(ah, idx) in a.activityHashtags">
                <span v-if="idx !== 0">,</span>
                <a @click="searchCallback('#' + ah.hashtag)">#{{ ah.hashtag }}</a>
              </span>
              <a v-if="a.linked" @click="goToPath(a)">
                <v-icon color="primary">mdi-link</v-icon>
                {{a.linkLabel}}
              </a>
            </v-toolbar-title>
            <v-spacer></v-spacer>
            <v-menu v-model="a.menuOpen" transition="scale-transition" offset-y left attach>
              <template v-slot:activator="{ on }">
                <v-btn text small color="primary" v-on="on">
                  <v-icon>mdi-dots-horizontal</v-icon>
                </v-btn>
              </template>
              <v-list dense class="pa-3">
                <v-list-item @click="editItem(a)" v-if="a.activityTypeId !== 1">
                  <v-list-item-content>
                    <v-list-item-title>Edit</v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
                <v-list-item @click="pinActivity(a)">
                  <v-list-item-content>
                    <v-list-item-title>{{ a.pinned ? 'Unpin' : 'Pin'}}</v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
                <v-list-item @click="deleteActivity(a)" v-if="a.activityTypeId !== 1">
                  <v-list-item-content>
                    <v-list-item-title>Delete</v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
              </v-list>
            </v-menu>
          </v-toolbar>

        <v-card-text>
          <!-- don't put a.note on a new line or it adds a space character to the beginning of the note in the UI -->
          <div class="text-formatting">
            <vue-clamp ellipsis="" autoresize :max-lines="5">{{ a.note }}
              <template #after="{ toggle, clamped }">
                <button v-if="clamped === true" @click="toggle">
                  ...see more
                </button>
              </template>
            </vue-clamp>
          </div>
        </v-card-text>
        <v-card-actions style="display: inline-block">
          {{ a.createdBy }}, {{ a.createdByPosition }} | {{ a.dateCreated | formatDate('timestamp', 'M/D/YY h:mm a') }}
          <span v-if="a.dateCreated !== a.dateModified">| Edited by {{ a.modifiedBy }}</span>
        </v-card-actions>
      </v-card>
    </div>
</template>

<script>
import {getRequest, deleteRequest, postRequest, putRequest, postRequestWithRequestParams, getSnackbar, handleHidingGlobalLoader} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from "vue2-filters"
import ConfirmationDialog from "@/components/ConfirmationDialog";
import AttachmentsTable from "@/views/flow/components/AttachmentsTable.vue";
import VueClamp from 'vue-clamp'

export default {
  name: 'ActivityList',
  components: {AttachmentsTable, ConfirmationDialog, VueClamp},
  mixins: [Vue2Filters.mixin],
  props: {
    activities: Array,
    contactId: Number,
    orgId: Number,
    userId: Number,
    projectId: Number,
    sectionType: String,
    editCallback: Function,
    searchCallback: Function
  },
  data() {
    return {
      snackbar: {},
      editedIndex: null,
    }
  },
  watch: {
  },
  computed: {

  },
  created() {
  },
  methods: {
    editItem(item) {
      //   editedActivity = cloneDeep(a),
      //   editedIndex = aIdx, addActivity = false,
      //     populateSelectedTopics()
      console.log('todo: handle this edit', item)
      this.editCallback(item)
    },
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
    async pinActivity(activity) {
      try {
        activity.pinned = !activity.pinned
        let params = {
          pinned: activity.pinned
        }
        await postRequestWithRequestParams(`/activity/${activity.id}/pin/${this.sectionType}`, null, params)
        let msg = activity.pinned ? 'Note Pinned' : 'Note Unpinned'
        //todo: handle sending this back up
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
        //todo handle sending this back up
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

.test {
  white-space: pre;
}

.text-formatting {
  white-space: pre-wrap;
  display: block;
}

.uncategorized-text {
  font-size: 14px;
  color: var(--v-grey-lighten1);
}

//.blah {
//  display: -webkit-box;
//  -webkit-line-clamp: 5;
//  -webkit-box-orient: vertical;
//  overflow: hidden;
//  text-overflow: ellipsis " [..]";
//}


</style>
