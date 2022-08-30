<template id="ahj-card">
  <v-card class="mb-3">
    <v-toolbar class="primary albatross-subtitle-1" @click="toggleCollapseExpand">
      <v-toolbar-title class="white--text font-weight-bold" :title="title">
        {{ title }}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-btn icon color="#ddd" style="border-radius: 3px" v-if="userCanEdit && showAdd">
        <v-icon v-show="!addMode && !editMode" @click.stop="[toggleCollapseExpand(), addLink()]" class="white--text">add</v-icon>
        <v-icon v-show="addMode || editMode"
                @click.stop="hideCtrls" class="white--text">remove</v-icon>
      </v-btn>
      <v-icon v-if="showExpanded" class="white--text">{{expanded ? 'mdi-chevron-up' : 'mdi-chevron-down'}}</v-icon>
    </v-toolbar>
    <v-card-text v-if="expanded">
      <div v-show="addMode || editMode">
      <slot name="addOrEdit">Add or Edit</slot>
      </div>
      <slot>Default</slot>
    </v-card-text>
  </v-card>
</template>

<script>
import {CollapseExpandEnum} from "@/views/blueraven/ahj/AhjEnums";

export default {
  name: "AhjCard",
  props: {
    title: String,
    userCanEdit: Boolean,
    showAdd: {
      type: Boolean,
      default: false
    },
    showExpanded: {
      type: Boolean,
      default: false
    },
    expandedAll: CollapseExpandEnum
  },
  data () {
    return {
      addMode: false,
      editMode: false,
      expanded: true
    }
  },
  watch: {
    expandedAll(){
      if(this.expandedAll === CollapseExpandEnum.EXPANDED && this.expanded !== true) {
        this.expanded = true
      } else if(this.expandedAll === CollapseExpandEnum.COLLAPSED && this.expanded === true){
        this.expanded = false
      }
    }
  },
  methods: {
    toggleCollapseExpand(){
      if(this.expanded && (this.addMode || this.editMode)){
        this.hideCtrls()
      }
      this.expanded = !this.expanded
      this.$emit('toggle-collapse-expand', this.expanded)
    },
    hideCtrls() {
      this.addMode = false
      this.editMode = false
      this.$emit('cancel-edit')
    },
  }
}
</script>

<style lang="scss" scoped>

</style>
