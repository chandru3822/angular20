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
  props: {
    contactId: Number
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
  computed: {
    notesTitle() {
      null != this.contactId ? `Contact Notes` : `Project Notes`
    }
  },
  methods: {
    hasDirtyNotes () {
      return this.$refs.notes.hasUnsavedNotes()
    },
    getNotes: async function () {
      try {
        let url = null != this.contactId ? `/note/getContactNotes` : `/note/getProjectNotes`
        const {data} = await getRequestWithParams(url, {
          params: {
            primaryId: null != this.contactId ? this.contactId : this.projectId
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
