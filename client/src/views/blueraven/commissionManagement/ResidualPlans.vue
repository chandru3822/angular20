<template>
  <v-container class="pa-0" id="residual-plan-container">
    <v-divider></v-divider>
    <v-toolbar flat color="white">
      <v-toolbar-title>
        Residual Plans
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
              :items="residualPlans"
              :fixed-header="true"
              :items-per-page="-1"
              :search="search"
              :loading="dataLoading"
              hide-default-footer
              class="elevation-1"
          >
            <template #no-data>
              No available residual plans
            </template>

            <template #no-results>
              No available residual plans
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

  import {handleHidingGlobalLoader, getRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'ResidualPlans',

    created() {
      this.getResidualPlans()
    },
    data() {
      return {
        snackbar: {},
        dataLoading: true,
        search: '',
        headers: [
          {text: 'Plan Name', value: 'name', show: true},
          {text: 'Description', value: 'description', show: true},
          {text: 'Status', value: 'statusType', show: true},
        ],
        residualPlans: []
      }
    },
    methods: {
      async getResidualPlans () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/commissionManagement/residuals/plans`, 'blueraven')
          this.residualPlans = data
          this.dataLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Residual Plans')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      goToDetails (item) {
        this.$router.push({name: 'residualPlan', params: {id: item.id}})
      }
    }
  }
</script>

<style lang="scss">
#residual-plan-container .v-data-table__wrapper {
  height: calc(100vh - 350px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>
.v-data-table {
  border-radius: 0;
}
</style>

