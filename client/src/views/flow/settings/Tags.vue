<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="title-large">Tags</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn variant="text" color="primary"
               @click="[addNew = !addNew, newTag = { bgColor: '#878787', fontColor: '#1F3C73'}]"
               v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')"
               :hide-text-on-mobile="constants.IS_MOBILE"
               :prepend-icon="constants.IS_MOBILE ? 'add' : ''"
               :text="addNew ? 'CANCEL' : 'ADD NEW'"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card v-if="addNew" flat color="transparent">
            <a-text-field v-model="newTag.tagName"
                          counter
                          :maxlength="tagMaxChars"
                          placeholder="Enter a tag name"
                          label="Tag Name">
            </a-text-field>
            <v-row>
              <v-col cols="6">
                <div>
                  <label>Tag Font Color:</label>
                  <v-color-picker class="my-3"
                                  v-model="newTag.fontColor"
                                  :canvas-height="colorOptions.height"
                                  :width="colorOptions.width"
                                  :mode="colorOptions.mode"
                                  :hide-mode-switch="colorOptions.hideModeSwitch">
                  </v-color-picker>
                </div>
              </v-col>
              <v-col cols="6">
                <div>
                  <label>Tag Background Color:</label>
                  <v-color-picker class="my-3"
                                  v-model="newTag.bgColor"
                                  :canvas-height="colorOptions.height"
                                  :width="colorOptions.width"
                                  :mode="colorOptions.mode"
                                  :hide-mode-switch="colorOptions.hideModeSwitch">
                  </v-color-picker>
                </div>
              </v-col>
            </v-row>
            <a-btn color="primary" class="mt-4" :disabled="!newTag.tagName || !newTag.fontColor || !newTag.bgColor"
                   @click="saveTag(newTag, true)" text="SAVE"/>
          </v-card>
          <div v-else>
            <v-list v-for="(a, index) in filteredTags"
                    :key="index" class="pa-0">
              <v-list-item :class="{'shaded-row': index % 2, 'mobile': vuetify.breakpoint.smAndDown}">
                <v-list-item-content class="text-left">
                  <div v-if="selectedTagId === a.id">
                    <a-text-field class="one-hunned"
                                  label="Tag Name"
                                  counter
                                  :maxlength="25"
                                  v-model="a.tagName">
                    </a-text-field>
                    <v-row>
                      <v-col cols="6">
                        <div>
                          <label>Tag Font Color:</label>
                          <v-color-picker class="my-3"
                                          v-model="a.fontColor"
                                          :canvas-height="colorOptions.height"
                                          :width="colorOptions.width"
                                          :mode="colorOptions.mode"
                                          :hide-mode-switch="colorOptions.hideModeSwitch">
                          </v-color-picker>
                        </div>
                      </v-col>
                      <v-col cols="6">
                        <div>
                          <label>Tag Background Color:</label>
                          <v-color-picker class="my-3"
                                          v-model="a.bgColor"
                                          :canvas-height="colorOptions.height"
                                          :width="colorOptions.width"
                                          :mode="colorOptions.mode"
                                          :hide-mode-switch="colorOptions.hideModeSwitch">
                          </v-color-picker>
                        </div>
                      </v-col>
                    </v-row>
                  </div>
                  <div v-else>
                    {{ a.tagName }}
                  </div>
                </v-list-item-content>
                <div>
                <span class="clickable"
                                    v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">
                  <a-btn variant="text" size="small" color="primary"
                   :disabled="!a.tagName || !a.fontColor || !a.bgColor"
                   v-if="selectedTagId === a.id" @click="saveTag(a, false)" prepend-icon="save"/>
                  <a-btn v-else variant="text" size="small" color="primary" @click="selectedTagId = a.id" prepend-icon="edit"/>
                </span>
                <a-btn
                  size="small" variant="text" color="primary"
                  v-if="selectedTagId === a.id"
                  @click="selectedTagId = null"
                  prepend-icon="close"
                />
                <a-btn size="small" variant="text" color="primary"
                       v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                       @click="tagToDelete=a" prepend-icon="delete"/>
                <v-tooltip
                  content-class="full-opacity-tooltip"
                  :max-width="300"
                  top
                >
                  <template v-slot:activator="{ on, attrs }">
                    <a-btn
                      variant="text"
                      size="small"
                      color="primary"
                      class="d-inline-block"
                      v-bind="attrs"
                      :activation-handler="on"
                      prepend-icon="mdi-information"
                    />
                  </template>
                  <span>Tag ID: {{ a.id }}</span>
                </v-tooltip>
                </div>
              </v-list-item>
            </v-list>
          </div>
          <ConfirmationDialog :open-dialog="!!tagToDelete" @confirm="deleteTag" @close-dialog="tagToDelete=null">
            Are you sure you want to delete this tag: <strong>{{ tagToDeleteValue }}</strong>?
          </ConfirmationDialog>
        </v-container>
      </v-col>

    </v-row>
  </v-container>
</template>


<script setup>

import orderBy from 'lodash.orderby'

import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  putRequest
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from "@/components/ConfirmationDialog";

import {getCurrentInstance, onMounted, ref, computed, watch} from "vue";

import { useUserStore } from '@/stores/UserStore.js'
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const vuetify = vueInstance.$vuetify
const store = vueInstance.$store
const userStore = useUserStore()

const tags = ref([])
const addNew = ref(false)
const tagMaxChars = ref(30)
const newTag = ref({})
const selectedTagId = ref(null)
const userId = ref(userStore.details.id)
const companyId = ref(userStore.details.companyId)
const tagToDelete = ref(null)
const colorOptions = ref({
  canvasHeight: 75,
  width: 200,
  mode: 'hexa',
  hideModeSwitch: true
})


const tagToDeleteValue = computed(() => {
  return tagToDelete.value ? tagToDelete.value.tagName : ''
})
const getTags = async () => {
  appStore.loading = true
  try {
    //for now this is just hardcoded to show project tags
    const {data, status} = await getRequest(`/tag/byType/1`)
    tags.value = orderBy(data, [a => a.tagName.toLowerCase()])
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    appStore.loading = false
  }
}
const deleteTag = async () => {
  const tag = tagToDelete.value
  const typeId = tagToDelete.value.id
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/tag/${typeId}`)
    snackbar('SUCCESS', 'Tag Deleted')

    tag.archived = true
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Tag')

    appStore.loading = false
  }
  tagToDelete.value = null
}
const saveTag = async (tag, isNew) => {
  appStore.loading = true
  try {
    //yes this is hardcoded. im just trying to prep for future requests
    tag.tagTypeId = 1
    const {data, status} = await putRequest(`/tag`, tag)
    if (isNew) {
      addNew.value = false
      newTag.value = {}
      tags.value.push(data)
      tags.value = orderBy(tags.value, [a => a.tagName.toLowerCase()])
    } else {
      selectedTagId.value = null
    }
    snackbar('SUCCESS', 'Tag Saved')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Tag')
    appStore.loading = false
  }
}
onMounted(()=> {
  getTags()
})

const filteredTags = computed(() => {
  return tags.value.filter((t) => t.archived === false)
})

</script>
<style scoped lang="scss">
.mobile {
  flex-direction: column;
}
</style>
