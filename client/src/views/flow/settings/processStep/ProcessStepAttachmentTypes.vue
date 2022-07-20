<template>
  <v-container class="pt-0">
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="req-header-bar">
          <v-toolbar-title class="app-title">Attachment Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn @click="[addNewType = !addNewType, getAvailableTypes()]" text v-if="userCanAdd">
              <v-icon v-if="!addNewType">add</v-icon>
              {{ addNewType ? 'Cancel' : 'Add Attachment Type'}}
            </v-btn>
            <v-btn text @click="expandTypes = !expandTypes">
              <v-icon v-if="!expandTypes">mdi-chevron-down</v-icon>
              <v-icon v-else>mdi-chevron-up</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-row v-if="addNewType">
          <v-col cols="12">
            <v-autocomplete v-model="newType"
                            :items="availableTypes"
                            label="Select Attachment Type"
                            item-value="id"
                            item-text="attachmentType"
                            return-object
            ></v-autocomplete>
            <v-btn class="white--text"
                   color="primaryButton"
                   :disabled="!newType.id"
                   @click="addTypeToProcessStep">
              Save
            </v-btn>
          </v-col>
        </v-row>
        <v-row v-if="expandTypes">
          <v-col cols="12" class="pt-0">
            <v-data-table
              :headers="headers"
              :items="filterTypes()"
              :items-per-page="-1"
              :sort-desc="[false]"
              :sort-by="['displayOrder']"
              :mobile-breakpoint="0"
              hide-default-footer
              disable-sort
              class="attachment-type-table elevation-1 fix-column-width-bug square-card"
            >
              <template #no-data>
                No attachment types for this process step
              </template>

              <template #no-results>
                No attachment types for this process step
              </template>

              <template #item="{ item, index }">
                <tr :class="{'shaded-row': index % 2}">
                  <td style="width: 50px">
                    <v-btn text v-if="userCanEdit" icon small class="handle">
                      <v-icon>drag_handle</v-icon>
                    </v-btn>
                  </td>
                  <td class="text-left">{{item.attachmentType}}</td>
                  <td>
                    <v-checkbox type="checkbox" class="ml-3" v-model="item.allowUpload"
                                @change="updateType(item)"  :disabled="!userCanEdit" :readonly="!userCanEdit">
                    </v-checkbox>
                  </td>
                  <td>
                    <v-checkbox type="checkbox" class="ml-3" v-model="item.linkable"
                                @change="updateType(item)"  :disabled="!userCanEdit" :readonly="!userCanEdit">
                    </v-checkbox>
                  </td>
                  <td>
                    <v-checkbox type="checkbox" class="ml-3" v-model="item.focused"
                                @change="updateType(item)" :disabled="!userCanEdit" :readonly="!userCanEdit">
                    </v-checkbox>
                  </td>
                  <td>
                    <div style="display: flex; justify-content: flex-end">
                      <router-link class="no-text-decoration pr-3"
                                   :to="`/settings/processStep/${processStepId}/attachmentType/${item.id}`">
                        <v-btn small text >
                          <v-icon>edit</v-icon>
                        </v-btn>
                      </router-link>
                      <v-dialog
                        v-if="userCanEdit"
                        v-model="item.deleteConfirm"
                        width="500">
                        <template #activator="{ on }">
                          <v-btn small text v-on="on">
                            <v-icon>delete</v-icon>
                          </v-btn>
                        </template>
                        <v-card>
                          <v-card-title
                            class="text-h5 grey lighten-2"
                            primary-title>
                            Confirm
                          </v-card-title>

                          <v-card-text class="pt-4">
                            Are you sure you want to delete this attachment type?
                          </v-card-text>

                          <v-divider></v-divider>

                          <v-card-actions>
                            <v-spacer></v-spacer>
                            <v-btn
                              @click="item.deleteConfirm = false">
                              No
                            </v-btn>
                            <v-btn
                              color="primaryCustom"
                              text
                              @click="deleteTypeFromStep(item)">
                              Yes
                            </v-btn>
                          </v-card-actions>
                        </v-card>
                      </v-dialog>
                    </div>
                  </td>
                </tr>
              </template>
            </v-data-table>
          </v-col>
        </v-row>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import Vue2Filters from 'vue2-filters'
import {AppMutations} from '@/stores/AppStore'
import Sortable from "sortablejs"
import cloneDeep from 'lodash.clonedeep'
import orderBy from 'lodash.orderby'
import {
  getRequest,
  deleteRequest,
  putRequest,
  postRequest,
  getSnackbar, handleHidingGlobalLoader
} from '@/helpers/helpers'

export default {
  name: 'ProcessStepAttachmentTypes',
  mixins: [Vue2Filters.mixin],
  mounted() {
    let table = document.querySelector('.attachment-type-table tbody')
    const _self = this
    Sortable.create(table, {
      handle: '.handle',
      onEnd({newIndex, oldIndex}) {
        const rowSelected = _self.attachmentTypes.splice(oldIndex, 1)[0]
        _self.attachmentTypes.splice(newIndex, 0, rowSelected)
        let rowsClone = cloneDeep(_self.attachmentTypes)

        let rowsToSave = []
        rowsClone.forEach((r, idx) => {
          //check if the row needs to be saved before updating display order
          //todo: vuetify table sorting is doing something weird where it won't sort right if i update the actual display order. hacked around it for now _rn
          let save = r.newDisplayOrder === undefined ? r.displayOrder !== idx : r.newDisplayOrder !== idx
          //update display order
          r.displayOrder = idx
          //save only rows that changed
          if (save) {
            _self.attachmentTypes[idx].newDisplayOrder = idx
            rowsToSave.push(r)
          }
        })
        _self.saveRowChanges(rowsToSave)
      }
    })
  },
  data() {
    return {
      snackbar: {},
      expandTypes: true,
      processStepId: this.$route.params.id,
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      headers: [
        {text: null, value: 'draggable', width: '50px', show: true, sortable: false},
        {text: 'Attachment Type', value: 'attachmentType', show: true},
        {text: 'Allow Upload', value: 'allowUpload', show: this.showUploadable, width: 100},
        {text: 'Linkable', value: 'linkable', show: this.showLinkable, width: 100},
        {text: 'Focused', value: 'focused', show: this.showFocused, width: 100},
        {text: null, value: 'icons', show: true, width: 150}
      ],
      addNewType: false,
      newType: {},
      attachmentTypes: [],
      availableTypes: [],
    }
  },
  computed: {},
  async created() {
    await this.getAttachmentTypes()
  },
  methods: {
    async updateType(item) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {status} = await putRequest(`/processStep/${this.processStepId}/attachmentType/update`, item)
        this.snackbar = getSnackbar('SUCCESS', 'Attachment Type Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Attachment Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getAttachmentTypes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/processStep/${this.processStepId}/attachmentType`)
        this.attachmentTypes = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getAvailableTypes() {
      if(this.addNewType) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/processStep/${this.processStepId}/attachmentType/available`)
          this.availableTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    filterTypes() {
      return orderBy(this.attachmentTypes.filter(e => { return !e.archived}), [e => e.displayOrder])
    },
    async addTypeToProcessStep() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let params = {
          attachmentTypeId: this.newType.id
        }
        const {data} = await postRequest(`/processStep/${this.processStepId}/attachmentType`, params)
        this.attachmentTypes.push(data)
        this.newType = {}
        this.addNewType = false
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Attachment Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteTypeFromStep(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await deleteRequest(`/processStep/${this.processStepId}/attachmentType/${item.id}`)
        item.archived = true
        this.snackbar = getSnackbar('SUCCESS', 'Attachment Type Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Attachment Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveRowChanges(rows) {
      if (rows?.length > 0) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await putRequest(`/processStep/${this.processStepId}/attachmentType/order`, rows)
          this.snackbar = getSnackbar('SUCCESS', 'Attachment Type Order Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Attachment Type Order')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
  }

}
</script>

<style scoped lang="scss">
.required-field-label {
  width: 100px;
}
</style>
