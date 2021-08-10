<template>
  <v-container class="pa-0" id="residuals-container">
    <v-divider></v-divider>
    <v-toolbar flat color="white">
      <v-toolbar-title>
        Residuals
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-btn text @click="goToDetails({})">
          <v-icon>add</v-icon>
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>
    <v-divider></v-divider>
    <v-row>
      <v-col class="pt-0">
        <v-card>
          <v-card-title class="pt-0">
            <v-text-field
              v-model="search"
              prepend-inner-icon="search"
              label="Search"
              single-line
              hide-details
            ></v-text-field>
          </v-card-title>
          <v-divider></v-divider>
          <v-data-table
            :headers="headers"
            :items="residuals"
            :fixed-header="true"
            :items-per-page="-1"
            :search="search"
            :loading="dataLoading"
            hide-default-footer
            class="elevation-1"
          >
            <template #no-data>
              No available residuals
            </template>

            <template #no-results>
              No available residuals
            </template>

            <template #item="{ item, index }">
              <tr class="clickable" :class="{'shaded-row': index % 2}">
                <td class="text-left">
                  <v-btn text @click="goToDetails(item)">
                    {{item.name}}
                  </v-btn>
                </td>
                <td class="text-left">{{item.description}}</td>
                <td class="text-left">{{item.statusType}}</td>
                <td class="text-left">{{item.activeUsers}}</td>
              </tr>
            </template>
          </v-data-table>
        </v-card>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'

  import {getRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Commissions',

    created() {
      this.getResiduals()
    },
    data() {
      return {
        snackbar: {},
        dataLoading: true,
        search: '',
        headers: [
          {text: 'Date', value: 'date', show: true},
          {text: 'Project', value: 'projectName', show: true},
          {text: 'M1 is met', value: 'm1Met', show: true},
          {text: 'M1\'s last month', value: 'm1LastMonth', show: true},
          {text: 'Residual Earned', value: 'residualEarned', show: true},
          {text: 'Residual Paid', value: 'residualPaid', show: true},
          {text: 'Residual Owed', value: 'residualOwed', show: true},
          {text: 'Cancelled', value: 'cancelled', show: true},
        ],
        residuals: []
      }
    },
    methods: {
      async getResiduals () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/commissionManagement/plans`, 'blueraven')
          this.residuals = data
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Residuals')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      goToDetails (item) {
        this.$router.push({name: 'residual', params: {id: item.id}})
      }
    }
  }
</script>

<style lang="scss">
  #residuals-container .v-data-table__wrapper {
    height: calc(100vh - 350px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  .v-data-table {
    border-radius: 0;
  }
</style>

