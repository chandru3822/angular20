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
        <v-btn v-on="on" v-bind="attrs" dark color="primary" class="text-capitalize">Next Steps</v-btn>
      </template>

      <v-card>

        <v-list>
          <v-list-item>
            <v-list-item-content>
              <v-list-item-title>Check Credit</v-list-item-title>
              <stateful-btn
                :successful="isCreditCompleted"
                @click="submitCredit"
              >
                Submit Credit
              </stateful-btn>
            </v-list-item-content>
          </v-list-item>
          <v-list-item>
            <v-list-item-content>
              <v-list-item-title>Send Documents</v-list-item-title>

              <v-form ref="docForm"
                      :disabled="!isCreditCompleted"
                      v-model="valid"
              >
                <v-text-field
                  label="Name"
                  v-model="docs.name"
                  :rules="rules"
                  required
                />
                <v-text-field
                  label="Email"
                  v-model="docs.email"
                  :rules="rules"
                  required
                />
                <v-text-field
                  label="Mobile"
                  v-model="docs.mobile"
                  :rules="rules"
                  required
                />
                <v-text-field
                  label="Language"
                  v-model="docs.language"
                  :rules="rules"
                  required
                />
                <v-text-field
                  label="Proposal #"
                  readonly
                  disabled
                />

              </v-form>

              <stateful-btn
                :successful="isSentLoanDocs"
                :disabled="!isCreditCompleted || !valid"
                @click="submitLoanDocs"
              >
                Send Loan Docs
              </stateful-btn>
              <stateful-btn
                :successful="isSentIADocs"
                :disabled="!isCreditCompleted || !valid"
                @click="submitIADocs"
              >
                Send IA Docs
              </stateful-btn>
            </v-list-item-content>
          </v-list-item>
        </v-list>
      </v-card>
    </v-menu>
  </div>
</template>
<script>
import StatefulBtn from '@/views/blueraven/proposals/StatefulBtn'

export default {
  components: { StatefulBtn },
  data() {
    return {
      valid: false,
      docs: {
        name: null,
        email: undefined,
        mobile: undefined,
        language: undefined
      },
      menu: false,
      isCreditCompleted: false,
      isSentIADocs: false,
      isSentLoanDocs: false,
      rules: [
        v => !!v || 'Value is required'
      ]
    }
  },
  methods: {
    submitCredit() {
      this.isCreditCompleted = !this.isCreditCompleted
    },
    submitIADocs() {
      this.isSentIADocs = !this.isSentIADocs
    },
    submitLoanDocs() {
      this.isSentLoanDocs = !this.isSentLoanDocs
    }
  }
}
</script>
