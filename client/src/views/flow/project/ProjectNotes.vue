<template>
<v-row id="project-notes-container">
  <v-col cols="12" lg="12" class="text-left">

    <NotesAndActivity
      ref="notes"
      :showNotes="true"
      :showActivity="false"
      :notes="notes"
      :primaryId="parseInt(projectId)"
      type="Project"
    />
  </v-col>

</v-row>
</template>

<script>

import {getRequest, putRequest, postRequest, logError, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
import NotesAndActivity from '@/views/flow/components/NotesAndActivity'



export default {
  name: 'ProjectNotes',
  components: {
    NotesAndActivity,
  },
  data () {
    return {
      snackbar: {},
      projectId: parseInt(this.$route.params.projectId),
      notes: []
    }
  },
  created () {
    this.getNotes()
  },
  computed: {},
  methods: {
    hasDirtyNotes () {
      return this.$refs.notes.hasUnsavedNotes()
    },
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
