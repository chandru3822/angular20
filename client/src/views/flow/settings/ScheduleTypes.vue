<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!IS_MOBILE" class="app-title">Scheduling Tool Event Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="addNew = !addNew; newType = {}">
              <v-icon v-if="IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-text-field v-if="addNew"
                        v-model="newType.scheduleType"
                        placeholder="Enter a type"
                        label="Schedule Type">
          </v-text-field>
          <v-btn v-if="addNew" :disabled="!newType.scheduleType" @click="addNewType">Save</v-btn>
          <v-list v-for="(st, index) in filterBy(scheduleTypes, false, 'archived')"
                  :key="index" class="pa-0">
            <v-list-item :class="{'shaded-row': index % 2}">
              <v-list-item-content class="text-left">
                <v-text-field class="one-hunned" v-if="selectedScheduleTypeId === st.id" v-model="st.scheduleType">
                </v-text-field>
                <div v-else>{{st.scheduleType}}</div>
              </v-list-item-content>
              <v-list-item-action class="clickable">
                <v-icon v-if="selectedScheduleTypeId === st.id" @click="saveType(st)">save</v-icon>
                <v-icon v-else @click="selectedScheduleTypeId = st.id">edit</v-icon>
              </v-list-item-action>
              <v-dialog
                  v-model="st.deleteConfirm"
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
                    Are you sure you want to delete this schedule type: <strong>{{ st.scheduleType }}</strong>?
                  </v-card-text>

                  <v-divider></v-divider>

                  <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn
                        @click="st.deleteConfirm = false">
                      No
                    </v-btn>
                    <v-btn
                        color="primary"
                        text
                        @click="st.archived = true; deleteType(st.id)">
                      Yes
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>
            </v-list-item>
          </v-list>
        </v-container>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>


<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import orderBy from 'lodash.orderby'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar, IS_MOBILE} from '@/helpers/helpers'

  export default {
    name: 'Schedules',
    mixins: [Vue2Filters.mixin],
    components: {
      Snackbar
    },
    data() {
      return {
        snackbar: {},
        IS_MOBILE,
        scheduleTypes: [],
        addNew: false,
        newType: {},
        selectedScheduleTypeId: null,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId
      }
    },
    computed: {},
    methods: {
      async getScheduleTypes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/scheduleType`)
          this.scheduleTypes = orderBy(data, [st => st.scheduleType.toLowerCase()])

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Schedule Types')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteType(typeId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/scheduleType/type/${typeId}`)
          this.snackbar = getSnackbar('SUCCESS', 'Successfully Deleted Schedule Type')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Schedule Type')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addNewType() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.newType.companyId = this.companyId
          const {data} = await postRequest(`/scheduleType/type`, this.newType)

          this.snackbar = getSnackbar('SUCCESS', 'Schedule Type Added')

          // add it to the records already on the screen
          this.scheduleTypes.push(data)
          this.scheduleTypes = orderBy(this.scheduleTypes, [st => st.scheduleType.toLowerCase()])

          // reset the new process fields
          this.addNew = false
          this.newType = {}

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Schedule Type')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveType(st) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.selectedScheduleTypeId = null
          st.modifiedById = this.userId
          await putRequest(`/scheduleType/type`, st)
          this.snackbar = getSnackbar('SUCCESS', 'Schedule Type Saved')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Schedule Type')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async created() {
      this.getScheduleTypes()
    }
  }
</script>

<style scoped lang="scss">

</style>
