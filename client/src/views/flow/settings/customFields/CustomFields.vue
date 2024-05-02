<template>
  <v-container id="custom-fields-container">
<!--todo: update dialog-->
    <ConfirmationDialog :open-dialog="deleteError" hideConfirm @close-dialog="deleteError=false">
      <template v-slot:title><span class="error--text">Error Deleting Custom Field</span></template>
      You cannot delete a field that is currently in use. Please remove the field from the following locations
      before deleting.
      <v-list v-for="(item, index) in fieldsInUse" :key="index">
        <v-list-item-content>
          {{ item.objectType }} <span v-if="item.processStepName">{{ item.processStepName }}</span>{{
            item.groupName
          }} - {{ item.fieldName }}
        </v-list-item-content>
      </v-list>
      <template v-slot:no>Ok</template>
    </ConfirmationDialog>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat>
          <v-toolbar-title v-if="!isMobile" class="title-large">Custom Fields</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn variant="text" color="primary"
                   @click="goToCustomField()"
                   v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')"
                   :prepend-icon="vuetify.breakpoint.smAndDown ? 'add' : ''"
                   :text="!vuetify.breakpoint.smAndDown ? 'ADD NEW' : ''"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-card class="square-card">
          <v-card-title class="pt-0">
            <a-text-field
              v-model="search"
              prepend-inner-icon="search"
              label="Search"
              single-line
              clearable
              hide-details
            ></a-text-field>
          </v-card-title>
          <v-data-table id="custom-fields-table"
            :headers="headers"
            :items="filterCustomFields"
            :fixed-header="true"
            :items-per-page="25"
            :loading="fieldsLoading"
            :search="search"
            hide-default-header
            :footer-props="footerProps"
            class="elevation-1 mt-1 square-card table-striped"
          >
            <template #no-data>
              <span class="default-text-color">No available fields</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No available fields</span>
            </template>

            <template #item="{ item, index }">
              <tr>
                <td class="text-left clickable field-name-col">
                  <router-link class="router-link-td" :to="`${getCustomFieldPath()}/${item.id}`">
                    {{ item.fieldName }}
                  </router-link>
                </td>
                <td class="text-right icon-col">
                  <div class="item-icons">
                    <a-btn class="clickable" size="small" variant="text" icon :large="vuetify.breakpoint.smAndDown" color="primary"
                           @click="goToCustomField(item.id)" prepend-icon="edit"
                    />
                    <a-btn v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'DELETE')" variant="text"
                                     icon :large="vuetify.breakpoint.smAndDown" color="primary" @click="getUsesForField(item)"
                                     prepend-icon="delete"
                    />
                  </div>
                </td>
              </tr>
            </template>
          </v-data-table>
        </v-card>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="showDeleteDialog"
                                 @confirm="deleteField"
                                 @close-dialog="closeDeleteDialog">
      Are you sure you want to delete this field: <strong>{{itemToDeleteName}}</strong>?
      <div class="mt-4">Custom Field Usages </div>
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
          <td v-if="apiPath === undefined">{{item.processStepName || item.eventName}}</td>
          <td>{{item.objectType}}</td>
          <td>{{item.groupName}}</td>
        </tr>
        </tbody>
      </v-simple-table>
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import cloneDeep from "lodash.clonedeep";
import orderBy from "lodash.orderby";
import {
  getRequest,
  handleHidingGlobalLoader,
  putRequest
} from "@/helpers/helpers";
import ConfirmationDialog from "@/components/ConfirmationDialog";

import {getCurrentInstance, onMounted, ref, computed, watch} from "vue";
import { useUserStore } from '@/stores/UserStore.js'
import {useRouter} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()
const vueInstance = getCurrentInstance().proxy
 const vuetify = vueInstance.$vuetify
const store = vueInstance.$store
const userStore = useUserStore()
const router = useRouter()

const props = defineProps({
  apiPath: {type: String}
})

const deleteError = ref(false)
const fieldsInUse = ref([])
const search = ref("")
const customFields = ref([])
const fieldsLoading = ref(true)
const showDeleteDialog = ref(false)
const itemToDelete = ref(null)
const usesForField = ref([])
const allCustomFields = ref([])
const headers = ref([
  {text: "Field Name", value: "fieldName", showFilter: true},
  {text: "", value: "icons", showFilter: false}
])
const footerProps = ref({
  "items-per-page-options": [25, 50]
})

const userIsSystemAdmin = computed(() => {
  return userStore.userHasFeature("SYSTEM")
})

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel("SETTINGS", "EDIT")
})

    const itemToDeleteName = computed(() => {
      return itemToDelete.value ? itemToDelete.value.fieldName : ''
    })
    const isMobile = computed(() => {
      return vuetify.breakpoint.smAndDown
    })

  onMounted(async () => {
    fieldsLoading.value = true
    Promise.all([
      getCustomFields(),
    ]).then(() => {
      fieldsLoading.value = false
    })
  })


    const goToCustomField = (customFieldId) => {
      let path = null == props.apiPath ? `/settings/customField` : `/settings/companyCustomField`
      if(customFieldId) {
        path += `/${customFieldId}`
      }
      router.push(path)
    }
    const getCustomFieldPath = () => {
      return null == props.apiPath ? `/settings/customField` : `/settings/companyCustomField`
    }
    const getCustomFields = async ()  => {
      try {
        const {data, status} = await getRequest(`/customField/getAll`, props.apiPath, null, []);
        allCustomFields.value = orderBy(data, d => d.fieldName.toLowerCase());
        customFields.value = cloneDeep(allCustomFields.value);
      } catch (e) {
        console.error("*** ERROR ***", e);
        appStore.showSnack("ERROR", "Error Retrieving Data");

      }
    }
    const getUsesForField = async (customField) => {
      appStore.loading = true
      try {
        const {data, status} = await getRequest(`/customField/getUses/${customField.id}`, props.apiPath, null, []);
        usesForField.value = data;
        itemToDelete.value=customField
        showDeleteDialog.value=true
        appStore.loading = false
      } catch (e) {
        console.error("*** ERROR ***", e);
        appStore.showSnack("ERROR", "Error Retrieving Data");

        appStore.loading = false
      }
    }
    const deleteField = async () => {
      const item = itemToDelete.value
      appStore.loading = true;
      try {
        const {data, status} = await putRequest(`/customField/delete/${item.id}`, null, props.apiPath, []);
        if (data?.length > 0) {
          item.deleteConfirm = false;
          deleteError.value = true;
          fieldsInUse.value = data;
          // appStore.showSnack("ERROR", "Field Cannot Be Deleted");
          //
        } else {
          item.archived = true;
          fieldsInUse.value = [];
          customFields.value = customFields.value.filter((cf) => {
            return cf.id !== item.id;
          });
          appStore.showSnack("SUCCESS", "Field Deleted");

        }
        handleHidingGlobalLoader(status);
      } catch (e) {
        console.error("*** ERROR ***", e);
        appStore.showSnack("ERROR", "Error Deleting Field");
        appStore.loading = false;
      }
      closeDeleteDialog()
    }
    const filterCustomFields = computed(() => {
      return customFields.value.filter(cf => {
        return !cf.archived;
      });
    })
    const closeDeleteDialog = ()=> {
      showDeleteDialog.value = false
      itemToDelete.value = null
    }
</script>

<style lang="scss">
#custom-fields-container .v-data-table__wrapper {
  height: calc(100vh - 275px);
  min-height: 300px;
}

@media (max-width: 770px) {
  #custom-fields-table {
    padding-bottom: 12px;
    div.v-data-footer {
      display: inline-block;
      width: 100%;
      height: auto;

      div.v-data-footer__select {
        justify-content: center;
      }

      div.v-data-footer__pagination {}

      div.v-data-footer__icons-before {
        display: inline;
        margin-left: calc(50% - 36px);
      }
      div.v-data-footer__icons-after {
        display: inline;
      }

    }
  }

.field-name-col {
  width: 100%;
}
  .icon-col {
    min-width: 120px;
  }
}

</style>

<style scoped lang="scss">

</style>
