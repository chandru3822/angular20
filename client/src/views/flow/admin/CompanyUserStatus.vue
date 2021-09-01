<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Company User Status</v-toolbar-title>
        </v-toolbar>
        <v-data-table
            :headers="headers"
            :items="statusTypes"
            :fixed-header="true"
            :items-per-page="-1"
            single-expand
            :expanded.sync="expanded"
            :mobile-breakpoint="0"
            hide-default-footer
            class="elevation-1 org-type-table"
        >
          <template #no-data>
            NO DATA HERE!
          </template>

          <template #no-results>
            NO DATA HERE!
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': statusTypes.indexOf(item) % 2}">
              <h3>Edit User Status</h3>
              <div class="mb-3">
                <label>Has Access:</label>
                <input class="ml-3" type="checkbox" v-model="item.hasAccess">
              </div>
              <v-btn color="primaryCustom" class="white--text mr-2"
                     @click="saveCompanyUserStatusType(item)">
                Save
              </v-btn>
            </td>
          </template>

          <template #item="{ item }">
            <tr  class="text-left" :class="{'shaded-row': statusTypes.indexOf(item) % 2}">
              <td class="text-left">{{ item.userStatusType }}</td>
              <td>
                <input type="checkbox" v-model="item.hasAccess" disabled readonly>
              </td>
              <td>
                <v-btn small text v-if="!expanded.includes(item)" @click="expanded = [item]">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text v-if="expanded.includes(item)" @click="expanded = []">cancel</v-btn>
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
  import {putRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import {getUserStatusTypes} from '@/services/userService'

  export default {
    name: 'CompanyUserStatus',

    data() {
      return {
        snackbar: {},
        constants,
        statusTypes: [],
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        headers: [
          { text: 'User Status Type', value: 'userStatusType', show: true },
          { text: 'Has Access', value: 'hasAccess', show: true },
          { text: null, value: 'icons', show: true, sortable: false }
        ],
        expanded: []
      }
    },
    async created () {
      this.getCompanyUserStatusTypes()
    },
    methods: {
      async getCompanyUserStatusTypes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getUserStatusTypes()
          this.statusTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Company User Status Types')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveCompanyUserStatusType(type) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/user/statusType`, type)
          this.expanded = []
          this.snackbar = getSnackbar('SUCCESS', 'User Status Type Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating User Status')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>
