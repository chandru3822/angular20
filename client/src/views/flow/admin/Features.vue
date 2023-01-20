<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Features</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addNew = !addNew, selectedFeature = {}]">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat >
          <h3>{{isCompanyRoot ? 'Add New Feature' : 'Add Feature to Company'}}</h3>
          <div class="mb-3">
            <div v-if="isCompanyRoot">
              <v-text-field text label="Enter the name of a new feature"
                            v-model="selectedFeature.featureName"></v-text-field>
              <v-text-field text label="Enter Feature Code"
                            v-model="selectedFeature.featureCode"></v-text-field>
              <label>Is System:</label>
              <input class="ml-3" type="checkbox" v-model="selectedFeature.isSystem">
            </div>
            <v-select
                v-else
                v-model="selectedFeature"
                :items="features"
                label="Select a feature to use"
                item-text="featureName"
                item-value="id"
                return-object
            ></v-select>
          </div>
          <v-btn text color="primary" @click="[addNew = !addNew, selectedFeature = {}]">Cancel</v-btn>
          <v-btn :disabled="!selectedFeature || !selectedFeature.featureName || !selectedFeature.featureCode"
                 color="primary" class="mr-2"
                 @click="saveFeature(true)">
            Save
          </v-btn>
        </v-card>
        <v-data-table
            :headers="headers"
            :items="filterFeatures()"
            :fixed-header="true"
            :items-per-page="-1"
            single-expand
            :mobile-breakpoint="0"
            :expanded.sync="expanded"
            hide-default-footer
            class="elevation-1 org-type-table"
        >
          <template #no-data>
            <span class="default-text-color">NO DATA HERE!</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No parameters exist for this function</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': companyFeatures.indexOf(item) % 2}">
              <h3>Edit Feature</h3>
              <div class="mb-3">
                <v-text-field text v-model="item.featureName"
                              label="Feature Name" />
                <div v-if="isCompanyRoot">
                  <v-text-field text v-model="item.featureCode"
                                label="Feature Name" />
                  <label>Is System:</label>
                  <input class="ml-3" type="checkbox" v-model="item.isSystem">
                </div>
              </div>
              <v-btn :disabled="!item.featureName"
                     color="primary" class="white--text mr-2"
                     @click="saveFeature(false, item)">
                Save
              </v-btn>
            </td>
          </template>

          <template #item="{ item }">
            <tr  class="text-left" :class="{'shaded-row': companyFeatures.indexOf(item) % 2}">
              <td class="text-left">{{ item.featureName }}</td>
              <td class="text-left">{{ item.featureCode }}</td>
              <td>
                <v-btn small text color="primary" v-if="!expanded.includes(item)" @click="expanded = [item]">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text color="primary" v-if="expanded.includes(item)" @click="expanded = []">cancel</v-btn>
                <v-btn small text color="primary" @click="featureToDelete=item"><v-icon>delete</v-icon></v-btn>
              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!featureToDelete" @confirm="deleteFeature" @close-dialog="featureToDelete = null">
      <div v-if="isCompanyRoot">
        <span class="error--text">WARNING:</span> This will delete this feature system-wide!
          </div>
      <div v-else>
        <span class="error--text">WARNING:</span> Feature access control will be completely reset for this feature even if you add the same one back in.
      </div>
      Are you sure you want to delete this feature: <b>{{ featureToDeleteName }}</b>?
    </ConfirmationDialog>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequest, deleteRequest, putRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import orderBy from "lodash.orderby";
  import ConfirmationDialog from "@/components/ConfirmationDialog";

  export default {
    name: 'Features',
    components: {ConfirmationDialog},
    data() {
      return {
        constants,
        snackbar: {},
        isCompanyRoot: this.$store.getters.isCompanyRoot(this.$store.state.user.details.companyId),
        addNew: false,
        levels: [],
        companyFeatures: [],
        selectedFeature: {},
        features: [],
        apiUrl: this.$store.getters.isCompanyRoot(this.$store.state.user.details.companyId) ? `/feature` : `/feature/company`,
        selectedFeatureId: null,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        headers: [
          { text: 'Feature', value: 'feature', show: true },
          { text: 'Feature Code', value: 'featureCode', show: true },
          { text: null, value: 'icons', show: true, sortable: false }
        ],
        expanded: [],
        featureToDelete: null
      }
    },
    computed: {
      featureToDeleteName(){
        return this.featureToDelete ? this.featureToDelete.featureName : ''
      }
    },
    async created () {
      this.getCompanyFeatures()
      this.getFeatures()
    },
    methods: {
      async saveFeature(isNew, feature) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          feature = isNew && this.isCompanyRoot ? this.selectedFeature :
            isNew && !this.isCompanyRoot ?
            {
              featureId: this.selectedFeature.id,
              featureName: this.selectedFeature.featureName,
            } : feature
          const {data, status} = await putRequest(`${this.apiUrl}`, feature)
          if(isNew){
            this.companyFeatures.push(data)
            this.addNew = false
            this.selectedFeature = {}
            this.snackbar = getSnackbar('SUCCESS', 'Feature Added')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          } else {
            this.expanded = []
            this.snackbar = getSnackbar('SUCCESS', 'Feature Updated')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', isNew ? 'Error Adding Feature' : 'Error Updating Feature')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getCompanyFeatures() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`${this.apiUrl}`)
          this.companyFeatures = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Features')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getFeatures() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/feature`)
          this.features = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Features')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteFeature() {
        const feature = this.featureToDelete
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`${this.apiUrl}/${feature.id}`)
          feature.archived = true
          this.snackbar = getSnackbar('SUCCESS', 'Feature Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Feature')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterFeatures () {
        return orderBy(this.companyFeatures.filter(cf => { return !cf.archived}), [cf => cf.featureName.toLowerCase()])
      },
    }
  }
</script>
