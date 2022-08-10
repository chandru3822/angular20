<template>
  <v-container id="functions-admin-container">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Functions</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addNew = !addNew, newFunction = {}, getDataTypes(), getFunctionTypes()]">
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

            <v-checkbox
              type="checkbox"
              v-model="newFunction.processStepActionable"
              label="Allow use by process steps"
            />

            <v-checkbox
              type="checkbox"
              v-model="newFunction.eventActionable"
              label="Allow use by events"
            />

            <v-checkbox
              v-if="newFunction.dbFunctionTypeId === 2"
              type="checkbox"
              v-model="newFunction.runInBackend"
              label="Run in backend"
            />
          </div>
          <v-btn :disabled="!newFunction || !newFunction.functionName || !newFunction.displayName || !newFunction.dbFunctionTypeId || (newFunction.dbFunctionTypeId === 1 && !newFunction.returnDataTypeId)"
                 color="primary" class="mr-2"
                 @click="addFunction()">
            Save
          </v-btn>
          <v-btn text color="primary" @click="[addNew = !addNew, newFunction = {}]">Cancel</v-btn>
        </v-card>
        <v-text-field
          v-model="search"
          class="mb-2 px-4 py-2"
          prepend-inner-icon="search"
          label="Search"
          single-line
          hide-details
        ></v-text-field>
        <v-divider></v-divider>
        <v-data-table
            :headers="headers"
            :search="search"
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
                <v-btn small text color="primary" @click="goToFunction(item.id)">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text color="primary" @click="functionToDelete=item"><v-icon>delete</v-icon></v-btn>
              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!functionToDelete" @confirm="deleteFunction" @close-dialog="functionToDelete = null">
      Are you sure you want to delete this function <strong>{{functionToDeleteName}}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import ConfirmationDialog from "@/ConfirmationDialog";

  export default {
    name: 'DbFunctions',
    components: {ConfirmationDialog},
    data() {
      return {
        constants,
        snackbar: {},
        search: '',
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
        expanded: [],
        functionToDelete: null
      }
    },
    computed:{
      functionToDeleteName(){
        return this.functionToDelete ? this.functionToDelete.functionName : ''
      }
    },
    async created () {
      this.getFunctions()
    },
    methods: {
      async getFunctions() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/dbFunction`)
          this.functions = data
          handleHidingGlobalLoader(this, status)
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
            const {data, status} = await getRequest(`/dataType/getSystem`)
            this.dataTypes = data
            handleHidingGlobalLoader(this, status)
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
            const {data, status} = await getRequest(`/dbFunction/types`)
            this.dbFunctionTypes = data
            handleHidingGlobalLoader(this, status)
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
          const {data, status} = await postRequest(`/dbFunction`, this.newFunction)
          this.goToFunction(data.id)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Functions')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteFunction() {
        const item = this.functionToDelete
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/dbFunction/${item.id}`)
          item.archived = true
          handleHidingGlobalLoader(this, status)
          this.snackbar = getSnackbar('SUCCESS', 'Function Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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

<style lang="scss">
#functions-admin-container .v-data-table__wrapper {
  max-height: calc(100vh - 275px);
  min-height: 300px;
}
</style>
