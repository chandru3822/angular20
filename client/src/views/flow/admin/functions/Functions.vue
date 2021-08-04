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
              <td class="text-left">{{ item.displayName }}</td>
              <td class="text-left">{{ item.functionType }}</td>
              <td>
                <v-btn small text @click="goToFunction(item.id)">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-dialog
                  v-model="item.deleteConfirm"
                  width="500">
                  <template #activator="{ on }">
                    <v-btn small text color="primaryCustom"
                           v-on="on">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </template>
                  <v-card>
                    <v-card-title class="headline grey lighten-2" primary-title>
                      Confirm
                    </v-card-title>

                    <v-card-text class="pt-4">
                      Are you sure you want to delete this function <strong>{{item.functionName}}</strong>?
                    </v-card-text>
                    <v-divider></v-divider>
                    <v-card-actions>
                      <v-spacer></v-spacer>
                      <v-btn @click="item.deleteConfirm = false">
                        No
                      </v-btn>
                      <v-btn
                        color="primaryCustom"
                        text
                        @click="[item.deleteConfirm = false, deleteFunction(item)]">
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

  import {getRequest, deleteRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

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
          { text: 'Display Name', value: 'displayName', show: true },
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
      async deleteFunction(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/dbFunction/${item.id}`)
          item.archived = true
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Functions')
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
