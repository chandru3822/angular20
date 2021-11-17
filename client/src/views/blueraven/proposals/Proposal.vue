<template>
  <v-container id="proposals-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar class="elevation-1">
          <v-toolbar-title>Proposal Details Page</v-toolbar-title>
        </v-toolbar>

        we'll put the proposal details here<br/>
        Proposal ID: {{proposalId}}
      </v-col>
    </v-row>
  </v-container>
</template>

<script>

  import {logError, getRequest} from '@/helpers/helpers'
  import {AppMutations} from "@/stores/AppStore";

  export default {
    name: "Proposal",
    data () {
      return {
        proposalId: this.$route.params.proposalId,
        proposal: {}
      }
    },
    created() {
      this.getProposalDetails()
    },
    methods: {
      async getProposalDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/proposals/${this.proposalId}`, 'blueraven')
          this.proposal = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          logError(e)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>

<style scoped lang="scss">
  @import "@/styles/main.scss";

  ::v-deep {
    .v-data-table__wrapper {
      height: calc(100vh - 290px);
      min-height: 300px;
    }
  }

  tr:nth-of-type(even) {
    @extend .shaded-row;
  }
</style>
