<template>
  <v-container id="proposals-container">
    <v-row justify="center" no-gutters>
      <v-col md="auto">
        <v-alert
          color="brYellow"
          dense
          tile
          :value="dirtyCfvs.length > 0"
          transition="scale-transition"
        >
          Changes haven't been reflected on proposal
        </v-alert>
      </v-col>
    </v-row>

    <v-row>
      <v-col cols="12" class="py-0">
        <router-link v-if="proposal && proposal.projectId"
                     :to="`/proposalDesigns/${proposal.projectId}`">Back
        </router-link>
        <v-toolbar dense flat color="transparent">
          <v-toolbar-title class="new-proposal-header">New Proposal</v-toolbar-title>
          <v-chip small color="brBlue" dark class="ml-2 text-uppercase">Primary</v-chip>
          <v-spacer />
          <v-toolbar-items />
        </v-toolbar>
      </v-col>
    </v-row>

    <v-form ref="proposalForm">
      <v-row>
        <v-col cols="12" sm="4">
          <v-card class="proposal-container">
            <div>
              <div class="proposal-container-header">
                <div class="proposal-title">Configurations</div>
              </div>
              <div
                v-for="(cfg, index) in sortedCustomFieldGroups"
                :key="index"
              >
                <div class="configuration-group-title">{{ cfg.groupName }}</div>
                <CustomValueInput
                  v-for="(field, idx) in cfg.customFieldValues"
                  :key="idx"
                  :required="field.required"
                  :callback="populateDirtyCfvs"
                  :readonly="!isConditionalFieldPopulated(field) || (field.conditionalOnId && loading) || field.ancillaryCustomFieldGroupAssignmentId !== null"
                  :field="field"
                  :show-field-name="false"
                  :list-of-value-filter="filters[field.customFieldId]"
                />
              </div>
            </div>
            <div class="configuration-save-container">
              <v-btn depressed
                     :disabled="dirtyCfvs.length === 0"
                     class="text-capitalize"
                     @click="resetToDefault"
              >
                Reset to Default
              </v-btn>
              <v-spacer />
              <v-btn color="primaryButton"
                     depressed
                     :dark="dirtyCfvs.length !== 0"
                     :disabled="dirtyCfvs.length === 0"
                     @click="validateForm()"
                     class="text-capitalize font-weight-bold"
              >
                Save and Reflect
              </v-btn>
            </div>
          </v-card>
        </v-col>
        <v-col cols="12" sm="8">
          <v-card class="proposal-container">
            <div class="proposal-container-header sticky-header">
              <div class="proposal-title">Proposal</div>
              <v-spacer/>
              <!--              <v-btn depressed-->
              <!--                     :disabled="dirtyCfvs.length === 0"-->
              <!--                     class="proposal-container-buttons text-capitalize font-weight-bold">Present-->
              <!--              </v-btn>-->
              <v-btn depressed
                     disabled
                     class="proposal-container-buttons text-capitalize font-weight-bold">
                Save Proposal
              </v-btn>
              <v-btn class="proposal-container-buttons text-capitalize font-weight-bold"
                     @click="downloadPdf">
                Download
              </v-btn>
            </div>
            <div>
              <proposal-template v-if="pages && pages.length > 0" :children="pages" :debug="false" :editable="false" />
            </div>
          </v-card>
        </v-col>
      </v-row>
    </v-form>
    <confirm-navigation-dialog ref="confirmDialog">
      <p>You still have unsaved changes are you sure you want to change?</p>
    </confirm-navigation-dialog>
  </v-container>
</template>

<script>

import {
  apiRequest,
  getRequest,
  getRequestWithParams,
  getSnackbar,
  handleHidingGlobalLoader,
  logError,
  postRequest
} from '@/helpers/helpers'
import { AppMutations } from '@/stores/AppStore'
import CustomValueInput from '@/views/flow/components/CustomValueInput'
import ProposalTemplate from '@/views/blueraven/settings/proposalDesigner/ProposalTemplate'
import { ProposalActions } from '@/views/blueraven/settings/proposalDesigner/store'
import ConfirmNavigationDialog from '@/views/blueraven/proposals/ConfirmNavigationDialog'
import { mapState } from 'vuex'

export default {
  name: 'Proposal',
  components: {
    CustomValueInput,
    ProposalTemplate,
    ConfirmNavigationDialog
  },
  data() {
    return {
      loading: false,
      proposalId: this.$route.params.proposalId,
      proposal: {
        customFieldGroups: []
      },
      dirtyCfvs: [],
      filters: {}
    }
  },
  created() {
    this.getProposalDetails()
    this.$store.dispatch(ProposalActions.FETCH_TEMPLATE_CONTEXT, { proposalId: this.proposalId })

    window.addEventListener('beforeunload', this.beforeWindowUnload)
  },
  beforeDestroy() {
    window.removeEventListener('beforeunload', this.beforeWindowUnload)
  },
  computed: {
    pages() {
      return this.template?.filter(x => x.parentId === undefined)
    },
    sortedCustomFieldGroups() {
      const customFieldGroups = [...this.proposal?.customFieldGroups]
      return customFieldGroups.sort((cfg1, cfg2) => {
        if (cfg1.groupOrder < cfg2.groupOrder) {
          return -1
        }
        if (cfg1.groupOrder > cfg2.groupOrder) {
          return 1
        }
        return 0
      })
    },
    ...mapState({
      template: (state) => state.proposal.template
    })
  },
  methods: {
    _showSnackbar(type, msg) {
      const snackbar = getSnackbar(type, msg)
      this.$store.commit(AppMutations.SHOW_SNACK, snackbar)
    },
    async getProposalDetails() {
      this.$store.commit(AppMutations.SET_LOADING, true)

      //reset cfvs
      this.dirtyCfvs = []

      try {
        const { data, status } = await getRequest(`/proposal/${this.proposalId}`, 'blueraven')
        this.proposal = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this._showSnackbar('ERROR', 'Error retrieving data')
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async resetToDefault() {
      await this.getProposalDetails()
      this.$refs.proposalForm.resetValidation()
    },
    validateForm() {
      //checks for required fields prior to opening the save dialog
      if (this.$refs.proposalForm.validate()) {
        this.saveCustomFieldValues()
      } else {
        this._showSnackbar('ERROR', 'Missing Required Fields')
      }
    },
    async saveCustomFieldValues() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)

        const { data, status } = await postRequest(`/proposal/${this.proposalId}`, this.dirtyCfvs, 'blueraven')
        this.proposal = data
        this.dirtyCfvs = []
        this._showSnackbar('SUCCESS', 'Fields Updated')
        await this.$store.dispatch(ProposalActions.FETCH_TEMPLATE_CONTEXT, { proposalId: this.proposalId })

        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this._showSnackbar('ERROR', 'Error Saving Fields')
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async populateDirtyCfvs(field, remove = false) {
      //some fields are for unique behavior and they dont need to be saved. this check should filter them out
      let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)

      if (match && remove) {
        //remove any from the array where the selected field is a marked as conditional field
        const removeIds = this.proposal?.customFieldGroups
          ?.map(cfg => cfg.customFieldValues)
          ?.flat()
          ?.filter(f => f.conditionalOnId === field.customFieldGroupAssignmentId)
          ?.map(f => f.customFieldGroupAssignmentId)

        removeIds.push(match.customFieldGroupAssignmentId)
        this.dirtyCfvs = this.dirtyCfvs.filter(x => !removeIds.includes(x.customFieldGroupAssignmentId))
      }

      if (!match) {
        this.dirtyCfvs.push(field)
      }
      await this.buildFilters(field)
    },
    async downloadPdf() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)

        const { data } = await apiRequest('blueraven', {
          method: 'get',
          url: `/proposal/${this.proposalId}/pdf`,
          responseType: 'blob'
        })

        if (data) {
          const pdfFile = URL.createObjectURL(new Blob([data], { type: 'application/pdf' }))
          const docUrl = document.createElement('a')
          docUrl.href = pdfFile
          docUrl.setAttribute('download', `proposal-${this.proposalId}.pdf`)
          document.body.appendChild(docUrl)
          docUrl.click()
          setTimeout(() => {
            docUrl.remove()
            URL.revokeObjectURL(pdfFile)
          }, 100)

          this._showSnackbar('INFO', 'Proposal Downloaded')
        }
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async buildFilters(field) {
      if (!field.hasListValues) {
        return
      }

      try {
        const selectedFieldValue = this.dirtyCfvs.find(cfv => cfv.customFieldId === field.customFieldId)?.intValue
        const conditionalOn = this.proposal?.customFieldGroups
          ?.map(cfg => cfg.customFieldValues)
          ?.flat()
          ?.filter(f => f?.conditionalOnId === field.customFieldGroupAssignmentId)

        if (conditionalOn.length > 0) {

          //clear out any already selected fields when data changes for conditional fields
          const existingFieldIds = conditionalOn.map(c => c.customFieldId)
          this.dirtyCfvs = this.dirtyCfvs.filter(cfv => !existingFieldIds.includes(cfv.customFieldId))

          this.loading = true
          const allFilters = conditionalOn.map(({ customFieldId, flowCustomFieldId }) => {

            //reset filter for customFieldId
            this.filters[customFieldId] = undefined

            if (selectedFieldValue != null) {
              const params = {
                targetFieldId: customFieldId,
                //used when the custom field ids don't match but are tied to the same backing flow custom field
                targetFlowCustomFieldId: flowCustomFieldId,
                parentFieldId: field.customFieldId,
                parentFieldValue: selectedFieldValue
              }

              return getRequestWithParams(`/proposal/${this.proposalId}/filter`, { params }, 'blueraven')
                .then(({ data }) => {
                  const { ids: filterValues } = data
                  this.filters[customFieldId] = (val) => filterValues?.indexOf(val?.id) > -1
                })
            }

            return Promise.resolve()
          })

          await Promise.all(allFilters)
        }
      } catch (e) {
        logError(e)
        const snackbar = getSnackbar('ERROR', e?.data?.message)
        this.$store.commit(AppMutations.SHOW_SNACK, snackbar)
      } finally {
        this.loading = false
      }
    },
    isConditionalFieldPopulated({ conditionalOnId }) {
      if (conditionalOnId === null || conditionalOnId === undefined) {
        return true
      }

      //does it come back from the server prepopulated
      const isPrepopulated = this.proposal?.customFieldGroups
        ?.map(cfg => cfg.customFieldValues)
        ?.flat()
        ?.find(f => f.customFieldGroupAssignmentId === conditionalOnId)
        ?.intValue !== undefined

      //has it been changed in this session
      const isDirtyCfv = this.dirtyCfvs.find(cfv => cfv.customFieldGroupAssignmentId === conditionalOnId) !== undefined
      return isDirtyCfv || isPrepopulated
    },
    beforeWindowUnload(e) {
      if (this.dirtyCfvs?.length > 0) {
        e.preventDefault()
        // Chrome requires returnValue to be set to anything -- it doesn't display it
        e.returnValue = ''
        return false
      }
    }
  },
  async beforeRouteLeave(to, from, next) {
    if (this.dirtyCfvs?.length > 0) {
      const confirmNavigation = await this.$refs.confirmDialog.open()
      return confirmNavigation ? next() : false
    }
    next()
  }
}
</script>

<style scoped lang="scss">
.new-proposal-header {
  font-size: 18px;
  font-weight: 700;
}

.proposal-container {
  padding: 24px;
  border-radius: 0;
}

.proposal-title {
  font-size: 14px;
  font-weight: 700;
  color: var(--v-blackText-base);
}

.configuration-group-title {
  font-size: 14px;
  font-weight: 700;
  color: #808588;
  margin-bottom: 16px;
}

.configuration-save-container {
  display: flex;
}

.proposal-container-header {
  display: flex;
  padding: 10px 0;
  margin-bottom: 24px;

  &.sticky-header {
    position: sticky;
    top: 0;
    background-color: white;
    padding: 10px;
    z-index: 200;
  }
}

.proposal-container-buttons {
  margin-left: 36px;
}
</style>
