<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12" class="pa-0 mt-4">
        <v-toolbar flat class="attach-header-bar">
          <v-toolbar-title class="app-title">Attachment Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="getAvailableAttachmentTypes" v-if="userCanAdd">
              <v-icon v-if="!addNewType">add</v-icon>
              {{ addNewType ? 'Cancel' : 'Add Type' }}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card class="square-card pa-2" color="primary lighten-9" v-if="addNewType">
          <v-autocomplete v-model="newType.attachmentTypeId"
                          :items="availableAttachmentTypes"
                          label="Select Attachment Type"
                          item-text="attachmentType"
                          item-value="id"
                          @input="assignNewType"
                          attach
          ></v-autocomplete>
        </v-card>

          <v-data-table
            :headers="visibleHeaders()"
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
              No attachment types found
            </template>

            <template #no-results>
              No attachment types found
            </template>

            <template #item="{ item, index }">
              <tr :class="{'shaded-row': index % 2}">
<!--                <td style="width: 50px">-->
<!--                  <v-btn text v-if="userCanEdit" icon small class="handle">-->
<!--                    <v-icon>drag_handle</v-icon>-->
<!--                  </v-btn>-->
<!--                </td>-->
                <td class="text-left">{{item.attachmentType}}</td>
                <td v-if="showUploadable">
                  <v-checkbox type="checkbox" class="ml-3" v-model="item.allowUpload"
                              @change="updateType(item)"  :disabled="!userCanEdit" :readonly="!userCanEdit">
                  </v-checkbox>
                </td>
                <td v-if="showLinkable">
                  <v-checkbox type="checkbox" class="ml-3" v-model="item.linkable"
                    @change="updateType(item)"  :disabled="!userCanEdit" :readonly="!userCanEdit">
                  </v-checkbox>
                </td>
                <td v-if="showFocused">
                  <v-checkbox type="checkbox" class="ml-3" v-model="item.focused"
                              @change="updateType(item)" :disabled="!userCanEdit" :readonly="!userCanEdit">
                  </v-checkbox>
                </td>
                <td>
                  <div style="display: flex; justify-content: flex-end">
                    <router-link class="no-text-decoration pr-3"
                                 :to="getAttachmentTypeUrl(item.id)">
                      <v-btn small text >
                        <v-icon>edit</v-icon>
                      </v-btn>
                    </router-link>
                    <v-btn v-if="userCanEdit" small text color="primary" class="clickable"
                           @click="attachmentTypeToDelete=item">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </div>
                </td>
              </tr>
            </template>
          </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!attachmentTypeToDelete"
                        @confirm="[attachmentTypeToDelete.archived = true, deleteTypeFromObject()]"
                        @close-dialog="attachmentTypeToDelete=null">
      Are you sure you want to delete this attachment type: <strong>{{attachmentTypeToDeleteName}}</strong>?

    </ConfirmationDialog>
  </v-container>
</template>

<script>
import {AppMutations} from "@/stores/AppStore";
import draggable from 'vuedraggable'
import {handleHidingGlobalLoader, deleteRequest, getRequest, getSnackbar, postRequest, putRequest} from "@/helpers/helpers";
import Vue2Filters from "vue2-filters"
import Sortable from "sortablejs"
import cloneDeep from 'lodash.clonedeep'
import orderBy from 'lodash.orderby'
import ConfirmationDialog from "@/ConfirmationDialog";

export default {
  name: 'ObjectTypeAttachments',
  mixins: [Vue2Filters.mixin],
  components: {
    ConfirmationDialog,
    draggable
  },
  props: {
    objectTypeValue: String,
    showReadOnly: Boolean,
    showLinkable: Boolean,
    showUploadable: {
      type: Boolean,
      default: false
    },
    showFocused: { //pretty sure that all types will be "focusable"
      type: Boolean,
      default: true
    },
    primaryId: Number //used to load objects types that have more than one value
  },
  // mounted() {
  //   let table = document.querySelector('.attachment-type-table tbody')
  //   const _self = this
  //   Sortable.create(table, {
  //     handle: '.handle',
  //     onEnd({newIndex, oldIndex}) {
  //       const rowSelected = _self.attachmentTypes.splice(oldIndex, 1)[0]
  //       _self.attachmentTypes.splice(newIndex, 0, rowSelected)
  //       let rowsClone = cloneDeep(_self.attachmentTypes)
  //
  //       let rowsToSave = []
  //       rowsClone.forEach((r, idx) => {
  //         //check if the row needs to be saved before updating display order
  //         //todo: vuetify table sorting is doing something weird where it won't sort right if i update the actual display order. hacked around it for now _rn
  //         let save = r.newDisplayOrder === undefined ? r.displayOrder !== idx : r.newDisplayOrder !== idx
  //         //update display order
  //         r.displayOrder = idx
  //         //save only rows that changed
  //         if (save) {
  //           _self.attachmentTypes[idx].newDisplayOrder = idx
  //           rowsToSave.push(r)
  //         }
  //       })
  //       _self.saveAttachmentTypeOrder(rowsToSave)
  //     }
  //   })
  // },
  computed: {
    attachmentTypeToDeleteName() {
      return this.attachmentTypeToDelete ? this.attachmentTypeToDelete.attachmentType : ''
    },
    headers() {
      return [
        // {text: null, value: 'draggable', width: '50px', show: true, sortable: false},
        {text: 'Attachment Type', value: 'attachmentType', show: true},
        {text: 'Allow Upload', value: 'allowUpload', show: this.showUploadable, width: 100},
        {text: 'Linkable', value: 'linkable', show: this.showLinkable, width: 100},
        {text: 'Focused', value: 'focused', show: this.showFocused, width: 100},
        {text: null, value: 'icons', show: true, width: 150}
      ]
    }
  },
  data () {
    return {
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
      addNewType: false,
      companyObjectTypeId: this.$route.query.companyObjectTypeId,
      objectType: this.objectTypeValue || this.$route?.query?.objectType?.toLowerCase(),
      newType: {},
      availableAttachmentTypes: [],
      attachmentTypes: [],
      attachmentTypeToDelete: null
    }
  },
  watch: {},
  created () {
    this.getAssignedAttachmentTypes()
  },
  methods: {
    async updateType(item) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {status} = await putRequest(`/attachmentType/${this.objectType}/update`, item)
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
    visibleHeaders() {
      return this.headers.filter(header => header.show === true)
    },
    getAttachmentTypeUrl (attachmentTypeId) {
      switch(this.objectTypeValue) {
        case 'project':
          return `/settings/project/attachmentType/${attachmentTypeId}?companyObjectTypeId=${this.companyObjectTypeId}`
        case 'event':
          return `/settings/event/${this.primaryId}/attachmentType/${attachmentTypeId}`
        default:
          return `/settings/objectType/${this.$route.params.id}/attachmentType/${attachmentTypeId}?objectType=${this.objectType}`
      }
    },
    async assignNewType() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        if(null != this.primaryId) {
          this.newType.primaryId = this.primaryId
        }
        const {data, status} = await postRequest(`/attachmentType/${this.objectType}`, this.newType)
        this.attachmentTypes.push(data)
        // reset fields
        this.addNewType = false
        this.newType = {}
        this.snackbar = getSnackbar('SUCCESS', 'Attachment Type Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Attachment Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getAvailableAttachmentTypes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addNewType = !this.addNewType
        if (this.addNewType) {
          let url = this.primaryId ? `/attachmentType/${this.objectType}/${this.primaryId}/available` : `/attachmentType/${this.objectType}/available`
          const {data} = await getRequest(url)
          this.availableAttachmentTypes = data
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      }
    },
    async getAssignedAttachmentTypes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let url = this.primaryId ? `/attachmentType/${this.objectType}/${this.primaryId}` : `/attachmentType/${this.objectType}`
        const {data, status} = await getRequest(url)
        this.attachmentTypes = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveAttachmentTypeOrder(rows) {
      if(rows?.length > 0) {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {status} = await putRequest(`/attachmentType/${this.objectType}/order`, rows)
          this.snackbar = getSnackbar('SUCCESS', 'Attachment Type Order Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Attachment Type Order')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async deleteTypeFromObject() {
      const id = this.attachmentTypeToDelete.id
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addNewType = false
        const {status} = await deleteRequest(`/attachmentType/${this.objectType}/${id}`)
        this.snackbar = getSnackbar('SUCCESS', 'Attachment Type Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Attachment Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.attachmentTypeToDelete = null
    },
    filterTypes() {
      return orderBy(this.attachmentTypes.filter(e => { return !e.archived}), [e => e.attachmentType])
    },
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
</style>
