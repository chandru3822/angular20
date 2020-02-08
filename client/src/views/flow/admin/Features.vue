<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!IS_MOBILE" class="app-title">Features</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="addNew = !addNew; selectedFeature = {}">
              <v-icon v-if="IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat >
          <h3>Add Feature to Company</h3>
          <div class="mb-3">
            <v-select
                v-model="selectedFeature"
                :items="features"
                label="Select a feature to use"
                item-text="featureName"
                item-value="id"
                return-object
            ></v-select>
          </div>
          <v-btn :disabled="!selectedFeature"
                 color="primary" class="white--text mr-2"
                 @click="saveCompanyFeature(true)">
            Save
          </v-btn>
          <v-btn @click="addNew = !addNew; selectedFeature = {}">Cancel</v-btn>
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
            NO DATA HERE!
          </template>

          <template #no-results>
            No parameters exist for this function
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': companyFeatures.indexOf(item) % 2}">
              <h3>Edit Feature</h3>
              <div class="mb-3">
                <v-text-field text v-model="item.featureName"
                              label="Feature Name" />
              </div>
              <v-btn :disabled="!item.featureName"
                     color="primary" class="white--text mr-2"
                     @click="saveCompanyFeature(false, item)">
                Save
              </v-btn>
            </td>
          </template>

          <template #item="{ item }">
            <tr  class="text-left" :class="{'shaded-row': companyFeatures.indexOf(item) % 2}">
              <td class="text-left">{{ item.featureName }}</td>
              <td>
                <v-btn small text v-if="!expanded.includes(item)" @click="expanded = [item]">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text v-if="expanded.includes(item)" @click="expanded = []">cancel</v-btn>
                <v-dialog
                    v-model="item.deleteConfirm"
                    width="500">
                  <template #activator="{ on }">
                    <v-btn small text v-on="on">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </template>
                  <v-card>
                    <v-card-title
                        class="headline grey lighten-2"
                        primary-title>
                      Confirm
                    </v-card-title>

                    <v-card-text class="pt-4">
                      <div class="error-text">
                        WARNING: Feature access control will be completely reset for this feature even if you add the same one back in.
                      </div>
                      Are you sure you want to delete this feature: {{ item.featureName }}?
                    </v-card-text>

                    <v-divider></v-divider>

                    <v-card-actions>
                      <v-spacer></v-spacer>
                      <v-btn
                          @click="item.deleteConfirm = false">
                        No
                      </v-btn>
                      <v-btn
                          color="primary"
                          text
                          @click="deleteCompanyFeature(item)">
                        Yes
                      </v-btn>
                    </v-card-actions>
                  </v-card>
                </v-dialog>
              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar, IS_MOBILE} from '@/helpers/helpers'
  import orderBy from "lodash.orderby";

  export default {
    name: 'CompanyFeatures',
    components: {
      Snackbar
    },
    data() {
      return {
        snackbar: {},
        IS_MOBILE,
        addNew: false,
        levels: [],
        companyFeatures: [],
        selectedFeature: {},
        features: [],
        selectedCompanyFeatureId: null,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        headers: [
          { text: 'Feature', value: 'feature', show: true },
          { text: null, value: 'icons', show: true, sortable: false }
        ],
        expanded: []
      }
    },
    async created () {
      this.getCompanyFeatures()
      this.getFeatures()
    },
    methods: {
      async saveCompanyFeature(isNew, cf) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          if(isNew) {
            cf = {
              featureId: this.selectedFeature.id,
              featureName: this.selectedFeature.featureName,
            }
          }
          const {data} = await putRequest(`/feature`, cf)
          if(isNew){
            this.companyFeatures.push(data)
            this.addNew = false
            this.selectedFeature = {}
            this.snackbar = getSnackbar('SUCCESS', 'Feature Added')
          } else {
            this.expanded = []
            this.snackbar = getSnackbar('SUCCESS', 'Feature Updated')
          }
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', isNew ? 'Error Adding Feature' : 'Error Updating Feature')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getCompanyFeatures() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/feature`)
          this.companyFeatures = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Company Features')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getFeatures() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/feature/all`)
          this.features = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Features')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteCompanyFeature(companyFeature) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/feature/${companyFeature.id}`)
          companyFeature.archived = true
          this.snackbar = getSnackbar('SUCCESS', 'Feature Deleted')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Feature')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterFeatures () {
        return orderBy(this.companyFeatures.filter(cf => { return !cf.archived}), [cf => cf.featureName.toLowerCase()])
      },
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

