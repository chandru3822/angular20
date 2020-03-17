<template>
  <v-container class="pa-0" id="override-container">
    <v-toolbar flat color="transparent">
      <v-toolbar-title>
        {{override.name}}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <div class="button-container">
          <v-dialog
              v-model="inactivateConfirm"
              width="500">
            <template #activator="{ on }">
              <v-btn color="red" dark class="mr-2" v-on="on">
                Inactivate
              </v-btn>
            </template>
            <v-card>
              <v-card-title
                  class="headline grey lighten-2"
                  primary-title>
                Confirm
              </v-card-title>

              <v-card-text class="pt-4">
                Are you sure you want to inactivate this plan?
              </v-card-text>

              <v-divider></v-divider>

              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn
                    @click="inactivateConfirm = false">
                  No
                </v-btn>
                <v-btn
                    color="primary"
                    text
                    @click="inactivateConfirm = true; inactivatePlan()">
                  Yes
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
          <v-btn color="primaryCustom" dark  @click="cloneOverride()">
            Clone
          </v-btn>
        </div>
      </v-toolbar-items>
    </v-toolbar>


    <v-divider></v-divider>
    <v-form ref="overrideForm">
      <v-container>
        <v-row>
          <v-col cols="12" sm="6">
            <v-card flat class="pa-3" color="transparent">
              <v-text-field text
                            label="Name"
                            v-model="override.name"></v-text-field>
              <v-text-field text
                            label="Description"
                            v-model="override.description"></v-text-field>
              <v-select v-model="override.positionId"
                        :items="positions"
                        :disabled="override.assignedUsers.length > 0"
                        no-data-text="No Users Available"
                        label="Position Type"
                        item-text="label"
                        item-value="id"
              ></v-select>
              <v-text-field text
                            label="Rate per kW ($)"
                            v-model="override.total"></v-text-field>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6">
            <v-card class="pa-3">
              <v-text-field text
                            label="Status"
                            v-model="override.status"></v-text-field>
              <v-text-field text
                            label="Created By"
                            v-model="override.createdBy.name"></v-text-field>
              <v-text-field text
                            label="Approved"
                            v-model="override.approved"></v-text-field>
              <v-text-field text
                            label="Approved By"
                            v-model="override.approvedBy.name"></v-text-field>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <v-row>
      <v-col>
        <v-card class="square-card">
          <v-card-title>
            Receiving Overrides
          </v-card-title>
        </v-card>
        <v-divider></v-divider>
        <v-data-table
            :headers="receivingHeaders"
            :items="override.receivingUsers"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
            :loading="dataLoading"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            No available users
          </template>

          <template #no-results>
            No available users
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.name}}</td>
              <td class="text-left">{{item.employeeId}}</td>
              <td class="text-left">{{item.allocation}}</td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <v-row>
      <v-col>
        <v-card class="square-card">
          <v-card-title>
            Assigned to Override Plan
          </v-card-title>
        </v-card>
        <v-divider></v-divider>
        <v-data-table
            :headers="headers"
            :items="override.assignedUsers"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
            :loading="dataLoading"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            No available users
          </template>

          <template #no-results>
            No available users
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.name}}</td>
              <td class="text-left">{{item.employeeId}}</td>
              <td class="text-left">{{item.startDate}}</td>
              <td class="text-left">{{item.endDate}}</td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Override',
    components: {
      Snackbar
    },
    created() {
      this.getOverrideDetails()
    },
    data() {
      return {
        snackbar: {},
        dataLoading: true,
        inactivateConfirm: false,
        overrideId: this.$route.params.id,
        headers: [
          {text: 'Name', value: 'name', show: true},
          {text: 'Employee ID', value: 'employeeId', show: true},
          {text: 'Start Date', value: 'startDate', show: true},
          {text: 'End Date', value: 'endDate', show: true},
        ],
        receivingHeaders: [
          {text: 'Name', value: 'name', show: true},
          {text: 'Employee ID', value: 'employeeId', show: true},
          {text: 'Allocation', value: 'allocation', show: true},
        ],
        override: {
          approvedBy: {},
          createdBy: {},
          assignedUsers: []
        },
        positions: [
          {id: 1, label: 'Closer'},
          {id: 4, label: 'Setter'}
        ]
      }
    },
    methods: {
      async getOverrideDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/commissionManagement/overrides/${this.overrideId}`, 'blueraven')
          this.override = data
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Override Details')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      goToDetails (item) {
        console.log('handle going to item', item)
      },
      // async deleteOverride () {
      //   this.$store.commit(AppMutations.SET_LOADING, true)
      //   try {
      //     const {data} = await deleteRequest(`/commissionManagement/overrides/${this.overrideId}`, 'blueraven')
      //     this.$store.commit(AppMutations.SET_LOADING, false)
      //   } catch (e) {
      //     console.error('*** ERROR ***', e)
      //     this.snackbar = getSnackbar('ERROR', 'Error Deleting Override')
      //     this.$store.commit(AppMutations.SET_LOADING, false)
      //   }
      // },
      async cloneOverride () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await deleteRequest(`/commissionManagement/overrides/${this.overrideId}`, 'blueraven')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Override')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      inactivatePlan () {
        console.log('INACTIVATE', this.override)
      }
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>
.v-data-table {
  border-radius: 0;
}
.button-container {
  display: flex;
  align-items: center;
}
</style>

