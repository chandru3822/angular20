<template>
<v-row id="project-notes-container">
  <v-col cols="12" lg="12" class="text-left">

    <NotesAndActivity
      :showNotes="true"
      :showActivity="false"
      :notes="notes"
      :primaryId="parseInt(projectId)"
      type="Project"
      :users="allUsers"
    />
  </v-col>

</v-row>
</template>

<script>

import {getRequest, putRequest, postRequest, logError, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
import NotesAndActivity from '@/views/flow/components/NotesAndActivity'
import {AppMutations} from "@/stores/AppStore";


export default {
  name: 'ProjectNotes',
  components: {
    NotesAndActivity,
  },
  data () {
    return {
      snackbar: {},
      projectId: parseInt(this.$route.params.projectId),
      notes: [],
      allUsers: []
    }
  },
  created () {
    this.getNotes()
    this.getUsers()
  },
  computed: {},
  methods: {
    getNotes: async function () {
      try {
        const {data} = await getRequestWithParams(`/note/getProjectNotes`, {
          params: {
            primaryId: this.projectId
          }
        })
        this.notes = data
      } catch {
        console.log('done gone boom')
      }
    },
    getUsers: async function () {
      try {
        const {data} = await getRequest('/user/mentionableUsers')
        this.allUsers = data;
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

<style lang="scss" scoped>
#project-notes-container {
  margin-top: -5px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}

</style>

<style lang="scss">

</style>
