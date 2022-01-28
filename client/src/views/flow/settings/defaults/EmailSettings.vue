<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Email Settings</v-toolbar-title>
        </v-toolbar>
      </v-col>
    </v-row>
    <v-form ref="emailSettingsForm" v-model="validForm">
      <v-col cols="12">
        <v-data-table
            :headers="headers"
            :items="emailValues"
            :items-per-page="-1"
            :mobile-breakpoint="0"
            hide-default-footer
            class="elevation-1 fix-column-width-bug square-card"
        >
          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">
                <v-text-field text
                              type="text"
                              v-if="index === editIndex"
                              v-model="item.senderName">
                </v-text-field>
                <div v-else>
                  {{item.senderName}}
                </div>
              </td>
              <td class="text-left">
                <v-text-field text
                              type="text"
                              v-if="index === editIndex"
                              v-model="item.emailAddress">
                </v-text-field>
                <div v-else>
                  {{ item.emailAddress }}
                </div>
              </td>
              <td>
                <v-icon v-show="item.isDefault" v-if="index !== editIndex" class="centered">mdi-check</v-icon>
                <v-checkbox v-if="index == editIndex" v-model="item.isDefault" label="Default"></v-checkbox>
              </td>
              <td>
                <v-btn small text @click="editIndex = index" v-if="index !== editIndex">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text v-if="index === editIndex">
                  <v-icon>save</v-icon>
                </v-btn>
                <v-btn small text @click="editIndex = null" v-if="index === editIndex">
                  cancel
                </v-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-form>
  </v-container>
</template>

<script>
import {getRequest, getSnackbar, handleHidingGlobalLoader} from "@/helpers/helpers";
import {AppMutations} from "@/stores/AppStore";

export default {
  name: "EmailSettings",

  data() {
    return {
      validForm: false,
      headers: [
        {text: 'Sender Name', value: 'name', show: true},
        {text: 'Email Address', value: 'value', show: true},
        {text: 'Default', value: 'isDefault', show: true},
        {text: null, value: 'icons', show: true}
      ],
      emailValues: [],
      companyId: this.$store.state.user.details.companyId,
      editIndex: null
    }
  },
  async created() {
    this.getEmailSenders()
  },
  methods: {
    async getEmailSenders() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/emailAddress`, null)
        this.emailValues = data;
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Email Addresses')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
}
</script>

<style scoped>

</style>
