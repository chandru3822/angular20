<template>
  <v-container id="custom-field-container">
    <v-dialog
      v-model="deleteError"
    >
      <v-card>
        <v-card-title class="text-h5 error--text">Error Deleting Custom Field</v-card-title>

        <v-card-text>
          You cannot delete a field that is currently in use.  Please remove the field from the following locations before deleting.
          <v-list v-for="(item, index) in fieldsInUse" :key="index">
            <v-list-item-content>
              {{ item.objectType }} <span v-if="item.processStepName">{{item.processStepName}}</span>{{ item.groupName }} - {{ item.fieldName}}
            </v-list-item-content>
          </v-list>
        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            color="primaryCustom"
            text
            dark
            class="white--text"
            @click="deleteError = false"
          >
            OK
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat>
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Custom Fields</v-toolbar-title>
          <v-spacer v-if="!constants.IS_MOBILE"></v-spacer>
          <v-toolbar-items>
            <v-select
              class="mt-4"
              v-model="selectedObjectType"
              :items="objectFilters"
              label="Filter by Object Type"
              item-text="objectType"
              return-object
              @input="changeSelectedObjectType()"
            ></v-select>
          </v-toolbar-items>
        </v-toolbar>
        <v-card>
          <v-card-title class="pt-0">
            <v-text-field
              v-model="search"
              prepend-inner-icon="search"
              label="Search"
              single-line
              clearable
              hide-details
            ></v-text-field>
          </v-card-title>
          <v-data-table
            :headers="headers"
            :items="filterCustomFields()"
            :fixed-header="true"
            :items-per-page="25"
            single-expand
            :search="search"
            hide-default-header
            :footer-props="footerProps"
            :expanded.sync="expanded"
            class="elevation-1 mt-1"
          >
            <template #no-data>
              No available fields
            </template>

            <template #no-results>
              No available fields
            </template>

            <template #item="{ item, index }">
              <tr :class="{'shaded-row': index % 2}">
                <td class="text-left clickable"
                    @click="[expanded.includes(item) ? expanded = [] : expanded = [item], item.newFieldName = item.fieldName, selectedIndex = index, getSystemListOptions(item.companySystemListId)]">
                  {{ item.custom ? "Add New" : item.fieldName }}
                </td>
                <td class="text-right">
                  <div class="item-icons">
                    <v-btn class="clickable" small text
                           @click="[expanded.includes(item) ? expanded = [] : expanded = [item], item.newFieldName = item.fieldName, selectedIndex = index, getSystemListOptions(item.companySystemListId)]">
                      <v-icon v-if="expanded.includes(item)">remove</v-icon>
                      <v-icon v-else-if="item.custom">add</v-icon>
                      <v-icon v-else>edit</v-icon>
                    </v-btn>
                    <v-dialog
                      v-model="item.deleteConfirm"
                      v-if="!item.custom && $store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                      width="500">
                      <template v-slot:activator="{ on }">
                        <v-btn small text class="clickable" v-on="on">
                          <v-icon>delete</v-icon>
                        </v-btn>
                      </template>
                      <v-card>
                        <v-card-title
                            class="text-h5 grey lighten-2"
                            primary-title
                        >
                          Confirm
                        </v-card-title>

                        <v-card-text>
                          Are you sure you want to delete this field: <strong>{{ item.fieldName }}</strong>?
                        </v-card-text>

                        <v-divider></v-divider>

                        <v-card-actions>
                          <v-spacer></v-spacer>
                          <v-btn
                            @click="item.deleteConfirm = false">
                            No
                          </v-btn>
                          <v-btn
                            color="primaryCustom"
                            text
                            @click="deleteField(item)">
                            Yes
                          </v-btn>
                        </v-card-actions>
                      </v-card>
                    </v-dialog>
                  </div>
                </td>
              </tr>
            </template>
            <template #expanded-item="{ headers, item, index }">
              <td :colspan="headers.length" class="pb-4" :class="{'shaded-row': selectedIndex % 2}">
                <v-col class="flex-display pl-3 pr-3 justify" :class="{'shaded-row': selectedIndex % 2}">
                  <v-card text class="text-center field-card one-hunned" flat
                          :color="selectedIndex % 2 ? 'rowShadeCustom' : 'white'">
                    <v-card-text>{{item.custom ? 'Add Field' : 'Edit Field'}}</v-card-text>
                    <v-text-field
                      label="Field Name"
                      :readonly="!userCanEdit"
                      :disabled="!userCanEdit"
                      tabindex="1"
                      v-model="item.newFieldName"
                    />
                    <div v-if="!apiPath && userIsSystemAdmin" class="text-left read-only-label">
                      <label>System Level Read-only:</label>
                      <input type="checkbox"
                             :readonly="!userCanEdit"
                             :disabled="!userCanEdit"
                             class="ml-2"
                             v-model="item.systemReadonly">
                    </div>
                    <div v-if="!apiPath" class="text-left read-only-label">
                      <label>{{ item.systemReadonly ? 'This field is readonly at system level and cannot be changed.' : 'Read-only:'}}</label>
                      <input type="checkbox"
                             v-if="!item.systemReadonly"
                             :readonly="!userCanEdit"
                             :disabled="!userCanEdit"
                             class="ml-2"
                             v-model="item.readonly">
                      <input type="checkbox"
                             v-else
                             :readonly="true"
                             :disabled="true"
                             class="ml-2"
                             v-model="item.systemReadonly">
                      <br>
                      <label>Allow Selecting Now: </label>
                      <input type="checkbox"
                             v-if="item.dataTypeId === 1 || item.dataTypeId === 2"
                             :readonly="!userCanEdit"
                             :disabled="!userCanEdit"
                             class="ml-2"
                             v-model="item.allowNow">
                    </div>
                    <v-autocomplete
                      v-model="item.companyDataType"
                      :items="filterDataTypes(item)"
                      :disabled="!item.custom || !userCanEdit"
                      :readonly="!item.custom || !userCanEdit"
                      tabindex="2"
                      label="Data Type"
                      item-text="companyDataType"
                      item-value="id"
                      autocomplete="off"
                      return-object
                      attach
                    />

                    <div
                      v-if="$store.getters.userHasFeature('SYSTEM') && item.companyDataType && item.companyDataType.customBehavior">

                      <div v-if="isSystemReference(item.companyDataType.companyDataType)">
                        <v-autocomplete
                          v-model="item.flowCustomFieldId"
                          :items="availableCustomFields"
                          :search-input.sync="customFieldQuery"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          label="Flow System Field"
                          item-text="fieldName"
                          item-value="id"
                          hide-no-data
                          cache-items
                          clearable
                        />
                        <span v-if="item.flowCustomFieldId">Tied to Flow Custom Field ID#{{item.flowCustomFieldId}}</span>
                      </div>

                      <div v-else>
                        <v-text-field
                          v-model="item.customFieldSqlKey"
                          label="SQL Key"
                        />
                        <v-text-field
                          v-model="item.customFieldSqlReferenceTable"
                          label="SQL Reference Table"
                        />

                        <v-checkbox
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          v-model="item.lazyLoadValues"
                          label="Lazy load values" />
                      </div>
                    </div>

                    <v-autocomplete
                      v-if="item.companyDataType && item.companyDataType.systemList"
                      v-model="item.companySystemListId"
                      :items="systemLists"
                      :disabled="!item.custom || !userCanEdit"
                      :readonly="!item.custom || !userCanEdit"
                      label="System List Type"
                      item-text="systemList"
                      item-value="companySystemListId"
                      @change="getSystemListOptions(item.companySystemListId)"
                      attach
                    />

                    <v-autocomplete
                      v-if="item.companySystemListId && systemLists.find(sl => sl.companySystemListId === item.companySystemListId)  && systemLists.find(sl => sl.companySystemListId === item.companySystemListId).hasSubOptions"
                      v-model="item.systemListOptionIds"
                      :items="systemListOptions"
                      :readonly="!userCanEdit"
                      :disabled="!userCanEdit"
                      multiple
                      label="System List Options"
                      item-text="name"
                      item-value="id"
                      attach
                    />

                    <v-col class="options-container"
                           v-if="item.companyDataType && item.companyDataType.hasListValues && !item.companyDataType.systemList && !item.companyDataType.customBehavior">
                      <div class="mb-2">
                        Selectable Options<br />
                        Sort Alphabetically:
                        <input type="checkbox" class="ml-3" v-model="item.sortListValuesAlphabetically">
                      </div>
                      <draggable v-model="item.listOfValues"
                                 group="listOfValues" @start="drag=true" @end="drag=false">
                        <v-list
                          v-for="(ddo, index2) in getLovValues(item.listOfValues, item.sortListValuesAlphabetically)"
                          :class="{'shaded-row': selectedIndex % 2}"
                          :key="index2">
                          <v-list-item dense>
                            <v-list-item-content>
                              <v-text-field
                                class="one-hunned"
                                :readonly="!userCanEdit"
                                :disabled="!userCanEdit"
                                :placeholder="ddo.placeholder"
                                v-model="ddo.name">
                              </v-text-field>
                            </v-list-item-content>
                            <v-list-item-action class="grab" v-if="!item.sortListValuesAlphabetically">
                              <v-icon>drag_handle</v-icon>
                            </v-list-item-action>
                            <v-list-item-action class="clickable" @click="ddo.archived = true">
                              <v-icon>delete</v-icon>
                            </v-list-item-action>
                          </v-list-item>
                        </v-list>
                      </draggable>
                      <v-btn
                        @click="addOption(item.listOfValues)">
                        Add Option
                      </v-btn>
                    </v-col>
                    <v-col class="options-container">
                      <div>Included Object Types</div>
                      <v-container v-if="item.custom">
                        <v-checkbox v-for="(ot, index) in customFieldObjectTypes"
                                    :key="index"
                                    :readonly="!userCanEdit"
                                    :disabled="!userCanEdit"
                                    class="fix-opacity"
                                    v-model="ot.archived"
                                    :false-value="true" :true-value="false"
                                    :label="ot.objectType" />
                      </v-container>
                      <v-container v-else>
                        <v-checkbox v-for="(ot, index) in item.customFieldObjectTypes"
                                    :key="index"
                                    flat
                                    :readonly="!userCanEdit"
                                    :disabled="!userCanEdit"
                                    v-model="ot.archived"
                                    :false-value="true" :true-value="false"
                                    :label="ot.objectType"></v-checkbox>
                      </v-container>
                    </v-col>
                    <v-btn
                        v-if="userCanEdit"
                        :disabled="invalid(item)"
                        @click="[saveChanges(item.custom, item), item.expanded = !item.expanded]">
                      {{item.custom ? 'Add Field' : 'Save Changes'}}
                    </v-btn>
                  </v-card>
                </v-col>
              </td>
            </template>
          </v-data-table>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import { AppMutations } from "@/stores/AppStore";
import Vue2Filters from "vue2-filters";
import cloneDeep from "lodash.clonedeep";
import orderBy from "lodash.orderby";
import debounce from "lodash.debounce";
import draggable from "vuedraggable";

import {
  getRequest,
  getRequestWithParams,
  getSnackbar,
  handleHidingGlobalLoader,
  postRequest,
  putRequest
} from "@/helpers/helpers";
import constants from "@/helpers/constants";

export default {
  name: "CustomFields",
  mixins: [Vue2Filters.mixin],
  props: {
    apiPath: { type: String }
  },
  components: {
    draggable
  },
  data() {
    return {
      snackbar: {},
      constants,
      deleteError: false,
      fieldsInUse: [],
      selectedFieldId: null,
      // this is used so the expanded row uses the full width...bug in vuetify
      // headers: Array(2).fill({}),
      headers: [
        { text: "Field Name", value: "fieldName", showFilter: true },
        { text: "", value: "icons", showFilter: false }
      ],
      footerProps: {
        "items-per-page-options": [25, 50]
      },
      addField: false,
      search: "",
      selectedIndex: null,
      expanded: [],
      customFieldQuery: "",
      availableCustomFields: [],
      customFields: [],
      systemLists: [],
      systemListOptions: [],
      dataTypes: [],
      companyId: this.$store.state.user.details.companyId,
      selectedObjectType: { id: -1, objectType: "All" },
      customFieldObjectTypes: [],
      objectFilters: [],
      userIsSystemAdmin: this.$store.getters.userHasFeature("SYSTEM"),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel("SETTINGS", "EDIT"),
      blankNewObject: {
        id: -1,
        fieldName: "",
        custom: true,
        createdById: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        listOfValues: [],
        customFieldObjectTypes: []
      }
    };
  },
  async created() {
    await this.getCompanyDataTypes();
    //todo @randa do this so that if there are exclusions they will load correctly
    this.getCustomFieldObjectTypes();
    this.getCustomFields();
    this.getSystemLists();
  },
  watch: {
    customFieldQuery(val){
      val && this.debounceFindCustomFields(val)
    }
  },
  methods: {
    isSystemReference (dataType){
      return /System Reference/i.test(dataType)
    },
    getLovValues(lovs, alphaSort) {
      // return lovs
      return orderBy(lovs.filter(lov => !lov.archived), lov => alphaSort ? lov.name.toLowerCase() : lov.displayOrder);
    },
    filterDataTypes(item) {
      if (this.userIsSystemAdmin) {
        return this.dataTypes;
      } else {
        // filter out the system item if not a system admin
        return !item.custom ? this.dataTypes : this.dataTypes.filter(dt => {
          return !dt.customBehavior;
        });
      }
    },
    debounceFindCustomFields: debounce(function(query){
      this.findCustomFields(query)
    }, 250),

    async findCustomFields(query){
      try {
        const { data } = await getRequestWithParams(`/customField/getAll`,{
          params: { query, hasListValues: true }
        }, null, []);
        this.availableCustomFields = data
      }catch (e){
        this.availableCustomFields = []
        console.error(e)
      }
    },
    async getCustomFields() {
      this.$store.commit(AppMutations.SET_LOADING, true);
      try {
        const { data, status } = await getRequest(`/customField/getAll`, this.apiPath, null, []);
        data?.forEach(d => {
          d.companyDataType = this.dataTypes.find(dt => dt.id === d.companyDataTypeId);
        });
        this.allCustomFields = orderBy(data, d => d.fieldName.toLowerCase());
        this.customFields = cloneDeep(this.allCustomFields);
        if (this.userCanEdit) {
          this.customFields.unshift(cloneDeep(this.blankNewObject));
        }
        handleHidingGlobalLoader(this, status);
      } catch (e) {
        console.error("*** ERROR ***", e);
        this.snackbar = getSnackbar("ERROR", "Error Retrieving Data");
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar);
        this.$store.commit(AppMutations.SET_LOADING, false);
      }
    },
    async getSystemLists() {
      this.$store.commit(AppMutations.SET_LOADING, true);
      try {
        const { data, status } = await getRequest(`/systemList`);
        this.systemLists = data;
        handleHidingGlobalLoader(this, status);
      } catch (e) {
        console.error("*** ERROR ***", e);
        this.snackbar = getSnackbar("ERROR", "Error Retrieving Data");
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar);
        this.$store.commit(AppMutations.SET_LOADING, false);
      }
    },
    async getSystemListOptions(listId) {
      let match = this.systemLists.find(sl => sl.companySystemListId === listId);
      if (listId && match?.hasSubOptions) {

        this.$store.commit(AppMutations.SET_LOADING, true);
        try {
          const { data, status } = await getRequestWithParams(`/systemList/${listId}/options`, {
            params: {
              //well i named these poorly...
              //  if a list itself has sub options it means they can select suboptions
              // this parameter means whether to get the subOptions or not
              subOptions: false
            }
          });
          this.systemListOptions = data;
          handleHidingGlobalLoader(this, status);
        } catch (e) {
          console.error("*** ERROR ***", e);
          this.snackbar = getSnackbar("ERROR", "Error Retrieving Data");
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar);
          this.$store.commit(AppMutations.SET_LOADING, false);
        }
      }
    },
    async getCustomFieldObjectTypes() {
      this.$store.commit(AppMutations.SET_LOADING, true);
      try {
        const { data, status } = await getRequest(`/objectType/getCompanyObjectTypes`, this.apiPath, null, []);
        data?.forEach(d => d.archived = true);
        this.customFieldObjectTypes = cloneDeep(data);
        this.objectFilters = data;
        this.objectFilters.unshift({ id: -2, objectType: "Unassigned" });
        this.objectFilters.unshift({ id: -1, objectType: "All" });
        handleHidingGlobalLoader(this, status);
      } catch (e) {
        console.error("*** ERROR ***", e);
        this.snackbar = getSnackbar("ERROR", "Error Retrieving Data");
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar);
        this.$store.commit(AppMutations.SET_LOADING, false);
      }
    },
    async getCompanyDataTypes() {
      this.$store.commit(AppMutations.SET_LOADING, true);
      try {
        const { data, status } = await getRequest(`/dataType/getCompanyDataTypes`);
        this.dataTypes = data;
        handleHidingGlobalLoader(this, status);
      } catch (e) {
        console.error("*** ERROR ***", e);
        this.snackbar = getSnackbar("ERROR", "Error Retrieving Data");
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar);
        this.$store.commit(AppMutations.SET_LOADING, false);
      }
    },
    async deleteField(item) {
      this.$store.commit(AppMutations.SET_LOADING, true);
      try {
        const { data, status } = await putRequest(`/customField/delete/${item.id}`, null, this.apiPath, []);
        if (data?.length > 0) {
          item.deleteConfirm = false;
          this.deleteError = true;
          this.fieldsInUse = data;
          this.snackbar = getSnackbar("ERROR", "Field Cannot Be Deleted");
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar);
        } else {
          item.archived = true;
          this.fieldsInUse = [];
          this.customFields = this.customFields.filter((cf) => {
            return cf.id !== item.id;
          });
          this.snackbar = getSnackbar("SUCCESS", "Field Deleted");
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar);
        }
        handleHidingGlobalLoader(this, status);
      } catch (e) {
        console.error("*** ERROR ***", e);
        this.snackbar = getSnackbar("ERROR", "Error Deleting Field");
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar);
        this.$store.commit(AppMutations.SET_LOADING, false);
      }
    },
    changeSelectedObjectType() {
      if (this.selectedObjectType.id === -1) {
        this.customFields = cloneDeep(this.allCustomFields);
      } else if (this.selectedObjectType.id === -2) {
        this.customFields = this.allCustomFields.filter(cf => {
          return !cf.customFieldObjectTypes.some(cfot => (!cfot.archived && null != cfot.archived));
        });
      } else {
        this.customFields = this.allCustomFields.filter(cf => {
          const match = cf.customFieldObjectTypes.find(cfot => {
            return cfot.objectTypeId === this.selectedObjectType.id && (!cfot.archived && null != cfot.archived);
          });
          return !!match;
        });
      }
      if (this.userCanEdit) {
        this.customFields.unshift(cloneDeep(this.blankNewObject));
      }
    },
    async saveChanges(editMode, object) {
      this.$store.commit(AppMutations.SET_LOADING, true);
      try {
        // woah @randa, wtf is this?
        // the 'Add Field' row had to have an id in order to use it in the data table repeat.  remove the id here
        object.id = object.id === -1 ? null : object.id;

        // set the display order to save to DB
        object.listOfValues.forEach((ddo, idx) => {
          ddo.displayOrder = idx;
        });

        object.companyDataTypeId = object.companyDataType.id;
        object.modifiedById = this.$store.state.user.details.id;

        // set the values of customFieldObjectTypes to be saved in db
        if (object.custom) {
          object.customFieldObjectTypes = this.customFieldObjectTypes.filter(cfot => {
            cfot.objectTypeId = cfot.id;
            return !cfot.archived;
          });
        }

        object.fieldName = object.newFieldName ?? object.fieldName;
        const { data, status } = await postRequest(`/customField`, object, this.apiPath);
        data.companyDataType = this.dataTypes.find(dt => dt.id === data.companyDataTypeId);
        this.$set(object, "listOfValues", data.listOfValues);

        this.expanded = [];
        // if it was a new field, reset the first index, then push it to both arrays
        if (null === object.id) {
          if (this.userCanEdit) {
            object = cloneDeep(this.blankNewObject);
            this.customFields[0] = object;
            this.allCustomFields.push(data);
            this.customFields.push(data);
            this.customFieldObjectTypes.forEach(ot => {
              ot.archived = true;
            });
          }
        }

        // re-sort in case the fieldName changed
        this.customFields = orderBy(this.customFields, cf => cf.fieldName.toLowerCase());
        this.snackbar = getSnackbar("SUCCESS", "Saved Changes");
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar);
        handleHidingGlobalLoader(this, status);
      } catch (e) {
        console.error("*** ERROR ***", e);
        this.snackbar = getSnackbar("ERROR", "Error Saving Changes");
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar);
        this.$store.commit(AppMutations.SET_LOADING, false);
      }
    },
    addOption(options) {
      options.push({ placeholder: "Enter New Option Name", archived: false });
    },
    invalid(item) {
      // todo: use real form validation?
      let invalidOptions = false;
      let invalidCustomSql = false;
      if ((item.companyDataType && item.companyDataType.hasListValues && !item.companyDataType.customBehavior) && !item.companyDataType.systemList) {
        if (item.listOfValues && item.listOfValues.length === 0) {
          invalidOptions = true;
        } else {
          item.listOfValues.forEach(ddo => {
            if (!ddo.name && !ddo.archived) {
              invalidOptions = true;
            }
          });
        }
      } else if (item.companyDataType?.customBehavior && !this.isSystemReference(item.companyDataType.companyDataType)) {
        if (!item.customFieldSqlKey || !item.customFieldSqlReferenceTable) {
          invalidCustomSql = true;
        }
      }
      return (!item.fieldName && !item.newFieldName) || !item.companyDataType || invalidOptions || invalidCustomSql;

    },
    filterCustomFields() {
      return this.customFields.filter(cf => {
        return !cf.archived;
      });
    }
  }
};
</script>

<style lang="scss">
#custom-field-container .v-data-table__wrapper {
  height: calc(100vh - 350px);
  min-height: 300px;
}
</style>

<style scoped lang="scss">
.read-only-label {
  font-size: 16px;
}

.options-container {
  text-align: left;
  padding: 12px 0 !important;
}
</style>
