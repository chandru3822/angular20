<template>
  <v-container>
    <v-row>
      <v-col>
        <v-data-table
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

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': userPositions.indexOf(item) % 2}">
              <h3>Edit Position</h3>
              <v-text-field text v-model="item.startDate"
                            placeholder="Enter a date"
                            type="date"
                            label="Start Date" />
              <v-text-field text v-model="item.endDate"
                            placeholder="Enter a date"
                            type="date"
                            label="End Date" />
              <v-select v-model="item.positionId"
                        :items="positions"
                        label="Position"
                        item-text="position"
                        item-value="id"
              ></v-select>
              <div v-for="(f, index) in filters" :key="index">
                <v-select
                          v-model="item.keyedHierarchy[f.orgLevelId]['orgId']"
                          :items="f.orgs"
                          :label="f.levelName"
                          item-text="orgName"
                          item-value="id"
                ></v-select>
              </div>
              <v-btn color="primary" class="white--text mr-2" @click="savePosition(item)">Save</v-btn>
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
                <v-btn text v-if="!expanded.includes(item)" @click="handleExpand(item, true)">
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
  import cloneDeep from 'lodash.clonedeep'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'UserPositions',
    components: {
      Snackbar
    },
    data() {
      return {
        snackbar: {},
        userPositions: [],
        positions: [],
        filters: [],
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
        console.log('save here', item)
      },
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

