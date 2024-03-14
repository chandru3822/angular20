<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="header-bar">
          <v-toolbar-title class="title-large text-wrap">Event Status Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addNewEventStatusType = !addNewEventStatusType, expanded = [], getCompanyEventStatusTypes()]" v-if="userCanAdd">
              <v-icon v-if="!addNewEventStatusType">add</v-icon>
              <span v-if="$vuetify.breakpoint.mdAndUp">{{ addNewEventStatusType ? 'Cancel' : 'Add Event Status Type' }}</span>
            </v-btn>
            <v-btn text color="primary" @click="expandEsst = !expandEsst">
              <v-icon v-if="!expandEsst">mdi-chevron-down</v-icon>
              <v-icon v-else>mdi-chevron-up</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <div class="mb-4">
          <v-card flat class="square-card mb-3 pa-3" color="primary lighten-9" v-if="addNewEventStatusType">
            <h3>Assign a Status Type</h3>
            <v-autocomplete label="Event Status Type"
                            :items="availableCompanyEventStatusTypes"
                            v-model="newEventStatusTypeId"
                            item-text="eventStatusType"
                            item-value="id"
                            :loading="companyStatusesLoading"
                            autocomplete="off"
                            @input="assignStatusTypeToEvent"
            >
              <template slot="item" slot-scope="data">
                <!-- HTML that describes how select should render items when the select is open -->
                {{ data.item.eventStatusType }} ({{ data.item.rootEventStatusType }})
              </template>
            </v-autocomplete>
          </v-card>
          <v-data-table
            v-if="expandEsst"
            :headers="eventHeaders"
            :items="filterAssignedEventStatusTypes()"
            hide-default-footer
            :items-per-page="-1"
            disable-sort
            class="elevation-1 square-card mb-2 table-striped"
          >
            <template #no-data>
              <span class="default-text-color">No available event status types</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No available event status types</span>
            </template>


                <template #item.statusType="{item}" class="text-left"><a href="/settings/eventStatuses">{{ item.eventStatusType }}</a></template>
                <template #item.category="{item}" class="text-left">{{ item.rootEventStatusType }}</template>
            <template #item.scheduleEditable="{item}" class="text-left">
              <v-checkbox v-model="item.editableInSchedule" @change="saveEditableInSchedule(item)"/>
            </template>
            <td class="text-right">
                  <div class="flex-display align-center">
                    <v-btn small text color="primary" v-if="userCanEdit" @click="eventStatusTypeToDelete=item"><v-icon>delete</v-icon></v-btn>
                  </div>
                </td>

          </v-data-table>
        </div>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="header-bar">
          <v-toolbar-title class="title-large">Event Access Control</v-toolbar-title>
        </v-toolbar>
        <v-card flat color="rowShadeCustom" class="square-card mt-2 d-flex">
          <v-card-text class="d-flex flex-column">
            <multi-select-group
              v-if="!eventLoading"
              :userCanEdit="userCanEdit"
              :returnObject="event"
              :content="positions"
              :dropdownEnabled="event.hidden"
              :selectedContent="event.hiddenWhiteListedPositions"
              :title="'Hidden'"
              :label="'Allowed Positions'"
              :alternateLabel = "'Denied Positions'"
              :allow="event.hiddenAllow"
              :contentLoading="positionsLoading"
              :full-size="$vuetify.breakpoint.smAndDown"
              :save-button="userCanEdit"
              @selected-changed="hiddenSelectedEventListener"
              @allow-changed="hiddenAllowEventListener"
              @checkbox-changed="hiddenCheckboxEventListener"
              @save-multi-select="saveHiddenAndWhiteList"
            ></multi-select-group>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import {AppMutations} from "@/stores/AppStore";
import draggable from 'vuedraggable'
import {getAvailableForEvent} from '@/services/eventStatusTypeService'
import {deleteRequest, getRequest, getSnackbar, postRequest, putRequest, handleHidingGlobalLoader} from "@/helpers/helpers";
import Vue2Filters from "vue2-filters"
import orderBy from "lodash.orderby"
import ConfirmationDialog from "@/components/ConfirmationDialog";
import cloneDeep from "lodash.clonedeep";
import MultiSelectGroup from "@/components/MultiSelectGroup.vue";

export default {
  name: 'EventComponents',
  mixins: [Vue2Filters.mixin],
  components: {
    MultiSelectGroup,
    ConfirmationDialog,
    draggable
  },
  data () {
    return {
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
      addNewType: false,
      expandEsst: true,
      event: {},
      eventId: this.$route.params.id,
      availableCompanyEventStatusTypes: [],
      companyStatusesLoading: false,
      addNewEventStatusType: false,
      newType: {},
      newEventStatusTypeId: null,
      combinedStatuses: [ {header: 'Category'} ],
      companyEventStatusTypes: [],
      eventStatusTypes: [],
      eventHeaders: [
        {text: 'Status Type', value: 'statusType', show: true},
        {text: 'Category', value: 'category', show: true},
        {text: '', value: 'icons', show: false, width: '100px'},
        {text: 'Editable in Schedule', value: 'scheduleEditable', show: true}
      ],
      eventStatusTypeToDelete: null,
      attachmentTypeToDelete: null,
      positions: [],
      positionsLoading: false,
      hiddenPositionsChanged: false,
      eventLoading: false
    }
  },
  computed: {
    eventStatusTypeToDeleteName(){
      return this.eventStatusTypeToDelete ? this.eventStatusTypeToDelete.eventStatusType : ''
    },
    attachmentTypeToDeleteType(){
      return this.attachmentTypeToDelete ? this.attachmentTypeToDelete.attachmentType : ''
    },
  },
  watch: {},
  created () {
    this.getEvent()
    this.getPositions()
  },
  methods: {
    async getEvent () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.eventLoading = true;
        const {data} = await getRequest(`/event/${this.eventId}`)
        this.event = data
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.eventLoading = false;
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    filterAssignedEventStatusTypes() {
      return orderBy(this.event?.companyEventStatusTypes?.filter(u => {
        return !u.archived
      }), [f => f.eventStatusType])
    },
    async assignStatusTypeToEvent () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newType.eventId = this.$route.params.id
        const {data} = await postRequest(`/event/status/assignCompanyStatus/${this.newEventStatusTypeId}/toEvent/${this.eventId}`)
        this.event.companyEventStatusTypes.push(data)
        // reset fields
        this.addNewEventStatusType = false
        this.newEventStatusTypeId = null
        this.snackbar = getSnackbar('SUCCESS', 'Status Type Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Status Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveEditableInSchedule (item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const params = {
          editableInSchedule: item.editableInSchedule
        }
       await postRequest(`/event/status/updateEditableInSchedule/${item.companyEventStatusTypeId}/forEvent/${parseInt(this.eventId)}?editableInSchedule=${item.editableInSchedule}`)
        this.snackbar = getSnackbar('SUCCESS', 'Editable in Schedule Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }catch (e){
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Editable in Schedule')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCompanyEventStatusTypes() {
      if(this.addNewEventStatusType) {
        this.companyStatusesLoading = true
        try {
          const {data} = await getAvailableForEvent(this.eventId)
          this.availableCompanyEventStatusTypes = data
          this.companyStatusesLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Event Status Types')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.companyStatusesLoading = false
        }
      }

    },
    async deleteStatusTypeFromEvent () {
      const item = this.eventStatusTypeToDelete
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        item.archived = true
        await deleteRequest(`/event/${this.eventId}/companyStatus/${item.id}`)
        this.snackbar = getSnackbar('SUCCESS', 'Event Status Type Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Event Status Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.eventStatusTypeToDelete = null
    },
    selectAllHidden () {
      return this.event.hiddenWhiteListedPositions?.length === this.positions?.length
    },
    selectSomeHidden (f) {
      return this.event.hiddenWhiteListedPositions?.length > 0 && !this.selectAllHidden(f)
    },
    icon () {
      if (this.selectAllHidden()) {
        return 'check_box'
      }
      if (this.selectSomeHidden()) {
        return 'indeterminate_check_box'
      }
      return 'check_box_outline_blank'
    },

    toggleSelectAllPositionsOwner () {
      this.$nextTick(() => {
        if (this.selectAllHidden()) {
          this.event.hiddenWhiteListedPositions = []
          this.hiddenPositionsChanged = true
        } else {
          this.event.hiddenWhiteListedPositions = cloneDeep(this.positions)
          this.hiddenPositionsChanged = true
        }
      })
    },
    async getPositions() {
      if(this.positions?.length === 0) {
        try {
          this.positionsLoading = true
          const {data, status} = await getRequest(`/position/withParent`)
          this.positions = data
          this.positionsLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          this.positionsLoading = false
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Positions')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async saveHiddenAndWhiteList () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await putRequest(`/event/saveHiddenAndWhiteList?positionsChanged=${this.event.hiddenPositionsChanged ?? false}`, this.event)
        this.hiddenPositionsChanged = false
        if(!this.event.hidden) {
          this.event.hiddenWhiteListedPositions = []
        }
        this.snackbar = getSnackbar('SUCCESS', 'Saved Successfully')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Event Access Control')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    hiddenSelectedEventListener(e){
      this.event.hiddenWhiteListedPositions = e;
      this.event.hiddenPositionsChanged = true;
    },
    hiddenAllowEventListener(e){
      this.event.hiddenAllow = (e === 0);
    },
    hiddenCheckboxEventListener(e){
      this.event.hidden = e;
    },
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.header-bar {
  border-bottom: 1px solid #E6E6E6;

}

</style>
