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
                          :rules="senderRequiredRule"
                          v-model="newEmail.senderName"
                          required
            >
            </v-text-field>
          </v-col>
          <v-col>
            <v-text-field text
                          type="text"
                          placeholder="Email Address"
                          :rules="emailRules"
                          v-model="newEmail.emailAddress"
                          required
            >
            </v-text-field>
          </v-col>
          <v-col>
            <v-checkbox v-model="newEmail.checked" :value="newEmail.isDefault" label="Default"></v-checkbox>
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
                              :ref="`senderName-edit-${item.id}`"
                              :rules="senderRequiredRule"
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
                              :ref="`emailAddress-edit-${item.id}`"
                              :rules="emailRules"
                              v-if="index === editIndex"
                              v-model="item.emailAddress">
                </v-text-field>
                <div v-else>
                  {{ item.emailAddress }}
                </div>
              </td>
              <td>
                <v-icon v-show="item.isDefault" v-if="index !== editIndex" class="centered">mdi-check</v-icon>
                <v-checkbox v-if="index == editIndex" v-model="item.checked" :value="item.isDefault" :disabled="item.isDefault" label="Default"></v-checkbox>
              </td>
              <td>
                <v-btn small text @click="editIndex = index" v-if="index !== editIndex">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text @click="updateEmailAddress(item)" :disabled="!isEditValid(item.id)" v-if="index === editIndex">
                  <v-icon>save</v-icon>
                </v-btn>
                <v-btn small text v-if="index === editIndex" @click="clearChanges()">
                  cancel
                </v-btn>
<!--todo: create delete confirmation dialog component to be used throughout the app-->
                <v-dialog
                    v-if="index !== editIndex"
                    v-model="item.deleteConfirm"
                    width="500">
                  <template #activator="{ on }">
                    <v-btn small text v-on="on" :disabled="item.isDefault">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </template>
                  <v-card>
                    <v-card-title
                        class="text-h5 grey lighten-2"
                        primary-title>
                      Confirm
                    </v-card-title>
                    <v-card-text>
                      Are you sure you want to delete this Email Address: <strong>{{ item.emailAddress }}</strong>?
                    </v-card-text>
                    <v-divider></v-divider>
                    <v-card-actions>
                      <v-spacer></v-spacer>
                      <v-btn
                          @click="item.deleteConfirm = false">
                        No
                      </v-btn>
                      <v-btn
                          color="primaryCustom"
                          text
                          @click="deleteEmailAddress(item)">
                        Yes
                      </v-btn>
                    </v-card-actions>
                  </v-card>
                </v-dialog>

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
import constants from "@/helpers/constants";

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
      newEmail: {},
      addNew: false,
      senderRequiredRule: [v => !!v || 'Sender name is required'],
      emailRules: constants.EMAIL_RULES,
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
        this.emailValues.map( email => email.checked = email.isDefault)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Email Addresses')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async clearChanges() {
      await this.getEmailSenders()
        this.editIndex = null
    },
    isEditValid(itemId){
      const senderNameRef = this.$refs[`senderName-edit-${itemId}`]
      const emailAddressRef = this.$refs[`emailAddress-edit-${itemId}`]
      if(senderNameRef && emailAddressRef){
        return senderNameRef.valid && emailAddressRef.valid
      } else if (senderNameRef && !emailAddressRef){
        return senderNameRef.valid
      } else if (!senderNameRef && emailAddressRef) {
        return emailAddressRef.valid
      } else {
        return false
      }
    },
    async updateEmailAddress(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        item.modifiedById = this.userId;
        item.companyId = this.companyId;
        const confirmChangeDefault = (item.checked !== item.isDefault)
        item.isDefault = item.checked;
        const {data, status} = await putRequestWithRequestParams('/emailAddress/updateEmailAddress', item, {updateDefault: confirmChangeDefault})
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
        const makeDefault = this.newEmail.checked || false
        this.newEmail.isDefault = makeDefault;
        this.newEmail.createdById = this.userId;
        this.newEmail.companyId=this.companyId;
        const {data, status} = await postRequestWithRequestParams('/emailAddress/saveEmailAddress', this.newEmail, {updateDefault: makeDefault})
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
        if(item.isDefault){
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
