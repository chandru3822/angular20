<template>
  <v-row class="fill-height" align="center" justify="start">
    <v-col class="shrink" cols="12">
      <v-card v-if="addType" class="text-left pa-5 mb-3" flat color="rowShadeCustom">
        <h3>Add Org Type</h3>
        <v-text-field text v-model="newOrgType.orgType"
                      label="Org Type Name" />
        <v-select v-model="newOrgType.level"
                  :items="levels"
                  label="Level"
        ></v-select>
        <v-select v-if="newOrgType.level && newOrgType.level !== 'n/a'" v-model="newOrgType.orgParentTypeId"
                  :items="filteredOrgTypes(newOrgType.level)"
                  label="Parent"
                  item-text="orgType"
                  item-value="id"
        ></v-select>
        <div class="mb-3">
          <label>Active:</label>
          <input class="ml-3" type="checkbox" v-model="newOrgType.active">
        </div>

        <v-btn :disabled="!newOrgType.orgType || !newOrgType.level || (newOrgType.level && newOrgType.level !== 'n/a' && !newOrgType.orgParentTypeId)"
               color="primary" class="white--text mr-2"
               @click="saveOrgType(newOrgType, true)">
          Save
        </v-btn>
        <v-btn @click="addType = !addType; newOrgType = {}">Cancel</v-btn>
      </v-card>
      <v-data-table
          :headers="headers"
          :items="orgTypes"
          :items-per-page="-1"
          single-expand
          :expanded.sync="expanded"
          hide-default-footer
          class="elevation-1"
      >
        <template #no-data>
          NO DATA HERE!
        </template>

        <template #no-results>
          No parameters exist for this function
        </template>

        <template #header.icons="{ header }">
          <div class="text-center">
            <v-btn small text v-if="!addType" @click="addType = !addType">
              <v-icon>add</v-icon>
            </v-btn>
          </div>
        </template>

        <template #expanded-item="{ headers, item }">
          <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': orgTypes.indexOf(item) % 2}">
            <h3>Edit Org Type</h3>
            <v-text-field text v-model="item.orgType"
                          label="Org Type Name" />
            <v-select v-model="item.level"
                      :items="levels"
                      label="Level"
            ></v-select>
            <v-select v-if="item.level && item.level !== 'n/a'"
                      v-model="item.orgParentTypeId"
                      :items="filteredOrgTypes(item.level)"
                      label="Parent"
                      item-text="orgType"
                      item-value="id"
            ></v-select>
            <div class="text-left mb-3">
              <label>Active:</label>
              <input class="ml-3" type="checkbox" v-model="item.active">
            </div>
            <v-btn :disabled="!item.orgType || !item.level || (item.level && item.level !== 'n/a' && !item.orgParentTypeId)"
                   color="primary" class="white--text mr-2" @click="saveOrgType(item, false)">Save</v-btn>
          </td>
        </template>

        <template #item="{ item }">
          <tr  class="text-xs-left" :class="{'shaded-row': orgTypes.indexOf(item) % 2}">
            <td class="text-left">{{ item.orgType }}</td>
            <td class="text-left">{{ item.level || 'n/a' }}</td>
            <td class="text-left">{{ item.orgParentType || 'n/a' }}</td>
            <td class="text-left">{{ item.active ? 'Yes' : 'No' }}</td>
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
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import { getRequest, deleteRequest, putRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import Snackbar from '@/components/Snackbar.vue'
  import orderBy from 'lodash.orderby'

  export default {
    name: 'Hierarchy',
    components: {
      Snackbar
    },
    data () {
      return {
        snackbar: {},
        orgTypes: [],
        newOrgType: {},
        addType: false,
        levels: ['n/a',1,2,3,4,5,6],
        headers: [
          { text: 'Org Type', value: 'orgType', show: true },
          { text: 'Level', value: 'level', show: true },
          { text: 'Parent', value: 'orgParentType', show: true},
          { text: 'Active', value: 'active', show: true, sortable: false},
          { text: null, value: 'icons', show: true, sortable: false }
        ],
        expanded: [],
      }
    },
    computed: {},
    methods: {
      async getOrgTypes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/orgType`, this.customer)
          this.orgTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Org Types')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getParentOrgTypes(level) {
        //todo: load available parents so they cant say level 4 but choose a level 8 as the parent,
        //todo: also, should probably make the level field a dropdown
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
      filteredOrgTypes(level) {
        return this.orgTypes.filter(ot => {
          return ot.level == null || ot.level < level
        })
      },
    },
    async created () {
      this.getOrgTypes()
    }
  }
</script>

<style lang="scss" scoped>

</style>
