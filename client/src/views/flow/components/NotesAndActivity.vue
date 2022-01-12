<template>
  <v-col>
    <v-toolbar color="transparent" class="elevation-0">
      <v-toolbar-title>Notes</v-toolbar-title>
    </v-toolbar>
    <v-card class="square-card mx-4">
      <NotesAndActivityContent
          :showNotes="showNotes"
          :showActivity="showActivity"
          :primaryId="primaryId"
          :secondaryId="secondaryId ? secondaryId : null"
          :install-dash-tile="installDashTile ? installDashTile : null"
          :is-wqt-note="isWqtNote ? isWqtNote : null"
          :notes="notes"
          :type="type"
          :callback="callback ? callback : null"
      ></NotesAndActivityContent>
    </v-card>
  </v-col>
</template>

<script>
import NotesAndActivityContent from "@/views/flow/components/NotesAndActivityContent";

export default {
  name: 'NotesAndActivity',
  components: {NotesAndActivityContent},
  props: {
    showNotes: Boolean,
    showActivity: Boolean,
    primaryId: Number,
    secondaryId: Number,
    installDashTile: String,
    isWqtNote: Boolean,
    notes: Array,
    type: String,
    callback: Function
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">

</style>
