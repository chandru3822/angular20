<template>
  <v-container class="px-5">
    <div class="flex-display">
      <v-text-field
        prepend-inner-icon="search"
        text
        label="Search"
        v-model="search"
        @input=""
      ></v-text-field>
      <v-btn text small color="primary"><v-icon>mdi-arrow-up</v-icon></v-btn>
      <v-btn text small color="primary"><v-icon>mdi-filter</v-icon></v-btn>
    </div>
    <div>
      <v-card v-for="a in activities" class="mt-2 elevation-1">
        <v-card-title>
          #fake-hashtag
          <v-spacer></v-spacer>
          <v-btn text small color="primary"><v-icon>mdi-dots-horizontal</v-icon></v-btn>
        </v-card-title>
        <v-card-text>
          {{a.note}}
        </v-card-text>
        <v-card-actions>
          {{a.createdBy}}, {{a.createdByPosition}} | {{a.dateCreated | formatDate('timestamp', 'M/D/YY h:mm a') }}
        </v-card-actions>
      </v-card>
    </div>
    <div>
      <v-divider v-if="addActivity" class="my-3"></v-divider>
      <v-btn outlined color="primary"
             v-if="!addActivity"
             :loading="topicsLoading"
             @click="getTopics">
        <v-icon>mdi-plus</v-icon>
        Add note
      </v-btn>
      <div v-if="addActivity">
        <v-textarea outlined v-model="newActivity.note"></v-textarea>
        <v-autocomplete
          v-model="selectedTopics"
          :items="topics"
          multiple
          label="Topics"
          return-object
          item-text="hashtag"
        ></v-autocomplete>
        <v-checkbox
          class="pt-5 ml-3"
          dense
          v-model="newActivity.link"
          :label="linkLabel"
        />
      </div>
      <div v-if="addActivity">
        <v-btn text color="primary">cancel</v-btn>
        <v-btn color="primary"
               :loading="savingActivity"
               @click="saveNewActivity"
               :disabled="!newActivity.note">
          Save
        </v-btn>
      </div>
    </div>
  </v-container>

</template>

<script>
import {getRequest, deleteRequest, postRequest, getSnackbar, handleHidingGlobalLoader} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from "vue2-filters"
import { getNoteHashtags } from "@/services/activityService"
import ConfirmationDialog from "@/components/ConfirmationDialog";

export default {
  name: 'ActivitySection',
  components: {ConfirmationDialog},
  mixins: [Vue2Filters.mixin],
  props: {
    showActivities: Boolean,
    primaryId: Number,
    activities: Array,
    type: String,
    path: String,
    callback: Function
  },
  data() {
    return {
      snackbar: {},
      search: '',
      linkLabel: '',
      addActivity: false,
      newActivity: {},
      selectedTopics: [],
      topics: [],
      topicsLoading: false,
      savingActivity: false
    }
  },
  computed: {},
  created() {
    this.linkLabel = 'Link need to load info from center'
  },
  methods: {
    async getTopics() {
      this.topicsLoading = true
      try {
        const {data, status} = await getNoteHashtags()
        this.topics = data
        this.addActivity = true
        this.topicsLoading = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error loading topics')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.topicsLoading = false
      }
    },
    async saveNewActivity() {
      this.savingActivity = true
      try {
        let params = {
          note: this.newActivity.note,
          hashtags: this.selectedTopics
        }
        const {data, status} = await postRequest(this.path, params)
        this.activities.push(data)
        this.addActivity = false
        this.newActivity = {}
        this.savingActivity = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error saving note')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.savingActivity = false
      }
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">

</style>
