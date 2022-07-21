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
        <v-card flat v-if="attachmentTypes && attachmentTypes.length > 0">
          <draggable v-model="attachmentTypes" group="attachmentTypes"
                     :disabled="!userCanEdit"
                     id="attachment-draggable"
                     @change="saveAttachmentTypeOrder(attachmentTypes)"
                     @start="drag=true" @end="drag=false">
            <v-list v-for="(a, index) in filterBy(attachmentTypes, false, 'archived')" :key="index">
              <v-list-item class="grab" dense :class="{'shaded-row': index % 2}">
                <v-list-item-action>
                  <v-icon>drag_handle</v-icon>
                </v-list-item-action>
                <v-list-item-content>
                  {{ a.attachmentType }}
                </v-list-item-content>
                <v-btn v-if="userCanEdit" small text color="primary" class="clickable" @click="attachmentTypeToDelete=a"><v-icon>delete</v-icon></v-btn>
              </v-list-item>
            </v-list>
          </draggable>
        </v-card>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!attachmentTypeToDelete"
                        @confirm="[attachmentTypeToDelete.archived = true, deleteTypeFromObject()]"
                        @close-dialog="attachmentTypeToDelete=null">
      Are you sure you want to delete this attachment type: <strong>{{attachmentTypeToDeleteName}}</strong>?
      <template v-slot:no>cancel</template>
      <template v-slot:yes>delete</template>
    </ConfirmationDialog>
  </v-container>
</template>

<script>
import {AppMutations} from "@/stores/AppStore";
import draggable from 'vuedraggable'
import {handleHidingGlobalLoader, deleteRequest, getRequest, getSnackbar, postRequest, putRequest} from "@/helpers/helpers";
import Vue2Filters from "vue2-filters";
import ConfirmationDialog from "@/ConfirmationDialog";

export default {
  name: 'ObjectTypeAttachments',
  mixins: [Vue2Filters.mixin],
  components: {
    ConfirmationDialog,
    draggable
  },
  data () {
    return {
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
      addNewType: false,
      companyObjectTypeId: this.$route.params.id,
      newType: {},
      availableAttachmentTypes: [],
      attachmentTypes: [],
      attachmentTypeToDelete: null
    }
  },
  computed: {
    attachmentTypeToDeleteName() {
      return this.attachmentTypeToDelete ? this.attachmentTypeToDelete.attachmentType : ''
    }
  },
  watch: {},
  created () {
    this.getAssignedAttachmentTypes()
  },
  methods: {
    async assignNewType() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newType.companyObjectTypeId = this.$route.params.id
        const {data, status} = await postRequest(`/attachmentType/objectType`, this.newType)
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
          const {data} = await getRequest(`/attachmentType/typesForObjectType/${this.$route.params.id}`)
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
        const {data, status} = await getRequest(`/attachmentType/objectTypes/${this.$route.params.id}`)
        this.attachmentTypes = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveAttachmentTypeOrder(attachmentTypes) {
      try {
        // if the fieldOrder of any item does not match idx + 1, it means it was changed and needs to be saved
        // pull those needing to be saved out of list
        let typesToSave = []
        attachmentTypes.forEach((f, idx) => {
          let order = idx + 1
          if (f.displayOrder !== order) {
            f.displayOrder = order
            typesToSave.push(f)
          }
        })
        // save them here
        if (typesToSave.length > 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {status} = await putRequest(`/attachmentType/updateOrderInObjectType`, typesToSave)
          this.snackbar = getSnackbar('SUCCESS', 'Attachment Types Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Attachment Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteTypeFromObject() {
      const id = this.attachmentTypeToDelete.id
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addNewType = false
        const {status} = await deleteRequest(`/attachmentType/objectType/${id}`)
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
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
#proj-attachment-draggable .v-list {
  padding-top: 0;
  padding-bottom: 0;
}
</style>
