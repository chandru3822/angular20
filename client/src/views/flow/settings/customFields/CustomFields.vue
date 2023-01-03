<template>
  <v-container id="custom-fields-container">
    <v-dialog
      v-model="deleteError"
    >
      <v-card>
        <v-card-title class="text-h5 error--text">Error Deleting Custom Field</v-card-title>

        <v-card-text>
          You cannot delete a field that is currently in use. Please remove the field from the following locations
          before deleting.
          <v-list v-for="(item, index) in fieldsInUse" :key="index">
            <v-list-item-content>
              {{ item.objectType }} <span v-if="item.processStepName">{{ item.processStepName }}</span>{{
                item.groupName
              }} - {{ item.fieldName }}
            </v-list-item-content>
          </v-list>
        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            color="primary"
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
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary"
                   @click="goToCustomField()"
                   v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
              {{ 'Add New'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card class="square-card">
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
            :loading="fieldsLoading"
            :search="search"
            hide-default-header
            :footer-props="footerProps"
            class="elevation-1 mt-1 square-card"
          >
            <template #no-data>
              <span class="default-text-color">No available fields</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No available fields</span>
            </template>

            <template #item="{ item, index }">
              <tr :class="{'shaded-row': index % 2}">
                <td class="text-left clickable"
                    @click="goToCustomField(item.id)">
                  {{ item.fieldName }}
                </td>
                <td class="text-right">
                  <div class="item-icons">
                    <v-btn small text color="primary" @click="getUsesForField(item.id)"><v-icon>mdi-information</v-icon></v-btn>
                    <v-btn class="clickable" small text color="primary"
                           @click="goToCustomField(item.id)">
                      <v-icon>edit</v-icon>
                    </v-btn>
                    <v-btn v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')" text color="primary" @click="[itemToDelete=item, showDeleteDialog=true]"><v-icon>delete</v-icon></v-btn>
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
      Are you sure you want to delete this field: <strong>{{itemToDeleteName}}</strong>

    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="showInfoDialog"
                        hideConfirm
                        @close-dialog="showInfoDialog=false"
                        width="700"
    >
      <template v-slot:title>Custom Field Usages: {{usesForField[0].fieldName}}</template>
      <span v-if="!usesForField || usesForField.length === 0">Nothing using this custom field.</span>
      <v-list dense>
        <v-simple-table>
          <thead>
          <tr>
            <th>Object Name</th>
            <th>Object Type</th>
            <th>Custom Field Group</th>
          </tr>
          </thead>
          <tbody>
          <tr v-for="(item, index) in usesForField" :key="index" :class="{'shaded-row': !(index % 2)}">
            <td>{{item.processStepName || item.eventName}}</td>
            <td>{{item.objectType}}</td>
            <td>{{item.groupName}}</td>
          </tr>
          </tbody>
        </v-simple-table>
      </v-list>
      <template v-slot:no>Close</template>
    </ConfirmationDialog>
  </v-container>
</template>

<script>
import {AppMutations} from "@/stores/AppStore";
import Vue2Filters from "vue2-filters";
import cloneDeep from "lodash.clonedeep";
import orderBy from "lodash.orderby";

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
import ConfirmDeleteDialog from "@/ConfirmDeleteDialog.vue";
import ConfirmationDialog from "@/ConfirmationDialog.vue";

export default {
  name: "CustomFields",
  mixins: [Vue2Filters.mixin],
  props: {
    apiPath: {type: String}
  },
  components: {
    ConfirmationDialog,
    ConfirmDeleteDialog,
    draggable
  },
  data() {
    return {
      snackbar: {},
      constants,
      deleteError: false,
      fieldsInUse: [],
      headers: [
        {text: "Field Name", value: "fieldName", showFilter: true},
        {text: "", value: "icons", showFilter: false}
      ],
      footerProps: {
        "items-per-page-options": [25, 50]
      },
      search: "",
      customFields: [],
      fieldsLoading: true,
      userIsSystemAdmin: this.$store.getters.userHasFeature("SYSTEM"),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel("SETTINGS", "EDIT"),
      showDeleteDialog: false,
      itemToDelete: null,
      showInfoDialog: false,
      usesForField: [],
    };
  },
  computed : {
    itemToDeleteName() {
      return this.itemToDelete ? this.itemToDelete.fieldName : ''
    }
  },
  async created() {
    this.fieldsLoading = true
    Promise.all([
      this.getCustomFields(),
    ]).then(() => {
      this.fieldsLoading = false
    })
  },

  methods: {
    goToCustomField(customFieldId) {
      let path = null == this.apiPath ? `/settings/customField` : `/settings/companyCustomField`
      if(customFieldId) {
        path += `/${customFieldId}`
      }
      this.$router.push(path)
    },
    async getCustomFields() {
      try {
        const {data, status} = await getRequest(`/customField/getAll`, this.apiPath, null, []);
        this.allCustomFields = orderBy(data, d => d.fieldName.toLowerCase());
        this.customFields = cloneDeep(this.allCustomFields);
      } catch (e) {
        console.error("*** ERROR ***", e);
        this.snackbar = getSnackbar("ERROR", "Error Retrieving Data");
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar);
      }
    },
    async getUsesForField(customFieldId){
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/customField/getUses/${customFieldId}`, this.apiPath, null, []);
        this.usesForField = data;
        this.showInfoDialog = true
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error("*** ERROR ***", e);
        this.snackbar = getSnackbar("ERROR", "Error Retrieving Data");
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar);
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteField() {
      const item = this.itemToDelete
      this.$store.commit(AppMutations.SET_LOADING, true);
      try {
        const {data, status} = await putRequest(`/customField/delete/${item.id}`, null, this.apiPath, []);
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
      this.closeDeleteDialog()
    },
    filterCustomFields() {
      return this.customFields.filter(cf => {
        return !cf.archived;
      });
    },
    closeDeleteDialog(){
      this.showDeleteDialog = false
      this.itemToDelete = null
    }
  }
};
</script>

<style lang="scss">
#custom-fields-container .v-data-table__wrapper {
  height: calc(100vh - 275px);
  min-height: 300px;
}
</style>

<style scoped lang="scss">

</style>
