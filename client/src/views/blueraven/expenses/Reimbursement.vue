<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">Reimbursement do after budgets and expenses cuz it requires those on backend</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[createNew = !createNew, newReimbursement = {}]">
              <v-icon>add</v-icon>
              New Reimbursement Request
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card flat v-if="createNew" class="pa-4">
          <h3>New Reimbursement Request</h3>
          <v-text-field text
                        type="text"
                        label="GL Code"
                        v-model="newReimbursement.code">
          </v-text-field>
          <v-text-field text
                        type="text"
                        label="Description"
                        v-model="newReimbursement.description">
          </v-text-field>
          <v-btn color="primaryCustom" dark class="white--text"
                 @click="submitReimbursementRequest()">
            Submit
          </v-btn>
          <v-btn class="ml-3" @click="[newReimbursement = {}, createNew = false]">
            Cancel
          </v-btn>
        </v-card>
        <v-divider v-if="createNew" ></v-divider>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

export default {
  name: 'GlCodes',

  computed: {},
  data() {
    return {
      snackbar: {},
      createNew: false,
      newReimbursement: {},
    }
  },
  created() {
  },
  methods: {
    async submitReimbursementRequest() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await postRequest(`/expenses/glCode`, item, 'blueraven')
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting GL Code')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
  }
}
</script>
