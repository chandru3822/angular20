<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Functions</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newFunction = {}, getDataTypes(), getFunctionTypes()]">
              {{addNew ? 'Cancel' : 'Add New'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat >
          <h3>Add New Function</h3>
          <div class="mb-3">
            <v-text-field text label="Function Name"
                      v-model="newFunction.functionName"
                      hint="* This MUST match the function name in the procedure files"
                      persistent-hint></v-text-field>
            <v-text-field text label="Display Name"
                          v-model="newFunction.displayName"></v-text-field>
            <v-select
              class="mt-2"
              v-model="newFunction.dbFunctionTypeId"
              :items="dbFunctionTypes"
              label="Function Type"
              item-text="functionType"
              item-value="id"
            ></v-select>
            <v-select
              v-if="newFunction.dbFunctionTypeId === 1"
              v-model="newFunction.returnDataTypeId"
              :items="dataTypes"
              label="Return Data Type"
              item-text="dataType"
              item-value="id"
            ></v-select>
          </div>
          <v-btn :disabled="!newFunction || !newFunction.functionName || !newFunction.displayName || !newFunction.dbFunctionTypeId || (newFunction.dbFunctionTypeId === 1 && !newFunction.returnDataTypeId)"
                 color="primaryCustom" class="white--text mr-2"
                 @click="addFunction()">
            Save
          </v-btn>
          <v-btn @click="[addNew = !addNew, newFunction = {}]">Cancel</v-btn>
        </v-card>
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
            No data
          </template>


          <template #item="{ item }">
            <tr  class="text-left" :class="{'shaded-row': functions.indexOf(item) % 2}">
              <td class="text-left">{{ item.functionName }}</td>
              <td class="text-left">{{ item.functionType }}</td>
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
        addNew: false,
        functions: [],
        dbFunctionTypes: [],
        dataTypes: [],
        newFunction: {},
        userId: this.$store.state.user.details.id,
        headers: [
          { text: 'Function', value: 'functionName', show: true },
          { text: 'Type', value: 'functionType', show: true },
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
      async getDataTypes() {
        if(this.dataTypes.length === 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {data} = await getRequest(`/dataType/getSystem`)
            this.dataTypes = data
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Loading Data Types')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async getFunctionTypes() {
        if(this.dbFunctionTypes.length === 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {data} = await getRequest(`/dbFunction/types`)
            this.dbFunctionTypes = data
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Loading Functions')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async addFunction() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          //unset the returnDataTypeId if they changed the function type back to Action
          this.newFunction.returnDataTypeId = this.newFunction.dbFunctionTypeId !== 1 ? null : this.newFunction.returnDataTypeId
          const {data} = await postRequest(`/dbFunction`, this.newFunction)
          this.goToFunction(data.id)
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

