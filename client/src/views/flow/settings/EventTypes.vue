<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Scheduling Tool Event Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newType = {}]">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-text-field v-if="addNew"
                        v-model="newType.eventType"
                        placeholder="Enter a type"
                        label="Event Type">
          </v-text-field>
          <v-btn v-if="addNew" :disabled="!newType.eventType" @click="addNewType">Save</v-btn>
          <v-list v-for="(st, index) in filterBy(eventTypes, false, 'archived')"
                  :key="index" class="pa-0">
            <v-list-item :class="{'shaded-row': index % 2}">
              <v-list-item-content class="text-left">
                <v-text-field class="one-hunned" v-if="selectedEventTypeId === st.id" v-model="st.eventType">
                </v-text-field>
                <div v-else>{{st.eventType}}</div>
              </v-list-item-content>
              <v-list-item-action class="clickable">
                <v-icon v-if="selectedEventTypeId === st.id" @click="saveType(st)">save</v-icon>
                <v-icon v-else @click="selectedEventTypeId = st.id">edit</v-icon>
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
                    Are you sure you want to delete this event type: <strong>{{ st.eventType }}</strong>?
                  </v-card-text>

                  <v-divider></v-divider>

                  <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn
                        @click="st.deleteConfirm = false">
                      No
                    </v-btn>
                    <v-btn
                        color="primaryCustom"
                        text
                        @click="[st.archived = true, deleteType(st.id)]">
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
  import {getEventTypes} from '@/services/scheduleService'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'Events',
    mixins: [Vue2Filters.mixin],
    components: {
      Snackbar
    },
    data() {
      return {
        snackbar: {},
        constants,
        eventTypes: [],
        addNew: false,
        newType: {},
        selectedEventTypeId: null,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId
      }
    },
    computed: {},
    methods: {
      async getEventTypes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getEventTypes()
          this.eventTypes = orderBy(data, [st => st.eventType.toLowerCase()])

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Event Types')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteType(typeId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/eventType/type/${typeId}`)
          this.snackbar = getSnackbar('SUCCESS', 'Successfully Deleted Event Type')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Event Type')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addNewType() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.newType.companyId = this.companyId
          const {data} = await postRequest(`/eventType/type`, this.newType)

          this.snackbar = getSnackbar('SUCCESS', 'Event Type Added')

          // add it to the records already on the screen
          this.eventTypes.push(data)
          this.eventTypes = orderBy(this.eventTypes, [st => st.eventType.toLowerCase()])

          // reset the new process fields
          this.addNew = false
          this.newType = {}

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Event Type')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveType(st) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.selectedEventTypeId = null
          st.modifiedById = this.userId
          await putRequest(`/eventType/type`, st)
          this.snackbar = getSnackbar('SUCCESS', 'Event Type Saved')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Event Type')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async created() {
      this.getEventTypes()
    }
  }
</script>

<style scoped lang="scss">

</style>
