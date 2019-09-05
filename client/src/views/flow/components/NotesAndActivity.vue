<template>
  <div>
    <h3 class="mb-4">Notes & Activity Feed</h3>
    <v-card class="pa-4">
      <v-toolbar color="white" class="mb-2 elevation-1">
        <v-toolbar-title class="app-title">Leave a note</v-toolbar-title>
      </v-toolbar>
      <v-textarea solo v-model="note"></v-textarea>
      <div class="text-right">
        <v-btn color="primary" dark @click="saveNote">Save</v-btn>
      </div>
    </v-card>
  </div>
</template>

<script>
  export default {
    name: 'CustomValueInput',
    props: {
      showNotes: Boolean,
      showActivity: Boolean
    },
    data () {
      return {
        note: null
      }
    },
    methods: {
      async saveNote() {
        console.log('save note here')
      }
    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">

</style>
<style lang="scss">

</style>
