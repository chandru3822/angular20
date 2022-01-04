<template>
  <v-container class="pa-0" id="numbers-container">
    <v-row>
      <v-col class="pt-0">
        <v-toolbar flat>
          <v-toolbar-title>
            Phone Numbers
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text v-if="userCanAdd" @click="[addNumber = !addNumber, newNumber = '']">
              <v-icon v-if="addNumber">remove</v-icon>
              <v-icon v-else>add</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addNumber" class="square-card text-left pa-5">
          <v-text-field text
                        label="Phone Number"
                        counter
                        type="number"
                        maxlength="20"
                        v-model="newNumber">
          </v-text-field>
          <div class="error-text mb-3" v-if="showError">{{errorMsg}}</div>
          <v-btn color="primaryCustom" class="mr-3 white--text" @click="addNumberToGroup()"
                 :disabled="!newNumber">
            Add
          </v-btn>
        </v-card>
        <v-divider v-if="addNumber"></v-divider>
        <v-card-title class="pt-0">
          <v-text-field
            v-model="numberSearch"
            prepend-inner-icon="search"
            label="Search"
            single-line
            hide-details
          ></v-text-field>
        </v-card-title>
        <v-divider></v-divider>
        <v-data-table
          :headers="numberHeaders"
          :items="filterPhoneNumbers()"
          :fixed-header="true"
          :items-per-page="-1"
          disable-sort
          :search="numberSearch"
          :loading="dataLoading"
          class="elevation-0"
        >
          <template #no-data>
            No available phone numbers
          </template>

          <template #no-results>
            No available phone numbers
          </template>

          <template #item="{ item, index }">
            <tr>
              <td class="text-left">
                <img v-if="item.maxCallCountHit"
                  name="userImg" src="../../../../assets/blueraven/alert_icon.jpg" class="icon-height"
                title="Max call count exceeded">
                {{item.phoneNumber}}</td>
              <td class="text-left">{{item.dateCreated  | formatDate('date', 'M/D/YYYY')}}</td>
              <td class="text-left">{{item.callCount}}</td>
              <td class="text-left">
                <v-select attach style="width: 120px" v-model="item.active" :items="items" @change="updatePhoneNumber(item)"></v-select>
              </td>
              <td>
                <v-dialog v-model="item.deleteConfirm" width="500" v-if="userCanDelete">
                  <template v-slot:activator="{ on }">
                    <v-btn text v-on="on">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </template>
                  <v-card>
                    <v-card-title class="text-h5 grey lighten-2" primary-title>
                      Confirm
                    </v-card-title>

                    <v-card-text>
                      Are you sure you want to remove this phone number: <strong>{{ item.phoneNumber }}</strong>?
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
                        @click="deleteNumber(item)">
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
    </v-row>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Numbers',

    data() {
      return {
        snackbar: {},
        phoneNumbers: [],
        showError: false,
        errorMsg: '',
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('CALL_GROUPS', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('CALL_GROUPS', 'EDIT'),
        userCanDelete: this.$store.getters.userHasFeatureAccessLevel('CALL_GROUPS', 'DELETE'),
        callGroupId: this.$route.params.id,
        dataLoading: true,
        addNumber: false,
        newNumber: '',
        numberSearch: '',
        numberHeaders: [
          {text: 'Phone Number', value: 'phoneNumber', show: true},
          {text: 'Date Added', value: 'dateCreated', show: true},
          {text: 'Contacts Assigned', value: 'callCount', show: true},
          {text: 'Status', value: 'active', show: true},
          {text: '', value: 'icons', show: true},
        ],
        items: [
          {text: 'Active', value: true},
          {text: 'Disabled', value: false}
        ]
      }
    },
    created () {
      this.getNumbersForGroup()
    },
    methods: {
      filterPhoneNumbers () {
        return this.phoneNumbers?.length ? this.phoneNumbers.filter(pc => { return !pc.archived}) : []
      },
      async getNumbersForGroup () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/callGroup/${this.callGroupId}/numbers`, 'blueraven')
          this.phoneNumbers = data
          this.dataLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteNumber (number) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/callGroup/number/${number.id}`, 'blueraven')
          number.archived = true
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Removing Phone Number')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addNumberToGroup () {
        this.showError = false
        this.errorMsg = ''
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let phoneRegex = '^\\s*(?:\\+?(\\d{1,3}))?[-. (]*(\\d{3})[-. )]*(\\d{3})[-. ]*(\\d{4})(?: *x(\\d+))?\\s*$'
          if (!this.newNumber.match(phoneRegex) || this.newNumber.length > 20) {
            this.snackbar = getSnackbar('ERROR', 'Error Adding Phone Number: Please reformat the Phone field with a valid phone number')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
            return;
          }

          let params = {
            callGroupId: this.callGroupId,
            phoneNumber: this.newNumber
          }
          const {data, status} = await postRequest(`/callGroup/addNumber`, params, 'blueraven')
          this.phoneNumbers.push(data)
          this.addNumber = false
          this.newNumber = {}
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          let msg = e.data?.message?.includes('Phone Number Already In Use') ? e.data.message : 'Error Adding Phone Number'
          this.snackbar = getSnackbar('ERROR', msg)
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async updatePhoneNumber (item) {
        this.showError = false
        this.errorMsg = ''
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            id: item.id,
            active: item.active
          }
          const {status} = await postRequest(`/callGroup/updateNumber`, params, 'blueraven')
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          let msg = 'Error updating Phone Number'
          this.snackbar = getSnackbar('ERROR', msg)
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    }
  }
</script>

<style lang="scss">
  #numbers-container .v-data-table__wrapper {
    max-height: calc(100vh - 410px);
    min-height: 300px;
  }
  .icon-height {
    height: 25px;
    width: 25px;
    margin-right: 15px;
  }
</style>

