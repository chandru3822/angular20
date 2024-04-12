<template id="feat-db-card">
  <v-card class="mb-3">
    <v-toolbar class="primary albatross-subtitle-1" @click="toggleCollapseExpand">
      <v-toolbar-title class="white--text font-weight-bold" :title="title">
        {{ title }}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <a-btn
          icon
          color="#ddd"
          html-style="border-radius: 3px"
          v-if="userCanEdit && showAdd"
          @click.native.stop="handleAddBtnClick(!addMode && !editMode)"
          :prepend-icon="!addMode && !editMode ? 'add' : 'remove'"
      ></a-btn>
      <a-btn
          icon
          color="#ddd"
          html-style="border-radius: 3px"
          v-if="showExpanded"
          :prepend-icon="expanded ? 'mdi-chevron-up' : 'mdi-chevron-down'"
      ></a-btn>
      <!--      <v-icon v-if="showExpanded" class="white&#45;&#45;text clickable">{{expanded ? 'mdi-chevron-up' : 'mdi-chevron-down'}}</v-icon>-->
    </v-toolbar>
    <v-card-text v-if="expanded">
      <div v-show="addMode || editMode" class="px-3 pt-4 pb-3">
        <slot name="addOrEdit">Add or Edit</slot>
        <div class="link-btns">
          <a-btn
              color="primary"
              variant="text"
              @click="hideCtrls"
              class="cancel-link"
              text="Cancel"
          ></a-btn>
          <a-btn
              v-show="editMode"
              v-if="userCanEdit"
              @click="deleteItem"
              class="error"
              color="unset"
              text="Delete"
          ></a-btn>
          <a-btn
              @click="save"
              color="primary"
              :disabled="addBtnDisabled"
              :text="addMode ? 'Add' : 'Update'"
          ></a-btn>
        </div>
      </div>
      <slot>Default</slot>
    </v-card-text>
  </v-card>
</template>

<script setup>
import {CollapseExpandEnum} from "@/views/blueraven/featDB/FeatDbConstants";
import { getCurrentInstance, computed, toRefs, ref, onMounted, watch } from 'vue'

import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const props = defineProps({
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
})
const { title, userCanEdit, showAdd, editMode, addBtnDisabled, showExpanded, expandedAll } = toRefs(props)

const addMode = ref(false)
const expanded = ref(true)

watch(expandedAll, () => {
  if(expandedAll.value === CollapseExpandEnum.EXPANDED && expanded.value !== true) {
    expanded.value = true
  } else if(expandedAll.value === CollapseExpandEnum.COLLAPSED && expanded.value === true){
    expanded.value = false
  }
})

const emit = defineEmits(['toggle-collapse-expand', 'hide-ctrls', 'save-new', 'save-update', 'delete-item'])

const toggleCollapseExpand = () => {
  if(expanded.value && (addMode.value || editMode.value)){
    hideCtrls()
  }
  expanded.value = !expanded.value
  emit('toggle-collapse-expand', expanded.value)
}
const hideCtrls = ()  => {
  addMode.value = false
  editMode.value = false
  emit('hide-ctrls')
}
const handleAddBtnClick = (add)  => {
  //without this method it would only show the "add" section if you clicked right on the icon and not if you were inside the button but outside the icon. was causing issues
  if(add) {
    addMe()
  } else {
    hideCtrls()
  }
}
const addMe = () => {
  if(!expanded.value){
    toggleCollapseExpand()
  }
  editMode.value = false
  addMode.value = true
}
const save = () => {
  console.log('here')
  if(addMode.value){
    emit('save-new')
    addMode.value = false
  } else {
    emit('save-update')
    emit('hide-ctrls')
  }
}
const deleteItem = ()  => {
  emit('delete-item')
  emit('hide-ctrls')
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
