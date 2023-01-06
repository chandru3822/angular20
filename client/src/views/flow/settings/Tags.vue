<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Tags</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary"
                   @click="[addNew = !addNew, newTag = { bgColor: '#878787', fontColor: '#1F3C73'}]"
                   v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{ addNew ? 'Cancel' : 'Add New' }}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card v-if="addNew" flat color="transparent">
            <v-text-field v-model="newTag.tagName"
                          counter
                          :maxlength="tagMaxChars"
                          placeholder="Enter a tag name"
                          label="Tag Name">
            </v-text-field>
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
            <v-btn color="primary" class="mt-4" :disabled="!newTag.tagName || !newTag.fontColor || !newTag.bgColor"
                   @click="saveTag(newTag, true)">Save
            </v-btn>
          </v-card>
          <div v-else>
            <v-list v-for="(a, index) in filterBy(tags, false, 'archived')"
                    :key="index" class="pa-0">
              <v-list-item :class="{'shaded-row': index % 2}">
                <v-list-item-content class="text-left">
                  <div v-if="selectedTagId === a.id">
                    <v-text-field class="one-hunned"
                                  label="Tag Name"
                                  counter
                                  :maxlength="25"
                                  v-model="a.tagName">
                    </v-text-field>
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
                <v-list-item-action class="clickable"
                                    v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">
                  <v-btn text color="primary" :disabled="!a.tagName || !a.fontColor || !a.bgColor"
                         v-if="selectedTagId === a.id" @click="saveTag(a, false)">
                    <v-icon>save</v-icon>
                  </v-btn>
                  <v-icon v-else color="primary" @click="selectedTagId = a.id">edit</v-icon>
                </v-list-item-action>
                <v-btn text color="primary" v-if="selectedTagId === a.id" @click="selectedTagId = null">
                  <v-icon>close</v-icon>
                </v-btn>
                <v-btn small text color="primary"
                       v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                       @click="tagToDelete=a">
                  <v-icon>delete</v-icon>
                </v-btn>
                <v-tooltip
                  content-class="full-opacity-tooltip"
                  :max-width="300"
                  top
                >
                  <template v-slot:activator="{ on, attrs }">
                    <v-btn
                      text small
                      color="primary"
                      class="d-inline-block"
                      v-bind="attrs"
                      v-on="on"
                    >
                      <v-icon color="primary" v-on="on">
                        mdi-information
                      </v-icon>
                    </v-btn>
                  </template>
                  <span>Tag ID: {{ a.id }}</span>
                </v-tooltip>
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


<script>
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import orderBy from 'lodash.orderby'

import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  putRequest,
  postRequest,
  getSnackbar
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from "@/ConfirmationDialog";

export default {
  name: 'Tags',
  components: {ConfirmationDialog},
  mixins: [Vue2Filters.mixin],

  data() {
    return {
      snackbar: {},
      constants,
      tags: [],
      addNew: false,
      tagMaxChars: 30,
      newTag: {},
      colorOptions: {
        canvasHeight: 75,
        width: 200,
        mode: 'hexa',
        hideModeSwitch: true
      },
      selectedTagId: null,
      userId: this.$store.state.user.details.id,
      companyId: this.$store.state.user.details.companyId,
      tagToDelete: null
    }
  },
  computed: {
    tagToDeleteValue() {
      return this.tagToDelete ? this.tagToDelete.tagName : ''
    }
  },
  methods: {
    async getTags() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //for now this is just hardcoded to show project tags
        const {data, status} = await getRequest(`/tag/byType/1`)
        this.tags = orderBy(data, [a => a.tagName.toLowerCase()])
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteTag() {
      const tag = this.tagToDelete
      const typeId = this.tagToDelete.id
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await deleteRequest(`/tag/${typeId}`)
        this.snackbar = getSnackbar('SUCCESS', 'Tag Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        tag.archived = true
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Tag')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.tagToDelete = null
    },
    async saveTag(tag, isNew) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //yes this is hardcoded. im just trying to prep for future requests
        tag.tagTypeId = 1
        const {data, status} = await putRequest(`/tag`, tag)
        if (isNew) {
          this.addNew = false
          this.newTag = {}
          this.tags.push(data)
          this.tags = orderBy(this.tags, [a => a.tagName.toLowerCase()])
        } else {
          this.selectedTagId = null
        }
        this.snackbar = getSnackbar('SUCCESS', 'Tag Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Tag')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  },
  async created() {
    this.getTags()
  }
}
</script>

