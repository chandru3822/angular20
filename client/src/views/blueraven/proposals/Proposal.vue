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
          <v-spacer></v-spacer>
          <v-toolbar-items>

          </v-toolbar-items>
        </v-toolbar>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12" sm="4">
        <v-card class="configuration-container square-card">
          <div class="configuration-title">Configurations</div>
          <v-card
            flat
            class="pt-0"
            v-for="(cfg, index) in proposal.customFieldGroups"
            :key="index"
          >
            <div class="configuration-group-title">{{cfg.groupName}}</div>
            <CustomValueInput
              v-for="(field, idx) in cfg.customFieldValues"
              :key="idx"
              :callback="populateDirtyCfvs"
              :readonly="field.ancillaryCustomFieldGroupAssignmentId !== null"
              :field="field"
              :show-field-name="false"
            />
          </v-card>
          <div class="configuration-save-container">
            <v-btn color="primaryButton"
                   :dark="dirtyCfvs.length !== 0"
                   :disabled="dirtyCfvs.length === 0"
                   @click="saveCustomFieldValues">
              Save and Reflect
            </v-btn>
          </div>
        </v-card>
      </v-col>
      <v-col cols="12" sm="8">
        <v-card class="proposal-container square-card">
          proposal goes here
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
  data() {
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
    async getProposalDetails() {
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
    async saveCustomFieldValues() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await postRequest(`/proposal/${this.proposalId}`, this.dirtyCfvs, 'blueraven')
        this.proposal = data
        this.snackbar = getSnackbar('SUCCESS', 'Fields Updated')
        this.dirtyCfvs = []
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
  padding: 20px;
  height: calc(100vh - 180px);
}
.configuration-title {
  font-size: 14px;
  font-weight: 700;
  margin-bottom: 24px;
}
.configuration-group-title {
  font-size: 14px;
  font-weight: 700;
  color: #808588;
  margin-bottom: 16px;
}
.configuration-save-container {
  position: absolute;
  bottom: 10px;
  width: 100%;
  padding-right: 30px;
  text-align: right;
}

.proposal-container {
  padding: 20px;
  height: calc(100vh - 180px);
}
</style>

