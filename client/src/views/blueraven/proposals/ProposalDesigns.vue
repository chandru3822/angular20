<template>
  <v-container id="proposals-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar class="elevation-1 mb-3">
          <v-toolbar-title>Designs </v-toolbar-title>
        </v-toolbar>

        <v-card v-for="(d, idx) in designs" :key="idx"
          width="300" height="300" class="pa-5">
          <v-icon>house</v-icon>
          PPS_ID: {{d.projectProcessStepId}}
            <v-list v-if="d.proposals.length > 0">
              <v-list-item v-for="(proposal, index) in d.proposals" :key="index"
                           @click="$router.push({name: 'proposal', params: {proposalId: proposal.id}})">
                <v-list-item-title>{{proposal.id}}</v-list-item-title>
              </v-list-item>
            </v-list>
          <div v-else>No Proposals Available</div>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>

  import {handleHidingGlobalLoader, logError, getRequest} from '@/helpers/helpers'
  import {AppMutations} from "@/stores/AppStore";

  export default {
    name: "ProposalDesigns",
    data () {
      return {
        designs: [],
        projectId: this.$route.params.projectId
      }
    },
    created() {
      this.getProposalDesigns()
    },
    methods: {
      async getProposalDesigns () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/proposal/designs/${this.projectId}`, 'blueraven')
          this.designs = data
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

</style>
