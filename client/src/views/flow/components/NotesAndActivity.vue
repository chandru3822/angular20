<template>
  <div>
    <h3 class="mb-4">Notes & Activity Feed</h3>
    <v-card class="pa-4">
      <v-toolbar color="white" class="mb-2 elevation-1">
        <v-toolbar-title class="app-title">Leave a note</v-toolbar-title>
      </v-toolbar>
      <v-textarea solo v-model="note"></v-textarea>
      <div class="text-right">
        <v-btn color="primary" dark
               @click="saveNote">Save</v-btn>
      </div>

      <v-spacer></v-spacer>
      Notes:
      <div v-for="n in notes">
        {{n.note}} | {{n.createdBy}}
      </div>
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
    notes: Array
  },
  components: {
    Snackbar
  },
  data () {
    return {
      snackbar: {},
      note: null
    }
  },
  methods: {
    async saveNote() {
      try {
        const {data} = await postRequest(`/api/v1/flow/note/saveCustomerNote`, {primaryId: this.primaryId, note: this.note})
        // this.notes.unshift(data)
        props.notes.unshift(data)
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

</style>
<style lang="scss">

</style>
