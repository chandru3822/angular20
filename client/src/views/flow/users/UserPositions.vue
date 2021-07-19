<template>
  <v-container>
    <v-row>
      <v-col>
        <v-card class="pa-4 text-left" v-if="addNew">
          <v-form ref="newPositionForm">
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
            <label>Make Primary:</label>
            <input type="checkbox" class="ml-3 mb-4" v-model="newPosition.primaryFlag">
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
                  :items="getOrgsMatchingPositionOrgType(f.orgs, newPosition)"
                  :rules="requiredRules"
                  :label="f.levelName"
                  item-value="id"
                  item-text="orgName"
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
            <div v-if="newPosition.startDate >= newPosition.endDate" class="error-text mb-2">
              End date must be null or after the start date
            </div>
            <v-btn color="secondary" class="mr-2"
                   @click="[newPosition = [], addNew = !addNew]">Cancel</v-btn>
            <v-btn color="primaryCustom" class="white--text mr-2"
                   :disabled="!newPosition.positionId ||
                              (newPosition.positionId && newPosition.endDate && !newPosition.startDate ) ||
                              (newPosition.positionId && newPosition.endDate <= newPosition.startDate )"
                   @click="validate(newPosition)">Add</v-btn>
          </v-form>
        </v-card>

<!--        existing positions -->
        <v-data-table
            v-if="!addNew"
            :headers="headers"
            :items="filterUserPositions()"
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
            <div class="text-right mr-2">
              <v-btn text x-small @click="addNew = !addNew" v-if="userCanAdd">
                <v-icon>add</v-icon>
              </v-btn>
            </div>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left" :class="{'shaded-row': userPositions.indexOf(item) % 2}">
              <h3 class="mb-3">Edit Position</h3>
              <DatetimePickerInput
                v-model="item.startDate"
                :timezone="timezone"
                :readonly="!userCanEdit"
                :disabled="!userCanEdit"
                :type="'date'"
                :format="'MM/DD/YYYY'"
                label="Start Date"
              />
              <DatetimePickerInput
                v-model="item.endDate"
                :timezone="timezone"
                :readonly="!userCanEdit"
                :disabled="!userCanEdit"
                :type="'date'"
                :format="'MM/DD/YYYY'"
                label="End Date"
              />
              <v-autocomplete v-model="item.positionId"
                              :items="positions"
                              :readonly="!userCanEdit"
                              :disabled="!userCanEdit"
                              label="Positions"
                              @input="populateHierarchy(item, false)"
                              item-text="position"
                              item-value="id"/>
              <label>Primary:</label>
              <input type="checkbox" class="ml-3 mb-4" v-model="item.primaryFlag"
                     :readonly="item.primary || !userCanEdit" :disabled="item.primary || !userCanEdit">
              <div v-for="(f, index) in filters" :key="index">
                <v-autocomplete
                          v-if="item.keyedHierarchy[f.orgLevelId] && isSameLevelAsPosition(f, item)"
                          v-model="item.keyedHierarchy[f.orgLevelId]['orgId']"
                          :items="getOrgsMatchingPositionOrgType(f.orgs, item)"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          :rules="requiredRules"
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
              <div v-if="item.startDate >= item.endDate" class="error-text mb-2">
                End date must be null or after the start date
              </div>
              <v-btn color="primaryCustom" class="white--text mr-2"
                     :disabled="item.startDate >= item.endDate || validatePositionFields(item)"
                     v-if="userCanEdit"
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
              <td width="150">
                <v-btn class="d-inline-block" text
                       v-if="!expanded.includes(item) && userCanEdit"
                       @click="[handleExpand(item, true), item.primary = item.primaryFlag]">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn class="d-inline-block" text v-if="expanded.includes(item)" @click="handleExpand(item, false)">cancel</v-btn>
                <v-dialog
                    v-if="$store.getters.userHasFeatureAccessLevel('USERS', 'DELETE')"
                  class="d-inline-block"
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

                    <v-card-text>
                      Are you sure you want to delete this User Position: <strong>{{ item.position }}</strong>?
                    </v-card-text>

                    <v-divider></v-divider>

                    <v-card-actions>
                      <v-spacer></v-spacer>
                      <v-btn
                        @click="item.deleteConfirm = false">
                        No
                      </v-btn>
                      <v-btn
                        color="primaryCustom"
                        text
                        @click="deleteUserPosition(item)">
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

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'

  import keyBy from 'lodash.keyby'
  import {getOrgFilters} from '@/services/orgService'
  import cloneDeep from 'lodash.clonedeep'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from "@/helpers/constants";

  export default {
    name: 'UserPositions',
    components: {

      DatetimePickerInput
    },
    data() {
      return {
        snackbar: {},
        newPosition: {},
        userPositions: [],
        requiredRules: constants.BASIC_REQUIRED_RULE,
        positions: [],
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('USERS', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('USERS', 'EDIT'),
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
      validate (item) {
        if (this.$refs.newPositionForm.validate()) {
          this.savePosition(item)
        }
      },
      getOrgsMatchingPositionOrgType(orgs, newPosition) {
        // get orgs that match the org type selected in the position (admin screen)
        let selectedPosition = this.positions.find(p => p.id === newPosition.positionId)
        return orgs.filter(o => o.orgTypeId === selectedPosition.orgTypeId)
      },
      async getPositions() {
        try {
          const {data} = await getRequest(`/position`)
          this.positions = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Positions')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.addNew = false
          let itemIndex = this.userPositions.indexOf(item)

          let lowestHierarchy = item?.hierarchy?.reduce((prev, current) => {
            return (prev.level > current.level) ? prev : current
          })
          let itemId = item.id
          item.orgId = lowestHierarchy.orgId
          let params = {
            ...item,
            primaryFlag: !itemId && this.userPositions.filter(up => !up.archived).length === 0 ? true : item.primaryFlag,
            userId: this.userId
          }

          const {data} = await postRequest(`/userPosition`, params)
          item = data
          this.$set(item, 'hierarchy', data.hierarchy)
          if (item && item.hierarchy) {
            this.$set(item, 'keyedHierarchy', keyBy(item.hierarchy, 'orgLevelId'))
            if (!itemId) {
              this.userPositions.push(item)
            } else {
              this.$set(this.userPositions, itemIndex, item)
            }
          }
          if (item.primaryFlag) {
            //clear out any other primary flags in the ui - the db should have already done it
            this.userPositions.forEach(up => {
              if (up.primaryFlag && up.id !== item.id) {
                up.primaryFlag = false
              }
            })
          }
          this.newPosition = {}
          this.addNew = false
          this.expanded = []
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Position')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
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
      },
      filterUserPositions () {
        return this.userPositions.filter(wqc => { return !wqc.archived})
      },
      async deleteUserPosition(item) {
        try {
          await deleteRequest(`/userPosition/${item.id}`)
          item.archived = true
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error deleting user position')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      }
    },

  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

