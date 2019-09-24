<template>
  <v-container id="hierarchy-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Organization Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text v-if="!addType" @click="addType = !addType">
              {{ addType ? 'Cancel' : 'Add New' }}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addType" class="text-left pa-5 mb-3 mt-2" flat >
          <h3>Add Org Type</h3>
          <v-text-field text v-model="newOrgType.orgType"
                        label="Org Type Name" />
          <v-select v-model="newOrgType.orgLevelId"
                    :items="levels"
                    label="Level"
                    item-text="level"
                    item-value="id"
          ></v-select>
          <v-select v-if="newOrgType.orgLevelId"
                    v-model="newOrgType.orgParentTypeId"
                    :items="filteredOrgTypes(newOrgType.orgLevelId)"
                    label="Parent"
                    item-text="orgType"
                    item-value="id"
          ></v-select>

          <v-btn :disabled="!newOrgType.orgType || !newOrgType.orgLevelId"
                 color="primary" class="white--text mr-2"
                 @click="saveOrgType(newOrgType, true)">
            Save
          </v-btn>
          <v-btn @click="addType = !addType; newOrgType = {}">Cancel</v-btn>
        </v-card>
        <v-data-table
            :headers="headers"
            :items="orgTypes"
            :fixed-header="true"
            :items-per-page="-1"
            single-expand
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
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': orgTypes.indexOf(item) % 2}">
              <h3>Edit Org Type</h3>
              <v-text-field text v-model="item.orgType"
                            label="Org Type Name" />
              <v-select v-model="item.orgLevelId"
                        :items="levels"
                        label="Level"
                        item-text="level"
                        item-value="id"
              ></v-select>
              <v-select v-if="item.orgLevelId && item.orgLevelId"
                        v-model="item.orgParentTypeId"
                        :items="filteredOrgTypes(item.orgLevelId)"
                        label="Parent"
                        item-text="orgType"
                        item-value="id"
              ></v-select>
              <v-btn :disabled="!item.orgType || !item.orgLevelId"
                     color="primary" class="white--text mr-2" @click="saveOrgType(item, false)">Save</v-btn>
            </td>
          </template>

          <template #item="{ item }">
            <tr  class="text-xs-left" :class="{'shaded-row': orgTypes.indexOf(item) % 2}">
              <td class="text-left">{{ item.orgType }}</td>
              <td class="text-left">{{ item.level || 'n/a' }}</td>
              <td class="text-left">{{ item.orgParentType || 'n/a' }}</td>
              <td>
                <v-btn small text v-if="!expanded.includes(item)" @click="expanded = [item]">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text v-if="expanded.includes(item)" @click="expanded = []">cancel</v-btn>
              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
      <Snackbar :snackbar="snackbar"></Snackbar>
    </v-row>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import { getRequest, deleteRequest, putRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import Snackbar from '@/components/Snackbar.vue'
  import orderBy from 'lodash.orderby'
  import {getOrgTypes} from '@/services/orgService'

  export default {
    name: 'OrgHierarchy',
    components: {
      Snackbar
    },
    data () {
      return {
        snackbar: {},
        orgTypes: [],
        newOrgType: {},
        addType: false,
        levels: [],
        headers: [
          { text: 'Org Type', value: 'orgType', show: true },
          { text: 'Level', value: 'level', width: 80, show: true },
          { text: 'Parent', value: 'orgParentType', show: true},
          { text: null, value: 'icons', show: true, sortable: false }
        ],
        expanded: [],
      }
    },
    computed: {},
    methods: {
      async getOrgTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getOrgTypes()
          this.orgTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Org Types')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getOrgLevels() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/orgType/levels`)
          this.levels = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Org Levels')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveOrgType(ot, isNew) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          ot.level = ot.level === 'n/a' ? null : ot.level
          const {data} = await putRequest(`/orgType`, ot)
          if(isNew){
            this.orgTypes.push(data)
            this.addType = false
            this.newOrgType = {}
            this.snackbar = getSnackbar('SUCCESS', 'Org Type Added')
          } else {
            this.expanded = []
            this.snackbar = getSnackbar('SUCCESS', 'Org Type Updated')
          }
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', isNew ? 'Error Adding Org Type' : 'Error Updating Org Type')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filteredOrgTypes(orgLevelId) {
        // filter list so they cannot select a parent that is further down in the hierarchy than self
        const orgLevel = this.levels.find(l => l.id === orgLevelId)
        return this.orgTypes.filter(ot => {
          return ot.level < orgLevel.level
        })
      },
    },
    async created () {
      this.getOrgTypes()
      this.getOrgLevels()
    }
  }
</script>

<style lang="scss">
  #hierarchy-container .v-data-table__wrapper {
    height: calc(100vh - 350px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  .org-type-table {
    margin-top: 2px;
  }
</style>
