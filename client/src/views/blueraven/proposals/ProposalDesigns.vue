<template>
  <v-container id="proposals-container">
    <v-row>
      <v-col cols="12">
        <router-link :to="`/proposals`">Back</router-link>
        <div class="project-title">
          {{ project.projectName }}
        </div>
        <div class="project-subtitle">
          Project ID: <router-link :to="`/project/${project.id}`">{{project.id}}</router-link> <br/>
          Address: {{ project.street1 }} - {{ project.city }}, {{project.state }} {{ project.postalCode }}
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
          <v-img name="designImg"
                 class="design-image"
                 src="https://media.istockphoto.com/photos/beautiful-luxury-home-exterior-at-twilight-picture-id1026205392?k=20&m=1026205392&s=612x612&w=0&h=lYFMV5cOuQQpddmwsE5QLBCyhgWQ1OI46i_dalro9OE="></v-img>
          <div class="mt-3 design-details">
            Created: {{d.dateCreated | formatDate('date', 'MMM D, YYYY') }}
          </div>
          <v-btn color="primaryCustom" dark class="mt-3 one-hunned" @click="addProposal(d)">
            Create new proposal
          </v-btn>
            <v-list v-if="d.proposals.length > 0">
              <v-list-item v-for="(proposal, index) in d.proposals.slice((d.offset * numberToDisplay),(numberToDisplay + (d.offset * numberToDisplay)))" :key="index"
                           class="proposal-container"
                           @click="$router.push({name: 'proposal', params: {proposalId: proposal.id}})">
                <v-list-item-title>Proposal {{proposal.id}}</v-list-item-title>
                <v-list-item-subtitle>{{proposal.dateCreated | formatDate('date')}}</v-list-item-subtitle>
              </v-list-item>
            </v-list>
          <div v-else>No Proposals Available</div>
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
          <div style="position:absolute; top: 0">PPS_ID: {{d.projectProcessStepId}} (temp for testing)</div>
        </v-card>
    </v-row>
  </v-container>
</template>

<script>

  import {handleHidingGlobalLoader, logError, getRequest, postRequest, formatPhoneNumber} from '@/helpers/helpers'
  import {AppMutations} from "@/stores/AppStore";

  export default {
    name: "ProposalDesigns",
    data () {
      return {
        designs: [],
        offset: 0,
        numberToDisplay: 3,
        project: {},
        projectId: this.$route.params.projectId,
        formatPhoneNumber
      }
    },
    created() {
      this.getProposalProject()
      this.getProposalDesigns()
    },
    methods: {
      disableAddSlice(proposalCount, offset) {
        let pageCount = (Math.floor(proposalCount / this.numberToDisplay))
        let dividesEqually = proposalCount % this.numberToDisplay === 0
        if(dividesEqually) {
          pageCount--
        }
        return pageCount === offset
      },
      async getProposalProject () {
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
      async getProposalDesigns () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/proposal/designs/${this.projectId}`, 'blueraven', [])
          this.designs = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          logError(e)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addProposal (design) {
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
}
.design-image {
  height: 170px;
  width: 323px;
  border-radius: 0 !important;
}
.design-details {
  color: #808588;
  font-size: 12px;
}
.proposal-container {
  height: 71px;
}
.slice-selectors {
  position: absolute;
  bottom: 0;
  width: calc(100% - 20px);
  text-align: center;
}
</style>
