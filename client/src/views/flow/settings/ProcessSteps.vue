<template>
  <v-container id="process-step-container" class="custom-field-group-container">
    <v-dialog
      v-model="deleteError"
    >
      <v-card>
        <v-card-title class="headline error--text">
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
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Process Steps</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newStep = {}]" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
              {{ addNew ? 'Cancel' : 'Add New'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card color="transparent" flat v-if="addNew" class="mb-3">
            <v-text-field
                label="Process Step Name"
                tabindex=1
                v-model="newStep.processStepName"
            ></v-text-field>
            <v-btn :disabled="!newStep.processStepName" @click="addProcessStep">Save</v-btn>
          </v-card>
          <v-card>
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
              class="elevation-1"
            >
              <template #item="{ item, index }">
                <tr :class="{'shaded-row': index % 2}">
                  <td class="text-left">{{item.processStepName}}</td>
                  <td class="text-right">
                    <v-btn small text @click="goToProcessStep(item.id)">
                      <v-icon>edit</v-icon>
                    </v-btn>
                    <v-dialog v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                        v-model="item.deleteConfirm" width="500">
                      <template v-slot:activator="{ on: dialog }">
                        <v-tooltip top v-if="item.workQueueTypes.length > 0">
                          <template v-slot:activator="{ on: tooltip }">
                            <div v-on="{ ...tooltip }" class="d-inline-block">
                              <v-btn small text disabled>
                                <v-icon>delete</v-icon>
                              </v-btn>
                            </div>
                          </template>
                          <span>Cannot delete a Process Step with assigned Work Queue Types</span>
                        </v-tooltip>

                        <v-btn small text v-on="{ ...dialog }" v-else>
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
                          Are you sure you want to delete this process step: <strong>{{ item.processStepName }}</strong>?
                        </v-card-text>

                        <v-divider></v-divider>

                        <v-card-actions>
                          <v-spacer></v-spacer>
                          <v-btn
                            @click="item.deleteConfirm = false">
                            No
                          </v-btn>
                          <v-btn
                            color="primary"
                            text
                            @click="deleteProcessStep(item)">
                            Yes
                          </v-btn>
                        </v-card-actions>
                      </v-card>
                    </v-dialog>
                  </td>

                </tr>
              </template>
            </v-data-table>
          </v-card>
        </v-container>
      </v-col>
      <Snackbar :snackbar="snackbar"></Snackbar>
    </v-row>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import Snackbar from '@/components/Snackbar.vue'
  import { getRequest, getRequestWithParams, putRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import debounce from "lodash.debounce";

  export default {
    name: 'ProcessSteps',
    mixins: [Vue2Filters.mixin],
    components: {
      Snackbar
    },
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
      goToProcessStep(stepId) {
        this.$router.push({path: `/settings/processStep/${stepId}/components`})
      },
      async getProcessSteps () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/processStep`)
          this.processSteps = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteProcessStep (processStep) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/processStep/delete/${processStep.id}`)
          if (data?.length > 0) {
            this.deleteError = true
            processStep.deleteConfirm = false
            this.fieldsInUse = data
            this.snackbar = getSnackbar('ERROR', 'Process Step Cannot Be Deleted')
          } else {
            this.fieldsInUse = []
            processStep.archived = true
            this.snackbar = getSnackbar('SUCCESS', 'Process Step Deleted')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Process Step')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addProcessStep () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/processStep`, this.newStep)
          this.$router.push({path: `/settings/processStep/${data.id}/components`})
          this.snackbar = getSnackbar('SUCCESS', 'Process Step Added')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Process Step')
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

</style>
