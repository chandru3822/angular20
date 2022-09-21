<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">User Profile Admin</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" v-if="userIsAdmin" :to="`/settings/userProfile`">
              Back to User Profile
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12" md="6">
        <v-data-table
          :headers="headers"
          :items="userProfileDefaultFields"
          disable-sort
          hide-default-footer
          :fixed-header="true"
          :items-per-page="-1"
          class="elevation-1">

          <template #no-data>
            <span class="default-text-color">No available default fields</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available default fields</span>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.fieldName}}</td>
              <td class="text-center">
                <v-checkbox v-model="item.showOnUserProfile"
                            @change="updateShowOnUserProfile(item)"
                ></v-checkbox>
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
import {getUserProfileDefaultFields} from '@/services/userService'
import {handleHidingGlobalLoader, putRequest, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'

export default {
  name: 'UserProfile',
  components: {
  },
  data () {
    return {
      constants,
      snackbar: {},
      userProfileDefaultFields: [],
      userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('USERS', 'ADMIN'),
      headers: [
        {text: 'Field Name', value: 'fieldName'},
        {text: 'Show On User Profile', value: 'showOnUserProfile'},
      ],
    }
  },
  computed: {},
  async created () {
    this.getUserProfileDefaultFields()
  },
  methods: {
    async getUserProfileDefaultFields() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getUserProfileDefaultFields()
        this.userProfileDefaultFields = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Default Fields')
        this.loadingUserProfileCustomFields = false
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateShowOnUserProfile(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await putRequest(`/defaultField`, item)
        this.snackbar = getSnackbar('SUCCESS', 'Saved Changes')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Changes')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },

  }
}
</script>
