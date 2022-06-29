<template>
  <NotesAndActivityContent
    v-if="primaryId"
    ref="notes"
    :showNotes="true"
    :showActivity="false"
    :notes="notes"
    :primaryId="primaryId"
    :type="noteType"
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
    contactId: Number,
    userId: Number,
    orgId: Number,
    projectId: Number,
    objectTypeId: Number
  },
  data() {
    return {
      snackbar: {},
      notes: [],
      path: null,
      primaryId: null,
      noteType: null
    }
  },
  created() {
    switch (this.objectTypeId) {
      case 2:
        this.primaryId = this.contactId
        this.path = `/note/getContactNotes`
        this.noteType = `Contact`
        break
      case 3:
        this.primaryId = this.userId
        this.path = `/note/getUserNotes`
        this.noteType = `User`
        break
      case 5:
        this.primaryId = this.orgId
        this.path = `/note/getOrgNotes`
        this.noteType = `Org`
        break
      default:
        this.primaryId = this.projectId
        this.path = `/note/getProjectNotes`
        this.noteType = `Project`
        break
    }
    this.getNotes()
  },
  computed: {},
  methods: {
    hasDirtyNotes() {
      return this.$refs.notes.hasUnsavedNotes()
    },
    getNotes: async function () {
      if (this.primaryId && this.path) {
        try {
          const {data} = await getRequestWithParams(this.path, {
            params: {
              primaryId: this.primaryId
            }
          })
          this.notes = data
        } catch {
          console.log('done gone boom')
        }
      }
    }
}
}
</script>

<style lang="scss" scoped>

</style>
