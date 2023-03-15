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
            <v-btn text color="primary"
                   @click="goToCustomField()"
                   v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
              <v-icon large v-if="$vuetify.breakpoint.smAndDown">add</v-icon>
              <span v-else>{{ 'Add New'}}</span>
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
          <v-data-table id="custom-fields-table"
            :headers="headers"
            :items="filterCustomFields()"
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
                <td class="text-left clickable field-name-col"
                    @click="goToCustomField(item.id)">
                  {{ item.fieldName }}
                </td>
                <td class="text-right icon-col">
                  <div class="item-icons">
                    <v-btn class="clickable" small icon :large="$vuetify.breakpoint.smAndDown" color="primary"
                           @click="goToCustomField(item.id)">
                      <v-icon>edit</v-icon>
                    </v-btn>
                    <v-btn v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')" icon :large="$vuetify.breakpoint.smAndDown" color="primary" @click="getUsesForField(item)"><v-icon>delete</v-icon></v-btn>
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
import ConfirmationDialog from "@/components/ConfirmationDialog";

export default {
  name: "CustomFields",
  mixins: [Vue2Filters.mixin],
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
      usesForField: [],
    };
  },
  computed : {
    itemToDeleteName() {
      return this.itemToDelete ? this.itemToDelete.fieldName : ''
    },
    isMobile(){
      return this.$vuetify.breakpoint.smAndDown
    },
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
    async getUsesForField(customField){
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/customField/getUses/${customField.id}`, this.apiPath, null, []);
        this.usesForField = data;
        this.itemToDelete=customField
        this.showDeleteDialog=true
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
          // this.snackbar = getSnackbar("ERROR", "Field Cannot Be Deleted");
          // this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar);
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

@media (max-width: 770px) {
  #custom-fields-table {
    padding-bottom: 12px;
    div.v-data-footer {
      display: inline-block;
      width: 100%;
      padding-bottom: 12px;

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
