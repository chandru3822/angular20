<template>
  <v-container>
    <v-row>
      <v-col>
        <v-card class="pa-4 text-left" v-if="addNew">
          <h3>Add User Position</h3>
          <DatetimePickerInput
            v-model="newPosition.startDate"
            :timezone="timezone"
            :type="'date'"
            :format="'MM/DD/YYYY'"
            label="Start Date"
          />
          <DatetimePickerInput
            v-model="newPosition.endDate"
            :timezone="timezone"
            :type="'date'"
            :format="'MM/DD/YYYY'"
            label="End Date"
          />
          <v-autocomplete v-model="newPosition.positionId"
                          :items="positions"
                          label="Positions"
                          item-text="position"
                          item-value="id"
                          @input="populateHierarchy(newPosition, true)"/>
          <div v-if="newPositionHierarchyPopulated">
            <div v-for="(f, index) in filters" :key="index">
              <v-autocomplete v-if="newPosition.keyedHierarchy && newPosition.keyedHierarchy[f.orgLevelId] && isSameLevelAsPosition(f, newPosition)"
                v-model="newPosition.keyedHierarchy[f.orgLevelId]['orgId']"
                :items="f.orgs"
                :label="f.levelName"
                item-value="id"
              >
                <template slot="selection" slot-scope="{ item, index }">
                  {{ item.orgName }} <span v-if="item.showType">&nbsp- {{ item.orgType }}</span>
                </template>
                <template slot='item' slot-scope='{ item }'>
                  {{ item.orgName }} <span v-if="item.showType">&nbsp- {{ item.orgType }}</span>
                </template>
              </v-autocomplete>
            </div>
          </div>
          <v-btn color="secondary" class="mr-2"
                 @click="[newPosition = [], addNew = !addNew]">Cancel</v-btn>
          <v-btn color="primary" class="white--text mr-2"
                 :disabled="!newPosition.startDate || !newPosition.positionId"
                 @click="savePosition(newPosition)">Add</v-btn>
        </v-card>

<!--        existing positions -->
        <v-data-table
            v-if="!addNew"
            :headers="headers"
            :items="userPositions"
            :fixed-header="true"
            :items-per-page="-1"
            hide-default-footer
            :expanded.sync="expanded"
            single-expand
            disable-sort
            class="elevation-1 mt-1"
        >
          <template #no-data>
            No available fields
          </template>

          <template #no-results>
            No available fields
          </template>

          <template #header.icons="{}">
            <th>
              <v-btn text x-small @click="addNew = !addNew">
                <v-icon>add</v-icon>
              </v-btn>
            </th>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left" :class="{'shaded-row': userPositions.indexOf(item) % 2}">
              <h3 class="mb-3">Edit Position</h3>
              <DatetimePickerInput
                v-model="item.startDate"
                :timezone="timezone"
                :type="'date'"
                :format="'MM/DD/YYYY'"
                label="Start Date"
              />
              <DatetimePickerInput
                v-model="item.endDate"
                :timezone="timezone"
                :type="'date'"
                :format="'MM/DD/YYYY'"
                label="End Date"
              />
              <v-autocomplete v-model="item.positionId"
                              :items="positions"
                              label="Positions"
                              @input="populateHierarchy(item, false)"
                              item-text="position"
                              item-value="id"/>
              <label>Primary:</label>
              <input type="checkbox" class="ml-3 mb-4" v-model="item.primaryFlag" :readonly="item.primary" :disabled="item.primary">
              <div v-for="(f, index) in filters" :key="index">
                <v-autocomplete
                          v-if="item.keyedHierarchy[f.orgLevelId] && isSameLevelAsPosition(f, item)"
                          v-model="item.keyedHierarchy[f.orgLevelId]['orgId']"
                          :items="f.orgs"
                          :label="f.levelName"
                          item-text="orgName"
                          item-value="id"
                >
                  <template slot="selection" slot-scope="{ item, index }">
                    {{ item.orgName }} <span v-if="item.showType">&nbsp- {{ item.orgType }}</span>
                  </template>
                  <template slot='item' slot-scope='{ item }'>
                    {{ item.orgName }} <span v-if="item.showType">&nbsp- {{ item.orgType }}</span>
                  </template>
                </v-autocomplete>
              </div>
              <v-btn color="primary" class="white--text mr-2"
                     :disabled="validatePositionFields(item)"
                     @click="savePosition(item)">Save</v-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr :class="{ 'shaded-row': index % 2 }">
              <td class="text-left">{{ item.startDate | formatDate('date')}}</td>
              <td class="text-left">{{ item.endDate | formatDate('date')}}</td>
              <td class="text-left">{{ item.position }}</td>
              <td class="text-left">
                <input type="checkbox" v-model="item.primaryFlag" disabled>
              </td>
              <td class="text-left user-column" v-for="(f, index) in filters" :key="index">
                {{getOrgNameForFilter(item.hierarchy, f.orgLevelId)}}
              </td>
              <td>
                <v-btn text v-if="!expanded.includes(item)" @click="[handleExpand(item, true), item.primary = item.primaryFlag]">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn text v-if="expanded.includes(item)" @click="handleExpand(item, false)">cancel</v-btn>
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
  import keyBy from 'lodash.keyby'
  import {getOrgFilters} from '@/services/orgService'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'UserPositions',
    components: {
      Snackbar,
      DatetimePickerInput
    },
    data() {
      return {
        snackbar: {},
        newPosition: {},
        userPositions: [],
        positions: [],
        addNew: false,
        newPositionHierarchyPopulated: false,
        filters: [],
        timezone: this.$store.state.user.details.timezone.value,
        expanded: [],
        userId: this.$route.params.id,
        headers: [
          { text: 'Start Date', value: 'startDate', show: true },
          { text: 'End Date', value: 'endDate', show: true },
          { text: 'Position', value: 'position', show: true },
          { text: 'Primary', value: 'primaryFlag', show: true },
        ],
      }
    },
    created() {
      this.getUserPositions()
      this.getFilters()
      this.getPositions()
    },
    methods: {
      async getPositions() {
        try {
          const {data} = await getRequest(`/position`)
          this.positions = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Positions')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      populateHeaders () {
        this.filters.forEach(f => {
          this.headers.push({
            text: f.levelName,
            value: f.levelName,
            show: true,
          })
        })
        this.headers.push({
          text: null,
          name: 'icons',
          value: 'icons',
          show: true,
          sortable: false
        })
      },
      async getFilters () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getOrgFilters()
          this.filters = data
          this.populateHeaders()
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Org Levels')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      populateHierarchy(item, isNew) {
        this.newPositionHierarchyPopulated = false
        let selectedPosition = this.positions.find(p => p.id === item.positionId)
        // level = selectedPosition.level
        item.hierarchy = []
        //push a hierarchy item in for the selected level
        this.filters.forEach(f => {
          if(f.level === selectedPosition.level) {
            let obj = {
              level: f.level,
              orgLevelId: f.orgLevelId,
              positionLevel: null,
              orgName: null,
              orgId: null,
              parentOrgId: null
            }
            item.hierarchy.push(obj)
          }
        })
        item.keyedHierarchy = keyBy(item.hierarchy, 'orgLevelId')
        if(isNew) {
          this.newPositionHierarchyPopulated = true
        }
      },
      async getUserPositions () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/userPosition/${this.userId}`)
          this.userPositions = data
          this.userPositions.forEach((p) => {
            p.keyedHierarchy = keyBy(p.hierarchy, 'orgLevelId')
          })
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      getOrgNameForFilter(hierarchy, filterOrgLevelId) {
        const result = hierarchy?.find(({orgLevelId}) => orgLevelId === filterOrgLevelId)
        return result?.orgName ?? 'N/A'
      },
      handleExpand (item, expand) {
        if(expand) {
          this.expanded = [item]
        } else {
          this.expanded = []
        }
      },
      async savePosition (item) {
        //todo: updating a position is not updating the materialized view so it is returning old data
        let lowestHierarchy = item.hierarchy.reduce((prev, current) => {
          return (prev.level > current.level) ? prev : current
        })
        let itemId = item.id
        item.orgId = lowestHierarchy.orgId
        let params = {
          ...item,
          userId: this.userId
        }

        const {data} = await postRequest(`/userPosition`, params)
        item = data
        if(item && item.hierarchy) {
          item.keyedHierarchy = keyBy(item.hierarchy, 'orgLevelId')
          if(!itemId) {
            this.userPositions.push(item)
          }
        }
        this.addNew = false
        this.expanded = []
      },
      isSameLevelAsPosition(f, item) {
        // get hierarchy level to show on screen
        let selectedPosition = this.positions.find(p => p.id === item.positionId)
        return f.level === selectedPosition.level

      },
      validatePositionFields(item) {
        let lowestHierarchy = item.hierarchy.reduce((prev, current) => {
          return (prev.level > current.level) ? prev : current
        })
        return lowestHierarchy.orgId == null
      }
    },

  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

