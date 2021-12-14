<template>
  <v-container id="proposals-container">
    <v-row>
      <v-col cols="12">
        <router-link v-if="proposal && proposal.projectId"
                     :to="`/proposalDesigns/${proposal.projectId}`">Back</router-link>
        <v-toolbar class="elevation-1">
          <v-toolbar-title>Proposal Details Page</v-toolbar-title>
        </v-toolbar>

        we'll put the proposal details here<br/>
        Proposal ID: {{proposalId}}
        <v-btn color="primaryButton"
               :dark="dirtyCfvs.length !== 0"
               :disabled="dirtyCfvs.length === 0"
               @click="saveCustomFieldValues">
          Save
        </v-btn>
      </v-col>

      <v-col
        class="pt-0"
        v-for="(cfg, index) in proposal.customFieldGroups"
        :key="index"
      >
        <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar">
          <v-toolbar-title>
            {{cfg.groupName}}
          </v-toolbar-title>
        </v-toolbar>
        <v-card class="pa-3">
          <CustomValueInput
            v-for="(field, idx) in cfg.customFieldValues"
            :key="idx"
            :callback="populateDirtyCfvs"
            :readonly="field.ancillaryCustomFieldGroupAssignmentId !== null"
            :field="field"
          />
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>

import {handleHidingGlobalLoader, logError, getRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import {AppMutations} from "@/stores/AppStore";
  import CustomValueInput from '@/views/flow/components/CustomValueInput'

  export default {
    name: "Proposal",
    components: {
      CustomValueInput
    },
    data () {
      return {
        proposalId: this.$route.params.proposalId,
        proposal: {
          customFieldGroups: []
        },
        dirtyCfvs: []
      }
    },
    created() {
      this.getProposalDetails()
    },
    methods: {
      async getProposalDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/proposal/${this.proposalId}`, 'blueraven')
          this.proposal = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveCustomFieldValues () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await postRequest(`/proposal/${this.proposalId}`, this.dirtyCfvs, 'blueraven')
          this.proposal = data
          this.snackbar = getSnackbar('SUCCESS', 'Fields Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Fields')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      populateDirtyCfvs(field) {
        //some fields are for unique behavior and they dont need to be saved. this check should filter them out
        let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
        if (!match) {
          this.dirtyCfvs.push(field)
        }
      }
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
