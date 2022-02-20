<template>
    <NotesAndActivityContent
      ref="notes"
      :showNotes="true"
      :showActivity="false"
      :notes="notes"
      :primaryId="parseInt(projectId)"
      type="Project"
      class="px-2"
    />

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

</style>
