<template>
  <v-container class="pt-0 px-0">
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-form ref="defaultFieldForm">
          <v-toolbar flat class="cfg-header-bar">
            <v-toolbar-title class="title-large">Default Event Fields</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items class="flex-display">
              <div class="flex-display align-center">
                <a-btn class="save-btn text-capitalize"
                       @click="saveChangesToDefaultFields"
                       color="primary"
                       v-if="userCanEdit"
                       text="Save Default Event Fields"
                />
              </div>
            </v-toolbar-items>
          </v-toolbar>
          <v-card color="transparent">
            <v-row class="mx-3" cols="12">
              <!--Start Time White Listed Fields-->
              <v-col cols="12" md="5" class="py-0">
                <a-text-field
                  label="Start Time"
                  readonly disabled
                  single-line
                  hide-details
                ></a-text-field>
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
                    full-size
                    @selected-changed="startTimeHiddenSelectedEventListener"
                    @allow-changed="startTimeHiddenAllowEventListener"
                    @checkbox-changed="startTimeHiddenCheckboxEventListener"></multi-select-group>

                </v-row>
              </v-col>
              <v-col style="height: 0" cols="0" md="1"></v-col>
              <!--End Time White Listed Fields-->
              <v-col cols="12" md="5" class="py-0">
                <a-text-field
                  label="End Time"
                  readonly disabled
                  single-line
                  hide-details
                ></a-text-field>
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
                    full-size
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
                    full-size
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
                  :rules="requiredRules"
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
                    full-size
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
                    full-size
                    @selected-changed="resourceHiddenSelectedEventListener"
                    @allow-changed="resourceHiddenAllowEventListener"
                    @checkbox-changed="resourceHiddenCheckboxEventListener"></multi-select-group>
                </v-row>
              </v-col>
            </v-row>
          </v-card>
        </v-form>
        <v-divider></v-divider>
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="title-large">Custom Field Groups</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn variant="text"
                             color="primary"
                             v-if="!createNew && userCanAdd"
                             @click="createNew = !createNew"
                             prepend-icon="add"
                             :text="!constants.IS_MOBILE ? 'Create Group' : ''"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="createNew" text class="text-left one-hunned pa-3 square-card add-new" flat
                color="primary lighten-9">
          <div>
            <a-text-field
              label="Group Name"
              tabindex=1
              v-model="newGroup.groupName"
            ></a-text-field>
          </div>
          <a-btn
            color="primary"
            class="mr-2"
            :disabled="!newGroup.groupName"
            @click="saveFieldGroup()"
            text="SAVE"
          />
          <a-btn
            variant="text" color="primary"
            @click="[newGroup = {}, createNew = false]"
            text="CANCEL"
          />
        </v-card>
        <v-row>
          <v-col cols="12">
            <v-data-table
              :key="componentKey"
              :headers="headers"
              :items="filterCustomFieldGroups"
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
                    <a-btn variant="text" icon size="small"
                                     class="handle" v-if="userCanEdit"
                                     prepend-icon="drag_handle"
                    />
                  </td>
                  <td class="text-left">
                    <div v-if="userCanEdit">
                      <a-text-field
                                    v-if="item.edit"
                                    v-model="item.groupName">
                        <template slot="append-outer">
                          <v-icon @click="[saveGroupName(item), item.edit = false]">save</v-icon>
                          <v-icon @click="item.edit = false">clear</v-icon>
                        </template>
                      </a-text-field>
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
                          <a-btn variant="text"
                                           icon
                                           color="primary"
                                           @click="copyToClipBoard(item.id)" v-bind="attrs"
                                           :activation-handler="on"
                                           prepend-icon="mdi-information"
                          />
                        </template>
                        <span>Custom Field Group Id: {{item.id}}</span>
                        <div class="text-center">(click to copy)</div>
                      </v-tooltip>
                      <a-btn v-if="userCanAdd" variant="text" size="small" color="primary"
                                       @click="[addField = !addField, selectedIndex = index, expanded = [item], fetchAvailableCustomFields(item.companyObjectTypeId, item.id)]"
                                       :prepend-icon="addField && expanded.includes(item) ? 'remove' : 'add'"
                      />
                      <a-btn size="small" variant="text" color="primary"
                             @click="[expanded.includes(item) ? expanded = [] : expanded = [item], selectedIndex = index]"
                             :prepend-icon="expanded.includes(item) ? 'expand_less' : 'expand_more'"
                      />
                      <a-btn v-if="userCanEdit" variant="text"
                                       color="primary" @click="cfgToDelete=item"
                                       prepend-icon="delete"
                      />
                    </div>
                  </td>
                </tr>
              </template>

              <template #expanded-item="{ headers, item }">
                <td :colspan="headers.length" class="pb-2 px-0" :class="{'shaded-row': selectedIndex % 2}">
                  <v-col cols="12" class="pl-3 pr-3 justify" v-if="addField">
                    <h3 class="text-left">Add New Field</h3>
                    <v-radio-group v-model="newFieldType"
                                   @change="fetchAvailableCustomFields(item.companyObjectTypeId, item.id)">
                      <v-radio label="Native Field"
                               value="native"></v-radio>
                      <v-radio label="Reference Field: viewed only from process steps or other object types"
                               value="ancillary"></v-radio>
                    </v-radio-group>

                    <v-autocomplete v-model="newField"
                                    v-if="newFieldType === 'native'"
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
                    <v-autocomplete v-if="newFieldType === 'ancillary'"
                                    v-model="parent"
                                    :items="parentObjects"
                                    label="Parent Object"
                                    item-text="name"
                                    return-object
                                    autocomplete="off"
                                    @input="loadFieldsByParent"
                    >
                      <template slot='item' slot-scope='{ item }'>
                        {{ item.name }}
                      </template>
                    </v-autocomplete>
                    <v-autocomplete v-if="newFieldType === 'ancillary'"
                                    v-model="selectedAncillaryField"
                                    :items="ancillaryCustomFields"
                                    label="Custom Field"
                                    item-text="fieldName"
                                    return-object
                                    autocomplete="off"
                                    @input="assignAncillaryCustomField(item)"
                    >
                      <template slot='item' slot-scope='{ item }'>
                        {{ item.fieldName }}
                      </template>
                    </v-autocomplete>
                    <a-btn variant="text"
                                     color="primary"
                                     @click="addField = false"
                                     text="CANCEL"
                    />
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
                      <v-list v-for="(cf, index) in item.customFields.filter(a => !a.archived)"
                              :key="index" class="pa-0" color="transparent">
                        <v-list-item :class="{grab: !item.eventId}">
                          <v-list-item-action>
                            <v-icon v-if="userCanEdit">drag_handle</v-icon>
                          </v-list-item-action>
                          <v-list-item-content>
                            <div v-if="cf.ancillaryCustomFieldGroupAssignmentId">
                              <a :href="`/settings/customField/${cf.customFieldId}`">{{ cf.processStepName || cf.objectType }}: {{ cf.groupName }} - {{ cf.fieldName }} (Ancillary) {{ cf.customFieldGroupAssignmentHidden ? '(Hidden)' : ''}}</a>
                            </div>
                            <div v-else>
                              <a :href="`/settings/customField/${cf.customFieldId}`">{{ cf.fieldName }} </a>
                              <span v-if="cf.customFieldGroupAssignmentReadOnly || cf.systemReadonly">(Read Only)</span>
                            </div>
                            <div>
                              Detail View:
                              <input :disabled="!userCanEdit" :readonly="!userCanEdit" type="checkbox" class="ml-2" v-model="cf.detailView"
                                     @input="saveDetailView(cf)">
                            </div>
                            <div v-if="cf.ancillaryCustomFieldGroupAssignmentId && cf.processStepName">
                              Use Parent Data:
                              <input :disabled="!userCanEdit" :readonly="!userCanEdit" type="checkbox" class="ml-2" v-model="cf.useParentData"
                                     @input="saveUseParentData(cf)">
                            </div>
                            <div class="text-left mt-3" v-if="cf.edit">
                              <v-row>
                                <v-col cols="12">
                                  <v-row class="flex-display">
                                  <v-card flat
                                          v-if="!cf.ancillaryCustomFieldGroupAssignmentId"
                                          :color="selectedIndex % 2 ? 'white' : 'primary lighten-9'"
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
                                        :allow="cf.customFieldGroupAssignmentReadOnlyAllow || null == cf.customFieldGroupAssignmentReadOnlyAllow"
                                        :contentLoading="positionsLoading"
                                        save-button
                                        save-button-text="Save Read Only"
                                        full-size
                                        @selected-changed="cfgReadOnlySelectedEventListener($event, cf)"
                                        @allow-changed="cfgReadOnlyAllowEventListener($event, cf)"
                                        @checkbox-changed="cfgReadOnlyCheckboxEventListener($event, cf)"
                                        @save-multi-select="saveReadOnlyAndWhiteList(cf)"
                                      ></multi-select-group>
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
                                        :allow="cf.customFieldGroupAssignmentHiddenAllow || null == cf.customFieldGroupAssignmentHiddenAllow"
                                        :contentLoading="positionsLoading"
                                        full-size
                                        @selected-changed="cfgHiddenSelectedEventListener($event, cf)"
                                        @allow-changed="cfgHiddenAllowEventListener($event, cf)"
                                        @checkbox-changed="cfgHiddenCheckboxEventListener($event, cf)"></multi-select-group>

                                      <br/>
                                      <a-btn color="primary"
                                                       dark
                                                       class="d-inline-block white--text"
                                                       @click="saveHiddenAndWhiteList(cf)"
                                                       prepend-icon="save"
                                                       text="Save Hidden"
                                      />
                                    </v-card-text>
                                  </v-card>
                                  </v-row>
                                </v-col>
                              </v-row>
                            </div>
                          </v-list-item-content>
                          <v-tooltip left>
                            <template v-slot:activator="{ on, attrs }">
                              <a-btn variant="text" icon
                                               color="primary"
                                               @click="copyToClipBoard(cf.customFieldGroupAssignmentId)"
                                               v-bind="attrs"
                                               :activation-handler="on"
                                               prepend-icon="mdi-information"
                              />
                            </template>
                            <span>Custom Field Group Assignment Id: {{cf.customFieldGroupAssignmentId}}</span>
                            <div class="text-center">(click to copy)</div>
                          </v-tooltip>
                          <a-btn variant="text"
                                           color="primary"
                                           size="small"
                                           v-if="userCanEdit"
                                           @click="[$set(cf, 'edit', !cf.edit)]"
                                           prepend-icon="edit"
                          />
                          <v-menu offset-y
                                  v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">
                            <template v-slot:activator="{ on: menu }">
                              <v-tooltip bottom>
                                <template v-slot:activator="{ on: tooltip }">
                                  <a-btn variant="text" size="small"
                                                   color="primary" :activation-handler="{...tooltip, ...menu}"
                                                   v-if="!cf.ancillaryCustomFieldGroupAssignmentId"
                                                   prepend-icon="mdi-cursor-move"
                                  />
                                </template>
                                <span>Move to Other Group</span>
                              </v-tooltip>
                            </template>
                            <v-list>
                              <v-list-item
                                v-for="(cfg, index) in localCustomFieldGroups.filter((g) => { return g.id !== cf.customFieldGroupId && !g.eventId })"
                                :key="index" @click="moveFieldToOtherGroup(cf, cfg)">
                                <v-list-item-title>{{ cfg.groupName }}</v-list-item-title>
                              </v-list-item>
                            </v-list>
                          </v-menu>
                          <a-btn variant="text"
                                           color="primary"
                                           v-if="userCanEdit"
                                           @click="[cFieldToDelete=cf]"
                                           prepend-icon="delete"
                          />
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
                :items="filterCustomFieldGroups"/>
            <v-autocomplete
                v-if="cfgToDisplayOnSnippet"
                label="Custom Field"
                v-model="cfToDisplayOnSnippet"
                :items="nonAncillaryGfgFields(cfgToDisplayOnSnippet.customFields)"
                item-text="fieldName"
                item-value="id"
                return-object
            />
            <a-btn
              v-if="cfToDisplayOnSnippet"
              @click="saveCfToDisplayOnSnippet"
              color="primary"
              prepend-icon="save"
              text="Save Field to Display"
            />
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

<script setup>
import draggable from 'vuedraggable'

import {getEventTypes} from '@/services/scheduleService'
import {
  getRequest,
  putRequest,
  deleteRequest,
  postRequest,
  getRequestWithParams,
  handleHidingGlobalLoader,
  defineSortableTable
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import cloneDeep from 'lodash.clonedeep'
import orderBy from "lodash.orderby"
import { getEventResourceFields } from "@/services/eventService"
import ConfirmationDialog from "@/components/ConfirmationDialog";
import MultiSelectGroup from "@/components/MultiSelectGroup";


import {ref, computed, onMounted, getCurrentInstance, watch} from "vue";
import { useUserStore } from '@/stores/UserStorePinia.js'
import {useRoute} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStorePinia.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()
const snackbar = vueInstance.$snackbar
const route = useRoute()
const vuetify = vueInstance.$vuetify

const WhiteListTypeEnum = Object.freeze({
  EVENT_START_TIME_READ_ONLY: 6,
  EVENT_END_TIME_READ_ONLY: 7,
  EVENT_RESOURCE_READ_ONLY: 8,
  EVENT_START_TIME_HIDDEN: 14,
  EVENT_END_TIME_HIDDEN: 15,
  EVENT_RESOURCE_HIDDEN: 16
});

onMounted(() => {
  defineSortableTable('.event-cfg-table tbody', localCustomFieldGroups, 'groupOrder', saveRowChanges)
})

const componentKey = ref(0)
const deleteError = ref(false)
const deleteHeader = ref(null)
const deleteText = ref(null)
const fieldsInUse = ref([])
const positions = ref([])
const positionsLoading = ref(false)
const resourceFieldChanged = ref(false)
const newGroup = ref({})
const event = ref({})
const eventLoading = ref(false)
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)
const newField = ref({})
// selectedIndex is a dumb work around because `index` is not available in the `expanded-item` slot yet
const selectedIndex = ref(null)
const createNew = ref(false)
const newFieldType = ref('native')
const addField = ref(false)
const selectedGroupId = ref(null)
const availableCustomFields = ref([])
const parent = ref({})
const parentObjects = ref([])
const selectedAncillaryField = ref({})
const ancillaryCustomFields = ref([])
const headers = ref([
  {text: null, value: 'draggable', width: '50px', show: true, sortable: false},
  {text: 'Name', value: 'groupName', show: true},
  {text: null, value: 'icons', show: true}
])
const expanded = ref([])
const eventResourceFields = ref([])
const eventTypes = ref([])
const cfgToDisplayOnSnippet = ref(null)
const cfToDisplayOnSnippet = ref(null)
const cfgToDelete = ref(null)
const cFieldToDelete = ref(null)

watch(cfgToDisplayOnSnippet, () => {
  if (cfgToDisplayOnSnippet.value === null){
    event.value.snippetCustomField = null
  }
})
const localCustomFieldGroups = computed( {
  get() {
    return event.value?.customFieldGroups
  },
  set(val) {
    val.forEach(v => {
      v.groupOrder = v.newGroupOrder ?? v.groupOrder
    })
    return orderBy(val, v => v.groupOrder)
  }
})
const eventId = computed(() => {
  return parseInt(route.params.id)
})
const cfgToDeleteName = computed(() => {
  return cfgToDelete.value ? cfgToDelete.value.groupName : ''
})
const cFieldToDeleteName = computed(() => {
  return cFieldToDelete.value ? cFieldToDelete.value.fieldName : ''
})
const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})
const userIsAdmin = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'ADMIN')
})
const companyId = computed(() => {
  return userStore.details.companyId
})
onMounted(async () => {
  await getResourceFields()
  await getPositions()
  await getEvent()
})
const nonAncillaryGfgFields = (fields) => {
  return fields.filter(f => !f.ancillaryCustomFieldGroupAssignmentId)
}
const getResourceFields = async () => {
  appStore.loading = true
  try {
    const {data} = await getEventResourceFields(eventId.value)
    eventResourceFields.value = data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const getEvent = async () => {
  appStore.loading = true
  try {
    eventLoading.value = true;
    const {data} = await getRequest(`/event/${eventId.value}`)
    event.value = data
    getDisplayOnSnippet()
    appStore.loading = false
    eventLoading.value = false;
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    appStore.loading = false
  }
}
const getDisplayOnSnippet = ()=> {
  for(let cfg of event.value.customFieldGroups){
    const customFieldToDisplay = cfg.customFields.find(cf => cf.displayOnSnippet === true)
    if(customFieldToDisplay) {
      cfgToDisplayOnSnippet.value = cfg
      cfToDisplayOnSnippet.value = customFieldToDisplay
      break
    }
  }
}
const startTimeReadOnlySelectedEventListener = (e)=> {
  event.value.startTimeWhiteListedPositions = e;
  event.value.startTimePositionsChanged = true;
}
const startTimeReadOnlyAllowEventListener = (e)=> {
  event.value.startTimeReadOnlyAllow = (e === 0);
}
const startTimeReadOnlyCheckboxEventListener = (e)=> {
  event.value.startTimeReadOnly = e;
}
const startTimeHiddenSelectedEventListener = (e)=> {
  event.value.startTimeHiddenWhiteListedPositions = e;
  event.value.startTimeHiddenPositionsChanged = true;
}
const startTimeHiddenAllowEventListener = (e)=> {
  event.value.startTimeHiddenAllow = (e === 0);
}
const startTimeHiddenCheckboxEventListener = (e)=> {
  event.value.startTimeHidden = e;
}
const endTimeReadOnlySelectedEventListener = (e)=> {
  event.value.endTimeWhiteListedPositions = e;
  event.value.endTimePositionsChanged = true;
}
const endTimeReadOnlyAllowEventListener = (e)=> {
  event.value.endTimeReadOnlyAllow = (e === 0);
}
const endTimeReadOnlyCheckboxEventListener = (e)=> {
  event.value.endTimeReadOnly = e;
}
const endTimeHiddenSelectedEventListener = (e)=> {
  event.value.endTimeHiddenWhiteListedPositions = e;
  event.value.endTimeHiddenPositionsChanged = true;
}
const endTimeHiddenAllowEventListener = (e)=> {
  event.value.endTimeHiddenAllow = (e === 0);
}
const endTimeHiddenCheckboxEventListener = (e)=> {
  event.value.endTimeHidden = e;
}
const resourceReadOnlySelectedEventListener = (e)=> {
  event.value.resourceWhiteListedPositions = e;
  event.value.resourcePositionsChanged = true;
}
const resourceReadOnlyAllowEventListener = (e)=> {
  event.value.resourceReadOnlyAllow = (e === 0);
}
const resourceReadOnlyCheckboxEventListener = (e)=> {
  event.value.resourceReadOnly = e;
}
const resourceHiddenSelectedEventListener = (e)=> {
  event.value.resourceHiddenWhiteListedPositions = e;
  event.value.resourceHiddenPositionsChanged = true;
}
const resourceHiddenAllowEventListener = (e)=> {
  event.value.resourceHiddenAllow = (e === 0);
}
const resourceHiddenCheckboxEventListener = (e)=> {
  event.value.resourceHidden = e;
}
const cfgReadOnlySelectedEventListener = (e, cf)=> {
  cf.whiteListedPositions = e;
  cf.positionsChanged = true;
}
const cfgReadOnlyAllowEventListener = (e, cf)=> {
  cf.customFieldGroupAssignmentReadOnlyAllow = (e == 0);
  cf.positionsChanged = true;
}
const cfgReadOnlyCheckboxEventListener = (e, cf)=> {
  cf.customFieldGroupAssignmentReadOnly = e;
  cf.positionsChanged = true;
}
const cfgHiddenSelectedEventListener = (e, cf)=> {
  cf.hiddenWhiteListedPositions = e;
  cf.hiddenPositionsChanged = true;
}
const cfgHiddenAllowEventListener = (e, cf)=> {
  cf.customFieldGroupAssignmentHiddenAllow = (e == 0);
  cf.hiddenPositionsChanged = true;
}
const cfgHiddenCheckboxEventListener = (e, cf)=> {
  cf.customFieldGroupAssignmentHidden = e;
  cf.hiddenPositionsChanged = true;
}
const selectAll = (f, fieldName) => {
  return f[fieldName]?.length === positions.value?.length
}
const selectSome = (f, fieldName) => {
  return f[fieldName]?.length > 0 && !selectAll(f)
}
const icon = (f, fieldName) => {
  if (selectAll(f, fieldName)) {
    return 'check_box'
  }
  if (selectSome(f, fieldName)) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
}
const saveChangesToDefaultFields = async () => {
  if (vueInstance.$refs.defaultFieldForm.validate()) {
    //save the read only and resource custom fields
    appStore.loading = true
    try {
      await postRequest(`/event/${eventId.value}/saveChangesToDefaultFields`, event.value)
      if (event.value.startTimePositionsChanged || (!event.value.startTimeReadOnly && event.value.startTimeWhiteListedPositions?.length > 0)) {
        saveWhiteListedPositions(WhiteListTypeEnum.EVENT_START_TIME_READ_ONLY, (!event.value.startTimeReadOnly && event.value.startTimeWhiteListedPositions?.length > 0) ? [] : event.value.startTimeWhiteListedPositions)
      }
      if (event.value.startTimeHiddenPositionsChanged || (!event.value.startTimeHidden && event.value.startTimeHiddenWhiteListedPositions?.length > 0)) {
        saveWhiteListedPositions(WhiteListTypeEnum.EVENT_START_TIME_HIDDEN, (!event.value.startTimeHidden && event.value.startTimeHiddenWhiteListedPositions?.length > 0) ? [] : event.value.startTimeHiddenWhiteListedPositions)
      }
      if (event.value.endTimePositionsChanged || (!event.value.endTimeReadOnly && event.value.endTimeWhiteListedPositions?.length > 0)) {

        for (var i = 0; i < event.value.endTimeWhiteListedPositions.length; i++) {
          event.value.endTimeWhiteListedPositions[i].allowFlag = true;
          //Do something
        }

        saveWhiteListedPositions(WhiteListTypeEnum.EVENT_END_TIME_READ_ONLY, (!event.value.endTimeReadOnly && event.value.endTimeWhiteListedPositions?.length > 0) ? [] : event.value.endTimeWhiteListedPositions)
      }
      if (event.value.endTimeHiddenPositionsChanged || (!event.value.endTimeHidden && event.value.endTimeHiddenWhiteListedPositions?.length > 0)) {
        saveWhiteListedPositions(WhiteListTypeEnum.EVENT_END_TIME_HIDDEN, (!event.value.endTimeHidden && event.value.endTimeHiddenWhiteListedPositions?.length > 0) ? [] : event.value.endTimeHiddenWhiteListedPositions)
      }
      if (event.value.resourcePositionsChanged || (!event.value.resourceReadOnly && event.value.resourceWhiteListedPositions?.length > 0)) {
        saveWhiteListedPositions(WhiteListTypeEnum.EVENT_RESOURCE_READ_ONLY, (!event.value.resourceReadOnly && event.value.resourceWhiteListedPositions?.length > 0) ? [] : event.value.resourceWhiteListedPositions)
      }
      if (event.value.resourceHiddenPositionsChanged || (!event.value.resourceHidden && event.value.resourceHiddenWhiteListedPositions?.length > 0)) {
        saveWhiteListedPositions(WhiteListTypeEnum.EVENT_RESOURCE_HIDDEN, (!event.value.resourceHidden && event.value.resourceHiddenWhiteListedPositions?.length > 0) ? [] : event.value.resourceHiddenWhiteListedPositions)
      }
      snackbar('SUCCESS', 'Event Changes Saved')

      appStore.loading = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Saving Changes')

      appStore.loading = false
    }
  }
}
const saveWhiteListedPositions = async (whiteListTypeId, whiteListedPositions) => {
  try {
    await putRequest(`/event/${eventId.value}/saveWhiteListPositions/${whiteListTypeId}`, whiteListedPositions)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving')

    appStore.loading = false
  }
}
const saveDetailView = async (cf) => {
  //because the the dumb dom i have to flip the detailView before I save it
  let detailViewValue = !cf.detailView
  appStore.loading = true
  try {
    await putRequest(`/customFieldGroup/saveDetailView/${cf.customFieldGroupAssignmentId}?detailView=${detailViewValue}`)
    snackbar('SUCCESS', 'Value Saved')

    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving')

    appStore.loading = false
  }
}
const saveCfToDisplayOnSnippet = async ()=> {
  appStore.loading = true
  try {
    await putRequest(`/customFieldGroup/saveDisplayOnSnippet/${cfToDisplayOnSnippet.value.customFieldGroupAssignmentId}`)
    snackbar('SUCCESS', 'Custom Field to Display on Snippet Saved')

    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Custom Field to Display on Snippet')

    appStore.loading = false
  }
}
const saveFieldGroup = async () => {
  appStore.loading = true
  try {
    newGroup.value.eventId = route.params.id

    const {data} = await postRequest(`/customFieldGroup/addEventCustomFieldGroup`, newGroup.value)
    localCustomFieldGroups.value.push(data)
    newGroup.value = {}
    createNew.value = false
    snackbar('SUCCESS', 'Group Saved')

    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Group')

    appStore.loading = false
  }
}
const deleteWithChecks = async (item, customFieldGroupId, customFieldGroupAssignmentId) => {
  appStore.loading = true
  try {
    let url = customFieldGroupAssignmentId ? `/customFieldGroup/deleteFieldFromGroup/${customFieldGroupAssignmentId}` : `/customFieldGroup/${customFieldGroupId}`
    await deleteRequest(url)
    fieldsInUse.value = []
    item.archived = true
    snackbar('SUCCESS', 'Item Deleted')

    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting')

    appStore.loading = false
  }
  cfgToDelete.value = null
  cFieldToDelete.value = null
}
const saveGroupName = async (group) => {
  appStore.loading = true
  try {
    await putRequest(`/customFieldGroup/updateCustomFieldGroup`, group)
    snackbar('SUCCESS', 'Group Name Updated')

    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Change')

    appStore.loading = false
  }
}
const moveFieldToOtherGroup = async (field, newGroup) => {
  appStore.loading = true
  try {
    await postRequest(`/customFieldGroup/moveFieldToOtherGroup/${newGroup.id}`, field)
    snackbar('SUCCESS', 'Field Moved')

    //currently reloading the page because moving the field in the UI seems too hard (even though it isn't i just cant make myself do it right now)
    window.location.reload()
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Moving Field')

    appStore.loading = false
  }
}
const fetchAvailableCustomFields = async (objectTypeId, groupId) => {
  appStore.loading = true
  try {
    if (addField.value && newFieldType.value === 'native') {
      const {data} = await getRequestWithParams(`/customFieldGroup/getAvailableCustomFields`, {
        params: {
          companyObjectTypeId: objectTypeId,
          groupId,
          eventId: eventId.value
        }
      })
      availableCustomFields.value = data
      parentObjects.value = []
      ancillaryCustomFields.value = []
    } else if (addField.value && newFieldType.value === 'ancillary') {
      availableCustomFields.value = []
      const {data} = await getRequestWithParams(`/processStep/getParentObjectsWithTypes`, {params: {id: processStepId.value}})
      selectedAncillaryField.value = {}
      parentObjects.value = data
    }
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    appStore.loading = false
  }
}
const loadFieldsByParent = async () => {
  appStore.loading = true
  try {
    if (parent.value.isProcessStep) {
      const {data} = await getRequest(`/customField/getByParentProcessStep/${parent.value.id}`)
      ancillaryCustomFields.value = data
    } else if (parent.value.objectTypeId === 8) {
      const {data, status} = await getRequest(`/customField/getByDataView/${parent.value.id}`)
      ancillaryCustomFields.value = data
      handleHidingGlobalLoader(status)
    } else {
      const {data} = await getRequest(`/customField/getByParentType/${parent.value.id}`)
      ancillaryCustomFields.value = data
    }
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    appStore.loading = false
  }
}
const saveUseParentData = async (field) => {
  //because of the dim dam dumb dom i have to flip the boolean before I save it
  field.useParentData = !field.useParentData
  appStore.loading = true
  try {
    await putRequest(`/customFieldGroup/saveUseParentData`, field)
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Field')

    appStore.loading = false
  }
}
const saveReadOnlyAndWhiteList = async (field) => {
  appStore.loading = true
  try {
    field.customFieldGroupAssignmentReadOnlyAllow = null != field.customFieldGroupAssignmentReadOnlyAllow ? field.customFieldGroupAssignmentReadOnlyAllow : true
    field.whiteListedPositions = null != field.whiteListedPositions ? field.whiteListedPositions : []
    await putRequest(`/customFieldGroup/saveReadOnlyAndWhiteList?savePositions=${field.positionsChanged ?? false}`, field)
    field.positionsChanged = false
    if (!field.customFieldGroupAssignmentReadOnly) {
      vueInstance.$set(field, 'whiteListedPositions', [])
    }
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Field')

    appStore.loading = false
  }
}
const saveHiddenAndWhiteList = async (field) => {
  appStore.loading = true
  try {
    field.customFieldGroupAssignmentHiddenAllow = null != field.customFieldGroupAssignmentHiddenAllow ? field.customFieldGroupAssignmentHiddenAllow : true
    field.hiddenWhiteListedPositions = null != field.hiddenWhiteListedPositions ? field.hiddenWhiteListedPositions : []

    await putRequest(`/customFieldGroup/saveHiddenAndWhiteList?savePositions=${field.hiddenPositionsChanged ?? false}`, field)
    field.hiddenPositionsChanged = false
    if (!field.customFieldGroupAssignmentHidden) {
      vueInstance.$set(field, 'hiddenWhiteListedPositions', [])
    }
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Field')

    appStore.loading = false
  }
}
const saveFieldChanges = async (fields) => {
  appStore.loading = true
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
    snackbar('SUCCESS', 'Fields Updated')

    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Updating Fields')

    appStore.loading = false
  }

}
const assignCustomField = async (cfg) => {
  appStore.loading = true
  try {
    addField.value = false
    newField.value.customFieldGroupId = cfg.id
    //this line makes pushing it to the list work
    newField.value.archived = false

    const {data} = await postRequest(`/customFieldGroup/addFieldToGroup`, newField.value)
    cfg.customFields.push(data)
    newField.value = {}
    snackbar('SUCCESS', 'Custom Field Assigned')

    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Assigning Custom Field')

    appStore.loading = false
  }
}
const assignAncillaryCustomField = async (cfg) => {
  appStore.loading = true
  try {
    const params = {
      customFieldGroupId: cfg.id,
      id: null,
      ancillaryCustomFieldGroupAssignmentId: selectedAncillaryField.value.customFieldGroupAssignmentId,
      dataViewFieldConfigId: selectedAncillaryField.value.dataViewChildFieldConfigId ? null : selectedAncillaryField.value.dataViewFieldConfigId,
      dataViewChildFieldConfigId: selectedAncillaryField.value.dataViewChildFieldConfigId,
      fieldOrder: 0
    }
    const {data} = await postRequest(`/customFieldGroup/addFieldToGroup`, params)
    cfg.customFields.push(data)
    selectedAncillaryField.value = {}
    addField.value = false
    parent.value = {}
    snackbar('SUCCESS', 'Reference Field Assigned')

    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Assigning Reference Field')

    appStore.loading = false
  }
}
const filterCustomFieldGroups = computed(() => {
  return localCustomFieldGroups.value?.filter(cfg => {
    return !cfg.archived
  })
})
const getAllEventTypes = async () => {
  appStore.loading = true
  try {
    const {data} = await getEventTypes()
    eventTypes.value = data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    appStore.loading = false
  }
}
const saveRowChanges = async (rows) => {
  if (rows?.length > 0) {
    appStore.loading = true
    try {
      await putRequest(`/customFieldGroup/updateCustomFieldGroups`, rows)
      localCustomFieldGroups.value = orderBy(localCustomFieldGroups.value, 'groupOrder')
      snackbar('SUCCESS', 'Group Order Saved')

      // this componentKey forces the data-table component to re-render
      componentKey.value += 1
      appStore.loading = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Saving Group Order')

      appStore.loading = false
    }
  }
}
const getPositions = async () => {
  if (positions.value?.length === 0) {
    try {
      positionsLoading.value = true
      const {data} = await getRequest(`/position/withParent`)
      positions.value = data
      positionsLoading.value = false
      appStore.loading = false
    } catch (e) {
      positionsLoading.value = false
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Positions')

      appStore.loading = false
    }
  }
}
const toggleHiddenSelectAllPositions = (field, fieldName)  => {
  vueInstance.$nextTick(() => {
    if (selectAll(field, fieldName)) {
      field[fieldName] = []
      field.hiddenPositionsChanged = true
    } else {
      field[fieldName] = cloneDeep(positions.value)
      field.hiddenPositionsChanged = true
    }
  })
}
const toggleSelectAllPositions = (item, wlpField) => {
  vueInstance.$nextTick(() => {
    if (selectAll(item, wlpField)) {
      item[wlpField] = []
      item.positionsChanged = true
    } else {
      item[wlpField] = cloneDeep(positions.value)
      item.positionsChanged = true
    }
  })
}
const copyToClipBoard = (textValue) => {
  navigator.clipboard.writeText(textValue);
  snackbar('SUCCESS', 'Copied text to clipboard')

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
