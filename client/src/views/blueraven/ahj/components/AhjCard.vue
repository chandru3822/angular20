<template id="ahj-card">
  <v-card class="mb-3">
    <v-toolbar class="primary albatross-subtitle-1" @click="toggleCollapseExpand">
      <v-toolbar-title class="white--text font-weight-bold" :title="title">
        {{ title }}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-btn icon color="#ddd" style="border-radius: 3px" v-if="userCanEdit && showAdd">
        <v-icon v-show="!addMode && !editMode" @click.stop="add" class="white--text">add</v-icon>
        <v-icon v-show="addMode || editMode"
                @click.stop="hideCtrls" class="white--text">remove</v-icon>
      </v-btn>
      <v-icon v-if="showExpanded" class="white--text clickable">{{expanded ? 'mdi-chevron-up' : 'mdi-chevron-down'}}</v-icon>
    </v-toolbar>
    <v-card-text v-if="expanded">
      <div v-show="addMode || editMode" class="px-3 pt-4 pb-3">
      <slot name="addOrEdit">Add or Edit</slot>
        <div class="link-btns">
          <v-btn color="primary" text @click="hideCtrls"
                 class="cancel-link">Cancel</v-btn>
          <v-btn v-show="editMode" dark v-if="userCanEdit"
                 @click="deleteItem" class="error">
            Delete
          </v-btn>
          <v-btn @click="save" color="primary" class="white--text"
                 :disabled="addBtnDisabled">
            {{ addMode ? 'Add' : 'Update' }}
          </v-btn>
        </div>
      </div>
      <slot>Default</slot>
    </v-card-text>
  </v-card>
</template>

<script>
import {CollapseExpandEnum} from "@/views/blueraven/ahj/AhjConstants";

export default {
  name: "AhjCard",
  props: {
    title: String,
    userCanEdit: Boolean,
    showAdd: {
      type: Boolean,
      default: false
    },
    editMode: Boolean,
    addBtnDisabled: Boolean,
    showExpanded: {
      type: Boolean,
      default: false
    },
    expandedAll: CollapseExpandEnum
  },
  data () {
    return {
      addMode: false,
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
    },
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
      this.$emit('hide-ctrls')
    },
    add(){
      if(!this.expanded){
        this.toggleCollapseExpand()
      }
      this.$emit('hide-ctrls')
      this.addMode = true
    },
    save(){
      if(this.addMode){
        this.$emit('save-new')
        this.addMode = false
      } else {
        this.$emit('save-update')
        this.$emit('hide-ctrls')

      }
    },
    deleteItem() {
      this.$emit('delete-item')
      this.$emit('hide-ctrls')
    }
  }
}
</script>

<style lang="scss" scoped>
.link-btns {
  display: flex;
  flex-flow: row nowrap;
  justify-content: flex-end;
  align-items: center;
  button {
    margin: 0 0 0 7px;
  }
}
</style>
