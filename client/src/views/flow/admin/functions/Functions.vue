<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Functions</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
          </v-toolbar-items>
        </v-toolbar>
        <v-data-table
            :headers="headers"
            :items="filterFunctions()"
            :fixed-header="true"
            :items-per-page="-1"
            :mobile-breakpoint="0"
            hide-default-footer
            class="elevation-1 org-type-table"
        >
          <template #no-data>
            NO DATA HERE!
          </template>

          <template #no-results>
            No parameters exist for this function
          </template>


          <template #item="{ item }">
            <tr  class="text-left" :class="{'shaded-row': functions.indexOf(item) % 2}">
              <td class="text-left">{{ item.functionName }}</td>
              <td>
                <v-btn small text @click="goToFunction(item.id)">
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

  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import orderBy from "lodash.orderby";

  export default {
    name: 'DbFunctions',

    data() {
      return {
        constants,
        snackbar: {},
        isCompanyRoot: this.$store.getters.isCompanyRoot(this.$store.state.user.details.companyId),
        addNew: false,
        levels: [],
        functions: [],
        selectedFunction: {},
        selectedFunctionId: null,
        userId: this.$store.state.user.details.id,
        headers: [
          { text: 'Function', value: 'functionName', show: true },
          { text: null, value: 'icons', show: true, sortable: false }
        ],
        expanded: []
      }
    },
    async created () {
      this.getFunctions()
    },
    methods: {
      async getFunctions() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/dbFunction`)
          this.functions = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Functions')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterFunctions () {
        return this.functions.filter(f => { return !f.archived})
      },
      goToFunction(functionId) {
        this.$router.push({path: `/admin/function/${functionId}`})
      },
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

