<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Data Views</v-toolbar-title>
<!--          <v-spacer></v-spacer>-->
<!--          <v-toolbar-items>-->
<!--            <v-btn text @click="[addNew = !addNew, newDataView = {}]">-->
<!--              <v-icon v-if="constants.IS_MOBILE">add</v-icon>-->
<!--              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>-->
<!--            </v-btn>-->
<!--          </v-toolbar-items>-->
        </v-toolbar>
<!--        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat >-->
<!--          <h3>Add Data View</h3>-->
<!--          <div class="mb-3">-->
<!--            <v-text-field text v-model="newDataView.displayName"-->
<!--                          label="Display Name" />-->
<!--            <v-text-field text v-model="newDataView.viewName"-->
<!--                          label="Table Name (all lower case, underscores instead of spaces)" />-->
<!--          </div>-->
<!--          <v-btn :disabled="!newDataView.displayName || !newDataView.viewName"-->
<!--                 color="primaryCustom" class="white&#45;&#45;text mr-2"-->
<!--                 @click="saveDataView(newDataView, true)">-->
<!--            Save-->
<!--          </v-btn>-->
<!--          <v-btn @click="[addNew = !addNew, newDataView = {}]">Cancel</v-btn>-->
<!--        </v-card>-->
        <v-data-table
            :headers="headers"
            :items="dataViews"
            :fixed-header="true"
            :items-per-page="-1"
            :mobile-breakpoint="0"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            NO DATA HERE!
          </template>

          <template #no-results>
            No data
          </template>

          <template #item="{ item }">
            <tr  class="text-left" :class="{'shaded-row': dataViews.indexOf(item) % 2}">
              <td class="text-left">{{ item.displayName }}</td>
              <td class="text-left">{{ item.viewName }}</td>
              <td>
                <v-btn small text @click="goToView(item.id)">
                  <v-icon>edit</v-icon>
                </v-btn>

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
  import {handleHidingGlobalLoader, getRequest, putRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'DataViews',

    data() {
      return {
        snackbar: {},
        constants,
        addNew: false,
        dataViews: [],
        newDataView: {},
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        headers: [
          { text: 'Display Name', value: 'displayName', show: true },
          { text: 'Table Name', value: 'viewName', width: 80, show: true },
          { text: null, value: 'icons', show: true, sortable: false }
        ]
      }
    },
    async created () {
      this.getDataViews()
    },
    methods: {
      async goToView(id) {
        this.$router.push(`/admin/dataView/${id}`)
      },
      // async saveDataView(dv, isNew) {
      //   this.$store.commit(AppMutations.SET_LOADING, true)
      //   try {
      //     const {data, status} = await putRequest(`/orgType/level`, dv)
      //     if(isNew){
      //       this.dataViews.push(data)
      //       this.addNew = false
      //       this.newDataView = {}
      //       this.snackbar = getSnackbar('SUCCESS', 'Data View Added')
      //       this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      //     } else {
      //       this.snackbar = getSnackbar('SUCCESS', 'Data View Updated')
      //       this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      //     }
      //     handleHidingGlobalLoader(this, status)
      //   } catch (e) {
      //     console.error('*** ERROR ***', e)
      //     this.snackbar = getSnackbar('ERROR', isNew ? 'Error Adding Data View' : 'Error Updating Data View')
      //     this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      //     this.$store.commit(AppMutations.SET_LOADING, false)
      //   }
      // },
      async getDataViews() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/dataView`)
          this.dataViews = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Data Views')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>
