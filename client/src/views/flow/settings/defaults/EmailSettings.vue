<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Email Settings</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text v-if="addNew" @click="addEmail()" :disabled="!addFormValid">
              <v-icon>save</v-icon>
            </v-btn>
            <v-btn text @click="[addNew = !addNew, newEmail = {}]">
              <span>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
      </v-col>
    </v-row>
    <v-col cols="12">
      <v-form v-if="addNew" ref="emailSettingsForm" v-model="addFormValid">
        <v-row>
          <v-col>
            <v-text-field text
                          type="text"
                          placeholder="Sender Name"
                          :rules="[v => !!v || 'Sender name is required']"
                          v-model="newEmail.senderName"
                          required
            >
            </v-text-field>
          </v-col>
          <v-col>
            <v-text-field text
                          type="text"
                          placeholder="Email Address"
                          :rules="[v => !!v || 'Email address is required']"
                          v-model="newEmail.emailAddress"
                          required
            >
            </v-text-field>
          </v-col>
          <v-col>
            <v-checkbox v-model="newEmail.isDefault" label="Default" @click="confirmChangeDefault = true"></v-checkbox>
          </v-col>
        </v-row>
      </v-form>
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
                <v-checkbox v-if="index == editIndex" v-model="item.isDefault" label="Default" @click="confirmChangeDefault = true"></v-checkbox>
              </td>
              <td>
                <v-btn small text @click="editIndex = index" v-if="index !== editIndex">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text @click="updateEmailAddress(item)" v-if="index === editIndex">
                  <v-icon>save</v-icon>
                </v-btn>
                <v-btn small text v-if="index === editIndex" @click="clearChangeToDefault(item)">
                  cancel
                </v-btn>
                <v-btn small text v-if="index !== editIndex" @click="deleteEmailAddress(item)" :disabled="item.isDefault"><v-icon>delete</v-icon></v-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>

  </v-container>
</template>

<script>
import {
  getRequest,
  putRequest,
  putRequestWithRequestParams,
  postRequestWithRequestParams,
  getSnackbar,
  handleHidingGlobalLoader
} from "@/helpers/helpers";
import {AppMutations} from "@/stores/AppStore";

export default {
  name: "EmailSettings",

  data() {
    return {
      addFormValid: false,
      headers: [
        {text: 'Sender Name', value: 'name', show: true},
        {text: 'Email Address', value: 'value', show: true},
        {text: 'Default', value: 'isDefault', show: true},
        {text: null, value: 'icons', show: true, sortable: false}
      ],
      emailValues: [],
      companyId: this.$store.state.user.details.companyId,
      userId: this.$store.state.user.details.id,
      editIndex: null,
      confirmChangeDefault: false,
      newEmail: {},
      addNew: false,
      displayErrors: false
    }
  },
  async created() {
    this.getEmailSenders()
  },
  methods: {
    async getEmailSenders() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/emailAddress/${this.companyId}`, null)
        this.emailValues = data;
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Email Addresses')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    clearChangeToDefault(item) {
      if(this.confirmChangeDefault){
        item.isDefault = !item.isDefault
        this.confirmChangeDefault = false
      }
      this.editIndex = null
    },
    async updateEmailAddress(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        item.modifiedById = this.userId;
        item.companyId = this.companyId;
        const {data, status} = await putRequestWithRequestParams('/emailAddress/updateEmailAddress', item, {updateDefault: this.confirmChangeDefault})
        this.emailValues = data;
        this.editIndex = null
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Email Address')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },

    async addEmail() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.$refs.emailSettingsForm.validate();
        if(!this.addFormValid) {
          throw {data: false};
        }
        this.newEmail.createdById = this.userId;
        this.newEmail.companyId=this.companyId;
        const {data, status} = await postRequestWithRequestParams('/emailAddress/saveEmailAddress', this.newEmail, {updateDefault: this.confirmChangeDefault})
        this.emailValues = data;
        this.newEmail = null;
        this.addNew = false;
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        if(e.data != false) {
          console.error('*** ERROR ***', e)
        }
        this.snackbar = getSnackbar('ERROR', 'Error Adding Email Address')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },

    async deleteEmailAddress(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        if(item.isDefault || this.confirmChangeDefault){
          throw {data: false}
        }
        item.modifiedById = this.userId;
        const {status} = await putRequest('/emailAddress/archiveEmailAddress', item)
        this.emailValues.splice(this.emailValues.indexOf(item), 1);//remove deleted address from list
        this.editIndex = null
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        if(e.data != false) {
          console.error('*** ERROR ***', e)
        }
        this.snackbar = getSnackbar('ERROR', 'Error Updating Email Address')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
}
</script>

<style scoped>

</style>
