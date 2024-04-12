<template>
  <v-container id="process-step-container" class="custom-field-group-container">
    <v-dialog
      v-model="deleteError"
    >
      <v-card>
        <v-card-title class="text-h5 error--text">
          Error Deleting Process Step
        </v-card-title>

        <v-card-text>
          You cannot delete a process step with fields that are currently in use.  Please remove any field from the following locations before deleting.
          <v-list v-for="(item, index) in fieldsInUse" :key="index">
            <v-list-item-content>
              {{ item.objectType }}
              <div v-if="item.processStepName">{{item.processStepName}}</div>
              <div v-if="item.groupName">{{ item.groupName }}<span v-if="item.fieldName"> - {{ item.fieldName }}</span></div>
            </v-list-item-content>
          </v-list>

        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>

          <a-btn
            color="primary"
            variant="text"
            dark
            class="white--text"
            @click="deleteError = false"
            text="OK"
          />
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-row>
      <v-col cols="12" class="pa-0">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Process Steps</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
              variant="text"
              color="primary"
              @click="[addNew = !addNew, newStep = {}]"
              v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')"
              :shide-text-on-mobile="true"
              :prepend-icon="addNew ? 'mdi-close' : 'mdi-plus'"
              :text="addNew ? 'CANCEL' : 'ADD NEW'"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-container class="pa-0">
          <v-card color="transparent" flat v-if="addNew" class="mb-3 pa-2">
            <a-text-field
                label="Process Step Name"
                tabindex=1
                v-model="newStep.processStepName"
            ></a-text-field>
            <a-btn
              color="primary"
              :disabled="!newStep.processStepName"
              @click="addProcessStep"
              text="SAVE"
            />
          </v-card>
          <v-divider v-if="addNew"></v-divider>
          <v-card class="square-card">
            <v-card-title class="pt-0">
              <a-text-field
                v-model="search"
                prepend-inner-icon="search"
                label="Search"
                single-line
                hide-details
              ></a-text-field>
            </v-card-title>
            <v-data-table
                id="process-steps-table"
              :headers="headers"
              :items="filterProcessSteps"
              :fixed-header="true"
              :items-per-page="100"
              :search="search"
              :footer-props="footerProps"
              hide-default-header
              class="elevation-1 square-card table-striped"
            >

                  <template #item.processStepName="{item}" >
                    <a-btn
                      size="small"
                      variant="text"
                      :to="`/settings/processStep/${item.id}/components`"
                      class="one-hunned process-step-button"
                      :text="item.processStepName"
                    />
                  </template>
                  <template #item.icons="{item}" >
                    <a-btn
                      size="small"
                      variant="text"
                      color="primary"
                      :to="`/settings/processStep/${item.id}/components`"
                      prepend-icon="edit"
                    />
                    <v-tooltip top :disabled="!(item.workQueueTypes.length > 0 || item.usedByProcess)">
                      <template v-slot:activator="{ on: tooltip }">
                        <div v-on="{ ...tooltip }" class="d-inline-block">
                          <a-btn
                            size="small"
                            variant="text"
                            color="primary"
                            v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                            :disabled="item.workQueueTypes.length > 0 || item.usedByProcess"
                            @click="psToDelete=item"
                            prepend-icon="delete"
                          />
                        </div>
                      </template>
                      <span>{{ getDeleteTooltip(item) }}</span>
                    </v-tooltip>
                  </template>
            </v-data-table>
          </v-card>
        </v-container>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!psToDelete" @confirm="deleteProcessStep" @close-dialog="psToDelete=null">
      Are you sure you want to delete this process step: <b>{{psToDeleteName}}</b>?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>


  import { handleHidingGlobalLoader, getRequest, putRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import debounce from "lodash.debounce";
  import ConfirmationDialog from "@/components/ConfirmationDialog";
  import constants from "@/helpers/constants.js";


  import {getCurrentInstance, onMounted, ref, computed, watch} from "vue";

  import { useUserStore } from '@/stores/UserStore.js'
  import {useRouter} from "vue-router/composables"
  import { useAppStore } from '@/stores/AppStore.js'
  const appStore = useAppStore()
  const vueInstance = getCurrentInstance().proxy
  const snackbar = vueInstance.$snackbar
  const vuetify = vueInstance.$vuetify
  const store = vueInstance.$store
  const userStore = useUserStore()
  const router = useRouter()

  const addNew = ref(false)
  const deleteError = ref(false)
  const fieldsInUse = ref([])
  const search = ref('')
  const newStep = ref({})
  const selectedProcessStepId = ref(null)
  const companyId = ref(userStore.details.companyId)
  const userId = ref(userStore.details.id)
  const processSteps = ref([])
  const headers = ref([
    {text: 'Process Step Name', value: 'processStepName', show: true},
    {text: '', value: 'icons', show: true},
  ])
  const footerProps = ref({
    'items-per-page-options': [25, 50, 100, 1000],
    'items-per-page-text': vuetify.breakpoint.smAndDown ? '' : 'Rows per page:'
  })
  const psToDelete = ref(null)

  const psToDeleteName = computed(() => {
    return psToDelete.value ? psToDelete.value.processStepName : ''
  })
  const isMobile = computed(() => {
    return vuetify.breakpoint.smAndDown
  })
  const debounceGetSteps = debounce(() => {
    getProcessSteps()
  }, 500)
  const getProcessSteps = async () => {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/processStep`)
      processSteps.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')
      appStore.loading = false
    }
  }
  const getDeleteTooltip = (item) => {
    if(item.usedByProcess) {
      return 'Cannot delete a Process Step that is assigned to a process'
    } else if (item.workQueueTypes.length > 0 ) {
      return 'Cannot delete a Process Step with assigned Work Queue Types'
    }
  }
  const deleteProcessStep = async () => {
   const processStep = psToDelete.value
    appStore.loading = true
    try {
      const {data, status} = await putRequest(`/processStep/delete/${processStep.id}`, null, null, [])
      if (data?.length > 0) {
        deleteError.value = true
        processStep.deleteConfirm = false
        fieldsInUse.value = data
        snackbar('ERROR', 'Process Step Cannot Be Deleted')
      } else {
        fieldsInUse.value = []
        processStep.archived = true
        snackbar('SUCCESS', 'Process Step Deleted')
      }
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Deleting Process Step')
      appStore.loading = false
    }
    psToDelete.value = null
  }
  const addProcessStep = async () => {
    appStore.loading = true
    try {
      const {data, status} = await postRequest(`/processStep`, newStep.value)
      router.push({path: `/settings/processStep/${data.id}/components`})
      snackbar('SUCCESS', 'Process Step Added')
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Adding Process Step')
      appStore.loading = false
    }
  }
  const filterProcessSteps = computed(() => {
    return processSteps.value.filter(ps => { return !ps.archived})
  })

onMounted(async () => {
  getProcessSteps()
})

</script>

<style lang="scss">
  #process-step-container .v-data-table__wrapper {
    height: calc(100vh - 310px);
    min-height: 300px;
  }

  .process-step-button::before {
    background-color: transparent;
  }

  .process-step-button .v-btn__content {
    text-transform: none;
    justify-content: flex-start;
  }

  #process-steps-table > div.v-data-table__wrapper > table > tbody > tr > td {
    justify-content: center;
  }

  @media (max-width: 770px) {
    #process-steps-table {
      padding-bottom: 12px;
      div.v-data-footer {
        display: inline-block;
        width: 100%;
        padding-bottom: 12px;

        div.v-data-footer__select {
          justify-content: center;
        }

        div.v-data-footer__pagination {

        }

        div.v-data-footer__icons-before {
          display: inline;
          margin-left: calc(50% - 36px);


        }

        div.v-data-footer__icons-after {
          display: inline;
        }

      }
    }
  }
</style>
