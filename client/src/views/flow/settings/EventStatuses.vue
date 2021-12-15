<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Event Status Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newType = {}]" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat v-if="addNew" class="px-5 py-2 square-card" color="rowShadeCustom">
          <h3>Add Event Status</h3>
          <v-text-field label="Event Status" v-model="newType.eventStatusType">
          </v-text-field>
          <v-autocomplete single-line
                          :items="rootStatusTypes"
                          v-model="newType.eventStatusTypeId"
                          item-value="id"
                          label="Select a Category"
                          item-text="eventStatusType"></v-autocomplete>
          <v-btn :disabled="!newType.eventStatusTypeId || !newType.eventStatusType" @click="saveType(newType, true)">Save</v-btn>
        </v-card>
        <v-data-table
          :headers="headers"
          :items="filterEventStatuses()"
          :fixed-header="true"
          :expanded.sync="expanded"
          single-expand
          :items-per-page="-1"
          hide-default-footer
          :sort-by="['displayOrder']"
          :sort-desc="[false]"
          class="elevation-1"
        >
          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left" :class="{'shaded-row': statusTypes.indexOf(item) % 2}">
              <h3 class="mb-3">Edit Status Type</h3>
              <v-text-field v-model="item.eventStatusType"
                            label="Status Type"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
              ></v-text-field>
              <v-autocomplete
                :items="rootStatusTypes"
                v-model="item.eventStatusTypeId"
                item-value="id"
                :readonly="!userCanEdit"
                :disabled="!userCanEdit"
                label="Select a Category"
                item-text="eventStatusType"></v-autocomplete>
              <v-btn color="primaryCustom" dark class="white--text"
                     :disabled="!item.eventStatusType || !item.eventStatusTypeId"
                     @click="saveType(item, false)">Save</v-btn>
            </td>
          </template>
          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td style="width: 50px">
                <v-btn text icon small class="handle" v-if="userCanEdit">
                  <v-icon>drag_handle</v-icon>
                </v-btn>
              </td>
              <td class="text-left">
                {{item.eventStatusType}}
              </td>
              <td class="text-left">
                {{item.rootEventStatusType}}
              </td>
              <td class="text-right">
                <v-btn small text v-if="!expanded.includes(item)" @click="expanded = [item]">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text v-if="expanded.includes(item)" @click="expanded = []">cancel</v-btn>
                <v-dialog v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                          v-model="item.deleteConfirm" width="500">
                  <template #activator="{ on }">
                    <v-btn small text v-on="on">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </template>
                  <v-card>
                    <v-card-title
                      class="headline grey lighten-2"
                      primary-title
                    >
                      Confirm
                    </v-card-title>

                    <v-card-text>
                      Are you sure you want to delete this status type: <strong>{{ item.eventStatusType }}</strong>?
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
                        @click="[item.archived = true, deleteType(item)]">
                        Yes
                      </v-btn>
                    </v-card-actions>
                  </v-card>
                </v-dialog>
              </td>

            </tr>
          </template>
        </v-data-table>
      </v-col>

    </v-row>
  </v-container>
</template>


<script>
  import { Actions } from '@/store'
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import draggable from 'vuedraggable'
  import cloneDeep from 'lodash.clonedeep'
  import Sortable from 'sortablejs'

  import orderBy from 'lodash.orderby'
  import {getCompanyEventStatusTypes, getEventStatusTypes} from '@/services/eventStatusTypeService'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'EventStatuses',
    mixins: [Vue2Filters.mixin],
    components: {
      draggable,
    },
    data () {
      return {
        snackbar: {},
        constants,
        statusTypes: [],
        expanded: [],
        rootStatusTypes: [],
        acceptedFileTypes: constants.STANDARD_IMAGES_ONLY,
        savingTypeLogo: false,
        headers: [
          { text: null, value: 'draggable', width: '50px', show: true },
          {text: 'Event Status', value: 'eventStatusType', show: true},
          {text: 'Status', value: 'rootEventStatusType', show: true},
          {text: '', value: 'icons', show: true},
        ],
        addNew: false,
        newType: {},
        selectedStatusTypeId: null,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      }
    },
    mounted() {
      let table = document.querySelector('tbody')
      const _self = this
      Sortable.create(table, {
        handle: '.handle',
        onEnd({ newIndex, oldIndex }) {
          const rowSelected = _self.statusTypes.splice(oldIndex, 1)[0]
          _self.statusTypes.splice(newIndex, 0, rowSelected)
          let statusTypesClone = cloneDeep(_self.statusTypes)
          statusTypesClone.forEach((g, idx) => {
            g.displayOrder = idx
          })
          _self.saveOrderChanges(statusTypesClone)
        }
      })
    },
    computed: {
    },
    methods: {
      async saveOrderChanges (types) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await putRequest(`/event/companyStatuses`, types)
          this.snackbar = getSnackbar('SUCCESS', 'Status Types Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Status Type Changes')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async uploadFile (item, files, attachmentTypeId, sourceId, sizeLimit) {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          await this.$store.dispatch(Actions.FILE_UPLOAD, {
            file: files[0],
            sizeLimit,
            attachmentTypeId,
            sourceId,
            callback: async (img, error) => {
              if(error?.error) {
                this.snackbar = getSnackbar('ERROR', error.errorMsg)
                this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
                this.$store.commit(AppMutations.SET_LOADING, false)
              } else {
                item.icon = img

                this.snackbar = getSnackbar('SUCCESS', 'Image Uploaded')
                this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
                this.$store.commit(AppMutations.SET_LOADING, false)
              }
            }
          })
        } catch(e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Uploading File')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteAttachment (item) {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          await this.$store.dispatch(Actions.FILE_DELETE, {
            id: item.icon.id,
            callback: async (status) => {
              item.icon = {}
              // this.$store.commit(UserMutations.SET_USER_IMAGE, {})
              this.snackbar = getSnackbar('SUCCESS', 'Image Deleted')
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$store.commit(AppMutations.SET_LOADING, false)
            }
          })
        } catch(e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting File')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getCompanyStatusTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getCompanyEventStatusTypes()
          this.statusTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getEventStatusTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getEventStatusTypes()
          this.rootStatusTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteType (item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/event/companyStatus/${item.id}`)
          this.snackbar = getSnackbar('SUCCESS', 'Status Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Status')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveType (type, isNew) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/event/companyStatus`, type)

          if(isNew) {
            // add it to the records already on the screen
            this.statusTypes.push(data)
            this.statusTypes = orderBy(this.statusTypes, [s => s.eventStatusType.toLowerCase()])

          // reset the new process fields
          this.addNew = false
          this.newType = {}
        }
        this.expanded = []
        this.selectedStatusTypeId = null
        this.snackbar = getSnackbar('SUCCESS', 'Event Status Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Event Status')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    filterEventStatuses () {
      return this.statusTypes.filter(s => { return !s.archived})
    }
  },
  async created () {
    this.getCompanyStatusTypes()
    this.getEventStatusTypes()
  }
}
</script>

<style scoped lang="scss">

</style>
