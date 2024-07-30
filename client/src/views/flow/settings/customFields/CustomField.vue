<template>
  <v-container id="custom-field-container">

    <v-row v-if="!fieldLoading">
      <v-col cols="12">
        <v-toolbar flat>
          <v-toolbar-title  class="title-large">
            <a-btn fab variant="text" size="small"
                             color="primary" class="mr-2"
                             :to="null == apiPath ? `/settings/customFields` : `/settings/companyCustomFields`"
                             prepend-icon="mdi-chevron-left"
                             :text="!isMobile ? 'Custom Field' : ''"
            />
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
              v-if="userCanEdit"
              variant="text"
              color="primary"
              :disabled="invalid(customField)"
              @click="saveChanges(customField)"
              :prepend-icon="vuetify.breakpoint.smAndDown ? 'save' : ''"
              :text="!vuetify.breakpoint.smAndDown ? 'Save Changes' : ''"
            />
          </v-toolbar-items>
        </v-toolbar>

        <v-card text class="text-left field-card one-hunned" flat>
          <v-card-text class="pl-0">{{ customFieldId ? 'Edit Field' : 'Add Field' }}</v-card-text>
          <a-text-field
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
          <a-autocomplete
            v-model="customField.companyDataType"
            :items="filterCompanyDataTypes"
            :disabled="undefined !== customFieldId || !userCanEdit"
            :readonly="undefined !== customFieldId || !userCanEdit"
            tabindex="2"
            label="Data Type"
            item-title="companyDataType"
            item-value="id"
            autocomplete="off"
            return-object
            attach
          />

          <div
            v-if="userStore.userHasFeature('SYSTEM') && customField.companyDataType && customField.companyDataType.customBehavior">

            <div v-if="isSystemReference(customField.companyDataType.companyDataType)">
              <a-autocomplete
                v-model="customField.flowCustomFieldId"
                :items="availableCustomFields"
                :search-input="customFieldQuery"
                :readonly="!userCanEdit"
                :disabled="!userCanEdit"
                label="Flow System Field"
                item-title="fieldName"
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
              <a-text-field variant="outlined"
                v-model="customField.customFieldSqlKey"
                label="SQL Key"
              />
              <a-textarea auto-grow variant="outlined"
                v-model="customField.customFieldSql"
                label="SQL"
              />
              <a-text-field variant="outlined"
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

          <a-autocomplete
            v-if="customField.companyDataType && customField.companyDataType.systemList"
            v-model="customField.companySystemListId"
            :items="systemLists"
            :disabled="undefined !== customFieldId || !userCanEdit"
            :readonly="undefined !== customFieldId || !userCanEdit"
            label="System List Type"
            item-title="systemList"
            item-value="companySystemListId"
            @change="getSystemListOptions(customField.companySystemListId)"
            attach
          />

          <a-autocomplete
            v-if="customField.companySystemListId && systemLists.find(sl => sl.companySystemListId === customField.companySystemListId)  && systemLists.find(sl => sl.companySystemListId === customField.companySystemListId).hasSubOptions"
            v-model="customField.systemListOptionIds"
            :items="systemListOptions"
            :readonly="!userCanEdit"
            :disabled="!userCanEdit"
            multiple
            label="System List Options"
            item-title="name"
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
                      <a-text-field
                      class="one-hunned"
                      :readonly="!userCanEdit"
                      :disabled="!userCanEdit"
                      :placeholder="ddo.placeholder"
                      @input="ddo.isDirty = true"
                      v-model="ddo.name">
                    </a-text-field>
                      <v-tooltip left v-if="!!ddo.id">
                        <template v-slot:activator="{ on, attrs }">
                          <a-btn variant="text" icon color="primary" @click="copyToClipBoard(ddo.id)" v-bind="attrs"
                                 :activation-handler="on" prepend-icon="mdi-information"/>
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
                    <a-text-field
                      class="one-hunned"
                      :readonly="!userCanEdit"
                      :disabled="!userCanEdit"
                      :placeholder="ddo.placeholder"
                      @input="ddo.isDirty = true"
                      v-model="ddo.name">
                    </a-text-field>
                      <v-tooltip left v-if="!!ddo.id">
                        <template v-slot:activator="{ on, attrs }">
                          <a-btn variant="text" icon color="primary" @click="copyToClipBoard(ddo.id)" v-bind="attrs"
                                 :activation-handler="on" prepend-icon="mdi-information"/>
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

            <a-btn
              color="primary"
              class="mt-2"
              @click="addOption(customField.listOfValues)"
              text="ADD OPTION"
            />
          </v-col>
        </v-card>
      </v-col>
    </v-row>
    <v-container v-if="!fieldLoading">
      <div class="title-medium">Custom Field Usages </div>
      <span v-if="!usesForField || usesForField.length === 0">Nothing using this custom field.</span>
      <v-simple-table v-else>
        <thead>
        <tr>
          <th v-if="apiPath === undefined">Object Name</th>
          <th>Object Type</th>
          <th>Custom Field Group</th>
        </tr>
        </thead>
        <tbody>
        <tr v-for="(item, index) in usesForField" :key="index" :class="{'shaded-row': !(index % 2)}">
          <td v-if="apiPath === undefined">{{item.processStepName || item.eventName }}</td>
          <td>{{item.objectType}}</td>
          <td>{{item.groupName}}</td>
        </tr>
        </tbody>
      </v-simple-table>
    </v-container>
  </v-container>
</template>

<script setup>
import orderBy from "lodash.orderby";
import draggable from "vuedraggable";
import debounce from "lodash.debounce";
import {
  getRequest,
  getRequestWithParams,
  handleHidingGlobalLoader,
  postRequest
} from "@/helpers/helpers";
import { useUserStore } from '@/stores/UserStore.js'

import {getCurrentInstance, onMounted, ref, computed, watch} from "vue";
import {useRouter, useRoute} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()
const vueInstance = getCurrentInstance().proxy
 const vuetify = vueInstance.$vuetify
const store = vueInstance.$store
const userStore = useUserStore()
const route = useRoute()
const router = useRouter()

const props = defineProps({
  apiPath: {type: String}
})
const customField = ref({})
const fieldLoading = ref(false)
const customFieldQuery = ref("")
const systemLists = ref([])
const systemListOptions = ref([])
const companyDataTypes = ref([])
const availableCustomFields = ref([])
const usesForField = ref([])

const selectedSystemListTypeIsUsers = computed(() => {
  let selectedSystemList = systemLists.value.find(sl => sl.id === customField.value.companySystemListId)
  return selectedSystemList.systemListTypeId === 2; //user type id
})
const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})

const customFieldId = computed(() => {
  return route.params.id
})
const userIsSystemAdmin = computed(() => {
  return userStore.userHasFeature("SYSTEM")
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})
const userCanDelete = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'DELETE')
})
const companyId = computed(() => {
  return userStore.details.companyId
})

onMounted(async () => {
  fieldLoading.value = true
  Promise.all([
    getCompanyDataTypes(),
    getSystemLists()
  ]).then(async () => {
    await getCustomField()
  }).then(async () => {
    if (customField.value.id) {
      //don't try to get uses when we're adding a new custom field
      await getUsesForField()
    }
    fieldLoading.value = false
  })
})
watch(customFieldQuery, (val) => {
  val && debounceFindCustomFields(val)
})

const debounceFindCustomFields = debounce((query) => {
  findCustomFields(query)
}, 250)

    const findCustomFields = async (query) => {
      try {
        const {data} = await getRequestWithParams(`/customField/getAll`, {
          params: {query, hasListValues: true}
        }, null, []);
        availableCustomFields.value = data
      } catch (e) {
        availableCustomFields.value = []
        console.error(e)
      }
    }
    const isSystemReference = (dataType) => {
      return /System Reference/i.test(dataType)
    }
    const getLovValues = (lovs, alphaSort) => {
      // return lovs
      //when user manually changes the order it was borked. this should fix it, even though it sucks it loads every time.  bandaid crap fixes for the win!
      lovs.forEach((lov, idx) => {
        if(lov.displayOrder !== idx) {
          lov.isDirty = true
        }
        lov.displayOrder = idx
        //this makes it so the UX doesn't freak out when editing names that would re-sort themselves
        Object.assign(lov, 'nameSortFix', lov.name)
      })
      return orderBy(lovs.filter(lov => !lov.archived), lov => alphaSort && lov.id ? lov.nameSortFix?.toLowerCase() : lov.displayOrder);
    }
    const filterCompanyDataTypes = computed(() => {
      if (userIsSystemAdmin.value) {
        return companyDataTypes.value;
      } else {
        // filter out the system item if not a system admin
        return undefined !== customFieldId.value ? companyDataTypes.value : companyDataTypes.value.filter(dt => {
          return !dt.customBehavior;
        });
      }
    })
    const getCustomField = async ()  => {
      if (customFieldId.value != null) {
        try {
          const {data, status} = await getRequest(`/customField/${customFieldId.value}`, props.apiPath, []);
          customField.value = data
          customField.value.companyDataType = companyDataTypes.value.find(dt => dt.id === data.companyDataTypeId);
          if (null != customField.value.companySystemListId) {
            getSystemListOptions(customField.value.companySystemListId)
          }
          if (null != customField.value.flowCustomFieldId) {
            findCustomFields()
          }
        } catch (e) {
          console.error("*** ERROR ***", e);
          appStore.showSnack("ERROR", "Error Retrieving Data");
        }
      } else {
        //not sure why i am doing  but.value leaving for now
        customField.value = {
          fieldName: "",
          createdById: userStore.details.id,
          listOfValues: [],
        }
      }
    }
    const getSystemLists = async ()  => {
      try {
        const {data, status} = await getRequest(`/systemList`);
        systemLists.value = data;
      } catch (e) {
        console.error("*** ERROR ***", e);
        appStore.showSnack("ERROR", "Error Retrieving Data");
      }
    }
    const getSystemListOptions = async (listId)  => {
      let match = systemLists.value.find(sl => sl.companySystemListId === listId);
      if (listId && match?.hasSubOptions) {

        appStore.loading = true;
        try {
          const {data, status} = await getRequestWithParams(`/systemList/${listId}/options`, {
            params: {
              // well i named these poorly...
              //  if a list itself has sub options it means they can select suboptions
              // this parameter means whether to get the subOptions or not
              subOptions: false
            }
          });
          systemListOptions.value = data;
          handleHidingGlobalLoader(status);
        } catch (e) {
          console.error("*** ERROR ***", e);
          appStore.showSnack("ERROR", "Error Retrieving Data");
          appStore.loading = false;
        }
      }
    }
    const getCompanyDataTypes = async ()  => {
      try {
        const {data, status} = await getRequest(`/dataType/getCompanyDataTypes`);
        companyDataTypes.value = data;
      } catch (e) {
        console.error("*** ERROR ***", e);
        appStore.showSnack("ERROR", "Error Retrieving Data");
      }
    }
    const saveChanges = async (object)  => {

      appStore.loading = true;
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
        debugger
        object.fieldName = object.fieldName
        const {data, status} = await postRequest(`/customField`, object, props.apiPath);
        data.companyDataType = companyDataTypes.value.find(dt => dt.id === data.companyDataTypeId);
        vueInstance.$set(object, "listOfValues", data.listOfValues);

        // if it was a new field, add the id to the customField object and the url
        if (undefined === customFieldId.value || null === customFieldId.value) {
          let path = null == props.apiPath ? `/settings/customField/${data.id}` : `/settings/companyCustomField/${data.id}`
          customField.value.id = data.id
          await router.push(path)
        }

        // re-sort in case the fieldName changed
        appStore.showSnack("SUCCESS", "Saved Changes");
        handleHidingGlobalLoader(status);
      } catch (e) {
        console.error("*** ERROR ***", e);
        appStore.showSnack("ERROR", "Error Saving Changes");
        appStore.loading = false;
      }
    }
    const addOption = (options)  => {
      options.push({placeholder: "Enter New Option Name", archived: false});
    }
    const invalid = (customField)  => {
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
      } else if (customField.companyDataType?.customBehavior && !isSystemReference(customField.companyDataType.companyDataType)) {
        if (!customField.customFieldSqlKey || !customField.customFieldSql || !customField.customFieldSqlReferenceTable) {
          invalidCustomSql = true;
        }
      }
      return (!customField.fieldName && !customField.newFieldName) || !customField.companyDataType || invalidOptions || invalidCustomSql;

    }
    const getUsesForField = async () => {
      appStore.loading = true
      try {
        const {data} = await getRequest(`/customField/getUses/${customFieldId.value}`, props.apiPath, null, []);
        usesForField.value = data;
        appStore.loading = false
      } catch (e) {
        console.error("*** ERROR ***", e);
        appStore.showSnack("ERROR", "Error Retrieving Data");
        appStore.loading = false
      }
    }
    const copyToClipBoard = (textValue) => {
      navigator.clipboard.writeText(textValue);
      appStore.showSnack('SUCCESS', 'Copied id to clipboard')
    }
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
