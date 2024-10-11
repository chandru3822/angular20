<template>
  <v-container class="custom-field-group-container">
    <v-dialog v-model="deleteError">
      <v-card>
        <v-card-title class="text-h5 error--text">
          {{ deleteHeader }}
        </v-card-title>

        <v-card-text>
          {{ deleteText }}
          <v-list v-for="(item, index) in fieldsInUse" :key="index">
            <v-list-item-content>
              {{ item.objectType }}
              <div v-if="item.processStepName">{{ item.processStepName }}</div>
              <div v-if="item.groupName">
                {{ item.groupName }}
                <span v-if="item.fieldName"> - {{ item.fieldName }}</span>
              </div>
            </v-list-item-content>
          </v-list>
        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>

          <a-btn
            color="primary"
            variant="text"
            dark
            class="white--text"
            @click="deleteError = false"
            text="Ok"
          />
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-card
      flat
      color="primary lighten-9"
      class="square-card"
      v-if="typeId === 2"
    >
      <multi-select-group
        v-if="!objectTypeLoading"
        background-color="transparent"
        :userCanEdit="userCanEdit"
        :returnObject="objectType"
        :content="positions"
        :dropdownEnabled="objectType.ownerReadOnly"
        :selectedContent="objectType.ownerReadOnlyWhiteListedPositions"
        :title="'Contact Owner Read Only'"
        :label="'Allowed Positions'"
        :alternateLabel="'Denied Positions'"
        :allow="objectType.ownerReadOnlyAllow"
        :contentLoading="objectTypeLoading"
        :full-size="isMobile"
        :save-button="true"
        @selected-changed="objectTypeReadOnlySelectedEventListener"
        @allow-changed="objectTypeReadOnlyAllowEventListener"
        @checkbox-changed="objectTypeReadOnlyCheckboxEventListener"
        @save-multi-select="saveOwnerReadOnlyAndWhiteList"
      ></multi-select-group>
    </v-card>
    <v-row>
      <v-col cols="12" class="shrink pt-0">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">
            Custom Field Groups
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-select
              v-if="hasMultipleCategories"
              v-model="selectedObjectCategory"
              :items="objectCategories"
              item-text="name"
              item-value="id"
              label="Object Category"
              solo
            >
              <template #prepend-item>
                <v-list-item ripple @click="selectedObjectCategory = -1">
                  <v-list-item-content>
                    <v-list-item-title> Select All </v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
              </template>
            </v-select>

            <a-btn
              variant="text"
              color="primary"
              @click=";[(addNew = !addNew), (newGroup = {})]"
              v-if="userCanAdd"
              :prepend-icon="addNew ? 'close' : 'add'"
              hide-text-on-mobile
              :text="addNew ? 'CANCEL' : 'ADD NEW'"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card class="pa-5 mb-2" v-if="addNew">
            <a-text-field
              v-model="newGroup.groupName"
              placeholder="Enter new group name"
              label="Custom Field Group"
            >
            </a-text-field>

            <v-select
              :items="objectCategories"
              v-if="requiresObjectCategory"
              v-model="newGroup.objectCategoryIds"
              item-text="name"
              item-value="id"
              label="Object Category"
              aria-required="true"
              multiple
            ></v-select>

            <a-btn prepend-icon="save" @click="addCustomFieldGroup">Save</a-btn>
          </v-card>

          <v-data-table
            id="cfg-table"
            :headers="headers"
            :items="filterCustomFieldGroups"
            :items-per-page="-1"
            single-expand
            :sort-by="['companyObjectTypeTabDisplayOrder', 'groupOrder']"
            :sort-desc="[false]"
            :expanded.sync="expanded"
            hide-default-footer
            :hide-default-header="!isProject"
            class="elevation-1 fix-column-width-bug mb-5"
          >
            <template #no-data>
              <span class="default-text-color">No available field groups</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No available field groups</span>
            </template>

            <template #item="{ header, item, index }">
              <tr
                :class="{
                  'shaded-row': customFieldGroups.indexOf(item) % 2,
                  'mobile-tr': vuetify.breakpoint.xsOnly
                }"
              >
                <td style="width: 50px">
                  <a-btn
                    variant="text"
                    icon
                    size="small"
                    color="primary"
                    class="handle"
                    v-if="userCanEdit"
                    prepend-icon="drag_handle"
                  />
                </td>
                <td
                  class="text-left"
                  :class="{ 'mb-4': vuetify.breakpoint.xsOnly && item.edit }"
                >
                  <a-text-field
                    :label="vuetify.breakpoint.xsOnly ? 'Name' : ''"
                    v-if="item.edit"
                    v-model="item.groupName"
                  >
                  </a-text-field>
                  <span v-else>
                    <span v-if="isMobile" class="label-medium">Name: </span>
                    {{ item.groupName }}
                  </span>
                </td>
                <td
                  class="text-left"
                  v-if="isProject"
                  :class="{
                    'mb-4': vuetify.breakpoint.xsOnly && item.edit
                  }"
                >
                  <a-select
                    attach
                    v-if="item.edit"
                    v-model="item.companyObjectTypeTabId"
                    :items="objectTypeTabs"
                    label="Tab"
                    item-title="tabName"
                    item-value="id"
                    autocomplete="off"
                  >
                  </a-select>
                  <span v-if="!item.edit">
                    <span v-if="isMobile" class="label-medium">Tab: </span>
                    {{ item.tabName || 'n/a' }}
                  </span>
                </td>
                <td v-if="requiresObjectCategory">
                  <a-select
                    attach
                    v-if="item.edit"
                    v-model="item.objectCategoryIds"
                    :items="objectCategories"
                    label="Object Category"
                    item-title="name"
                    item-value="id"
                    autocomplete="off"
                    multiple
                  >
                  </a-select>
                  <span v-else>
                    {{
                      getObjectCategoryById(item.objectCategoryId)?.name ?? ''
                    }}
                  </span>
                </td>
                <td>
                  <div class="item-icons">
                    <v-tooltip left>
                      <template v-slot:activator="{ on, attrs }">
                        <a-btn
                          variant="text"
                          size="small"
                          icon
                          color="primary"
                          @click="copyToClipBoard(item.id)"
                          v-bind="attrs"
                          :activation-handler="on"
                          prepend-icon="mdi-information"
                        />
                      </template>
                      <span>Custom Field Group Id: {{ item.id }}</span>
                      <div class="text-center">(click to copy)</div>
                    </v-tooltip>
                    <div v-if="userCanEdit" class="flex-display">
                      <a-btn
                        size="small"
                        variant="text"
                        color="primary"
                        @click="item.edit = !item.edit"
                        :prepend-icon="item.edit ? 'remove' : 'edit'"
                      />
                      <a-btn
                        size="small"
                        variant="text"
                        color="primary"
                        v-if="item.edit"
                        @click=";[saveGroup(item), (item.edit = false)]"
                        prepend-icon="save"
                      />
                    </div>
                    <a-btn
                      size="small"
                      variant="text"
                      color="primary"
                      v-if="userCanAdd"
                      @click="expandItem(item, index)"
                      :prepend-icon="
                        addField && expanded.includes(item) ? 'remove' : 'add'
                      "
                    />
                    <a-btn
                      size="small"
                      variant="text"
                      color="primary"
                      @click="
                        ;[
                          expanded.includes(item)
                            ? (expanded = [])
                            : (expanded = [item]),
                          (selectedIndex = index)
                        ]
                      "
                      :prepend-icon="
                        expanded.includes(item) ? 'expand_less' : 'expand_more'
                      "
                    />
                    <a-btn
                      v-if="userCanEdit"
                      size="small"
                      variant="text"
                      color="primary"
                      @click="cfgToDelete = item"
                      prepend-icon="delete"
                    />
                  </div>
                </td>
              </tr>
            </template>
            <template #expanded-item="{ headers, item, index }">
              <td
                :colspan="headers.length"
                class="pb-2"
                :class="{
                  'shaded-row': selectedIndex % 2,
                  'mobile-width': vuetify.breakpoint.smAndDown
                }"
              >
                <v-col cols="12" class="pl-3 pr-3 justify" v-if="addField">
                  <h3 class="text-left">Add New Field</h3>
                  <v-radio-group
                    v-if="isProject"
                    v-model="newFieldType"
                    @change="fetchAvailableCustomFields(item.id)"
                  >
                    <v-radio
                      label="Project Custom Field"
                      value="native"
                    ></v-radio>
                    <v-radio
                      label="Reference Field: from Process Step"
                      value="ancillary"
                    ></v-radio>
                  </v-radio-group>
                  <a-autocomplete
                    v-if="newFieldType === 'native' || !isProject"
                    v-model="newField"
                    :items="availableCustomFields"
                    label="New Custom Field"
                    item-title="fieldName"
                    return-object
                    autocomplete="off"
                    @input="assignCustomField(item)"
                  >
                  </a-autocomplete>
                  <a-autocomplete
                    v-if="newFieldType === 'ancillary' && isProject"
                    v-model="parent"
                    :items="parentObjects"
                    label="Parent Object"
                    item-title="name"
                    return-object
                    autocomplete="off"
                    @input="loadFieldsByParent"
                  >
                  </a-autocomplete>
                  <a-autocomplete
                    v-if="newFieldType === 'ancillary' && isProject"
                    v-model="selectedAncillaryField"
                    :items="ancillaryCustomFields"
                    label="Custom Field"
                    item-title="fieldName"
                    return-object
                    autocomplete="off"
                    @input="assignAncillaryCustomField(item)"
                  >
                  </a-autocomplete>
                </v-col>
                <v-col cols="12" class="px-3 py-0 justify">
                  <draggable
                    v-model="item.customFields"
                    v-if="item.customFields && item.customFields.length > 0"
                    :disabled="!userCanEdit"
                    group="customFields"
                    @start="drag = true"
                    @end="drag = false"
                    @change="saveFieldChanges(item.customFields)"
                  >
                    <v-list
                      v-for="(cf, index) in filterCustomFields(item)"
                      :key="index"
                      class="pa-0"
                      :class="{ 'shaded-row': selectedIndex % 2 }"
                    >
                      <v-list-item
                        class="grab pr-1"
                        :class="{ 'mobile-tr': vuetify.breakpoint.xsOnly }"
                      >
                        <v-list-item-action v-if="userCanEdit">
                          <v-icon color="primary">drag_handle</v-icon>
                        </v-list-item-action>
                        <v-list-item-content>
                          <div
                            v-if="
                              cf.ancillaryCustomFieldGroupAssignmentId ==
                                null && cf.dataViewFieldConfigId == null
                            "
                          >
                            <a
                              :href="`/settings/customField/${cf.customFieldId}`"
                            >
                              {{ cf.fieldName }}
                            </a>
                            <span
                              v-if="
                                cf.customFieldGroupAssignmentReadOnly ||
                                cf.systemReadonly
                              "
                            >
                              (Read Only)
                            </span>
                            <span v-if="cf.customFieldGroupAssignmentHidden">
                              (Hidden)
                            </span>
                            <div class="text-left mt-3" v-if="cf.edit">
                              <v-row>
                                <v-col cols="10" lg="6">
                                  <v-card
                                    flat
                                    :color="
                                      selectedIndex % 2
                                        ? 'white'
                                        : 'primary lighten-9'
                                    "
                                    class="square-card"
                                  >
                                    <v-card-text
                                      v-if="cf.systemReadonly"
                                      class="mt-2"
                                    >
                                      System Readonly Cannot Change
                                    </v-card-text>
                                    <v-card-text v-else>
                                      <multi-select-group
                                        v-if="!positionsLoading"
                                        background-color="transparent"
                                        :userCanEdit="userCanEdit"
                                        :returnObject="cf"
                                        :content="positions"
                                        :dropdownEnabled="
                                          cf.customFieldGroupAssignmentReadOnly
                                        "
                                        :selectedContent="
                                          cf.whiteListedPositions
                                        "
                                        :title="'Read Only'"
                                        :label="'Allowed Positions'"
                                        :alternateLabel="'Denied Positions'"
                                        :allow="
                                          cf.customFieldGroupAssignmentReadOnlyAllow
                                        "
                                        :contentLoading="positionsLoading"
                                        @selected-changed="
                                          cfgaReadOnlySelectedEventListener
                                        "
                                        @allow-changed="
                                          cfgaReadOnlyAllowEventListener
                                        "
                                        @checkbox-changed="
                                          cfgaReadOnlyCheckboxEventListener
                                        "
                                      ></multi-select-group>

                                      <br />
                                      <div class="d-flex">
                                        <v-spacer v-if="isMobile" />
                                        <a-btn
                                          color="primary"
                                          dark
                                          class="d-inline-block white--text"
                                          @click="saveReadOnlyAndWhiteList(cf)"
                                          prepend-icon="save"
                                          text="SAVE READ ONLY"
                                        />
                                      </div>
                                    </v-card-text>
                                  </v-card>
                                </v-col>
                                <v-col cols="10" lg="6">
                                  <v-card
                                    flat
                                    :color="
                                      selectedIndex % 2
                                        ? 'white'
                                        : 'primary lighten-9'
                                    "
                                    class="square-card"
                                  >
                                    <v-card-text>
                                      <multi-select-group
                                        v-if="!positionsLoading"
                                        background-color="transparent"
                                        :userCanEdit="userCanEdit"
                                        :returnObject="cf"
                                        :content="positions"
                                        :dropdownEnabled="
                                          cf.customFieldGroupAssignmentHidden
                                        "
                                        :selectedContent="
                                          cf.hiddenWhiteListedPositions
                                        "
                                        :title="'Hidden'"
                                        :label="'Allowed Positions'"
                                        :alternateLabel="'Denied Positions'"
                                        :allow="
                                          cf.customFieldGroupAssignmentHiddenAllow
                                        "
                                        :contentLoading="positionsLoading"
                                        @selected-changed="
                                          cfgaHiddenSelectedEventListener
                                        "
                                        @allow-changed="
                                          cfgaHiddenAllowEventListener
                                        "
                                        @checkbox-changed="
                                          cfgaHiddenCheckboxEventListener
                                        "
                                      ></multi-select-group>

                                      <br />
                                      <div class="d-flex">
                                        <v-spacer v-if="isMobile" />
                                        <a-btn
                                          color="primary"
                                          dark
                                          class="white--text d-inline-block"
                                          @click="saveHiddenAndWhiteList(cf)"
                                          prepend-icon="save"
                                          :text="
                                            vuetify.breakpoint.mdAndUp
                                              ? 'Save Hidden'
                                              : ''
                                          "
                                        />
                                      </div>
                                    </v-card-text>
                                  </v-card>
                                </v-col>
                              </v-row>
                            </div>
                          </div>
                          <div v-else>
                            {{ cf.processStepName || cf.objectType }}:
                            {{ cf.groupName }} - {{ cf.fieldName }} (Ancillary)
                            <span v-if="cf.customFieldGroupAssignmentHidden">
                              (Hidden)
                            </span>
                            <div class="text-left mt-3" v-if="cf.edit">
                              <v-row>
                                <v-col cols="10" lg="6">
                                  <v-card
                                    flat
                                    :color="
                                      selectedIndex % 2
                                        ? 'white'
                                        : 'primary lighten-9'
                                    "
                                    class="square-card"
                                  >
                                    <v-card-text>
                                      <multi-select-group
                                        v-if="!positionsLoading"
                                        background-color="transparent"
                                        :userCanEdit="userCanEdit"
                                        :returnObject="cf"
                                        :content="positions"
                                        :dropdownEnabled="
                                          cf.customFieldGroupAssignmentHidden
                                        "
                                        :selectedContent="
                                          cf.hiddenWhiteListedPositions
                                        "
                                        :title="'Hidden'"
                                        :label="'Allowed Positions'"
                                        :alternateLabel="'Denied Positions'"
                                        :allow="
                                          cf.customFieldGroupAssignmentHiddenAllow
                                        "
                                        :contentLoading="positionsLoading"
                                        @selected-changed="
                                          cfgaHiddenSelectedEventListener
                                        "
                                        @allow-changed="
                                          cfgaHiddenAllowEventListener
                                        "
                                        @checkbox-changed="
                                          cfgaHiddenCheckboxEventListener
                                        "
                                      ></multi-select-group>
                                      <br />
                                      <div class="d-flex">
                                        <v-spacer v-if="isMobile" />
                                        <a-btn
                                          color="primary"
                                          dark
                                          class="white--text d-inline-block"
                                          @click="saveHiddenAndWhiteList(cf)"
                                          prepend-icon="save"
                                          :text="
                                            vuetify.breakpoint.mdAndUp
                                              ? 'Save Hidden'
                                              : ''
                                          "
                                        />
                                      </div>
                                    </v-card-text>
                                  </v-card>
                                </v-col>
                              </v-row>
                            </div>
                          </div>
                          <div
                            class="text-left"
                            v-if="
                              !cf.edit &&
                              !cf.ancillaryCustomFieldGroupAssignmentId
                            "
                          >
                            <div>
                              <input
                                type="checkbox"
                                v-model="cf.required"
                                :readonly="!userCanEdit"
                                :disabled="!userCanEdit"
                                @change="updateShowOrRequire(cf)"
                              />
                              Required
                            </div>
                            <div v-if="!isProject">
                              <input
                                type="checkbox"
                                v-model="cf.showOnInsert"
                                :readonly="!userCanEdit"
                                :disabled="!userCanEdit"
                                @change="updateShowOrRequire(cf)"
                              />
                              Show On Insert
                            </div>
                            <div v-if="typeId === 3">
                              <input
                                type="checkbox"
                                v-model="cf.showOnUserProfile"
                                :readonly="!userCanEdit"
                                :disabled="!userCanEdit"
                                @change="updateShowOrRequire(cf)"
                              />
                              Show On User Profile
                            </div>
                          </div>
                        </v-list-item-content>
                        <div>
                          <v-tooltip left>
                            <template v-slot:activator="{ on, attrs }">
                              <a-btn
                                variant="text"
                                icon
                                color="primary"
                                @click="
                                  copyToClipBoard(
                                    cf.customFieldGroupAssignmentId
                                  )
                                "
                                v-bind="attrs"
                                :activation-handler="on"
                                prepend-icon="mdi-information"
                              />
                            </template>
                            <span>
                              Custom Field Group Assignment Id:
                              {{ cf.customFieldGroupAssignmentId }}
                            </span>
                            <div class="text-center">(click to copy)</div>
                          </v-tooltip>
                          <v-menu
                            offset-y
                            v-if="
                              !cf.ancillaryCustomFieldGroupAssignmentId &&
                              userStore.userHasFeatureAccessLevel(
                                'SETTINGS',
                                'EDIT'
                              )
                            "
                          >
                            <template v-slot:activator="{ on }">
                              <a-btn
                                variant="text"
                                size="small"
                                color="primary"
                                :activation-handler="on"
                                prepend-icon="mdi-cursor-move"
                              />
                            </template>
                            <v-list>
                              <v-list-item
                                v-for="(cfg, index) in customFieldGroups.filter(
                                  (g) => {
                                    return g.id !== cf.customFieldGroupId
                                  }
                                )"
                                :key="index"
                                @click="moveFieldToOtherGroup(cf, cfg)"
                              >
                                <v-list-item-title>
                                  {{ cfg.groupName }}
                                </v-list-item-title>
                              </v-list-item>
                            </v-list>
                          </v-menu>
                          <a-btn
                            variant="text"
                            size="small"
                            color="primary"
                            v-else
                          />
                          <a-btn
                            variant="text"
                            color="primary"
                            size="small"
                            v-if="userCanEdit"
                            @click="
                              ;[
                                $set(cf, 'edit', !cf.edit),
                                getPositions(),
                                resetCurrentField()
                              ]
                            "
                            :prepend-icon="cf.edit ? 'close' : 'edit'"
                          />
                          <a-btn
                            v-if="userCanEdit"
                            variant="text"
                            size="small"
                            color="primary"
                            @click="
                              ;[(cFieldToDelete = cf), (cfgToDelete = item)]
                            "
                            prepend-icon="delete"
                          />
                        </div>
                      </v-list-item>
                    </v-list>
                  </draggable>
                </v-col>
              </td>
            </template>
          </v-data-table>

          <ConfirmationDialog
            :open-dialog="cfgToDelete && !cFieldToDelete"
            @confirm="deleteWithChecks(cfgToDelete, cfgToDelete.id, null)"
            @close-dialog="cfgToDelete = null"
          >
            Are you sure you want to delete this Custom Field Group:
            <strong>{{ cfgToDeleteName }}</strong
            >?
          </ConfirmationDialog>
          <ConfirmationDialog
            :open-dialog="!!cFieldToDelete"
            @confirm="deleteWithChecks(cFieldToDelete, null, cFieldToDelete.id)"
            @close-dialog=";[(cfgToDelete = null), (cFieldToDelete = null)]"
          >
            <span class="error--text">WARNING:</span>
            By deleting a field you will lose all data associated with the
            field. If you meant to "move" the field to another group please
            cancel and move the field. <br /><br />
            Are you sure you want to delete this field from
            {{ cfgToDeleteName }}: <strong>{{ cFieldToDeleteName }}</strong
            >?
          </ConfirmationDialog>
        </v-container>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import draggable from 'vuedraggable'
import cloneDeep from 'lodash.clonedeep'

import {
  handleHidingGlobalLoader,
  getRequest,
  putRequest,
  postRequest,
  getRequestWithParams,
  defineSortableTable
} from '@/helpers/helpers'
import ConfirmationDialog from '@/components/ConfirmationDialog'
import MultiSelectGroup from '@/components/MultiSelectGroup.vue'
import { useUserStore } from '@/stores/UserStore.js'

import {
  ref,
  onMounted,
  toRefs,
  getCurrentInstance,
  computed,
  watch
} from 'vue'
import { useRoute } from 'vue-router/composables'
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const route = useRoute()
const vuetify = vueInstance.$vuetify
const userStore = useUserStore()

const props = defineProps({
  isProject: Boolean
})

const { isProject } = toRefs(props)

const addNew = ref(false)
const ownerPositionsChanged = ref(false)
const objectType = ref({})
const objectTypeLoading = ref(false)
const ownerWhiteListedPositions = ref([])
const deleteError = ref(false)
const deleteHeader = ref(null)
const deleteText = ref(null)
const fieldsInUse = ref([])
const positions = ref([])
const positionsLoading = ref(false)
const newFieldType = ref('native')
const selectedIndex = ref(null)
const fieldOrderChanged = ref(false)
const groupOrderChanged = ref(false)
const whiteListedPositions = ref([])
const whiteListedPositionsChanged = ref(null)
const customFieldGroupAssignmentReadOnly = ref(null)
const hiddenWhiteListedPositionsChanged = ref(null)
const hiddenWhiteListedPositions = ref(null)
const customFieldGroupAssignmentHiddenAllow = ref(null)
const customFieldGroupAssignmentHidden = ref(null)
const customFieldGroupAssignmentReadOnlyAllow = ref(null)
const newGroup = ref({
  groupName: null
})
//ugh! is this a good idea? projects is a custom view that calls this but orgs/users/contacts do too and i dont want to add a view for each of those
const typeId = computed(() => {
  return parseInt(route.params.id ?? route.query.companyObjectTypeId)
})

const addField = ref(false)
const newField = ref({})
const customFieldGroups = ref([])
const availableCustomFields = ref([])
//if you set this to a value it doesn't update when the route param changes
// objectTypeId: route.params.id
const headers = computed(() => {
  const h = [
    {
      text: null,
      value: 'draggable',
      width: '50px',
      show: true,
      sortable: false,
      order: 0
    },
    { text: 'Name', value: 'groupName', show: true, order: 1 },
    { text: null, value: 'icons', show: true, sortable: false, order: 4 }
  ]

  if (isProject.value) {
    h.splice(2, 0, { text: 'Tab', value: 'tabName', show: true, order: 2 })
  }

  if (requiresObjectCategory.value) {
    h.splice(h.length - 1, 0, {
      text: 'Object Category',
      value: 'tabName',
      show: true,
      order: 3
    })
  }
  return h
})
const expanded = ref([])
const parent = ref({})
const parentObjects = ref([])
const selectedAncillaryField = ref({})
const ancillaryCustomFields = ref([])
const objectTypeTabs = ref([])
const cfgToDelete = ref(null)
const cFieldToDelete = ref(null)

const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})
const cfgToDeleteName = computed(() => {
  return cfgToDelete.value ? cfgToDelete.value.groupName : ''
})
const cFieldToDeleteName = computed(() => {
  return cFieldToDelete.value ? cFieldToDelete.value.fieldName : ''
})
const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})
const filterCustomFields = (cuf) => {
  return cuf?.customFields?.filter((c) => c.archived === false)
}

const selectedObjectCategory = ref(-1)
const objectCategories = ref([])
// ['project', 'contact'].includes(objectType.value)
const requiresObjectCategory = computed(() => [1, 2].includes(typeId.value))

onMounted(() => {
  defineSortableTable(
    'tbody',
    customFieldGroups,
    'groupOrder',
    saveGroupChanges
  )

  getObjectCategories()
  getCustomFieldGroups()
  getObjectTypeTabs()
  getPositions()
  if (parseInt(route.params.id) === 2) {
    getObjectTypeDetails()
  }
})

watch(
  () => typeId.value,
  () => {
    // whenever objectTypeId changes, this function will run
    // reset the selected group when the object type changes
    availableCustomFields.value = []
    getCustomFieldGroups()
  }
)

const selectAll = (f) => {
  return f.whiteListedPositions?.length === positions.value?.length
}
const selectSome = (f) => {
  return f.whiteListedPositions?.length > 0 && !selectAll(f)
}

const selectAllOwner = () => {
  return ownerWhiteListedPositions.value?.length === positions.value?.length
}

const getObjectCategories = async () => {
  try {
    if (requiresObjectCategory.value) {
      const { data } = await getRequest(
        `/objectCategory?objectTypeId=${typeId.value}`
      )
      objectCategories.value = data
    } else {
      objectCategories.value = []
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Object Categories')
  }
}

const getObjectCategoryById = (id) =>
  objectCategories.value.find((o) => o.id === id)

const getObjectTypeTabs = async () => {
  appStore.loading = true
  try {
    //currently we only do this for projects.. will have to change if we allow custom tabs for other object types
    const { data, status } = await getRequest(`/objectTypeTab/project`)
    objectTypeTabs.value = data

    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Tabs')

    appStore.loading = false
  }
}

const getCustomFieldGroups = async () => {
  appStore.loading = true
  try {
    const { data, status } = await getRequestWithParams(
      `/customFieldGroup/getCustomFieldGroupsByObjectTypeId`,
      {
        params: {
          companyObjectTypeId: typeId.value
        }
      }
    )
    customFieldGroups.value = cloneDeep(data)
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const fetchAvailableCustomFields = async (groupId) => {
  appStore.loading = true
  try {
    if (addField.value && newFieldType.value === 'native') {
      const { data, status } = await getRequestWithParams(
        `/customFieldGroup/getAvailableCustomFields`,
        {
          params: {
            companyObjectTypeId: typeId.value,
            groupId
          }
        }
      )
      availableCustomFields.value = data
    } else if (addField.value && newFieldType.value === 'ancillary') {
      //this is really dumb code i dont have the energy to fix. fyi
      let url = isProject.value
        ? `/processStep/getParentObjectsForProject`
        : `/processStep/getParentObjects`
      const { data, status } = await getRequest(url)
      selectedAncillaryField.value = {}
      parentObjects.value = data
      availableCustomFields.value = []
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
  } finally {
    appStore.loading = false
  }
}
const addCustomFieldGroup = async () => {
  if (newGroup.value?.groupName) {
    try {
      appStore.loading = true
      newGroup.value.companyObjectTypeId =
        route.params.id ?? route.query.companyObjectTypeId
      const { data, status } = await postRequest(
        `/customFieldGroup/addCustomFieldGroup`,
        newGroup.value
      )
      newGroup.value = {}
      addNew.value = false
      // add the new type to the list
      customFieldGroups.value.push(data)
      appStore.showSnack('SUCCESS', 'Group Added')
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Adding Custom Field Group')
    } finally {
      appStore.loading = false
    }
  }
}
const assignCustomField = async (item) => {
  try {
    appStore.loading = true
    addField.value = false
    newField.value.customFieldGroupId = item.id
    const { data, status } = await postRequest(
      `/customFieldGroup/addFieldToGroup`,
      newField.value
    )
    item.customFields.push(data)
    newField.value = {}
    selectedAncillaryField.value = {}
    parent.value = {}
    addField.value = false
    appStore.showSnack('SUCCESS', 'Field Added to Group')

    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Adding Field to Group')
  } finally {
    appStore.loading = false
  }
}

const moveFieldToOtherGroup = async (field, newGroup) => {
  try {
    appStore.loading = true
    await postRequest(
      `/customFieldGroup/moveFieldToOtherGroup/${newGroup.id}`,
      field
    )
    appStore.showSnack('SUCCESS', 'Field Moved')

    //currently reloading the page because moving the field in the UI seems too hard (even though it isn't i just cant make myself do it right now)
    window.location.reload()
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Moving Field')
  } finally {
    appStore.loading = false
  }
}

const assignAncillaryCustomField = async (item) => {
  try {
    appStore.loading = true

    const params = {
      customFieldGroupId: item.id,
      id: null,
      ancillaryCustomFieldGroupAssignmentId:
        selectedAncillaryField.value.customFieldGroupAssignmentId,
      dataViewFieldConfigId: selectedAncillaryField.value
        .dataViewChildFieldConfigId
        ? null
        : selectedAncillaryField.value.dataViewFieldConfigId,
      dataViewChildFieldConfigId:
        selectedAncillaryField.value.dataViewChildFieldConfigId
    }
    const { data, status } = await postRequest(
      `/customFieldGroup/addFieldToGroup`,
      params
    )
    item.customFields.push(data)
    newField.value = {}
    selectedAncillaryField.value = {}
    parent.value = {}
    addField.value = false
    appStore.showSnack('SUCCESS', 'Field Added to Group')
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Adding Field to Group')
  } finally {
    appStore.loading = false
  }
}
const saveGroupChanges = async (groups) => {
  try {
    appStore.loading = true

    await putRequest(`/customFieldGroup/updateCustomFieldGroups`, groups)
    appStore.showSnack('SUCCESS', 'Groups Updated')
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Saving Group Changes')
  } finally {
    appStore.loading = false
  }
}
const saveGroup = async (group) => {
  try {
    appStore.loading = true

    const { data } = await putRequest(
      `/customFieldGroup/updateCustomFieldGroup`,
      group
    )
    group.tabName = data.tabName
    group.companyObjectTypeTabDisplayOrder =
      data.companyObjectTypeTabDisplayOrder
    appStore.showSnack('SUCCESS', 'Custom Field Group Updated')
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Saving Change')
  } finally {
    appStore.loading = false
  }
}
const deleteWithChecks = async (
  item,
  customFieldGroupId,
  customFieldGroupAssignmentId
) => {
  try {
    appStore.loading = true
    let params = {
      customFieldGroupId,
      customFieldGroupAssignmentId
    }
    const { data } = await putRequest(
      `/customFieldGroup/deleteWithRequirementChecks`,
      params,
      null,
      []
    )
    if (data?.length > 0) {
      deleteError.value = true
      item.deleteConfirm = false
      fieldsInUse.value = data
      let errorMsg = 'Group Cannot Be Deleted'
      deleteHeader.value = 'Error Deleting Custom Field Group'
      deleteText.value =
        'You cannot delete a group that has a field in use by other groups or requirements.'
      if (null !== customFieldGroupAssignmentId) {
        errorMsg = 'Field Cannot Be Deleted'
        deleteHeader.value = 'Error Deleting Custom Field from Group'
        deleteText.value =
          'You cannot delete a field from a group that is in use by other groups or requirements.'
      }
      appStore.showSnack('ERROR', errorMsg)
    } else {
      fieldsInUse.value = []
      item.archived = true
      appStore.showSnack('SUCCESS', 'Item Deleted')
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Deleting')
  } finally {
    appStore.loading = false
  }
  cfgToDelete.value = null
  cFieldToDelete.value = null
}

const resetCurrentField = () => {
  whiteListedPositionsChanged.value = null
  whiteListedPositions.value = null
  customFieldGroupAssignmentReadOnlyAllow.value = null
  customFieldGroupAssignmentReadOnly.value = null
  hiddenWhiteListedPositionsChanged.value = null
  hiddenWhiteListedPositions.value = null
  customFieldGroupAssignmentHiddenAllow.value = null
  customFieldGroupAssignmentHidden.value = null
}

const saveReadOnlyAndWhiteList = async (field) => {
  try {
    appStore.loading = true
    if (whiteListedPositionsChanged.value != null) {
      field.positionsChanged = whiteListedPositionsChanged.value
    }
    if (whiteListedPositions.value != null) {
      field.whiteListedPositions = whiteListedPositions.value
    }
    if (customFieldGroupAssignmentReadOnlyAllow.value != null) {
      field.customFieldGroupAssignmentReadOnlyAllow =
        customFieldGroupAssignmentReadOnlyAllow.value
    }
    if (customFieldGroupAssignmentReadOnly.value != null) {
      field.customFieldGroupAssignmentReadOnly =
        customFieldGroupAssignmentReadOnly.value
    }
    await putRequest(
      `/customFieldGroup/saveReadOnlyAndWhiteList?savePositions=${
        field.positionsChanged ?? false
      }`,
      field
    )
    field.positionsChanged = false
    if (!field.customFieldGroupAssignmentReadOnly) {
      vueInstance.$set(field, 'whiteListedPositions', [])
    }
    appStore.showSnack('SUCCESS', 'Field Updated')
  } catch (e) {
    console.error('*** ERROR ***', e)
  } finally {
    appStore.loading = false
  }
}
const saveHiddenAndWhiteList = async (field) => {
  try {
    appStore.loading = true

    if (hiddenWhiteListedPositionsChanged.value != null) {
      field.hiddenPositionsChanged = hiddenWhiteListedPositionsChanged.value
    }
    if (hiddenWhiteListedPositions.value != null) {
      field.hiddenWhiteListedPositions = hiddenWhiteListedPositions.value
    }
    if (customFieldGroupAssignmentHiddenAllow.value != null) {
      field.customFieldGroupAssignmentHiddenAllow =
        customFieldGroupAssignmentHiddenAllow.value
    }
    if (customFieldGroupAssignmentHidden.value != null) {
      field.customFieldGroupAssignmentHidden =
        customFieldGroupAssignmentHidden.value
    }
    await putRequest(
      `/customFieldGroup/saveHiddenAndWhiteList?savePositions=${
        field.hiddenPositionsChanged ?? false
      }`,
      field
    )
    field.hiddenPositionsChanged = false
    if (!field.customFieldGroupAssignmentHidden) {
      vueInstance.$set(field, 'hiddenWhiteListedPositions', [])
    }
    appStore.showSnack('SUCCESS', 'Field Updated')
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Saving Field')
  } finally {
    appStore.loading = false
  }
}
const getObjectTypeDetails = async () => {
  try {
    appStore.loading = true

    objectTypeLoading.value = true
    const { data } = await getRequest(`/objectType/getByType/${typeId.value}`)
    objectType.value = data
    objectTypeLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Details')
  } finally {
    appStore.loading = false
  }
}
const saveOwnerReadOnlyAndWhiteList = async () => {
  try {
    appStore.loading = true

    await putRequest(
      `/objectType/saveOwnerReadOnlyAndWhiteList?savePositions=${
        ownerReadOnlyPositionsChanged.value ?? false
      }`,
      objectType.value
    )
    ownerReadOnlyPositionsChanged.value = false
    if (!objectType.value.ownerReadOnly) {
      ownerReadOnlyWhiteListedPositions.value = []
    }
    appStore.showSnack('SUCCESS', 'Saved Successfully')
  } catch (e) {
    console.error('*** ERROR ***', e)
  } finally {
    appStore.loading = false
  }
}
const saveFieldChanges = async (fields) => {
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
      appStore.loading = true
      const { status } = await putRequest(
        `/customFieldGroup/updateFieldsInGroup`,
        fieldsToSave
      )
      appStore.showSnack('SUCCESS', 'Fields Updated')
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Updating Fields')
  } finally {
    appStore.loading = false
  }
}
const filterCustomFieldGroups = computed(() => {
  return customFieldGroups.value
    ?.filter((cfgt) => !cfgt.archived)
    ?.filter((cfgt) => {
      if (selectedObjectCategory.value === -1) {
        return true
      }
      return cfgt.objectCategoryId === selectedObjectCategory.value
    })
})

const hasMultipleCategories = computed(() => {
  const types = customFieldGroups.value
    ?.map((at) => at.objectCategoryId)
    ?.filter((at) => at !== undefined)

  return new Set(types).size > 1
})

const updateShowOrRequire = async (cf) => {
  try {
    appStore.loading = true

    const objectType = {
      customFieldGroupAssignmentId: cf.customFieldGroupAssignmentId,
      showOnUserProfile: cf.showOnUserProfile,
      showOnInsert: cf.showOnInsert,
      //can only set requireOnInsert true if showOnInsert is also true
      required: cf.required || false
    }
    await putRequest(`/customFieldGroup/updateFieldShowOrRequire`, objectType)
    appStore.showSnack('SUCCESS', 'Updated Field')
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Saving Data')
  } finally {
    appStore.loading = false
  }
}
const loadFieldsByParent = async () => {
  try {
    appStore.loading = true
    if (parent.value.isProcessStep) {
      const { data, status } = await getRequest(
        `/customField/getByParentProcessStep/${parent.value.id}`
      )
      ancillaryCustomFields.value = data
      handleHidingGlobalLoader(status)
    } else if (parent.value.objectTypeId === 8) {
      const { data, status } = await getRequest(
        `/customField/getByDataView/${parent.value.id}`
      )
      ancillaryCustomFields.value = data
      handleHidingGlobalLoader(status)
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
  } finally {
    appStore.loading = false
  }
}

const getPositions = async () => {
  if (positions.value?.length === 0) {
    try {
      appStore.loading = true

      positionsLoading.value = true
      const { data, status } = await getRequest(`/position/withParent`)
      positions.value = data
      positionsLoading.value = false
    } catch (e) {
      positionsLoading.value = false
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Positions')
    } finally {
      appStore.loading = false
    }
  }
}
const copyToClipBoard = (textValue) => {
  navigator.clipboard.writeText(textValue)
  appStore.showSnack('SUCCESS', 'Copied id to clipboard')
}
const objectTypeReadOnlySelectedEventListener = (e) => {
  objectType.value.ownerReadOnlyWhiteListedPositions = e
  ownerReadOnlyPositionsChanged.value = true
}
const objectTypeReadOnlyAllowEventListener = (e) => {
  objectType.value.ownerReadOnlyAllow = e === 0
}
const objectTypeReadOnlyCheckboxEventListener = (e) => {
  objectType.value.ownerReadOnly = e
}
const cfgaReadOnlySelectedEventListener = (e) => {
  whiteListedPositions.value = e
  whiteListedPositionsChanged.value = true
}
const cfgaReadOnlyAllowEventListener = (e) => {
  customFieldGroupAssignmentReadOnlyAllow.value = e === 0
}
const cfgaReadOnlyCheckboxEventListener = (e) => {
  customFieldGroupAssignmentReadOnly.value = e
}
const cfgaHiddenSelectedEventListener = (e) => {
  hiddenWhiteListedPositions.value = e
  hiddenWhiteListedPositionsChanged.value = true
}
const cfgaHiddenAllowEventListener = (e) => {
  customFieldGroupAssignmentHiddenAllow.value = e === 0
}
const cfgaHiddenCheckboxEventListener = (e) => {
  customFieldGroupAssignmentHidden.value = e
}

const expandItem = (item, index) => {
  addField.value = !addField.value
  fetchAvailableCustomFields(item.id)
  expanded.value = [item]
  selectedIndex.value = index
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.item-icons {
  display: flex;
  float: right;
}
.handle {
  cursor: move !important;
}

.hideId {
  visibility: hidden;
}

.mobile-width {
  width: calc(100vw - 100px);
}

.mobile-tr {
  display: flex;
  flex-direction: column;
  align-items: center;
  border-bottom: thin solid rgba(0, 0, 0, 0.12);
  width: calc(100vw - 100px);
}
</style>
<style lang="scss">
#cfg-table > div > table > thead > tr > th {
  width: 100%;
}
//I don't know why this was necessary, but the first row of the table does not change if we keep it scoped
#cfg-table > div > table > tbody > tr.mobile-tr {
  display: flex;
  flex-direction: column;
  align-items: center;
  border-bottom: thin solid rgba(0, 0, 0, 0.12);
  width: calc(100vw - 100px);
  td {
    border-bottom: none !important;
  }
}
</style>
