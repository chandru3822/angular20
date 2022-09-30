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
                :successful="proposal.creditCheckSubmitted"
                :disabled="!(proposal.locked && isCreditCheckRequired)"
                @click="submitCreditCheck"
              >
                Check Credit
              </stateful-btn>
            </v-list-item-content>
          </v-list-item>

          <v-list-item>
            <v-list-item-content>
              <v-list-item-title>Send Documents</v-list-item-title>

              <v-form ref="docForm"
                      :disabled="!proposal.locked"
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
                :disabled="!(proposal.locked && valid && isCreditCheckRequired)"
                @click="sendDocs('FINANCE_DOCS')"
              >
                Send Finance Documents
              </stateful-btn>

              <stateful-btn
                class="text-capitalize mt-2"
                :successful="proposal.installationAgreementSent"
                :disabled="!(proposal.locked && valid)"
                @click="sendDocs('INSTALLATION_AGREEMENT')"
              >
                Send Installation Agreement
              </stateful-btn>

            </v-list-item-content>
          </v-list-item>
        </v-list>
      </v-card>
    </v-menu>

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
  computed: {
    isCreditCheckRequired() {
      // find financial field custom group
      const cfv = this.proposal.customFieldGroups.find(x => x.id === 27)?.customFieldValues?.find(x => x.customFieldId === 128)
      // find custom field value for "Financial Product"
      const financialProduct = cfv.listOfValues?.find(x => x.id === cfv.intValue)
      // does the name have "cash" (probably need a better way of handling this at some point)
      return financialProduct?.name?.toLowerCase().indexOf('cash') > -1
    },
    isEmailValid() {
      if (this.confirmEmail.isCorrectEmail) {
        return true
      }
      return this.confirmEmail.emailAddress.trim().length > 0 && /.+@.+[.].+/.test(this.confirmEmail.emailAddress)
    }
  },
  methods: {
    async submitCreditCheck() {
      if (this.proposal.creditCheckSubmitted) {
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
        const { status, data } = await getRequest(`/proposal/${this.proposal.id}/loanApplication`, 'blueraven')
        if (status !== 200) {
          this.$snackbar('ERROR', data?.message || 'Error creating credit application')
          return
        }

        this.$emit('update', { ...this.proposal, creditCheckSubmitted: true })

        if (data && data !== 'Quote Updated') {
          open(data, '_blank')
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
      if (!(this.proposal.locked && this.valid)) {
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
