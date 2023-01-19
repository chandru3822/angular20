<template>
  <v-container id="custom-field-container">

    <v-row v-if="!fieldLoading">
      <v-col cols="12">
        <v-toolbar flat>
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">
            <v-btn fab text small color="primary" class="mr-2" :to="null == apiPath ? `/settings/customFields` : `/settings/companyCustomFields`">
              <v-icon>mdi-chevron-left</v-icon>
            </v-btn>
            Custom Field
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn v-if="userCanEdit" text
              color="primary"
              :disabled="invalid(customField)"
              @click="saveChanges(customField)">
              {{ 'Save Changes' }}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>

        <v-card text class="text-left field-card one-hunned" flat>
          <v-card-text class="pl-0">{{ customFieldId ? 'Edit Field' : 'Add Field' }}</v-card-text>
          <v-text-field
            label="Field Name"
            :readonly="!userCanEdit"
            :disabled="!userCanEdit"
            tabindex="1"
            v-model="customField.fieldName"
          />
          <div v-if="!apiPath && userIsSystemAdmin" class="text-left read-only-label">
            <label>System Level Read-only:</label>
            <input type="checkbox"
                   :readonly="!userCanEdit"
                   :disabled="!userCanEdit"
                   class="ml-2"
                   v-model="customField.systemReadonly">
          </div>
          <div v-if="!apiPath" class="text-left read-only-label">
            <label>{{
                customField.systemReadonly ? 'This field is readonly at system level and cannot be changed.' : 'Read-only:'
              }}</label>
            <input type="checkbox"
                   v-if="!customField.systemReadonly"
                   :readonly="!userCanEdit"
                   :disabled="!userCanEdit"
                   class="ml-2"
                   v-model="customField.readonly">
            <input type="checkbox"
                   v-else
                   :readonly="true"
                   :disabled="true"
                   class="ml-2"
                   v-model="customField.systemReadonly">
            <br>
            <div
              v-if="customField.companyDataType && (customField.companyDataType.dataTypeId === 1 || customField.companyDataType.dataTypeId === 2)">
              <label>Allow Selecting Now: </label>
              <input type="checkbox"
                     :readonly="!userCanEdit"
                     :disabled="!userCanEdit"
                     class="ml-2"
                     v-model="customField.allowNow">
            </div><div
              v-if="customField.companyDataType && customField.companyDataType.systemList &&
              customField.companySystemListId && selectedSystemListTypeIsUsers">
              <label>Allow Selecting Self: </label>
              <input type="checkbox"
                     :readonly="!userCanEdit"
                     :disabled="!userCanEdit"
                     class="ml-2"
                     v-model="customField.allowSelectSelf">
            </div>
          </div>
          <v-autocomplete
            v-model="customField.companyDataType"
            :items="filterCompanyDataTypes()"
            :disabled="undefined !== customFieldId || !userCanEdit"
            :readonly="undefined !== customFieldId || !userCanEdit"
            tabindex="2"
            label="Data Type"
            item-text="companyDataType"
            item-value="id"
            autocomplete="off"
            return-object
            attach
          />

          <div
            v-if="$store.getters.userHasFeature('SYSTEM') && customField.companyDataType && customField.companyDataType.customBehavior">

            <div v-if="isSystemReference(customField.companyDataType.companyDataType)">
              <v-autocomplete
                v-model="customField.flowCustomFieldId"
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
              <span
                v-if="customField.flowCustomFieldId">Tied to Flow Custom Field ID#{{
                  customField.flowCustomFieldId
                }}</span>
            </div>

            <div v-else>
              <v-text-field outlined
                v-model="customField.customFieldSqlKey"
                label="SQL Key"
              />
              <v-textarea auto-grow outlined
                v-model="customField.customFieldSql"
                label="SQL"
              />
              <v-text-field outlined
                v-model="customField.customFieldSqlReferenceTable"
                label="SQL Reference Table"
              />

              <v-checkbox
                :readonly="!userCanEdit"
                :disabled="!userCanEdit"
                v-model="customField.lazyLoadValues"
                label="Lazy load values"/>
            </div>
          </div>

          <v-autocomplete
            v-if="customField.companyDataType && customField.companyDataType.systemList"
            v-model="customField.companySystemListId"
            :items="systemLists"
            :disabled="undefined !== customFieldId || !userCanEdit"
            :readonly="undefined !== customFieldId || !userCanEdit"
            label="System List Type"
            item-text="systemList"
            item-value="companySystemListId"
            @change="getSystemListOptions(customField.companySystemListId)"
            attach
          />

          <v-autocomplete
            v-if="customField.companySystemListId && systemLists.find(sl => sl.companySystemListId === customField.companySystemListId)  && systemLists.find(sl => sl.companySystemListId === customField.companySystemListId).hasSubOptions"
            v-model="customField.systemListOptionIds"
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
                 v-if="customField.companyDataType && customField.companyDataType.hasListValues && !customField.companyDataType.systemList && !customField.companyDataType.customBehavior">
            <div class="mb-2">
              Selectable Options<br/>
              Sort Alphabetically:
              <input :disabled="!userCanEdit" type="checkbox" class="ml-3" v-model="customField.sortListValuesAlphabetically">
            </div>
            <draggable v-if="userCanEdit" v-model="customField.listOfValues"
                       group="listOfValues" @start="drag=true" @end="drag=false">
              <v-list
                v-for="(ddo, index2) in getLovValues(customField.listOfValues, customField.sortListValuesAlphabetically)"
                :class="{'shaded-row': index2 % 2}"
                :key="index2">
                <v-list-item dense>
                  <v-list-item-action class="grab" v-if="!customField.sortListValuesAlphabetically && userCanEdit">
                    <v-icon color="primary">drag_handle</v-icon>
                  </v-list-item-action>
                  <v-list-item-content>
                    <div class="flex-align-items-center">
                      <v-text-field
                      class="one-hunned"
                      :readonly="!userCanEdit"
                      :disabled="!userCanEdit"
                      :placeholder="ddo.placeholder"
                      @input="ddo.isDirty = true"
                      v-model="ddo.name">
                    </v-text-field>
                      <v-tooltip left>
                        <template v-slot:activator="{ on, attrs }">
                          <v-btn icon color="primary" @click="copyToClipBoard(ddo.id)" v-bind="attrs"
                                 v-on="on"><v-icon>mdi-information</v-icon></v-btn>
                        </template>
                        <span>List of Value ID: {{ddo.id}}</span>
                        <div class="text-center">(click to copy)</div>
                      </v-tooltip>
                    </div>
                  </v-list-item-content>
                  <v-list-item-action class="clickable" @click="ddo.archived = true">
                    <v-icon color="primary">delete</v-icon>
                  </v-list-item-action>
                </v-list-item>
              </v-list>
            </draggable>

            <div v-else v-model="customField.listOfValues"
                       group="listOfValues" @start="drag=true" @end="drag=false">
              <v-list
                v-for="(ddo, index2) in getLovValues(customField.listOfValues, customField.sortListValuesAlphabetically)"
                :class="{'shaded-row': index2 % 2}"
                :key="index2">
                <v-list-item dense>
                  <v-list-item-action class="grab" v-if="!customField.sortListValuesAlphabetically && userCanEdit">
                    <v-icon color="primary">drag_handle</v-icon>
                  </v-list-item-action>
                  <v-list-item-content>
                    <div flex-align-items-center>
                    <v-text-field
                      class="one-hunned"
                      :readonly="!userCanEdit"
                      :disabled="!userCanEdit"
                      :placeholder="ddo.placeholder"
                      @input="ddo.isDirty = true"
                      v-model="ddo.name">
                    </v-text-field>
                      <v-tooltip left>
                        <template v-slot:activator="{ on, attrs }">
                          <v-btn icon color="primary" @click="copyToClipBoard(ddo.id)" v-bind="attrs"
                                 v-on="on"><v-icon>mdi-information</v-icon></v-btn>
                        </template>
                        <span>List of Value ID: {{ddo.id}} </span>
                        <div class="text-center">(click to copy)</div>
                      </v-tooltip>
                    </div>
                  </v-list-item-content>
                  <v-list-item-action v-if="userCanDelete" class="clickable" @click="ddo.archived = true">
                    <v-icon color="primary">delete</v-icon>
                  </v-list-item-action>
                  <v-icon v-else :disabled="true" color="primary">delete</v-icon>
                </v-list-item>
              </v-list>
            </div>

            <v-btn
              color="primary"
              class="mt-2"
              @click="addOption(customField.listOfValues)">
              Add Option
            </v-btn>
          </v-col>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import {AppMutations} from "@/stores/AppStore";
import cloneDeep from "lodash.clonedeep";
import orderBy from "lodash.orderby";
import draggable from "vuedraggable";
import debounce from "lodash.debounce";

import {
  getRequest,
  getRequestWithParams,
  getSnackbar,
  handleHidingGlobalLoader,
  postRequest,
  putRequest
} from "@/helpers/helpers";
import constants from "@/helpers/constants";
import ConfirmationDialog from "@/components/ConfirmationDialog";

export default {
  name: "CustomField",
  props: {
    apiPath: {type: String}
  },
  components: {
    ConfirmationDialog,
    draggable
  },
  data() {
    return {
      snackbar: {},
      constants,
      customFieldId: this.$route.params.id,
      customField: {},
      fieldLoading: false,
      customFieldQuery: "",
      systemLists: [],
      systemListOptions: [],
      companyDataTypes: [],
      availableCustomFields: [],
      companyId: this.$store.state.user.details.companyId,
      userIsSystemAdmin: this.$store.getters.userHasFeature("SYSTEM"),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel("SETTINGS", "EDIT"),
      userCanDelete: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE'),
    };
  },
  computed: {
    selectedSystemListTypeIsUsers(){
      let selectedSystemList = this.systemLists.find(sl => sl.id === this.customField.companySystemListId)
      return selectedSystemList.systemListTypeId === 2; //user type id
    }
  },
  async created() {
    this.fieldLoading = true
    Promise.all([
      this.getCompanyDataTypes(),
      this.getSystemLists()
    ]).then(async () => {
      await this.getCustomField()
      this.fieldLoading = false
    })
  },
  watch: {
    customFieldQuery(val) {
      val && this.debounceFindCustomFields(val)
    }
  },
  methods: {
    debounceFindCustomFields: debounce(function (query) {
      this.findCustomFields(query)
    }, 250),
    async findCustomFields(query) {
      try {
        const {data} = await getRequestWithParams(`/customField/getAll`, {
          params: {query, hasListValues: true}
        }, null, []);
        this.availableCustomFields = data
      } catch (e) {
        this.availableCustomFields = []
        console.error(e)
      }
    },
    isSystemReference(dataType) {
      return /System Reference/i.test(dataType)
    },
    getLovValues(lovs, alphaSort) {
      // return lovs
      //when user manually changes the order it was borked. this should fix it, even though it sucks it loads every time.  bandaid crap fixes for the win!
      lovs.forEach((lov, idx) => {
        if(lov.displayOrder !== idx) {
          lov.isDirty = true
        }
        lov.displayOrder = idx
      })
      return orderBy(lovs.filter(lov => !lov.archived), lov => alphaSort && lov.id ? lov.name?.toLowerCase() : lov.displayOrder);
    },
    filterCompanyDataTypes() {
      if (this.userIsSystemAdmin) {
        return this.companyDataTypes;
      } else {
        // filter out the system item if not a system admin
        return undefined !== this.customFieldId ? this.companyDataTypes : this.companyDataTypes.filter(dt => {
          return !dt.customBehavior;
        });
      }
    },
    async getCustomField() {
      if (this.customFieldId != null) {
        try {
          const {data, status} = await getRequest(`/customField/${this.customFieldId}`, this.apiPath, []);
          this.customField = data
          this.customField.companyDataType = this.companyDataTypes.find(dt => dt.id === data.companyDataTypeId);
          if (null != this.customField.companySystemListId) {
            this.getSystemListOptions(this.customField.companySystemListId)
          }
          if (null != this.customField.flowCustomFieldId) {
            this.findCustomFields()
          }
        } catch (e) {
          console.error("*** ERROR ***", e);
          this.snackbar = getSnackbar("ERROR", "Error Retrieving Data");
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar);
        }
      } else {
        //not sure why i am doing this. but leaving for now
        this.customField = {
          fieldName: "",
          createdById: this.$store.state.user.details.id,
          listOfValues: [],
        }
      }
    },
    async getSystemLists() {
      try {
        const {data, status} = await getRequest(`/systemList`);
        this.systemLists = data;
        debugger
      } catch (e) {
        console.error("*** ERROR ***", e);
        this.snackbar = getSnackbar("ERROR", "Error Retrieving Data");
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar);
      }
    },
    async getSystemListOptions(listId) {
      let match = this.systemLists.find(sl => sl.companySystemListId === listId);
      if (listId && match?.hasSubOptions) {

        this.$store.commit(AppMutations.SET_LOADING, true);
        try {
          const {data, status} = await getRequestWithParams(`/systemList/${listId}/options`, {
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
    async getCompanyDataTypes() {
      try {
        const {data, status} = await getRequest(`/dataType/getCompanyDataTypes`);
        this.companyDataTypes = data;
      } catch (e) {
        console.error("*** ERROR ***", e);
        this.snackbar = getSnackbar("ERROR", "Error Retrieving Data");
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar);
      }
    },
    async saveChanges(object) {
      debugger
      this.$store.commit(AppMutations.SET_LOADING, true);
      try {
        // set the display order to save to DB
        //this should have already been done by the getLovValues function, but it was in both places so i just left this one
        object?.listOfValues?.forEach((ddo, idx) => {
          //if the current display order doesn't match the saved display order make it dirty
          if(ddo.displayOrder !== idx) {
            ddo.isDirty = true
            ddo.displayOrder = idx
          }
        });

        object.companyDataTypeId = object.companyDataType.id

        object.fieldName = object.fieldName
        const {data, status} = await postRequest(`/customField`, object, this.apiPath);
        data.companyDataType = this.companyDataTypes.find(dt => dt.id === data.companyDataTypeId);
        this.$set(object, "listOfValues", data.listOfValues);

        // if it was a new field, add the id to the object and the url
        if (undefined === this.customFieldId || null === this.customFieldId) {
          this.customFieldId = data.id
          this.customField.id = data.id
          let path = null == this.apiPath ? `/settings/customField/${data.id}` : `/settings/companyCustomField/${data.id}`
          this.$router.push(path)
        }

        // re-sort in case the fieldName changed
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
      options.push({placeholder: "Enter New Option Name", archived: false});
    },
    invalid(customField) {
      // todo: use real form validation?
      let invalidOptions = false;
      let invalidCustomSql = false;
      if ((customField.companyDataType && customField.companyDataType.hasListValues && !customField.companyDataType.customBehavior) && !customField.companyDataType.systemList) {
        if (customField.listOfValues && customField.listOfValues.length === 0) {
          invalidOptions = true;
        } else {
          customField.listOfValues.forEach(ddo => {
            if (!ddo.name && !ddo.archived) {
              invalidOptions = true;
            }
          });
        }
      } else if (customField.companyDataType?.customBehavior && !this.isSystemReference(customField.companyDataType.companyDataType)) {
        if (!customField.customFieldSqlKey || !customField.customFieldSql || !customField.customFieldSqlReferenceTable) {
          invalidCustomSql = true;
        }
      }
      return (!customField.fieldName && !customField.newFieldName) || !customField.companyDataType || invalidOptions || invalidCustomSql;

    },
    copyToClipBoard(textValue){
      navigator.clipboard.writeText(textValue);
      this.snackbar = getSnackbar('SUCCESS', 'Copied id to clipboard')
      this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
    },
  }
};
</script>

<style lang="scss">
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
