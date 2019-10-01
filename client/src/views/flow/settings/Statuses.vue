<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Process Step Status Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="addNew = !addNew; newType = {}">
              {{addNew ? 'Cancel' : 'Add New'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-text-field v-if="addNew"
                        v-model="newType.statusType"
                        placeholder="Enter a type"
                        label="Status Type">
          </v-text-field>
          <v-btn v-if="addNew" :disabled="!newType.statusType" @click="addNewType">Save</v-btn>
          <v-list v-for="(s, index) in filterBy(statusTypes, false, 'archived')"
                  :key="index">
            <v-list-item :class="{'shaded-row': index % 2}">
              <v-list-item-content  class="text--primary text-left">
                <v-text-field class="one-hunned" v-if="selectedStatusTypeId === s.id" v-model="s.processStepStatusType">
                </v-text-field>
                <div v-else>{{s.processStepStatusType}}</div>
              </v-list-item-content>
              <v-list-item-action class="clickable">
                <v-icon v-if="selectedStatusTypeId === s.id" @click="saveType(s)">save</v-icon>
                <v-icon v-else @click="selectedStatusTypeId = s.id">edit</v-icon>
              </v-list-item-action>
              <v-dialog
                  v-model="s.deleteConfirm"
                  width="500">
                <template v-slot:activator="{ on }">
                  <v-list-item-action class="clickable" v-on="on">
                    <v-icon>delete</v-icon>
                  </v-list-item-action>
                </template>
                <v-card>
                  <v-card-title
                      class="headline grey lighten-2"
                      primary-title
                  >
                    Confirm
                  </v-card-title>

                  <v-card-text>
                    Are you sure you want to delete this status type: <strong>{{ s.processStepStatusType }}</strong>?
                  </v-card-text>

                  <v-divider></v-divider>

                  <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn
                        @click="s.deleteConfirm = false">
                      No
                    </v-btn>
                    <v-btn
                        color="primary"
                        text
                        @click="s.archived = true; deleteType(s.id)">
                      Yes
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>
            </v-list-item>
          </v-list>
        </v-container>
      </v-col>
      <Snackbar :snackbar="snackbar"></Snackbar>
    </v-row>
  </v-container>
</template>


<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import Snackbar from '@/components/Snackbar.vue'
  import orderBy from 'lodash.orderby'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Statuses',
    mixins: [Vue2Filters.mixin],
    components: {
      Snackbar
    },
    data () {
      return {
        snackbar: {},
        statusTypes: [],
        addNew: false,
        newType: {},
        selectedStatusTypeId: null,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId
      }
    },
    computed: {
    },
    methods: {
      async getStatusTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/processStep/status`)
          this.statusTypes = orderBy(data, [s => s.processStepStatusType.toLowerCase()])
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteType (typeId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/processStep/status/${typeId}`)
          this.snackbar = getSnackbar('SUCCESS', 'Status Deleted')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Status')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addNewType () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.newType.companyId = this.companyId
          const {data} = await postRequest(`/processStep/status`, this.newType)

          // add it to the records already on the screen
          this.statusTypes.push(data)
          this.statusTypes = orderBy(this.statusTypes, [s => s.processStepStatusType.toLowerCase()])

          // reset the new process fields
          this.addNew = false
          this.newType = {}
          this.snackbar = getSnackbar('SUCCESS', 'Status Added')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Status')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveType (s) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.selectedStatusTypeId = null
          await putRequest(`/processStep/status`, s)
          this.snackbar = getSnackbar('SUCCESS', 'Status Updated')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating Status')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async created () {
      this.getStatusTypes()
    }
  }
</script>

<style scoped lang="scss">

</style>
