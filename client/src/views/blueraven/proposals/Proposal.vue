<template>
  <v-container id="proposals-container" v-if="proposalExists">
    <v-row>
      <v-col cols="12" class="py-0">
        <router-link
          v-if="proposal && proposal.projectId"
          :to="`/proposalDesigns/${proposal.projectId}`"
          >Back
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
            <editable-input
              :editable="!proposal.locked"
              :display-text="proposal.displayName"
              :value="defaultProposalName"
              @input="handleNameChange"
            />
          </v-toolbar-title>
          <v-chip
            v-if="proposal.locked"
            small
            color="error"
            dark
            class="ml-2 text-uppercase"
          >
            <v-icon small>mdi-lock</v-icon>
            Locked
          </v-chip>
          <v-spacer />
          <v-toolbar-items>
            <v-menu
              v-model="versionMenu"
              v-if="proposal && proposal.projectId"
              transition="slide-x-transition"
              :close-on-content-click="false"
              :offset-y="true"
              :z-index="250"
              :max-width="375"
            >
              <template #activator="{ on, attrs }">
                <v-btn
                  text
                  v-on="on"
                  v-bind="attrs"
                  :disabled="!userIsAdmin && !userCanManage"
                  @click="loadProposalVersions()"
                >
                  v.{{ proposal.version }}
                </v-btn>
              </template>
              <v-card flat color="white" class="pa-4" :elevation="0">
                <v-autocomplete
                  :items="versions"
                  item-value="id"
                  item-text="version"
                  :loading="loadingVersions"
                  hide-details
                  class="mt-0"
                  label="Select a version..."
                  v-model="proposal.proposalVersionId"
                />
                <v-btn
                  color="primary"
                  class="mt-3"
                  :disabled="
                    (!userIsAdmin && !userCanManage) ||
                    !proposal.proposalVersionId
                  "
                  @click="updateProposalVersion()"
                >
                  Save
                </v-btn>
              </v-card>
            </v-menu>
            <next-step-menu
              v-if="proposal.id"
              :disabled="dirtyCfvs.length > 0"
              :proposal="proposal"
              @update="handleStepChange"
            />
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
              <div v-for="(cfg, index) in sortedCustomFieldGroups" :key="index">
                <div class="configuration-group-title">{{ cfg.groupName }}</div>
                <div
                  class="cf-container"
                  v-for="(field, idx) in filterBy(cfg.customFieldValues, (f) =>
                    userHasWhiteListedPosition(f, 'hidden')
                  )"
                  :key="idx"
                >
                  <CustomValueInput
                    :required="field.required"
                    :callback="populateDirtyCfvs"
                    :readonly="
                      !canEdit ||
                      proposal.locked ||
                      !isConditionalFieldPopulated(field) ||
                      (field.conditionalOnId && loading) ||
                      !userHasWhiteListedPosition(field, 'readonly') ||
                      field.ancillaryCustomFieldGroupAssignmentId !== null
                    "
                    :field="field"
                    :show-field-name="false"
                    :list-of-value-filter="filters[field.customFieldId]"
                    :hint="getHint(field)"
                  />
                  <CommissionDetailsMenu
                    v-if="field.customFieldGroupAssignmentId === 454"
                    :custom-field-groups="sortedCustomFieldGroups"
                    :proposal-id="proposalId"
                  />
                </div>
              </div>
            </div>
            <div
              class="configuration-save-container"
              v-if="canEdit && !proposal.locked"
            >
              <v-btn
                depressed
                text
                color="primary"
                :disabled="dirtyCfvs.length === 0"
                class="text-capitalize"
                @click="resetToDefault"
              >
                Reset to Default
              </v-btn>
              <v-spacer />
              <v-btn
                color="primary"
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
          <v-card class="proposal-container" v-if="!hideProposalSection">
            <div
              class="proposal-container-header sticky-header"
              :class="isIntersecting ? 'is-pinned' : ''"
              v-intersect="{
                handler: onStickyHeader,
                options: { threshold: [1] }
              }"
            >
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
                <div class="proposal-title">
                  Proposal <span>#{{ proposal.proposalNbr }}</span>
                </div>
                <v-spacer />
                <v-btn
                  v-if="canEdit && !proposal.locked"
                  color="grey lighten-4"
                  class="proposal-container-buttons text-capitalize primary--text"
                  @click="deleteProposal"
                >
                  Delete
                </v-btn>
                <v-btn
                  v-if="canEdit && pages && pages.length"
                  color="grey lighten-4"
                  class="proposal-container-buttons text-capitalize primary--text"
                  :disabled="dirtyCfvs.length > 0"
                  @click="duplicate"
                >
                  Duplicate
                </v-btn>
                <v-btn
                  v-if="pages && pages.length"
                  color="grey lighten-4"
                  :disabled="dirtyCfvs.length > 0"
                  class="proposal-container-buttons text-capitalize primary--text"
                  @click="downloadPdf"
                >
                  Download
                </v-btn>
              </div>
            </div>
            <div class="proposal-zoom-lock" v-if="pages && pages.length > 0">
              <proposal-template
                :children="pages"
                :debug="false"
                :editable="false"
              />
            </div>
            <div v-else>
              <v-alert v-if="!templateLoading" prominent type="error">
                <v-row>
                  <v-col class="grow"> Error generating proposal </v-col>
                </v-row>
              </v-alert>
            </div>
          </v-card>
        </v-col>
      </v-row>
    </v-form>
    <confirm-dialog ref="confirmDialog" />
    <confirm-dialog ref="deleteConfirmDialog">
      <p>Are you sure you want to delete this proposal?</p>
    </confirm-dialog>
  </v-container>
  <v-container v-else>
    <v-alert prominent type="error">
      <v-row align="center">
        <v-col class="grow"> Proposal #{{ proposalId }} does not exist. </v-col>
        <v-col class="shrink">
          <router-link
            v-if="proposal && proposal.projectId"
            :to="`/proposalDesigns/${proposal.projectId}`"
            custom
            v-slot="{ href, route, navigate, isActive, isExactActive }"
          >
            <v-btn @click="navigate">Back to project</v-btn>
          </router-link>
        </v-col>
      </v-row>
    </v-alert>
  </v-container>
</template>

<script>
import {
  apiRequest,
  deleteRequest,
  getRequest,
  getRequestWithParams,
  handleHidingGlobalLoader,
  logError,
  postRequest,
  putRequest
} from '@/helpers/helpers'
import { AppMutations } from '@/stores/AppStore'
import CustomValueInput from '@/views/flow/components/CustomValueInput'
import ProposalTemplate from '@/views/blueraven/settings/proposalDesigner/ProposalTemplate'
import { ProposalActions } from '@/views/blueraven/settings/proposalDesigner/store'
import ConfirmDialog from '@/views/blueraven/proposals/ConfirmDialog'
import NextStepMenu from '@/views/blueraven/proposals/NextStepMenu'
import EditableInput from '@/views/blueraven/proposals/EditableInput'
import { mapState } from 'vuex'
import Vue2Filters from 'vue2-filters'
import CommissionDetailsMenu from '@/views/blueraven/proposals/CommissionDetailsMenu.vue'
import ResidualDetailModal from '@/views/blueraven/commissionManagement/ResidualDetailModal.vue'

const { VITE_HIDE_PROPOSAL } = import.meta.env

const autoSelectFieldIds = [407, 102, 81]

const USD = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD'
})

export default {
  name: 'Proposal',
  mixins: [Vue2Filters.mixin],
  components: {
    ResidualDetailModal,
    CommissionDetailsMenu,
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
      hideProposalSection: VITE_HIDE_PROPOSAL || false,
      userIsAdmin: this.$store.getters.userHasFeatureAccessLevel(
        'PROPOSALS',
        'ADMIN'
      ),
      userCanManage: this.$store.getters.userHasFeatureAccessLevel(
        'PROPOSALS',
        'MANAGE'
      ),
      proposalId: parseInt(this.$route.params.proposalId),
      versionMenu: false,
      loadingVersions: true,
      versions: [],
      proposal: {
        customFieldGroups: []
      },
      dirtyCfvs: [],
      filters: {}
    }
  },
  provide() {
    return {
      editor: undefined
    }
  },
  created() {
    this.getProposalDetails()
    this.$store.dispatch(ProposalActions.FETCH_TEMPLATE_CONTEXT, {
      proposalId: this.proposalId
    })
    window.addEventListener('beforeunload', this.beforeWindowUnload)
  },
  beforeDestroy() {
    window.removeEventListener('beforeunload', this.beforeWindowUnload)
  },
  computed: {
    canEdit() {
      const hasAdmin = this.$store.getters.userHasFeatureAccessLevel(
        'PROPOSALS',
        'ADMIN'
      )
      const hasEdit = this.$store.getters.userHasFeatureAccessLevel(
        'PROPOSALS',
        'EDIT'
      )
      return hasAdmin || hasEdit
    },
    defaultProposalName() {
      if (this.proposal?.name) {
        return this.proposal.name
      }
      return 'New Proposal'
    },
    pages() {
      return this.template?.filter((x) => x.parentId === undefined)
    },
    sortedCustomFieldGroups() {
      const customFieldGroups = [...(this?.proposal?.customFieldGroups ?? [])]
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
      template: (state) => state.proposal.template,
      templateLoading: (state) => state.proposal.loading
    })
  },
  methods: {
    getHint(field) {
      if (!field) {
        return undefined
      }

      if (field.customFieldGroupAssignmentId === 167) {
        const maxDiscountAmount = this.proposal.maxDiscountAmount
        if (maxDiscountAmount) {
          return `Max discount allowed is ${USD.format(
            this.proposal.maxDiscountAmount
          )}`
        }
      }
    },
    userHasWhiteListedPosition(cf, arg = 'readonly') {
      const wlAttr =
        arg === 'readonly'
          ? 'whiteListedPositions'
          : 'hiddenWhiteListedPositions'
      const prAttr =
        arg === 'readonly'
          ? 'customFieldGroupAssignmentReadOnly'
          : 'customFieldGroupAssignmentHidden'

      //field doesn't require a white listed position
      if (!cf[prAttr]) {
        return true
      }

      //positions required for user
      const positions = cf[wlAttr]?.map((wlp) => wlp.positionId) ?? []
      return this.$store.getters.userHasAnyPosition(positions)
    },
    onStickyHeader(entries) {
      const ratio = entries[0].intersectionRatio
      this.isIntersecting = ratio < 1
    },
    async handleNameChange({ save, value }) {
      const hasChanged = this.proposal?.name !== value
      this.proposal = { ...this.proposal, name: value }
      if (save && hasChanged) {
        try {
          const { data: proposal } = await postRequest(
            `/proposal/${this.proposalId}/name`,
            { name: value },
            'blueraven',
            {}
          )
          this.proposal = proposal
        } catch (e) {
          this.$snackbar(
            'ERROR',
            e?.data?.message || 'Error updating proposal name'
          )
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

        const { data, status } = await getRequest(
          `/proposal/${this.proposalId}`,
          'blueraven'
        )
        this.proposal = data

        // build filters on load for any field with a conditional property
        const fields = this.proposal?.customFieldGroups
          ?.map((cfg) => cfg.customFieldValues)
          ?.flat()

        const conditionalOnFields = fields
          ?.filter((f) => f.conditionalOnId !== null)
          ?.map((f) => f.conditionalOnId)

        const filters = fields
          ?.filter((f) =>
            conditionalOnFields.includes(f.customFieldGroupAssignmentId)
          )
          ?.map(this.buildFilters)

        //wait for all the filters to run initially
        await Promise.allSettled(filters)

        //preselect certain fields _after_ we've built the filters
        //todo order might matter at some point
        fields
          .filter((f) => autoSelectFieldIds.includes(f.customFieldId))
          .filter((f) => f.listOfValues?.length > 0)
          .filter((f) => f.intValue === null || f.intValue === undefined)
          .filter((f) => {
            //if we don't have a conditional field don't filter it out
            if (!f.conditionalOnId) {
              return true
            }
            //if we do we need to have a value set
            return fields
              ?.filter(
                (x) => x?.customFieldGroupAssignmentId === f.conditionalOnId
              )
              ?.every((x) => x.intValue !== null)
          })
          .forEach((field) => {
            const filter = this.filters[field.customFieldId]
            const listOfValues = filter
              ? field.listOfValues.filter(filter)
              : field.listOfValues
            const initialValue = listOfValues[0]

            //only pre-select if we have one option available
            if (listOfValues.length === 1 && initialValue) {
              field.intValue = initialValue.id
              this.populateDirtyCfvs(field)
            }
          })

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
    async loadProposalVersions() {
      try {
        this.loadingVersions = true
        const { data } = await getRequest(
          `/proposal/versions?published=true&size=50&page=0`,
          'blueraven'
        )
        this.versions = data.content
      } catch (e) {
        this.$snackbar('ERROR', 'Error loading proposal versions')
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.loadingVersions = false
      }
    },
    async updateProposalVersion() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await putRequest(
          `/proposal/${this.proposalId}/version/${this.proposal.proposalVersionId}`,
          {},
          'blueraven'
        )
        //fully reload page due to implications of changing a proposals version
        //todo: probably should put in a v-dialog warning thing when they try to save
        window.location.reload()
      } catch (e) {
        this.$snackbar('ERROR', 'Error updating proposal versions')
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveCustomFieldValues() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)

        const { data, status } = await postRequest(
          `/proposal/${this.proposalId}`,
          this.dirtyCfvs,
          'blueraven'
        )
        this.proposal = data
        this.dirtyCfvs = []
        this.$snackbar('SUCCESS', 'Proposal Updated')
        await this.$store.dispatch(ProposalActions.FETCH_TEMPLATE_CONTEXT, {
          proposalId: this.proposalId
        })

        handleHidingGlobalLoader(this, status)
      } catch (e) {
        const msg = e?.data?.message || 'Error Saving Proposal'
        this.$snackbar('ERROR', msg)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async populateDirtyCfvs(field, remove = false) {
      //some fields are for unique behavior and they dont need to be saved. this check should filter them out
      let match = this.dirtyCfvs.find(
        (f) =>
          (null !== f.id && f.id === field.id) ||
          f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId
      )

      if (match && remove) {
        //remove any from the array where the selected field is a marked as conditional field
        const removeIds = this.proposal?.customFieldGroups
          ?.flatMap((cfg) => cfg.customFieldValues)
          ?.filter(
            (f) => f.conditionalOnId === field.customFieldGroupAssignmentId
          )
          ?.map((f) => f.customFieldGroupAssignmentId)

        removeIds.push(match.customFieldGroupAssignmentId)
        this.dirtyCfvs = this.dirtyCfvs.filter(
          (x) => !removeIds.includes(x.customFieldGroupAssignmentId)
        )
      }

      if (!match) {
        this.dirtyCfvs.push(field)
      }
      await this.buildFilters(field)
    },

    async deleteProposal() {
      try {
        const { ok } = await this.$refs.deleteConfirmDialog.open()
        if (!ok) {
          return
        }

        const { status } = await deleteRequest(
          `/proposal/${this.proposalId}`,
          'blueraven'
        )
        this.proposalExists = false
        this.$snackbar(
          'SUCCESS',
          `Deleted proposal #${this?.proposal?.proposalNbr}`
        )
        handleHidingGlobalLoader(this, status)
        await this.$router.push({
          name: 'proposalDesigns',
          params: { projectId: this?.proposal?.projectId }
        })
      } catch (e) {
        this.$snackbar('ERROR', e?.data?.message || 'Error deleting proposal')
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async duplicate() {
      if (this.dirtyCfvs.length > 0) {
        return
      }

      try {
        const { data, status } = await postRequest(
          `/proposal/${this.proposalId}/duplicate`,
          {},
          'blueraven'
        )
        if (data?.id) {
          const { href } = this.$router.resolve({
            name: 'proposal',
            params: { proposalId: data.id }
          })
          this.$snackbar(
            'SUCCESS',
            `Duplicate proposal #${data?.proposalNbr} created in new tab. <br/> <a href="${href}">Click to open again</a>`,
            true
          )
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

        const { data, headers } = await apiRequest('blueraven', {
          method: 'get',
          url: `/proposal/${this.proposalId}/pdf`,
          responseType: 'blob'
        })
        const contentDisposition = headers['content-disposition']
        const filename = contentDisposition
          .substring(contentDisposition.indexOf('filename=') + 9)
          .replace(/['"]+/g, '')

        if (data) {
          const pdfFile = URL.createObjectURL(
            new Blob([data], { type: 'application/pdf' })
          )
          const docUrl = document.createElement('a')
          docUrl.href = pdfFile
          docUrl.setAttribute('download', filename)
          document.body.appendChild(docUrl)
          docUrl.click()
          setTimeout(() => {
            docUrl.remove()
            URL.revokeObjectURL(pdfFile)
          }, 100)

          this.$snackbar('SUCCESS', 'Proposal Downloaded')
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
        const fields = this.proposal?.customFieldGroups?.flatMap(
          (cfg) => cfg.customFieldValues
        )

        //value is either going to come from a local change
        const dirtyCfvValue = this.dirtyCfvs.find(
          (cfv) => cfv.customFieldId === field.customFieldId
        )?.intValue

        //or it's coming from the server
        const prePopulatedValue = fields.find(
          (f) => f.customFieldId === field.customFieldId
        )?.intValue

        //local changes take precedence over server
        const selectedFieldValue = dirtyCfvValue || prePopulatedValue || null

        const conditionalOn = fields?.filter(
          (f) => f?.conditionalOnId === field.customFieldGroupAssignmentId
        )

        if (conditionalOn.length > 0) {
          //clear out any already selected fields when data changes for conditional fields
          //unless there was already a saved value then we still need to clear it out
          const existingFieldIds = conditionalOn.map((c) => c.customFieldId)
          this.dirtyCfvs = this.dirtyCfvs.filter(
            (cfv) =>
              !existingFieldIds.includes(cfv.customFieldId) || cfv.id != null
          )

          this.loading = true
          const allFilters = conditionalOn.map(
            ({ customFieldId, flowCustomFieldId }) => {
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

                return getRequestWithParams(
                  `/proposal/${this.proposalId}/filter`,
                  { params },
                  'blueraven'
                ).then(({ data }) => {
                  const { ids: filterValues } = data
                  this.filters[customFieldId] = (val) =>
                    filterValues?.indexOf(val?.id) > -1

                  conditionalOn.forEach((c) => {
                    if (
                      c.customFieldId === customFieldId &&
                      c.intValue != null &&
                      !filterValues.includes(c.intValue)
                    ) {
                      //if one of the conditional fields has a selected value that is now an unavailable value, unset it and add to dirty fields
                      c.intValue = null
                      const match = this.dirtyCfvs.find(
                        (f) =>
                          null !== f.customFieldId &&
                          f.customFieldId === customFieldId
                      )
                      if (!match) {
                        this.dirtyCfvs.push(c)
                      }
                    }
                  })
                })
              }

              return Promise.resolve()
            }
          )

          await Promise.allSettled(allFilters)
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

      const cfg = this.proposal?.customFieldGroups
        ?.map((cfg) => cfg.customFieldValues)
        ?.flat()
        ?.find((f) => f.customFieldGroupAssignmentId === conditionalOnId)

      //does it come back from the server prepopulated
      const isPrepopulated =
        cfg?.intValue !== undefined && cfg?.intValue !== null

      //has it been changed in this session
      const dirtyCfv = this.dirtyCfvs.find(
        (cfv) => cfv.customFieldGroupAssignmentId === conditionalOnId
      )
      if (dirtyCfv !== undefined) {
        return dirtyCfv.intValue !== null
      }
      return isPrepopulated
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

//this is to make the button on the desired commission field align properly without screwing everything else up
.cf-container {
  display: flex;
  align-items: center;
}

.cf-container div {
  width: 100%;
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

//TODO: need to fix this
.proposal-zoom-lock {
  --scale: 0.75;
  transform: scale(var(--scale));
  transform-origin: top left;

  @media (min-width: 1500px) {
    transform-origin: top center;
  }
}
</style>
