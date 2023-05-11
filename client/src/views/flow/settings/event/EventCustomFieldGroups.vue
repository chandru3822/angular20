<template>
  <v-container class="pt-0 px-0">
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">Default Event Fields</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items class="flex-display">
            <div class="flex-display align-center">
              <v-btn class="save-btn text-capitalize"
                     @click="saveChangesToDefaultFields"
                     color="primary"
                     v-if="userCanEdit"
              >Save Default Event Fields
              </v-btn>
            </div>
          </v-toolbar-items>
        </v-toolbar>
        <v-card color="transparent">
          <v-row class="mx-3" cols="12">
            <!--Start Time White Listed Fields-->
            <v-col cols="12" md="5" class="py-0">
              <v-text-field
                label="Start Time"
                readonly disabled
                single-line
                hide-details
              ></v-text-field>
              <v-row class="flex-display">
                <multi-select-group
                  v-if="!eventLoading"
                  background-color="primary lighten-9"
                  :userCanEdit="userCanEdit"
                  :returnObject="event"
                  :content="positions"
                  :dropdownEnabled="event.startTimeReadOnly"
                  :selectedContent="event.startTimeWhiteListedPositions"
                  :title="'Read Only'"
                  :label="'Allowed Positions'"
                  :alternateLabel = "'Denied Positions'"
                  :allow="event.startTimeReadOnlyAllow"
                  :contentLoading="positionsLoading"
                  @selected-changed="startTimeReadOnlySelectedEventListener"
                  @allow-changed="startTimeReadOnlyAllowEventListener"
                  @checkbox-changed="startTimeReadOnlyCheckboxEventListener"></multi-select-group>


                <multi-select-group
                  v-if="!eventLoading"
                  background-color="primary lighten-9"
                  :userCanEdit="userCanEdit"
                  :returnObject="event"
                  :content="positions"
                  :dropdownEnabled="event.startTimeHidden"
                  :selectedContent="event.startTimeHiddenWhiteListedPositions"
                  :title="'Hidden'"
                  :label="'Allowed Positions'"
                  :alternateLabel = "'Denied Positions'"
                  :allow="event.startTimeHiddenAllow"
                  :contentLoading="positionsLoading"
                  @selected-changed="startTimeHiddenSelectedEventListener"
                  @allow-changed="startTimeHiddenAllowEventListener"
                  @checkbox-changed="startTimeHiddenCheckboxEventListener"></multi-select-group>

              </v-row>
            </v-col>
            <v-col style="height: 0" cols="0" md="1"></v-col>
            <!--End Time White Listed Fields-->
            <v-col cols="12" md="5" class="py-0">
              <v-text-field
                label="End Time"
                readonly disabled
                single-line
                hide-details
              ></v-text-field>
              <v-row class="flex-display">
                <multi-select-group
                  v-if="!eventLoading"
                  background-color="primary lighten-9"
                  :userCanEdit="userCanEdit"
                  :returnObject="event"
                  :content="positions"
                  :dropdownEnabled="event.endTimeReadOnly"
                  :selectedContent="event.endTimeWhiteListedPositions"
                  :title="'Read Only'"
                  :label="'Allowed Positions'"
                  :alternateLabel = "'Denied Positions'"
                  :allow="event.endTimeReadOnlyAllow"
                  :contentLoading="positionsLoading"
                  @selected-changed="endTimeReadOnlySelectedEventListener"
                  @allow-changed="endTimeReadOnlyAllowEventListener"
                  @checkbox-changed="endTimeReadOnlyCheckboxEventListener"></multi-select-group>

                <multi-select-group
                  v-if="!eventLoading"
                  background-color="primary lighten-9"
                  :userCanEdit="userCanEdit"
                  :returnObject="event"
                  :content="positions"
                  :dropdownEnabled="event.endTimeHidden"
                  :selectedContent="event.endTimeHiddenWhiteListedPositions"
                  :title="'Hidden'"
                  :label="'Allowed Positions'"
                  :alternateLabel = "'Denied Positions'"
                  :allow="event.endTimeHiddenAllow"
                  :contentLoading="positionsLoading"
                  @selected-changed="endTimeHiddenSelectedEventListener"
                  @allow-changed="endTimeHiddenAllowEventListener"
                  @checkbox-changed="endTimeHiddenCheckboxEventListener"></multi-select-group>

              </v-row>
            </v-col>
          </v-row>
          <v-row class="mx-3">
            <!--Resource Fields-->
            <v-col cols="12" md="5">
              <v-autocomplete
                v-model="event.resourceCustomFieldId"
                :items="eventResourceFields"
                :disabled="!userCanEdit"
                label="Resource"
                @change="resourceFieldChanged = true"
                item-text="fieldName"
                item-value="id"
              ></v-autocomplete>
              <v-row class="flex-display">
                <multi-select-group
                  v-if="!eventLoading"
                  background-color="primary lighten-9"
                  :userCanEdit="userCanEdit"
                  :returnObject="event"
                  :content="positions"
                  :dropdownEnabled="event.resourceReadOnly"
                  :selectedContent="event.resourceWhiteListedPositions"
                  :title="'Read Only'"
                  :label="'Allowed Positions'"
                  :alternateLabel = "'Denied Positions'"
                  :allow="event.resourceReadOnlyAllow"
                  :contentLoading="positionsLoading"
                  @selected-changed="resourceReadOnlySelectedEventListener"
                  @allow-changed="resourceReadOnlyAllowEventListener"
                  @checkbox-changed="resourceReadOnlyCheckboxEventListener"></multi-select-group>

                <multi-select-group
                  v-if="!eventLoading"
                  background-color="primary lighten-9"
                  :userCanEdit="userCanEdit"
                  :returnObject="event"
                  :content="positions"
                  :dropdownEnabled="event.resourceHidden"
                  :selectedContent="event.resourceHiddenWhiteListedPositions"
                  :title="'Hidden'"
                  :label="'Allowed Positions'"
                  :alternateLabel = "'Denied Positions'"
                  :allow="event.resourceHiddenAllow"
                  :contentLoading="positionsLoading"
                  @selected-changed="resourceHiddenSelectedEventListener"
                  @allow-changed="resourceHiddenAllowEventListener"
                  @checkbox-changed="resourceHiddenCheckboxEventListener"></multi-select-group>
              </v-row>
            </v-col>
          </v-row>
        </v-card>
        <v-divider></v-divider>
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">Custom Field Groups</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" v-if="!createNew && userCanAdd" @click="createNew = !createNew">
              <v-icon>add</v-icon>
              <span v-if="!constants.IS_MOBILE">Create Group</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="createNew" text class="text-left one-hunned pa-3 square-card add-new" flat
                color="primary lighten-9">
          <div>
            <v-text-field
              label="Group Name"
              tabindex=1
              v-model="newGroup.groupName"
            ></v-text-field>
          </div>
          <v-btn
            color="primary"
            class="mr-2"
            :disabled="!newGroup.groupName"
            @click="saveFieldGroup()">
            Save
          </v-btn>
          <v-btn
            text color="primary"
            @click="[newGroup = {}, createNew = false]">
            Cancel
          </v-btn>
        </v-card>
        <v-row>
          <v-col cols="12">
            <v-data-table
              :key="componentKey"
              :headers="headers"
              :items="filterCustomFieldGroups()"
              :items-per-page="-1"
              single-expand
              :expanded.sync="expanded"
              hide-default-footer
              hide-default-header
              :sort-desc="[false]"
              :sort-by="['groupOrder']"
              class="elevation-1 fix-column-width-bug event-cfg-table square-card"
            >
              <template #no-data>
                <span class="default-text-color">No custom field groups for this event</span>
              </template>

              <template #no-results>
                <span class="default-text-color">No custom field groups for this event</span>
              </template>

              <template #item="{ item, index }">
                <tr :class="{'shaded-row': localCustomFieldGroups.indexOf(item) % 2}">
                  <td style="width: 50px">
                    <v-btn text icon small class="handle" v-if="userCanEdit">
                      <v-icon>drag_handle</v-icon>
                    </v-btn>
                  </td>
                  <td class="text-left">
                    <div v-if="userCanEdit">
                      <v-text-field text
                                    v-if="item.edit"
                                    v-model="item.groupName">
                        <template slot="append-outer">
                          <v-icon @click="[saveGroupName(item), item.edit = false]">save</v-icon>
                          <v-icon @click="item.edit = false">clear</v-icon>
                        </template>
                      </v-text-field>
                      <a style="text-decoration: underline;" v-else @click="item.edit = true">
                        {{ item.groupName }}
                      </a>
                    </div>
                    <span v-else>{{ item.groupName }}</span>
                  </td>
                  <td>
                    <div class="item-icons">
                      <v-tooltip left>
                        <template v-slot:activator="{ on, attrs }">
                          <v-btn icon color="primary" @click="copyToClipBoard(item.id)" v-bind="attrs"
                                 v-on="on"><v-icon>mdi-information</v-icon></v-btn>
                        </template>
                        <span>Custom Field Group Id: {{item.id}}</span>
                        <div class="text-center">(click to copy)</div>
                      </v-tooltip>
                      <v-btn v-if="userCanAdd" small text color="primary"
                             @click="[addField = !addField, selectedIndex = index, expanded = [item], fetchAvailableCustomFields(item.companyObjectTypeId, item.id)]">
                        <v-icon v-if="addField && expanded.includes(item)">remove</v-icon>
                        <v-icon v-else>add</v-icon>
                      </v-btn>
                      <v-btn small text color="primary"
                             @click="[expanded.includes(item) ? expanded = [] : expanded = [item], selectedIndex = index]">
                        <v-icon v-if="expanded.includes(item)">expand_less</v-icon>
                        <v-icon v-else>expand_more</v-icon>
                      </v-btn>
                      <v-btn v-if="userCanEdit" text color="primary" @click="cfgToDelete=item">
                        <v-icon>delete</v-icon>
                      </v-btn>
                    </div>
                  </td>
                </tr>
              </template>

              <template #expanded-item="{ headers, item }">
                <td :colspan="headers.length" class="pb-2 px-0" :class="{'shaded-row': selectedIndex % 2}">
                  <v-col cols="12" class="pl-3 pr-3 justify" v-if="addField">
                    <h3 class="text-left">Add New Field</h3>
                    <!--                    <v-radio-group v-model="newFieldType"-->
                    <!--                                   @change="fetchAvailableCustomFields(item.companyObjectTypeId, item.id)">-->
                    <!--                      <v-radio label="Native Field"-->
                    <!--                               value="native"></v-radio>-->
                    <!--                      <v-radio label="Reference Field: viewed only from process steps or other object types"-->
                    <!--                               value="ancillary"></v-radio>-->
                    <!--                    </v-radio-group>-->

                    <v-autocomplete v-model="newField"
                                    :items="availableCustomFields"
                                    label="New Custom Field"
                                    item-text="fieldName"
                                    return-object
                                    autocomplete="off"
                                    @input="assignCustomField(item)"
                    >
                      <template slot='item' slot-scope='{ item }'>
                        {{ item.fieldName }}
                      </template>
                    </v-autocomplete>
                    <v-btn text color="primary" @click="addField = false">Cancel</v-btn>
                  </v-col>
                  <v-col cols="12" class="px-3 py-0 pt-2 justify"
                         v-if="!addField && (!item.customFields || item.customFields.length === 0)">
                    No Custom Fields Added
                  </v-col>
                  <v-col cols="12" class="px-3 py-0 justify"
                         v-if="item.customFields && item.customFields.length > 0">
                    <draggable v-model="item.customFields" v-if="item.customFields && item.customFields.length > 0"
                               :disabled="!userCanEdit"
                               group="customFields" @start="drag=true" @end="drag=false"
                               @change="saveFieldChanges(item.customFields)">
                      <v-list v-for="(cf, index) in filterBy(item.customFields, false, 'archived')"
                              :key="index" class="pa-0" color="transparent">
                        <v-list-item :class="{grab: !item.eventId}">
                          <v-list-item-action>
                            <v-icon v-if="userCanEdit">drag_handle</v-icon>
                          </v-list-item-action>
                          <v-list-item-content>
                            <a :href="`/settings/customField/${cf.customFieldId}`">{{ cf.fieldName }} </a><span v-if="cf.customFieldGroupAssignmentReadOnly || cf.systemReadonly">(Read Only)</span>
                            <div>
                              Detail View:
                              <input :disabled="!userCanEdit" type="checkbox" class="ml-2" v-model="cf.detailView"
                                     @input="saveDetailView(cf)">
                            </div>
                            <div class="text-left mt-3" v-if="cf.edit">
                              <v-row>
                                <v-col cols="12">
                                  <v-row class="flex-display">
                                  <v-card flat :color="selectedIndex % 2 ? 'white' : 'primary lighten-9'"
                                          class="square-card px-4" style="width:50%">
                                    <v-card-text v-if="cf.systemReadonly" class="mt-2">
                                      System Readonly Cannot Change
                                    </v-card-text>
                                    <v-card-text v-else>
                                      <multi-select-group
                                        v-if="!eventLoading"
                                        background-color="primary lighten-9"
                                        :userCanEdit="userCanEdit"
                                        :returnObject="cf"
                                        :content="positions"
                                        :dropdownEnabled="cf.customFieldGroupAssignmentReadOnly"
                                        :selectedContent="cf.whiteListedPositions"
                                        :title="'Read Only'"
                                        :label="'Allowed Positions'"
                                        :alternateLabel = "'Denied Positions'"
                                        :allow="cf.customFieldGroupAssignmentReadOnlyAllow"
                                        :contentLoading="positionsLoading"
                                        @selected-changed="cfgReadOnlySelectedEventListener($event, cf)"
                                        @allow-changed="cfgReadOnlyAllowEventListener($event, cf)"
                                        @checkbox-changed="cfgReadOnlyCheckboxEventListener($event, cf)"></multi-select-group>
                           <br/>
                                      <v-btn color="primary" dark class="d-inline-block white--text"
                                             @click="saveReadOnlyAndWhiteList(cf)">
                                        <v-icon class="mr-2">save</v-icon>
                                        Save Read Only
                                      </v-btn>
                                    </v-card-text>
                                  </v-card>
                                  <v-card flat :color="selectedIndex % 2 ? 'white' : 'primary lighten-9'"
                                          class="square-card px-4" style="width:50%">
                                    <v-card-text>
                                      <multi-select-group
                                        v-if="!eventLoading"
                                        background-color="primary lighten-9"
                                        :userCanEdit="userCanEdit"
                                        :returnObject="cf"
                                        :content="positions"
                                        :dropdownEnabled="cf.customFieldGroupAssignmentHidden"
                                        :selectedContent="cf.hiddenWhiteListedPositions"
                                        :title="'Hidden'"
                                        :label="'Allowed Positions'"
                                        :alternateLabel = "'Denied Positions'"
                                        :allow="cf.customFieldGroupAssignmentHiddenAllow"
                                        :contentLoading="positionsLoading"
                                        @selected-changed="cfgHiddenSelectedEventListener($event, cf)"
                                        @allow-changed="cfgHiddenAllowEventListener($event, cf)"
                                        @checkbox-changed="cfgHiddenCheckboxEventListener($event, cf)"></multi-select-group>

                                      <br/>
                                      <v-btn color="primary" dark class="d-inline-block white--text"
                                             @click="saveHiddenAndWhiteList(cf)">
                                        <v-icon class="mr-2">save</v-icon>
                                        Save Hidden
                                      </v-btn>
                                    </v-card-text>
                                  </v-card>
                                  </v-row>
                                </v-col>
                              </v-row>
                            </div>
                          </v-list-item-content>
                          <v-tooltip left>
                            <template v-slot:activator="{ on, attrs }">
                              <v-btn icon color="primary" @click="copyToClipBoard(cf.customFieldGroupAssignmentId)" v-bind="attrs"
                                     v-on="on"><v-icon>mdi-information</v-icon></v-btn>
                            </template>
                            <span>Custom Field Group Assignment Id: {{cf.customFieldGroupAssignmentId}}</span>
                            <div class="text-center">(click to copy)</div>
                          </v-tooltip>
                          <v-btn text color="primary" small v-if="userCanEdit" @click="[$set(cf, 'edit', !cf.edit)]">
                            <v-icon>edit</v-icon>
                          </v-btn>
                          <v-menu offset-y
                                  v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">
                            <template v-slot:activator="{ on: menu }">
                              <v-tooltip bottom>
                                <template v-slot:activator="{ on: tooltip }">
                                  <v-btn text small color="primary" v-on="{...tooltip, ...menu}"
                                         v-if="!cf.ancillaryCustomFieldGroupAssignmentId">
                                    <v-icon>mdi-cursor-move</v-icon>
                                  </v-btn>
                                </template>
                                <span>Move to Other Group</span>
                              </v-tooltip>
                            </template>
                            <v-list>
                              <v-list-item
                                v-for="(cfg, index) in filterBy(localCustomFieldGroups, (g) => { return g.id !== cf.customFieldGroupId && !g.eventId })"
                                :key="index" @click="moveFieldToOtherGroup(cf, cfg)">
                                <v-list-item-title>{{ cfg.groupName }}</v-list-item-title>
                              </v-list-item>
                            </v-list>
                          </v-menu>
                          <v-btn text color="primary" v-if="userCanEdit" @click="[cFieldToDelete=cf]">
                            <v-icon>delete</v-icon>
                          </v-btn>
                        </v-list-item>
                        <v-divider v-if="cf.edit"></v-divider>
                      </v-list>
                    </draggable>
                  </v-col>
                </td>
              </template>
            </v-data-table>
          </v-col>
        </v-row>
        <v-card>
          <div v-if="userIsAdmin" class="snippet-selector-grid">
            <div class="label-medium">Field to Display on Event Snippet</div>
            <v-autocomplete
                label="Custom Field Group"
                v-model="cfgToDisplayOnSnippet"
                return-object
                clearable
                item-text="groupName"
                :items="filterCustomFieldGroups()"/>
            <v-autocomplete
                v-if="cfgToDisplayOnSnippet"
                label="Custom Field"
                v-model="cfToDisplayOnSnippet"
                :items="cfgToDisplayOnSnippet.customFields"
                item-text="fieldName"
                item-value="id"
                return-object
            />
            <v-btn v-if="cfToDisplayOnSnippet" @click="saveCfToDisplayOnSnippet" color="primary"><v-icon class="mr-2">save</v-icon>save field to display</v-btn>
          </div>
          <div v-else class="pa-5 d-flex align-baseline" style="gap: 1rem">
            <div class="label-medium">Field to Display on Event Snippet: </div>
            <div>{{ cfToDisplayOnSnippet?.fieldName || 'none' }}</div>
          </div>
        </v-card>
      </v-col>
    </v-row>

    <ConfirmationDialog
      :open-dialog="cfgToDelete && !cFieldToDelete"
      @confirm="deleteWithChecks(cfgToDelete, cfgToDelete.id, null)"
      @close-dialog="cfgToDelete=null">
      <span class="error--text">WARNING:</span>
      By deleting a Custom Field Group you will lose all data associated with fields in the group.<br/><br/>
      Are you sure you want to delete this Custom Field Group: <strong>{{ cfgToDeleteName }}</strong>?
    </ConfirmationDialog>
    <ConfirmationDialog
      :open-dialog="!!cFieldToDelete"
      @confirm="[addField=false, newField={}, deleteWithChecks(cFieldToDelete, null, cFieldToDelete.id)]"
      @close-dialog="[cfgToDelete = null, cFieldToDelete = null]">
      <span class="error--text">WARNING:</span>
      By deleting a field you will lose all data associated with the field. If you meant to "move" the field to another
      group please cancel and move the field. <br/><br/>
      Are you sure you want to delete this field from {{ cfgToDeleteName }}: <strong>{{ cFieldToDeleteName }}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script>
import Vue2Filters from 'vue2-filters'
import draggable from 'vuedraggable'
import {AppMutations} from '@/stores/AppStore'
import {getEventTypes} from '@/services/scheduleService'
import {
  getRequest,
  putRequest,
  deleteRequest,
  postRequest,
  getRequestWithParams,
  getSnackbar
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import Sortable from "sortablejs";
import cloneDeep from 'lodash.clonedeep'
import orderBy from "lodash.orderby"
import ConfirmationDialog from "@/components/ConfirmationDialog";
import MultiSelectGroup from "../../../../components/MultiSelectGroup";

const WhiteListTypeEnum = Object.freeze({
  EVENT_START_TIME_READ_ONLY: 6,
  EVENT_END_TIME_READ_ONLY: 7,
  EVENT_RESOURCE_READ_ONLY: 8,
  EVENT_START_TIME_HIDDEN: 14,
  EVENT_END_TIME_HIDDEN: 15,
  EVENT_RESOURCE_HIDDEN: 16
});

export default {
  name: 'EventCustomFieldGroups',
  mixins: [Vue2Filters.mixin],
  components: {
    MultiSelectGroup,
    ConfirmationDialog,
    draggable,
  },
  updated() {
    // this had to be in updated vs mounted so that after the re-render the dragging still works
    let table = document.querySelector('.event-cfg-table tbody')
    const _self = this
    Sortable.create(table, {
      handle: '.handle',
      onEnd({newIndex, oldIndex}) {
        if (_self.localCustomFieldGroups?.length > 0) {
          const rowSelected = _self.localCustomFieldGroups.splice(oldIndex, 1)[0]
          _self.localCustomFieldGroups.splice(newIndex, 0, rowSelected)
          let rowsClone = cloneDeep(_self.localCustomFieldGroups)

          let rowsToSave = []
          rowsClone.forEach((r, idx) => {
            //check if the row needs to be saved before updating display order
            //todo: vuetify table sorting is doing something weird where it won't sort right if i update the actual display order. hacked around it for now _rn
            let save = r.newGroupOrder === undefined ? r.groupOrder !== idx : r.newGroupOrder !== idx
            //update display order
            r.groupOrder = idx
            //save only rows that changed
            if (save) {
              _self.localCustomFieldGroups[idx].newGroupOrder = idx
              rowsToSave.push(r)
            }
          })
          _self.saveRowChanges(rowsToSave)
        }
      }
    })
  },
  data() {
    return {
      snackbar: {},
      componentKey: 0,
      deleteError: false,
      deleteHeader: null,
      deleteText: null,
      fieldsInUse: [],
      positions: [],
      positionsLoading: false,
      resourceFieldChanged: false,
      constants,
      newGroup: {},
      event: {},
      newField: {},
      // selectedIndex is a dumb work around because `index` is not available in the `expanded-item` slot yet.
      selectedIndex: null,
      createNew: false,
      newFieldType: 'native',
      addField: false,
      selectedGroupId: null,
      availableCustomFields: [],
      parent: {},
      eventId: this.$route.params.id,
      userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADMIN'),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
      companyId: this.$store.state.user.details.companyId,
      parentObjects: [],
      selectedAncillaryField: {},
      ancillaryCustomFields: [],
      headers: [
        {text: null, value: 'draggable', width: '50px', show: true, sortable: false},
        {text: 'Name', value: 'groupName', show: true},
        {text: null, value: 'icons', show: true}
      ],
      expanded: [],
      eventResourceFields: [],
      eventTypes: [],
      cfgToDisplayOnSnippet: null,
      cfToDisplayOnSnippet: null,
      cfgToDelete: null,
      cFieldToDelete: null,
      WhiteListTypeEnum
    }
  },
  watch: {
    cfgToDisplayOnSnippet() {
      if (this.cfgToDisplayOnSnippet === null){
        this.event.snippetCustomField = null
      }
    }
  },
  computed: {
    localCustomFieldGroups: {
      get: function () {
        return this.event?.customFieldGroups
      },
      set: function (val) {
        val.forEach(v => {
          v.groupOrder = v.newGroupOrder ?? v.groupOrder
        })
        return orderBy(val, v => v.groupOrder)
      }
    },
    cfgToDeleteName() {
      return this.cfgToDelete ? this.cfgToDelete.groupName : ''
    },
    cFieldToDeleteName() {
      return this.cFieldToDelete ? this.cFieldToDelete.fieldName : ''
    }
  },
  async created() {
    this.getEventResourceFields()
    this.getPositions()
    await this.getEvent()
  },
  methods: {
    async getEventResourceFields() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/customFieldGroup/getEventResourceFields`)
        this.eventResourceFields = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getEvent() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.eventLoading = true;
        const {data} = await getRequest(`/event/${this.eventId}`)
        this.event = data
        this.getDisplayOnSnippet()
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.eventLoading = false;
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    getDisplayOnSnippet(){
      for(let cfg of this.event.customFieldGroups){
        const customFieldToDisplay = cfg.customFields.find(cf => cf.displayOnSnippet === true)
        if(customFieldToDisplay) {
          this.cfgToDisplayOnSnippet = cfg
          this.cfToDisplayOnSnippet = customFieldToDisplay
          break
        }
      }

    },
    startTimeReadOnlySelectedEventListener(e){
      this.event.startTimeWhiteListedPositions = e;
      this.event.startTimePositionsChanged = true;
    },
    startTimeReadOnlyAllowEventListener(e){
      this.event.startTimeReadOnlyAllow = (e === 0);
    },
    startTimeReadOnlyCheckboxEventListener(e){
      this.event.startTimeReadOnly = e;
    },
    startTimeHiddenSelectedEventListener(e){
      this.event.startTimeHiddenWhiteListedPositions = e;
      this.event.startTimeHiddenPositionsChanged = true;
    },
    startTimeHiddenAllowEventListener(e){
      this.event.startTimeHiddenAllow = (e === 0);
    },
    startTimeHiddenCheckboxEventListener(e){
      this.event.startTimeHidden = e;
    },
    endTimeReadOnlySelectedEventListener(e){
      this.event.endTimeWhiteListedPositions = e;
      this.event.endTimePositionsChanged = true;
    },
    endTimeReadOnlyAllowEventListener(e){
      this.event.endTimeReadOnlyAllow = (e === 0);
    },
    endTimeReadOnlyCheckboxEventListener(e){
      this.event.endTimeReadOnly = e;
    },
    endTimeHiddenSelectedEventListener(e){
      this.event.endTimeHiddenWhiteListedPositions = e;
      this.event.endTimeHiddenPositionsChanged = true;
    },
    endTimeHiddenAllowEventListener(e){
      this.event.endTimeHiddenAllow = (e === 0);
    },
    endTimeHiddenCheckboxEventListener(e){
      this.event.endTimeHidden = e;
    },
    resourceReadOnlySelectedEventListener(e){
      this.event.resourceWhiteListedPositions = e;
      this.event.resourcePositionsChanged = true;
    },
    resourceReadOnlyAllowEventListener(e){
      this.event.resourceReadOnlyAllow = (e === 0);
    },
    resourceReadOnlyCheckboxEventListener(e){
      this.event.resourceReadOnly = e;
    },
    resourceHiddenSelectedEventListener(e){
      this.event.resourceHiddenWhiteListedPositions = e;
      this.event.resourceHiddenPositionsChanged = true;
    },
    resourceHiddenAllowEventListener(e){
      this.event.resourceHiddenAllow = (e === 0);
    },
    resourceHiddenCheckboxEventListener(e){
      this.event.resourceHidden = e;
    },
    cfgReadOnlySelectedEventListener(e, cf){
      cf.whiteListedPositions = e;
      cf.positionsChanged = true;
    },
    cfgReadOnlyAllowEventListener(e, cf){
      cf.customFieldGroupAssignmentReadOnlyAllow = (e == 0);
      cf.positionsChanged = true;
    },
    cfgReadOnlyCheckboxEventListener(e, cf){
      cf.customFieldGroupAssignmentReadOnly = e;
      cf.positionsChanged = true;
    },
    cfgHiddenSelectedEventListener(e, cf){
      cf.hiddenWhiteListedPositions = e;
      cf.hiddenPositionsChanged = true;
    },
    cfgHiddenAllowEventListener(e, cf){
      cf.customFieldGroupAssignmentHiddenAllow = (e == 0);
      cf.hiddenPositionsChanged = true;
    },
    cfgHiddenCheckboxEventListener(e, cf){
      cf.customFieldGroupAssignmentHidden = e;
      cf.hiddenPositionsChanged = true;
    },
    selectAll(f, fieldName) {
      return f[fieldName]?.length === this.positions?.length
    },
    selectSome(f, fieldName) {
      return f[fieldName]?.length > 0 && !this.selectAll(f)
    },
    icon(f, fieldName) {
      if (this.selectAll(f, fieldName)) {
        return 'check_box'
      }
      if (this.selectSome(f, fieldName)) {
        return 'indeterminate_check_box'
      }
      return 'check_box_outline_blank'
    },
    async saveChangesToDefaultFields() {
      //save the read only and resource custom fields
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await postRequest(`/event/${this.eventId}/saveChangesToDefaultFields`, this.event)
        if (this.event.startTimePositionsChanged || (!this.event.startTimeReadOnly && this.event.startTimeWhiteListedPositions?.length > 0)) {
          this.saveWhiteListedPositions(WhiteListTypeEnum.EVENT_START_TIME_READ_ONLY, (!this.event.startTimeReadOnly && this.event.startTimeWhiteListedPositions?.length > 0) ? [] : this.event.startTimeWhiteListedPositions)
        }
        if (this.event.startTimeHiddenPositionsChanged || (!this.event.startTimeHidden && this.event.startTimeHiddenWhiteListedPositions?.length > 0)) {
          this.saveWhiteListedPositions(WhiteListTypeEnum.EVENT_START_TIME_HIDDEN, (!this.event.startTimeHidden && this.event.startTimeHiddenWhiteListedPositions?.length > 0) ? [] : this.event.startTimeHiddenWhiteListedPositions)
        }
        if (this.event.endTimePositionsChanged || (!this.event.endTimeReadOnly && this.event.endTimeWhiteListedPositions?.length > 0)) {

          for (var i = 0; i < this.event.endTimeWhiteListedPositions.length; i++) {
            this.event.endTimeWhiteListedPositions[i].allowFlag = true;
            //Do something
          }

          this.saveWhiteListedPositions(WhiteListTypeEnum.EVENT_END_TIME_READ_ONLY, (!this.event.endTimeReadOnly && this.event.endTimeWhiteListedPositions?.length > 0) ? [] : this.event.endTimeWhiteListedPositions)
        }
        if (this.event.endTimeHiddenPositionsChanged || (!this.event.endTimeHidden && this.event.endTimeHiddenWhiteListedPositions?.length > 0)) {
          this.saveWhiteListedPositions(WhiteListTypeEnum.EVENT_END_TIME_HIDDEN, (!this.event.endTimeHidden && this.event.endTimeHiddenWhiteListedPositions?.length > 0) ? [] : this.event.endTimeHiddenWhiteListedPositions)
        }
        if (this.event.resourcePositionsChanged || (!this.event.resourceReadOnly && this.event.resourceWhiteListedPositions?.length > 0)) {
          this.saveWhiteListedPositions(WhiteListTypeEnum.EVENT_RESOURCE_READ_ONLY, (!this.event.resourceReadOnly && this.event.resourceWhiteListedPositions?.length > 0) ? [] : this.event.resourceWhiteListedPositions)
        }
        if (this.event.resourceHiddenPositionsChanged || (!this.event.resourceHidden && this.event.resourceHiddenWhiteListedPositions?.length > 0)) {
          this.saveWhiteListedPositions(WhiteListTypeEnum.EVENT_RESOURCE_HIDDEN, (!this.event.resourceHidden && this.event.resourceHiddenWhiteListedPositions?.length > 0) ? [] : this.event.resourceHiddenWhiteListedPositions)
        }
        this.snackbar = getSnackbar('SUCCESS', 'Event Changes Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Changes')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveWhiteListedPositions(whiteListTypeId, whiteListedPositions) {
      try {
        await putRequest(`/event/${this.eventId}/saveWhiteListPositions/${whiteListTypeId}`, whiteListedPositions)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveDetailView(cf) {
      //because the the dumb dom i have to flip the detailView before I save it
      let detailViewValue = !cf.detailView
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await putRequest(`/customFieldGroup/saveDetailView/${cf.customFieldGroupAssignmentId}?detailView=${detailViewValue}`)
        this.snackbar = getSnackbar('SUCCESS', 'Value Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveCfToDisplayOnSnippet(){
      debugger;
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await putRequest(`/customFieldGroup/saveDisplayOnSnippet/${this.cfToDisplayOnSnippet.customFieldGroupAssignmentId}`)
        this.snackbar = getSnackbar('SUCCESS', 'Custom Field to Display on Snippet Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Custom Field to Display on Snippet')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveFieldGroup() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newGroup.eventId = this.$route.params.id

        const {data} = await postRequest(`/customFieldGroup/addEventCustomFieldGroup`, this.newGroup)
        this.localCustomFieldGroups.push(data)
        this.newGroup = {}
        this.createNew = false
        this.snackbar = getSnackbar('SUCCESS', 'Group Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Group')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteWithChecks(item, customFieldGroupId, customFieldGroupAssignmentId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let url = customFieldGroupAssignmentId ? `/customFieldGroup/deleteFieldFromGroup/${customFieldGroupAssignmentId}` : `/customFieldGroup/${customFieldGroupId}`
        await deleteRequest(url)
        this.fieldsInUse = []
        item.archived = true
        this.snackbar = getSnackbar('SUCCESS', 'Item Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.cfgToDelete = null
      this.cFieldToDelete = null
    },
    async saveGroupName(group) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await putRequest(`/customFieldGroup/updateCustomFieldGroup`, group)
        this.snackbar = getSnackbar('SUCCESS', 'Group Name Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Change')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async moveFieldToOtherGroup(field, newGroup) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await postRequest(`/customFieldGroup/moveFieldToOtherGroup/${newGroup.id}`, field)
        this.snackbar = getSnackbar('SUCCESS', 'Field Moved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        //currently reloading the page because moving the field in the UI seems too hard (even though it isn't i just cant make myself do it right now)
        window.location.reload()
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Moving Field')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async fetchAvailableCustomFields(objectTypeId, groupId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        if (this.addField && this.newFieldType === 'native') {
          const {data} = await getRequestWithParams(`/customFieldGroup/getAvailableCustomFields`, {
            params: {
              companyObjectTypeId: objectTypeId,
              groupId,
              eventId: this.eventId
            }
          })
          this.availableCustomFields = data
          this.parentObjects = []
          this.ancillaryCustomFields = []
        } else if (this.addField && this.newFieldType === 'ancillary') {
          this.availableCustomFields = []
          const {data} = await getRequestWithParams(`/processStep/getParentObjectsWithTypes`, {params: {id: this.processStepId}})
          this.selectedAncillaryField = {}
          this.parentObjects = data
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async loadFieldsByParent() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        if (this.parent.isProcessStep) {
          const {data} = await getRequest(`/customField/getByParentProcessStep/${this.parent.id}`)
          this.ancillaryCustomFields = data
        } else {
          const {data} = await getRequest(`/customField/getByParentType/${this.parent.id}`)
          this.ancillaryCustomFields = data
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveUseParentData(field) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await putRequest(`/customFieldGroup/saveUseParentData`, field)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Field')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveReadOnlyAndWhiteList(field) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await putRequest(`/customFieldGroup/saveReadOnlyAndWhiteList?savePositions=${field.positionsChanged ?? false}`, field)
        field.positionsChanged = false
        if (!field.customFieldGroupAssignmentReadOnly) {
          this.$set(field, 'whiteListedPositions', [])
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Field')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveHiddenAndWhiteList(field) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await putRequest(`/customFieldGroup/saveHiddenAndWhiteList?savePositions=${field.hiddenPositionsChanged ?? false}`, field)
        field.hiddenPositionsChanged = false
        if (!field.customFieldGroupAssignmentHidden) {
          this.$set(field, 'hiddenWhiteListedPositions', [])
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Field')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveFieldChanges(fields) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        // if the fieldOrder of any item does not match idx + 1, it means it was changed and needs to be saved
        // pull those needing to be saved out of list
        let fieldsToSave = []
        fields.forEach((f, idx) => {
          let order = idx + 1
          if (f.fieldOrder !== order) {
            f.fieldOrder = order
            fieldsToSave.push(f)
          }
        })
        // save them here
        if (fieldsToSave.length > 0) {
          await putRequest(`/customFieldGroup/updateFieldsInGroup`, fieldsToSave)
        }
        this.snackbar = getSnackbar('SUCCESS', 'Fields Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }

    },
    async assignCustomField(cfg) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addField = false
        this.newField.customFieldGroupId = cfg.id
        //this line makes pushing it to the list work
        this.newField.archived = false

        const {data} = await postRequest(`/customFieldGroup/addFieldToGroup`, this.newField)
        cfg.customFields.push(data)
        this.newField = {}
        this.snackbar = getSnackbar('SUCCESS', 'Custom Field Assigned')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Assigning Custom Field')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async assignAncillaryCustomField(cfg) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const params = {
          customFieldGroupId: cfg.id,
          id: null,
          ancillaryCustomFieldGroupAssignmentId: this.selectedAncillaryField.customFieldGroupAssignmentId,
          fieldOrder: 0
        }
        const {data} = await postRequest(`/customFieldGroup/addFieldToGroup`, params)
        cfg.customFields.push(data)
        this.selectedAncillaryField = {}
        this.addField = false
        this.parent = {}
        this.snackbar = getSnackbar('SUCCESS', 'Reference Field Assigned')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Assigning Reference Field')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    filterCustomFieldGroups() {
      return this.localCustomFieldGroups?.filter(cfg => {
        return !cfg.archived
      })
    },
    async getEventTypes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getEventTypes()
        this.eventTypes = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveRowChanges(rows) {
      if (rows?.length > 0) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await putRequest(`/customFieldGroup/updateCustomFieldGroups`, rows)
          this.localCustomFieldGroups = orderBy(this.localCustomFieldGroups, 'groupOrder')
          this.snackbar = getSnackbar('SUCCESS', 'Group Order Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          // this componentKey forces the data-table component to re-render
          this.componentKey += 1
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Group Order')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async getPositions() {
      if (this.positions?.length === 0) {
        try {
          this.positionsLoading = true
          const {data} = await getRequest(`/position/withParent`)
          this.positions = data
          this.positionsLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          this.positionsLoading = false
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Positions')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    toggleHiddenSelectAllPositions(field, fieldName) {
      this.$nextTick(() => {
        if (this.selectAll(field, fieldName)) {
          field[fieldName] = []
          field.hiddenPositionsChanged = true
        } else {
          field[fieldName] = cloneDeep(this.positions)
          field.hiddenPositionsChanged = true
        }
      })
    },
    toggleSelectAllPositions(item, wlpField) {
      this.$nextTick(() => {
        if (this.selectAll(item, wlpField)) {
          item[wlpField] = []
          item.positionsChanged = true
        } else {
          item[wlpField] = cloneDeep(this.positions)
          item.positionsChanged = true
        }
      })
    },
    copyToClipBoard(textValue){
      navigator.clipboard.writeText(textValue);
      this.snackbar = getSnackbar('SUCCESS', 'Copied text to clipboard')
      this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
    }

  }

}
</script>

<style scoped lang="scss">
.custom-field-group {
  border: solid 1px var(--v-primary-lighten9) !important;
}

.custom-field-group-border {
  border-bottom: solid 1px var(--v-primary-lighten9) !important;
}

.item-icons {
  display: flex;
  float: right;
}

.color-swatch {
  height: 30px;
  width: 30px;
  border-radius: 5px;
}

.cfg-header-bar {
  border-bottom: 1px solid #E6E6E6;
}

.add-new {
  border-bottom: 1px solid #E6E6E6;
}

.snippet-selector-grid {
  display: grid;
  grid-template-columns: 2fr 3fr 3fr 2fr;
  column-gap: 2rem;
  align-items: baseline;
  padding: 1rem;
  margin-right: 1rem;
}
.snippet-selector-background {
  background-color: var(--v-grey-lighten4);
}

</style>
