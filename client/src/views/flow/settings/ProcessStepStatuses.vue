<template>
  <v-container id="ps-container" class="custom-field-group-container">
    <v-dialog width="700"
              v-model="deleteError"
    >
      <v-card>
        <v-card-title class="text-h5 grey lighten-2 error--text">
          Error Deleting Process Step Status
        </v-card-title>

        <v-card-text class="pt-5">
          <div v-if="fieldsInUse && fieldsInUse.inUseByPps" class="mb-5">
            Status is in use by one or more project process steps.
          </div>
          <div v-if="fieldsInUse && fieldsInUse.steps && fieldsInUse.steps.length > 0" class="mb-5">
            <div class="mb-3">* This process step type is being used by the following Process Steps.</div>
            <div v-for="a in fieldsInUse.steps" :key="a.id" class="ml-5">
              <strong>{{ a.processStepName }}</strong>
            </div>
          </div>
        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>

          <AlbatrossButton
            color="primary"
            dark
            class="white--text"
            @click="deleteError = false"
            text="OK"
          />
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Process Step Status Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AlbatrossButton
              v-if="userCanEdit"
              variant="text"
              color="primary"
              @click="[addNew = !addNew, newType = {}]"
              :hide-text-on-mobile="constants.IS_MOBILE"
              :prepend-icon="constants.IS_MOBILE ? 'add' : ''"
              :text="addNew ? 'CANCEL' : 'ADD NEW'"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card flat v-if="addNew" class="px-5 py-2 square-card" color="primary lighten-9">
            <v-text-field v-if="addNew"
                          v-model="newType.processStepStatusType"
                          placeholder="Enter a type"
                          label="Status Type">
            </v-text-field>
            <v-autocomplete single-line
                            :items="rootStatusTypes"
                            v-model="newType.processStepStatusTypeId"
                            item-value="id"
                            label="Select a Category"
                            item-text="processStepStatusType"
                            attach></v-autocomplete>
            <AlbatrossButton
              color="primary"
              :disabled="!newType.processStepStatusTypeId || !newType.processStepStatusType"
              @click="addNewType"
              text="SAVE"
            />
          </v-card>
          <v-card class="square-card">
            <v-card-title class="pt-0">
              <v-text-field
                v-model="search"
                prepend-inner-icon="search"
                label="Search"
                single-line
                hide-details
              ></v-text-field>
            </v-card-title>
            <v-data-table
              :headers="headers"
              :items="filterProcessStepStatuses()"
              :fixed-header="true"
              :expanded.sync="expanded"
              single-expand
              :search="search"
              :footer-props="footerProps"
              :options.sync="options"
              class="elevation-1"
            >
              <template #expanded-item="{ headers, item }">
                <td :colspan="headers.length" class="pa-4 text-left" :class="{'shaded-row': statusTypes.indexOf(item) % 2}">
                  <h3 class="mb-3">Edit Status Type</h3>
                  <v-text-field v-model="item.processStepStatusType"
                                label="Status Type"
                                :readonly="!userCanEdit"
                                :disabled="!userCanEdit"
                  ></v-text-field>
                  <v-autocomplete
                    :items="filteredRootStatuses"
                    v-model="item.processStepStatusTypeId"
                    item-value="id"
                    :readonly="!userCanEdit"
                    :disabled="!userCanEdit || item.processStepStatusTypeId === 3"
                    label="Select a Category"
                    item-text="processStepStatusType"
                    attach
                  ></v-autocomplete>
                  <AlbatrossButton
                    v-if="userCanEdit"
                    color="primary"
                    dark
                    class="white--text mr-4"
                    :disabled="!item.processStepStatusType || !item.processStepStatusTypeId"
                    @click="saveType(item, false)"
                    text="SAVE"
                  />
                </td>
              </template>
              <template #item="{ item, index }">
                <tr :class="{'shaded-row': index % 2}">
                  <td class="text-left">
                    {{item.processStepStatusType}}
                  </td>
                  <td class="text-left">
                    {{item.rootProcessStepStatusType}}
                  </td>
                  <td class="text-right">
                    <AlbatrossButton
                      size="small"
                      variant="text"
                      color="primary"
                      @click="getUsesForStatus(item.id, item.processStepStatusType)"
                      prepend-icon="mdi-clipboard-list-outline"
                    />
                    <v-tooltip left>
                      <template v-slot:activator="{ on, attrs }">
                        <AlbatrossButton
                          icon
                          color="primary"
                          @click="copyToClipBoard(item.id)"
                          v-bind="attrs"
                          :activation-handler="on"
                          prepend-icon="mdi-information"
                          round
                        />
                      </template>
                      <span>Process Step Status ID: {{item.id}}</span>
                      <div class="text-center">(click to copy)</div>
                    </v-tooltip>
                    <AlbatrossButton
                      size="small"
                      variant="text"
                      color="primary"
                      v-if="!expanded.includes(item)"
                      @click="expanded = [item]"
                      prepend-icon="edit"
                    />
                    <AlbatrossButton
                      size="small"
                      variant="text"
                      color="primary"
                      v-if="expanded.includes(item)"
                      @click="expanded = []"
                      text="CANCEL"
                    />

                    <AlbatrossButton
                      size="small"
                      variant="text"
                      color="primary"
                      v-if="store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                      @click="[itemToDelete=item, showDeleteDialog=true]"
                      prepend-icon="delete"
                    />
                  </td>

                </tr>
              </template>
            </v-data-table>
          </v-card>
        </v-container>
      </v-col>

    </v-row>
    <ConfirmationDialog :open-dialog="showDeleteDialog"
                                 @confirm="deleteType"
                                 @close-dialog="closeDeleteDialog"
    >
      Are you sure you want to delete this status type: <strong>{{toDeleteProcessStepStatusType}}</strong>?

    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="showInfoDialog"
                        hideConfirm
                        @close-dialog="showInfoDialog=false"
    >
      <template v-slot:title>Process Step Status Usages: {{!!objectsUsingStatus ? objectsUsingStatus.fieldName : ''}}</template>
      <span v-if="!objectsUsingStatus || objectsUsingStatus.steps.length === 0">
        Nothing using this process step status.
      </span>
      <span v-else id="process-step-table">
        <div v-if="objectsUsingStatus.steps.length > 0" class="label-large mt-6">Process Steps</div>
      <v-simple-table v-if="objectsUsingStatus.steps.length > 0">
        <tbody>
        <tr v-for="(item, index) in objectsUsingStatus.steps" :key="index" :class="{'shaded-row': objectsUsingStatus.steps.length>1 && !(index % 2)}">
          <td>{{item.processStepName}}</td>
        </tr>
        </tbody>
      </v-simple-table>
      </span>
      <template v-slot:no>Close</template>
    </ConfirmationDialog>

  </v-container>
</template>


<script setup>
  import {AppMutations} from '@/stores/AppStore'

  import orderBy from 'lodash.orderby'
  import {getStatusTypes, getCompanyStatusTypes} from '@/services/processStepStatusTypeService'
  import {handleHidingGlobalLoader, deleteRequest, putRequest, postRequest, getSnackbar, getRequest} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import ConfirmationDialog from "@/components/ConfirmationDialog";

  import {getCurrentInstance, onMounted, ref, computed, watch} from "vue";
  import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
  const vueInstance = getCurrentInstance().proxy
  const snackbar = vueInstance.$snackbar
  const store = vueInstance.$store

  const search = ref('')
  const statusTypes = ref([])
  const expanded = ref([])
  const rootStatusTypes = ref([])
  const headers = ref([
    {text: 'Process Step Status', value: 'processStepStatusType', show: true},
    {text: 'Category', value: 'rootProcessStepStatusType', show: true},
    {text: '', value: 'icons', show: true, sortable: false},
  ])
  const footerProps = ref({
    'items-per-page-options': [25, 50, 100, 1000],
    'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
  })
  const options = ref({
    itemsPerPage: 100
  })
  const addNew = ref(false)
  const newType = ref({})
  const selectedStatusTypeId = ref(null)
  const userId = ref(store.state.user.details.id)
  const companyId = ref(store.state.user.details.companyId)
  const userCanEdit = ref(store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'))
  const fieldsInUse = ref([])
  const deleteError = ref(false)
  const showDeleteDialog = ref(false)
  const itemToDelete = ref(null)
  const showInfoDialog = ref(false)
  const objectsUsingStatus = ref({
    fieldName: null,
    steps: []
  })
  const toDeleteProcessStepStatusType = computed(() => {
    return itemToDelete.value ? itemToDelete.value.processStepStatusType : ''
  })
  const filteredRootStatuses = computed(() => {
    return rootStatusTypes.value.filter(rst => rst.id !== 3)
  })
  const getAllCompanyStatusTypes = async () => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data, status} = await getCompanyStatusTypes()
      statusTypes.value = data
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const getAllStatusTypes = async () => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data, status} = await getStatusTypes()
      rootStatusTypes.value = data
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const getUsesForStatus = async (processStepStatusId, processStepStatusName) => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data, status} = await getRequest(`/processStep/status/getObwjectsUsingStatus/${processStepStatusId}`, null, []);
      objectsUsingStatus.value.steps = data
      objectsUsingStatus.value.fieldName = processStepStatusName
      showInfoDialog.value = true
      store.commit(AppMutations.SET_LOADING, false)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const deleteType = async () => {
    const type = itemToDelete.value
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data, status} = await deleteRequest(`/processStep/status/${type.id}`)
      fieldsInUse.value = [];
      type.archived = true
      snackbar('SUCCESS', 'Status Deleted')
      handleHidingGlobalLoader(vueInstance, status)
      store.commit(AppMutations.SET_LOADING, false)
    } catch (e) {
      if (e.status === 400) {
        deleteError.value = true;
        fieldsInUse.value = e.data;
        snackbar("ERROR", "Status Cannot Be Deleted");
        store.commit(AppMutations.SET_LOADING, false)
      }
      else {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Deleting Status')
        store.commit(AppMutations.SET_LOADING, false)
      }
    }
    closeDeleteDialog()
  }
  const addNewType = async () => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      newType.value.companyId = companyId.value
      const {data, status} = await postRequest(`/processStep/status`, newType.value)

      // add it to the records already on the screen
      statusTypes.value.push(data)
      statusTypes.value = orderBy(statusTypes.value, [s => s.processStepStatusType.toLowerCase()])

      // reset the new process fields
      addNew.value = false
      newType.value = {}
      snackbar('SUCCESS', 'Status Added')

      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Adding Status')

      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const saveType = async (s) => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {status} = await putRequest(`/processStep/status`, s)
      selectedStatusTypeId.value = null
      expanded.value = []
      snackbar('SUCCESS', 'Status Updated')

      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Updating Status')

      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const filterProcessStepStatuses =  () => {
    return statusTypes.value.filter(s => { return !s.archived})
  }
  const copyToClipBoard = (textValue)=> {
    navigator.clipboard.writeText(textValue);
    snackbar('SUCCESS', 'Copied id to clipboard')

  }
  const closeDeleteDialog = () => {
    showDeleteDialog.value = false
    itemToDelete.value = null
  }
  onMounted(async () => {
    await getAllCompanyStatusTypes()
    await getAllStatusTypes()
  })

</script>

<style lang="scss">
  #ps-container .v-data-table__wrapper {
    height: calc(100vh - 290px);
    min-height: 300px;
  }
</style>

<style scoped lang="scss">
  #ps-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }
</style>
<style lang="scss">
#process-step-table > div.v-data-table.theme--light > div.v-data-table__wrapper {
  max-height: calc(100vh - 450px);
  overflow-y: scroll;
}
</style>
