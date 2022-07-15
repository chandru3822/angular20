<template>
  <v-container id="proposals-container">
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
          <v-card class="configuration-container square-card">
            <div>
              <div class="configuration-title">Configurations</div>
              <v-card
                flat
                class="pt-0"
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
              </v-card>
            </div>
            <div class="configuration-save-container">
              <v-btn depressed
                     :disabled="dirtyCfvs.length === 0"
                     class="text-capitalize font-weight-bold"
              >
                Reset to Default
              </v-btn>
              <!--todo: above button requires @click and accompanying function-->
              <!--todo: fix disabled logic-->
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
          <v-card class="proposal-container square-card">
            <div class="proposal-container-header">
              <div class="configuration-title">Proposal</div>
              <v-spacer></v-spacer>
              <v-btn depressed
                     :disabled="dirtyCfvs.length === 0"
                     class="proposal-container-buttons text-capitalize font-weight-bold">Present
              </v-btn>
              <!--todo: above button requires @click and accompanying function-->
              <!--todo: fix disabled logic-->
              <v-btn depressed
                     :disabled="dirtyCfvs.length === 0"
                     class="proposal-container-buttons text-capitalize font-weight-bold">Save Proposal
              </v-btn>
              <!--todo: above button requires @click and accompanying function-->
              <v-btn class="proposal-container-buttons text-capitalize font-weight-bold"
                     @click="downloadPdf">
                Download
              </v-btn>
              <!--todo: above button requires @click and accompanying function-->
              <!--todo: fix disabled logic-->
            </div>
            <div class="proposal-container">
              <proposal-template v-if="pages && pages.length > 0" :children="pages" :debug="false" :editable="false" />
            </div>
          </v-card>
        </v-col>
      </v-row>
    </v-form>
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
import { mapState } from 'vuex'

export default {
  name: 'Proposal',
  components: {
    CustomValueInput,
    ProposalTemplate
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
    async getProposalDetails() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const { data, status } = await getRequest(`/proposal/${this.proposalId}`, 'blueraven')
        this.proposal = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    validateForm() {
      //checks for required fields prior to opening the save dialog
      if (this.$refs.proposalForm.validate()) {
        this.saveCustomFieldValues()
      } else {
        this.snackbar = getSnackbar('ERROR', 'Missing Required Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async saveCustomFieldValues() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const { data, status } = await postRequest(`/proposal/${this.proposalId}`, this.dirtyCfvs, 'blueraven')
        this.proposal = data
        this.snackbar = getSnackbar('SUCCESS', 'Fields Updated')
        this.dirtyCfvs = []

        this.$store.dispatch(ProposalActions.FETCH_TEMPLATE_CONTEXT, { proposalId: this.proposalId })

        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
      return this.dirtyCfvs.find(cfv => cfv.customFieldGroupAssignmentId === conditionalOnId) !== undefined
    }
  }
}
</script>

<style scoped lang="scss">
@import "@/styles/main.scss";

.new-proposal-header {
  font-size: 18px;
  font-weight: 700;
}

::v-deep {
  .v-data-table__wrapper {
    height: calc(100vh - 290px);
    min-height: 300px;
  }
}

tr:nth-of-type(even) {
  @extend .shaded-row;
}

.configuration-container {
  position: relative;
  padding: 24px;
  //height: calc(100vh - 180px);
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.configuration-title {
  font-size: 14px;
  font-weight: 700;
  margin-bottom: 24px;
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

.proposal-container {
  padding: 28px;
}

.proposal-container-header {
  display: flex;
  align-items: baseline;
}

.proposal-container-buttons {
  margin-left: 36px;
  color: var(--v-blackText-base);
}

</style>

