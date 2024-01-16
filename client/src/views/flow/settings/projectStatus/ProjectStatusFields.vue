<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="title-large">Data View Fields</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" v-if="!addNew && userCanAdd" @click="[addNew = !addNew, loadDataViews()]">
              <v-icon>add</v-icon>
              <span v-if="!constants.IS_MOBILE">Add Field</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <div class="px-5" v-if="addNew">
          Add New Field to Milestone
          <v-select attach
                    class="mt-3"
                    v-model="selectedDataView"
                    :items="dataViews"
                    label="Select Data View"
                    item-value="id"
                    return-object
                    item-text="displayName"
                    @input="[availableDataViewFields = [], selectedDataViewField = {}, getDataViewFields() ]"
          ></v-select>
          <v-autocomplete
            v-model="selectedDataViewField"
            :items="availableDataViewFields"
            label="Data View Field"
            return-object
            attach
            item-text="fieldName"
          ></v-autocomplete>
          <v-btn v-if="userCanEdit"
                 :disabled="!selectedDataViewField.id"
                 color="primary" class="d-inline-block"
                 @click="saveFieldToMilestone()">
            <v-icon class="mr-2">save</v-icon>
            Save
          </v-btn>
          <v-btn
            class="ml-3"
            @click="[addNew = false, selectedDataViewField = {} ]">
            cancel
          </v-btn>
        </div>
        <v-divider class="my-3" v-if="addNew"></v-divider>

        <v-data-table
          :headers="headers"
          :items="filterAssignedFields()"
          :fixed-header="true"
          :items-per-page="-1"
          hide-default-footer
          :loading="fieldsLoading"
          :sort-by="['displayOrder']"
          :sort-desc="[false]"
          class="elevation-1"
        >
          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td style="width: 50px">
                <v-btn text color="primary" icon small class="handle" v-if="userCanEdit">
                  <v-icon>drag_handle</v-icon>
                </v-btn>
              </td>
              <td class="text-left">
                {{item.fieldName}}
              </td>
              <td class="text-right">
                <v-btn small text color="primary" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')" @click.stop="[itemToDelete=item, showDeleteDialog=true]">
                  <v-icon >delete</v-icon>
                </v-btn>
              </td>

            </tr>
          </template>
        </v-data-table>
      </v-col>

    </v-row>
    <ConfirmationDialog :open-dialog="showDeleteDialog"
                        @confirm="deleteField"
                        @close-dialog="closeDeleteDialog"
    >
      Are you sure you want to delete this field: <strong>{{ itemToDelete?.fieldName }}</strong>?

    </ConfirmationDialog>
  </v-container>
</template>


<script>
import {Actions} from '@/store'
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import draggable from 'vuedraggable'
import cloneDeep from 'lodash.clonedeep'
import Sortable from 'sortablejs'

import orderBy from 'lodash.orderby'
import {getCompanyProjectStatusType, getProjectStatusTypes} from '@/services/projectStatusTypeService'
import {handleHidingGlobalLoader, deleteRequest, putRequest, getSnackbar, getRequest, postRequest} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";

export default {
  name: 'ProjectStatusFields',
  mixins: [Vue2Filters.mixin],
  components: {
    ConfirmationDialog,
    draggable,
  },
  mounted() {
    let table = document.querySelector('tbody')
    const _self = this
    Sortable.create(table, {
      handle: '.handle',
      onEnd({ newIndex, oldIndex }) {
        const rowSelected = _self.assignedFields.splice(oldIndex, 1)[0]
        _self.assignedFields.splice(newIndex, 0, rowSelected)
        let assignedFieldsClone = cloneDeep(_self.assignedFields)
        assignedFieldsClone.forEach((g, idx) => {
          g.displayOrder = idx
        })
        _self.saveOrderChanges(assignedFieldsClone)
      }
    })
  },
  data() {
    return {
      snackbar: {},
      constants,
      addNew: false,
      selectedDataView: {},
      selectedDataViewField: {},
      showDeleteDialog: false,
      itemToDelete: null,
      headers: [
        { text: null, value: 'draggable', width: '50px', show: true },
        {text: 'Field Name', value: 'fieldName', show: true},
        {text: '', value: 'icons', show: true},
      ],
      dataViews: [],
      fieldsLoading: true,
      assignedFields: [],
      availableDataViewFields: [],
      statusId: this.$route.params.id,
      userId: this.$store.state.user.details.id,
      companyId: this.$store.state.user.details.companyId,
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')
    }
  },
  computed: {},
  methods: {
    async saveOrderChanges (fields) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await putRequest(`/projectStatus/company/${this.statusId}/fields`, fields)
        this.snackbar = getSnackbar('SUCCESS', 'Field Order Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Field Order')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    closeDeleteDialog() {
      this.showDeleteDialog = false
      this.itemToDelete = null
    },
    async loadDataViews() {
      //dont reload the list every time
      if(this.dataViews.length === 0) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/dataView`, null, [])
          this.dataViews = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async getDataViewFields() {
      //dont reload the list every time
      if(this.availableDataViewFields.length === 0) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/customField/getByDataView/${this.selectedDataView.id}`)
          this.availableDataViewFields = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async deleteField() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let id = this.itemToDelete.id
        const {status} = await deleteRequest(`/projectStatus/field/${id}`)
        this.assignedFields = this.assignedFields.filter(af => af.id !== id)
        this.snackbar = getSnackbar('SUCCESS', 'Field Removed')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Removing Field')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveFieldToMilestone() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let params = {
          dataViewFieldConfigId: !this.selectedDataViewField.dataViewChildFieldConfigId ? this.selectedDataViewField.dataViewFieldConfigId : null,
          dataViewChildFieldConfigId: this.selectedDataViewField.dataViewChildFieldConfigId
        }
        const {data, status} = await postRequest(`/projectStatus/company/${this.statusId}/field`, params)
        this.assignedFields.push(data)
        this.selectedDataViewField = {}
        this.addNew = false
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async loadFields() {
      this.fieldsLoading = true
      try {
        const {data} = await getRequest(`/projectStatus/company/${this.statusId}/fields`, null, [])
        this.assignedFields = data
        this.fieldsLoading = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.fieldsLoading = false
      }
    },
    filterAssignedFields () {
      return this.assignedFields.filter(s => { return !s.archived})
    },
  },
  async created() {
    this.loadFields()
  }
}
</script>

<style scoped lang="scss">

</style>
