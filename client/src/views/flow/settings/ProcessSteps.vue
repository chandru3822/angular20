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

          <v-btn
            color="primaryCustom"
            text
            dark
            class="white--text"
            @click="deleteError = false"
          >
            OK
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-row>
      <v-col cols="12" class="pa-0">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Process Steps</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newStep = {}]" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
              {{ addNew ? 'Cancel' : 'Add New'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container class="pa-0">
          <v-card color="transparent" flat v-if="addNew" class="mb-3 pa-2">
            <v-text-field
                label="Process Step Name"
                tabindex=1
                v-model="newStep.processStepName"
            ></v-text-field>
            <v-btn :disabled="!newStep.processStepName" @click="addProcessStep">Save</v-btn>
          </v-card>
          <v-divider v-if="addNew"></v-divider>
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
              :items="filterProcessSteps()"
              :fixed-header="true"
              :items-per-page="100"
              :search="search"
              :footer-props="footerProps"
              hide-default-header
              class="elevation-1 square-card"
            >
              <template #item="{ item, index }">
                <tr :class="{'shaded-row': index % 2}">
                  <td class="text-left pr-0">
                    <v-btn small text :to="`/settings/processStep/${item.id}/components`" class="one-hunned process-step-button">
                      {{item.processStepName}}
                    </v-btn>
                  </td>
                  <td class="text-right pl-0">
                    <v-btn small text :to="`/settings/processStep/${item.id}/components`">
                      <v-icon>edit</v-icon>
                    </v-btn>
                    <confirm-delete-dialog v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                                           label="this process step: "
                                           :item-to-delete="item.processStepName"
                                           :is-disabled="item.workQueueTypes.length > 0 || item.usedByProcess"
                                           :show-tooltip="item.workQueueTypes.length > 0 || item.usedByProcess"
                                           :tooltip-text="getDeleteTooltip(item)"
                                           @confirm-delete="deleteProcessStep(item)"
                    ></confirm-delete-dialog>
                  </td>
                </tr>
              </template>
            </v-data-table>
          </v-card>
        </v-container>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'

  import { handleHidingGlobalLoader, getRequest, putRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import debounce from "lodash.debounce";
  import ConfirmDeleteDialog from "@/ConfirmDeleteDialog";

  export default {
    name: 'ProcessSteps',
    components: {ConfirmDeleteDialog},
    mixins: [Vue2Filters.mixin],

    data () {
      return {
        snackbar: {},
        addNew: false,
        deleteError: false,
        fieldsInUse: [],
        search: '',
        newStep: {},
        selectedProcessStepId: null,
        companyId: this.$store.state.user.details.companyId,
        userId: this.$store.state.user.details.id,
        processSteps: [],
        headers: [
          {text: 'Process Step Name', value: 'processStepName', show: true},
          {text: '', value: 'icons', show: true},
        ],
        footerProps: {
          'items-per-page-options': [25, 50, 100, 1000],
          'items-per-page-text': 'Rows per page:'
        },
      }
    },
    watch: {
      options: {
        handler () {
          this.getProcessSteps()
        },
        deep: true,
      },
    },
    computed: {
    },
    methods: {
      debounceGetSteps: debounce( function () {
        this.getProcessSteps()
      }, 500),
      async getProcessSteps () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/processStep`)
          this.processSteps = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      getDeleteTooltip(item) {
        if(item.usedByProcess) {
          return 'Cannot delete a Process Step that is assigned to a process'
        } else if (item.workQueueTypes.length > 0 ) {
          return 'Cannot delete a Process Step with assigned Work Queue Types'
        }
      },
      async deleteProcessStep (processStep) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await putRequest(`/processStep/delete/${processStep.id}`, null, null, [])
          if (data?.length > 0) {
            this.deleteError = true
            processStep.deleteConfirm = false
            this.fieldsInUse = data
            this.snackbar = getSnackbar('ERROR', 'Process Step Cannot Be Deleted')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          } else {
            this.fieldsInUse = []
            processStep.archived = true
            this.snackbar = getSnackbar('SUCCESS', 'Process Step Deleted')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Process Step')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addProcessStep () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await postRequest(`/processStep`, this.newStep)
          this.$router.push({path: `/settings/processStep/${data.id}/components`})
          this.snackbar = getSnackbar('SUCCESS', 'Process Step Added')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Process Step')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterProcessSteps () {
        return this.processSteps.filter(ps => { return !ps.archived})
      },
    },
    async created () {
      this.getProcessSteps()
    }
  }
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
</style>
