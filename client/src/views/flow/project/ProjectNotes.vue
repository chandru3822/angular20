<template>
<v-row id="project-notes-container">
  <v-col cols="12" lg="12" class="text-left">
    <v-card class="px-3 elevation-0 square-card notes-card">
    <NotesAndActivityContent
      ref="notes"
      :showNotes="true"
      :showActivity="false"
      :notes="notes"
      :primaryId="parseInt(projectId)"
      type="Project"
    />
    </v-card>
  </v-col>

</v-row>
</template>

<script>

import {getRequestWithParams} from '@/helpers/helpers'
import NotesAndActivityContent from "@/views/flow/components/NotesAndActivityContent";


export default {
  name: 'ProjectNotes',
  components: {
    NotesAndActivityContent,
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

.notes-card {
  overflow: scroll;
}
</style>
