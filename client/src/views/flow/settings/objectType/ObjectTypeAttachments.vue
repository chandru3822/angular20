<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12" class="pa-0 mt-4">
        <v-toolbar flat class="attach-header-bar">
          <v-toolbar-title class="app-title">Attachment Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="getAvailableAttachmentTypes" v-if="userCanAdd">
              <v-icon v-if="!addNewType">add</v-icon>
              {{ addNewType ? 'Cancel' : 'Add Type' }}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card class="square-card pa-2" color="rowShadeCustom" v-if="addNewType">
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
                <router-link class="no-text-decoration pr-3"
                             :to="`/settings/project/attachmentType/${a.id}?companyObjectTypeId=${companyObjectTypeId}`">
                  <v-btn small text >
                    <v-icon>edit</v-icon>
                  </v-btn>
                </router-link>
                <v-dialog
                  v-if="userCanEdit"
                  v-model="a.deleteConfirm"
                  width="500">
                  <template v-slot:activator="{ on }">
                    <v-list-item-action class="clickable" v-on="on">
                      <v-icon>delete</v-icon>
                    </v-list-item-action>
                  </template>
                  <v-card>
                    <v-card-title
                      class="text-h5 grey lighten-2"
                      primary-title
                    >
                      Confirm
                    </v-card-title>

                    <v-card-text>
                      Are you sure you want to delete this attachment type: <strong>{{
                        a.attachmentType
                      }}</strong>?
                    </v-card-text>

                    <v-divider></v-divider>

                    <v-card-actions>
                      <v-spacer></v-spacer>
                      <v-btn
                        @click="a.deleteConfirm = false">
                        No
                      </v-btn>
                      <v-btn
                        color="primaryCustom"
                        text
                        @click="[a.archived = true, deleteTypeFromObject(a.id)]">
                        Yes
                      </v-btn>
                    </v-card-actions>
                  </v-card>
                </v-dialog>
              </v-list-item>
            </v-list>
          </draggable>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import {AppMutations} from "@/stores/AppStore";
import draggable from 'vuedraggable'
import {handleHidingGlobalLoader, deleteRequest, getRequest, getSnackbar, postRequest, putRequest} from "@/helpers/helpers";
import Vue2Filters from "vue2-filters";

export default {
  name: 'ObjectTypeAttachments',
  mixins: [Vue2Filters.mixin],
  components: {
    draggable
  },
  props: {
    objectTypeValue: String,
    showReadOnly: Boolean
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
      attachmentTypes: []
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
          const {data} = await getRequest(`/attachmentType/${this.objectType}/available`)
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
        const {data, status} = await getRequest(`/attachmentType/${this.objectType}`)
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
          const {status} = await putRequest(`/attachmentType/${this.objectType}/order`, typesToSave)
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
    async deleteTypeFromObject(id) {
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
    },
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
</style>
