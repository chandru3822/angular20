<template>
  <v-container id="proposals-container" v-if="proposalExists">

    <v-row>
      <v-col cols="12" class="py-0">
        <router-link v-if="proposal && proposal.projectId"
                     :to="`/proposalDesigns/${proposal.projectId}`">Back
        </router-link>

        <v-row align="center" justify="center" no-gutters>
          <v-col md="auto">
            <v-alert
              color="warning"
              dense
              tile
              :value="dirtyCfvs.length > 0"
              transition="scale-transition"
            >
              Changes haven't been reflected on proposal
            </v-alert>
          </v-col>
        </v-row>

        <v-toolbar dense flat color="transparent">
          <v-toolbar-title class="new-proposal-header">
            <editable-input :editable="!proposal.locked"
                            :display-text="proposal.displayName"
                            :value="defaultProposalName"
                            @input="handleNameChange" />

          </v-toolbar-title>
          <!--          <v-chip small color="brBlue" dark class="ml-2 text-uppercase">Primary</v-chip>-->
          <v-chip v-if="proposal.locked" small color="red" dark class="ml-2 text-uppercase">
            <v-icon small>mdi-lock</v-icon>
            Locked
          </v-chip>
          <v-spacer />
          <v-toolbar-items>
            <next-step-menu v-if="proposal.id"
                            :disabled="dirtyCfvs.length > 0"
                            :proposal="proposal"
                            @update="handleStepChange" />
          </v-toolbar-items>
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
                  :readonly="proposal.locked || !isConditionalFieldPopulated(field) || (field.conditionalOnId && loading) || field.ancillaryCustomFieldGroupAssignmentId !== null"
                  :field="field"
                  :show-field-name="false"
                  :list-of-value-filter="filters[field.customFieldId]"
                />
              </div>
            </div>
            <div class="configuration-save-container" v-if="!proposal.locked">
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
                Save
              </v-btn>
            </div>
          </v-card>
        </v-col>
        <v-col cols="12" sm="8">
          <v-card class="proposal-container">
            <div class="proposal-container-header sticky-header" :class="isIntersecting ? 'is-pinned' : ''"
                 v-intersect="{handler: onStickyHeader, options: { threshold: [1]}}">
              <v-alert
                class="text-center"
                v-if="isIntersecting"
                color="warning"
                dense
                tile
                :value="dirtyCfvs.length > 0"
                transition="scale-transition"
              >
                Changes haven't been reflected on proposal
              </v-alert>

              <div class="d-flex align-center">
                <div class="proposal-title">Proposal <span>#{{ proposal.proposalNbr }}</span></div>
                <v-spacer />
                <v-btn v-if="pages && pages.length"
                       class="proposal-container-buttons text-capitalize"
                       :disabled="dirtyCfvs.length > 0"
                       @click="duplicate">
                  Duplicate
                </v-btn>
                <v-btn v-if="pages && pages.length"
                       :disabled="dirtyCfvs.length > 0"
                       class="proposal-container-buttons text-capitalize"
                       @click="downloadPdf">
                  Download
                </v-btn>
              </div>
            </div>
            <div>
              <proposal-template v-if="pages && pages.length > 0"
                                 :children="pages"
                                 :debug="false"
                                 :editable="false" />
            </div>
          </v-card>
        </v-col>
      </v-row>
    </v-form>
    <confirm-dialog ref="confirmDialog" />
  </v-container>
</template>

<script>

import {
  apiRequest,
  getRequest,
  getRequestWithParams,
  handleHidingGlobalLoader,
  logError,
  postRequest
} from '@/helpers/helpers'
import { AppMutations } from '@/stores/AppStore'
import CustomValueInput from '@/views/flow/components/CustomValueInput'
import ProposalTemplate from '@/views/blueraven/settings/proposalDesigner/ProposalTemplate'
import { ProposalActions } from '@/views/blueraven/settings/proposalDesigner/store'
import ConfirmDialog from '@/views/blueraven/proposals/ConfirmDialog'
import NextStepMenu from '@/views/blueraven/proposals/NextStepMenu'
import EditableInput from '@/views/blueraven/proposals/EditableInput'
import { mapState } from 'vuex'

export default {
  name: 'Proposal',
  components: {
    CustomValueInput,
    ProposalTemplate,
    ConfirmDialog,
    NextStepMenu,
    EditableInput
  },
  data() {
    return {
      proposalExists: false,
      isIntersecting: false,
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
    defaultProposalName() {
      if (this.proposal?.name) {
        return this.proposal.name
      }
      return 'New Proposal'
    },
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
    onStickyHeader(entries) {
      const ratio = entries[0].intersectionRatio
      this.isIntersecting = ratio < 1
    },
    async handleNameChange({ save, value }) {
      const hasChanged = this.proposal?.name !== value
      this.proposal = { ...this.proposal, name: value }
      if (save && hasChanged) {
        try {
          const { data: proposal } = await postRequest(`/proposal/${this.proposalId}/name`, { name: value }, 'blueraven', {})
          this.proposal = proposal
        } catch (e) {
          this.$snackbar('ERROR', e?.data?.message || 'Error updating proposal name')
        }
      }
    },
    async getProposalDetails() {
      this.$store.commit(AppMutations.SET_LOADING, true)

      try {
        //assume the proposal exists
        this.proposalExists = true

        //reset cfvs
        this.dirtyCfvs = []

        const { data, status } = await getRequest(`/proposal/${this.proposalId}`, 'blueraven')
        this.proposal = data

        // build filters on load for any field with a conditional property
        const fields = this.proposal?.customFieldGroups
          ?.map(cfg => cfg.customFieldValues)
          ?.flat()

        const conditionalOnFields = fields
          ?.filter(f => f.conditionalOnId !== null)
          ?.map(f => f.conditionalOnId)

        fields
          ?.filter(f => conditionalOnFields.includes(f.customFieldGroupAssignmentId))
          ?.forEach(this.buildFilters)

        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.proposalExists = false
        this.$snackbar('ERROR', `Error retrieving proposal #${this.proposalId}`)
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
        this.$snackbar('ERROR', 'Missing Required Fields')
      }
    },
    async saveCustomFieldValues() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)

        const { data, status } = await postRequest(`/proposal/${this.proposalId}`, this.dirtyCfvs, 'blueraven')
        this.proposal = data
        this.dirtyCfvs = []
        this.$snackbar('SUCCESS', 'Proposal Updated')
        await this.$store.dispatch(ProposalActions.FETCH_TEMPLATE_CONTEXT, { proposalId: this.proposalId })

        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        const msg = e?.data?.message || 'Error Saving Proposal'
        this.$snackbar('ERROR', msg)
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
    async duplicate() {
      if (this.dirtyCfvs.length > 0) {
        return
      }

      try {
        const { data, status } = await postRequest(`/proposal/${this.proposalId}/duplicate`, {}, 'blueraven')
        if (data?.id) {
          const { href } = this.$router.resolve({
            name: 'proposal',
            params: { proposalId: data.id }
          })
          this.$snackbar('SUCCESS', `Duplicate proposal #${data?.proposalNbr} created in new tab. <br/> <a href="${href}">Click to open again</a>`, true)
          window.open(href, '_blank')
        }
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        this.$snackbar('ERROR', e?.data?.message || 'Error creating duplicate')

      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
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

          this.$snackbar('INFO', 'Proposal Downloaded')
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
        const fields = this.proposal?.customFieldGroups
          ?.map(cfg => cfg.customFieldValues)
          ?.flat()

        //value is either going to come from a local change
        const dirtyCfvValue = this.dirtyCfvs.find(cfv => cfv.customFieldId === field.customFieldId)?.intValue

        //or it's coming from the server
        const prePopulatedValue = fields.find(f => f.customFieldId === field.customFieldId)?.intValue

        //local changes take precedence over server
        const selectedFieldValue = dirtyCfvValue || prePopulatedValue || null

        const conditionalOn = fields?.filter(f => f?.conditionalOnId === field.customFieldGroupAssignmentId)

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
        this.$snackbar('ERROR', e?.data?.message)
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
    handleStepChange(updated) {
      this.proposal = { ...updated }
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
      const { ok } = await this.$refs.confirmDialog.open()
      return ok ? next() : false
    }
    next()
  }
}
</script>

<style scoped lang="scss">
.new-proposal-header {
  font-size: 18px;
  font-weight: 700;
  display: flex;
  align-items: center;
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
  padding: 10px 0;
  margin-bottom: 24px;

  &.sticky-header {
    position: sticky;
    top: -1px;
    background-color: white;
    padding: 10px;
    z-index: 200;

    &.is-pinned {
      border-bottom: 1px solid #ccc;
      box-shadow: 0 3px 2px 0 rgb(0 0 0 / 10%);
    }
  }
}

.proposal-container-buttons {
  margin-left: 36px;
}
</style>
