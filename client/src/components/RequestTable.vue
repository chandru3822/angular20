<template>
  <v-container class="pa-0">
    <v-toolbar color="white" class="elevation-1 mt-3">
      <v-text-field
          class="mt-5 pay-search"
          prepend-inner-icon="search"
          text
          label="Search projects..."
          v-model="searchQuery"
          @input="debounceFilterProjects"
      ></v-text-field>
    </v-toolbar>
    <v-col cols="12">
      <v-data-table
          :headers="headers"
          :items="projects"
          :fixed-header="true"
          :search="projectsSearch"
          :options.sync="options"
          :footer-props="footerProps"
          :items-per-page="50"
          :server-items-length="totalItems"
          :loading="dataLoading"
          dense
          class="elevation-1"
      >

        <template #no-data>
          No requests found
        </template>

        <template #no-results>
          No requests found
        </template>

        <template #body="{ items }">
          <tr
              v-for="(it, index) in items"
              :key="it.id"
              :class="['text-sm-left', 'row-hover', { 'shaded-row': !(index % 2) }, {'clickable' : $store.getters.userHasFeatureAccessLevel(featureCode, 'ADD')}]"
              @click="submitRequest(it)"
          >
            <td class="text-left pl-4">
                {{ it.customer_name ? it.customer_name : '' }}
            </td>
            <td class="text-left pl-4">{{ it.address ? it.address : '' }}</td>
          </tr>
        </template>
      </v-data-table>

      <v-dialog v-model="requestDialog" max-width="700px">
        <v-card>
          <slot name="dialogContent"></slot>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn
                @click="closeDialog"
                color="primary" text
                class="text-capitalize mr-2 mb-2">
              cancel
            </v-btn>
            <v-btn
                @click="[$emit('submitRequest'), closeDialog()]"
                color="primary"
                class="white--text elevation-2 text-capitalize mr-2 mb-2">
              Submit
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </v-col>
  </v-container>
</template>


<script>
import constants from "@/helpers/constants";
import debounce from "lodash.debounce";

export default {
  name: "RequestTable",
  props: {
    headers: Array, // format {text: '', value: '', show: boolean}
    projects: Array,
    totalItems: Number,
    featureCode:String,
    isLoading: Boolean
  },
  data: () => ({
    snackbar: {},
    footerProps: {
      'items-per-page-options': [25, 50, 100, 500],
      'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
    },
    options: {
      itemsPerPage: 100
    },
    pagination: {},
    projectsSearch: '',
    searchQuery: '', //holds the search input string to pass up to parent
    requestDialog: false,
  }),
  computed: {
    dataLoading(){
      return this.isLoading
      //computed so that it updates when the value changes on the parent
    }
  },
  methods: {
    changeSort(column) {
      //todo: make sort actually work
      if (this.pagination.sortBy === column) {
        this.pagination.descending = !this.pagination.descending
      } else {
        this.pagination.sortBy = column
        this.pagination.descending = false
      }
    },
    closeDialog() {
      this.requestDialog = false
    },
    debounceFilterProjects: debounce(function () {
      if(this.searchQuery == ''){
        this.$emit('clearSearch')
      }
      this.$emit('searchInput', this.searchQuery)
    }, 500),

    submitRequest(item) {
      if(this.$store.getters.userHasFeatureAccessLevel(this.featureCode, 'ADD')){
        this.$emit('openRequest', item)
        this.requestDialog = true
      }
    }
  }

}
</script>

<style scoped>

</style>
