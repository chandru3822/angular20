<template>
  <div>
    <v-menu
      v-model="menu"
      transition="slide-x-transition"
      :close-on-content-click="false"
      :offset-y="true"
      :z-index="250"
      :max-width="375"
    >
      <template #activator="{on, attrs }">
        <!--        TODO: kill overflow so you can't scroll while this is open -->
        <v-btn v-on="on" v-bind="attrs" :dark="!disabled" :disabled="disabled" color="primary" class="text-capitalize">
          Next Steps
        </v-btn>
      </template>

      <v-card class="pa-2">

        <v-list>
          <v-list-item three-line>
            <v-list-item-content>
              <v-list-item-title>Lock to Proceed</v-list-item-title>
              <span class="desc">
                Proposal needs to be locked before sending documents. Further edits to the proposal will not be possible after this.
              </span>

              <v-btn
                class="text-capitalize mt-1"
                :color="!proposal.locked ? 'primary' : ''"
                :disabled="proposal.locked"
                :dark="!proposal.locked"
                @click="lockProposal"
              >
                <v-icon v-if="!proposal.locked">mdi-lock-open</v-icon>
                <span v-if="!proposal.locked">Lock Proposal</span>

                <v-icon v-if="proposal.locked">mdi-lock</v-icon>
                <span v-if="proposal.locked">Proposal locked</span>
              </v-btn>
            </v-list-item-content>
          </v-list-item>

          <v-list-item>
            <v-list-item-content>
              <v-list-item-title>Check Credit</v-list-item-title>
              <stateful-btn
                class="text-capitalize mt-1"
                :loading="loadingCreditStatus"
                :successful="proposal.creditCheckSubmitted && isCreditApproved === true"
                :error="proposal.creditCheckSubmitted && isCreditApproved === false"
                :disabled="!proposal.locked"
                @click="submitCreditCheck"
              >
                Check Credit
              </stateful-btn>
              <div class="one-hunned text-center mt-1 desc" v-if="creditCheckErrorMsg">{{ creditCheckErrorMsg }}</div>
            </v-list-item-content>
          </v-list-item>

          <v-list-item>
            <v-list-item-content>
              <v-list-item-title>Send Documents</v-list-item-title>

              <v-form ref="docForm"
                      :disabled="!(isCreditApproved && proposal.locked)"
                      v-model="valid"
              >
                <v-text-field label="Email" v-model="docs.email" :rules="rules" required readonly disabled />

                <v-radio-group v-model="docs.language" required column :rules="rules">
                  <v-radio label="English" value="english" />
                  <v-radio label="Spanish" value="spanish" />
                </v-radio-group>

                <v-text-field label="Proposal #"
                              :value="proposal.proposalNbr"
                              :rules="rules"
                              required readonly disabled />
              </v-form>

              <stateful-btn
                class="text-capitalize"
                :successful="proposal.financeDocsSent"
                :disabled="!(isCreditApproved && proposal.locked && valid)"
                @click="sendDocs('FINANCE_DOCS')"
              >
                Send Finance Documents
              </stateful-btn>

              <stateful-btn
                class="text-capitalize mt-2"
                :successful="proposal.installationAgreementSent"
                :disabled="!(isCreditApproved && proposal.locked && valid)"
                @click="sendDocs('INSTALLATION_AGREEMENT')"
              >
                Send Installation Agreement
              </stateful-btn>

            </v-list-item-content>
          </v-list-item>
        </v-list>
      </v-card>
    </v-menu>

    <!--    TODO: form validation before going forward-->
    <confirm-dialog ref="confirmEmail">
      <template #title>Confirm Email</template>
      <v-container>
        <p>Is <strong>{{ proposal.email }}</strong> the correct email address?</p>
        <v-radio-group v-model="confirmEmail.isCorrectEmail">
          <v-radio label="Yes" :value="true" @click="confirmEmail.emailAddress= ''" />
          <v-radio label="No" :value="false" />
        </v-radio-group>

        <v-text-field v-if="confirmEmail.isCorrectEmail !== undefined && confirmEmail.isCorrectEmail === false"
                      v-model="confirmEmail.emailAddress"
                      placeholder="Enter correct email address"
                      :disabled="confirmEmail.isCorrectEmail" />
      </v-container>

      <template #actions="{ok, cancel}">
        <v-btn
          text
          @click="cancel(false)"
          class="text-capitalize"
        >
          Cancel
        </v-btn>
        <v-spacer />

        <v-btn
          color="primary"
          @click="ok({ email: confirmEmail.emailAddress || proposal.email, updated: !confirmEmail.isCorrectEmail })"
          class="text-capitalize"
          :disabled="!isEmailValid"
          :dark="isEmailValid"
        >
          Check Credit
        </v-btn>
      </template>
    </confirm-dialog>
  </div>
</template>
<script>
import StatefulBtn from '@/views/blueraven/proposals/StatefulBtn'
import ConfirmDialog from '@/views/blueraven/proposals/ConfirmDialog'
import { getRequest, logError, postRequest, putRequest } from '@/helpers/helpers'
import { AppMutations } from '@/stores/AppStore'
//TODO: only show credit check if the type requires it (ie. don't show for cash)
const DOCS_MESSAGE = {
  'FINANCE_DOCS': { key: 'financeDocsSent', message: 'Finance docs request submitted' },
  'INSTALLATION_AGREEMENT': { key: 'installationAgreementSent', message: 'Installation agreement request submitted' }
}

export default {
  components: { StatefulBtn, ConfirmDialog },
  props: {
    disabled: {
      type: Boolean,
      default: false
    },
    proposal: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      loadingCreditStatus: false,
      creditCheckIntervalId: undefined,
      creditCheckErrorMsg: undefined,
      valid: false,
      confirmEmail: {
        emailAddress: '',
        isCorrectEmail: undefined
      },
      docs: {
        email: this.proposal.email,
        language: undefined
      },
      menu: false,
      creditStatus: undefined,
      rules: [
        v => !!v || 'Value is required'
      ]
    }
  },
  async mounted() {
    // run check initially
    await this.checkCreditStatus()

    this.creditCheckIntervalId = setInterval(() => {
      //only run check when the modal is open
      if (!this.menu) {
        return
      }
      this.checkCreditStatus()
    }, 60 * 1000)
  },
  beforeDestroy() {
    clearInterval(this.creditCheckIntervalId)
    this.creditCheckIntervalId = undefined
  },
  computed: {
    isCreditApproved() {
      if (this.creditStatus === undefined) {
        return
      }
      return ['Approved', 'Pending', 'Funded'].includes(this.creditStatus)
    },
    isEmailValid() {
      if (this.confirmEmail.isCorrectEmail) {
        return true
      }
      return this.confirmEmail.emailAddress.trim().length > 0 && /.+@.+[.].+/.test(this.confirmEmail.emailAddress)
    }
  },
  methods: {
    async checkCreditStatus() {
      if (this.proposal.locked && this.proposal.creditCheckSubmitted && this.creditStatus === undefined) {
        try {
          this.creditCheckErrorMsg = undefined
          this.loadingCreditStatus = true
          const { data } = await getRequest(`/proposal/${this.proposal.id}/loanStatus`, 'blueraven')
          this.creditStatus = data?.status
          if (this.creditStatus) {
            clearInterval(this.creditCheckIntervalId)
            this.creditCheckIntervalId = undefined
          }
        } catch (e) {
          this.creditCheckErrorMsg = e?.data?.message
        } finally {
          this.loadingCreditStatus = false
        }
      }
    },

    async submitCreditCheck() {
      if (this.proposal.creditCheckSubmitted && this.isCreditApproved === undefined) {
        await this.checkCreditStatus()
        return
      }

      if (this.isCreditApproved !== undefined) {
        return
      }

      this.menu = false
      const { ok, value } = await this.$refs.confirmEmail.open()
      if (!ok) {
        return
      }
      if (value.email?.trim().length > 0 && value.updated) {
        const body = { email: value.email }
        try {
          await putRequest(`/install-agreement/updateEmailAddress/${this.proposal.projectId}`, body, 'blueraven')
        } catch (e) {
          this.$snackbar('ERROR', 'Error updating email')
          return
        }
      }

      try {
        const { data: creditUrl } = await getRequest(`/proposal/${this.proposal.id}/loanApplication`, 'blueraven')
        this.$emit('update', { ...this.proposal, creditCheckSubmitted: true })

        if (creditUrl && creditUrl !== 'Quote Updated') {
          open(creditUrl, '_blank')
        }
      } catch (e) {
        this.$snackbar('ERROR', e?.data.message || 'Error creating credit application')
      }
    },
    async lockProposal() {
      if (this.proposal.locked) {
        return
      }

      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const { data } = await postRequest(`/proposal/${this.proposal.id}/lock`, {}, 'blueraven')
        this.$snackbar('SUCCESS', 'Proposal locked')
        this.$emit('update', data)
      } catch (e) {
        this.$snackbar('ERROR', e?.data?.message)
        logError(e)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async sendDocs(docType) {
      if (!(this.isCreditApproved && this.proposal.locked && this.valid)) {
        return
      }

      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const { data = {} } = await postRequest(`/proposal/${this.proposal.id}/sendDocs`,
          {
            docType,
            isSpanish: this.docs.language === 'spanish'
          }, 'blueraven')

        const { success, message } = data
        if (success) {
          const msg = DOCS_MESSAGE[docType]
          this.$snackbar('SUCCESS', msg.message)
          this.$emit('update', { ...this.proposal, [msg.key]: true })
        } else {
          this.$snackbar('ERROR', message)
        }
      } catch (e) {
        logError(e)
        this.$snackbar('ERROR', e?.data?.message)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
}
</script>
<style scoped lang="scss">
.desc {
  font-size: 0.875rem;
  line-height: 1.2;
  color: rgba(0, 0, 0, 0.6);
}
</style>
