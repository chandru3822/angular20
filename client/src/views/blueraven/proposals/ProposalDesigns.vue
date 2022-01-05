<template>
  <v-container id="proposals-container">
    <v-row>
      <v-col cols="12">
        <router-link :to="`/proposals`">Back</router-link>
        <div class="project-title">
          {{ project.projectName }}
        </div>
        <div class="project-subtitle">
          Project ID:
          <router-link :to="`/project/${project.id}`">{{ project.id }}</router-link>
          <br/>
          Address: {{ project.street1 }} - {{ project.city }}, {{ project.state }} {{ project.postalCode }}
          <br/>
          <span v-if="project.mobile">
            Phone: {{ formatPhoneNumber(project.mobile) }}
          </span>
        </div>
      </v-col>
    </v-row>
    <v-divider></v-divider>
    <v-toolbar flat color="transparent">
      <v-toolbar-title class="app-title">Designs and Proposals</v-toolbar-title>
    </v-toolbar>
    <v-row class="mx-2">
      <v-card v-for="(d, idx) in designs" :key="idx"
              width="355" height="535" class="pa-5 proposal-card">
        <div v-if="d.attachments.length > 0" style="position: relative;" class="design-image">
          <v-img name="designImg"
                 class="design-image"
                 :src="d.attachments[d.imageIndex].presignedUrl"></v-img>
          <div class="design-image image-selection-container" :style="{'justify-content': d.imageIndex === 0 ? 'end' : d.imageIndex !== 0 ? 'space-between' : ''}">
            <v-btn x-small v-if="d.imageIndex !== 0"
                   @click="d.imageIndex--"
                   color="black" fab class="image-selection-icon">
              <v-icon color="white">mdi-chevron-left</v-icon>
            </v-btn>
            <v-btn x-small v-if="d.imageIndex !== d.attachments.length - 1"
                   @click="d.imageIndex++"
                   color="black" fab class="image-selection-icon">
              <v-icon color="white">mdi-chevron-right</v-icon>
            </v-btn>
          </div>
        </div>
        <div v-else class="design-image no-image-placeholder">
          <v-icon size="50">mdi-home</v-icon>
        </div>
        <div class="mt-3 design-small-gray">
          Created: {{ d.dateCreated | formatDate('date', 'MMM D, YYYY') }}
        </div>
        <v-btn color="primaryCustom" dark class="mt-3 one-hunned" @click="addProposal(d)">
          Create new proposal
        </v-btn>
        <v-list v-if="d.proposals.length > 0">
          <v-list-item
            v-for="(proposal, index) in d.proposals.slice((d.offset * numberToDisplay),(numberToDisplay + (d.offset * numberToDisplay)))"
            :key="index" two-line
            class="proposal-container"
            @click="$router.push({name: 'proposal', params: {proposalId: proposal.id}})">
            <v-list-item-content>
              <v-list-item-title>Proposal {{ proposal.id }}</v-list-item-title>
              <v-list-item-subtitle class="design-small-gray">
                {{ proposal.dateCreated | formatDate('date', 'MMM D, YYYY') }}
              </v-list-item-subtitle>
            </v-list-item-content>
          </v-list-item>
        </v-list>
        <div class="mt-6 ml-4" v-else>No Proposals Available</div>
        <div class="slice-selectors" v-if="d.proposals.length > numberToDisplay">
          <v-btn text
                 :disabled="d.offset === 0"
                 @click="d.offset--">
            <v-icon>mdi-chevron-left</v-icon>
          </v-btn>
          <v-btn text
                 :disabled="disableAddSlice(d.proposals.length, d.offset)"
                 @click="d.offset++">
            <v-icon>mdi-chevron-right</v-icon>
          </v-btn>
        </div>
        <div style="position:absolute; top: 0">PPS_ID: {{ d.projectProcessStepId }} (temp for testing)</div>
      </v-card>
      <v-card width="355" height="535" class="proposal-card request-new"
          :class="{'disable-new': activeDesign && null != activeDesign.projectId}">
        <v-btn :disabled="activeDesign && null != activeDesign.projectId"
          text @click="showNewDesignRequestForm = true">
          <v-icon :size="60">add</v-icon>
        </v-btn>
        <div class="mt-5">
          Request New Design
        </div>
        <div class="request-new-details" v-if="activeDesign && null != activeDesign.projectId">
          Last Requested: {{activeDesign.dateCreated | formatDate('date')}} <br/>
          Current Status: {{activeDesign.companyProcessStepStatusType}}
        </div>
      </v-card>
    </v-row>
    <v-dialog width="500" v-model="showNewDesignRequestForm">
      <v-card>
        <v-card-title
          class="text-h5 grey lighten-2"
          primary-title
        >
          Request New design
        </v-card-title>

        <v-card-text class="pt-4">
          Describe your request (Required)
          <v-textarea required auto-grow filled
                      v-model="newDesignRequest.description">
          </v-textarea>

          <v-file-input
            dense
            class="mb-3"
            multiple
            :accept="acceptedFileTypes"
            ref="fileInput"
            hide-details
            label="Attach utility bill, notes/drawings for reference"
            @change="uploadFiles"
          />

          <DatetimePickerInput
            v-model="newDesignRequest.dueDate"
            :timezone="timezone"
            :type="'date'"
            :format="'MMMM DD, YYYY'"
            :min-date="minDate"
            label="Pick a due date and time (Required)"
          />

        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            color="primaryCustom"
            class="white--text"
            :disabled="!newDesignRequest.description || !newDesignRequest.dueDate"
            @click="requestNewDesign()">
            Request
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>

<script>

import {
  handleHidingGlobalLoader,
  logError,
  getRequest,
  postRequest,
  formatPhoneNumber
} from '@/helpers/helpers'
import {AppMutations} from "@/stores/AppStore";
import moment from 'moment'
import DatetimePickerInput from "@/components/DatetimePickerInput";
import constants from "@/helpers/constants";

export default {
  name: "ProposalDesigns",
  components: {
    DatetimePickerInput,
  },
  data() {
    return {
      designs: [],
      minDate: moment().format('YYYY-MM-DDTHH:mm:ssZ'),
      offset: 0,
      numberToDisplay: 3,
      newDesignRequest: {},
      acceptedFileTypes: constants.STANDARD_IMAGES_AND_DOCS,
      showNewDesignRequestForm: false,
      project: {},
      activeDesign: {},
      projectId: this.$route.params.projectId,
      timezone: this.$store.state.user.details.timezone?.value,
      formatPhoneNumber
    }
  },
  created() {
    this.getProposalProject()
    this.getCompletedProposalDesigns()
    this.getActiveDesign()
  },
  methods: {
    async requestNewDesign() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const formData = new FormData()
        formData.append('projectId', this.projectId);
        formData.append('description', this.newDesignRequest.description);
        formData.append('dueDate', this.newDesignRequest.dueDate);

        this.newDesignRequest?.attachments?.forEach(a => {
          formData.append('attachments', a);
        });

        const {data, status} = await postRequest(`/proposal/design`, formData, 'blueraven')
        //this endpoint returns all of the designs because adding a new one could possible remove (cancel) an existing one
        this.designs = data
        await this.getActiveDesign()
        this.newDesignRequest = {}
        this.showNewDesignRequestForm = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    disableAddSlice(proposalCount, offset) {
      let pageCount = (Math.floor(proposalCount / this.numberToDisplay))
      let dividesEqually = proposalCount % this.numberToDisplay === 0
      if (dividesEqually && pageCount !== 0) {
        pageCount--
      }
      return pageCount === offset
    },
    async getProposalProject() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/project/${this.projectId}`)
        this.project = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCompletedProposalDesigns() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/proposal/designs/${this.projectId}`, 'blueraven', [])
        this.designs = data
        //get the active one (there should only ever be one of these)
        this.activeDesign = data.find(d => d.processStepStatusTypeId === 1)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getActiveDesign() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/proposal/design/${this.projectId}/active`, 'blueraven', [])
        this.activeDesign = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async addProposal(design) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let params = {
          projectProcessStepId: design.projectProcessStepId
        }
        const {data, status} = await postRequest(`/proposal`, params, 'blueraven')
        this.$router.push({name: 'proposal', params: {proposalId: data.id}})
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    uploadFiles: function (files) {
      this.newDesignRequest.attachments = files
    },
  }
}
</script>

<style scoped lang="scss">
.project-title {
  font-size: 20px;
}

.project-subtitle {
  font-size: 15px;
}

.proposal-card {
  display: inline-block;
  margin-left: 10px;
  margin-right: 10px;
  position: relative;
  margin-bottom: 20px;
}

.design-image {
  height: 170px;
  width: 323px;
  border-radius: 0 !important;
}

.image-selection-icon {
  opacity: .6;
}

.image-selection-container {
  position: absolute;
  top: 0;
  left: 0;
  padding: 5px;
  display: flex;
  align-items: center;
}

.no-image-placeholder {
  text-align: center;
  display: flex;
  background-color: #dddddd;
  justify-content: center;
}

.design-small-gray {
  color: #808588;
  font-size: 12px;
}

.proposal-container {
  height: 71px;
}

.slice-selectors {
  position: absolute;
  bottom: 0;
  width: calc(100% - 40px);
  text-align: center;
}

.request-new {
  text-align: center;
  width: 100%;
  height: 100%;
  font-size: 18px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.request-new-details {
  margin-top: 16px;
  font-size: 12px;
}

.disable-new {
  color: #BDBDBD !important;
}
</style>
