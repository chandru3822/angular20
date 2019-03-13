<template>
<v-layout column align-start justify-start>
  <v-flex shrink xs12>
    <v-layout row wrap>
      <v-flex xs6 text-xs-left>Users</v-flex>
      <v-flex xs6 text-xs-right>
        <v-menu
          :close-on-content-click="false"
        >
          <v-btn
            class="app-button"
            slot="activator"
          >Adv. Search</v-btn>

          <v-card>
            <v-menu>
              <v-text-field
                slot="activator"
                label="Hire Date After"
                readonly
                v-model="dateAfterFormatted"
              ></v-text-field>

              <v-date-picker
                v-model="externalFilters.dateAfter"
                @input="fetchUsers"
              ></v-date-picker>
            </v-menu>

            <v-menu>
              <v-text-field
                slot="activator"
                label="Hire Date Before"
                readonly
                v-model="dateBeforeFormatted"
              ></v-text-field>

              <v-date-picker
                v-model="externalFilters.dateBefore"
                @input="fetchUsers"
              ></v-date-picker>
            </v-menu>

            <v-select
              v-model="externalFilters.areaIds"
              :items="salesAreas"
              item-value="id"
              item-text="area"
              multiple
              outline
              label="Area"
              @input="fetchUsers"
            >

            </v-select>

            <v-select
              v-model="externalFilters.roleIds"
              :items="roles"
              item-value="id"
              item-text="name"
              multiple
              outline
              label="Role"
              @input="fetchUsers"
            >

            </v-select>

            <v-list>
              <v-list-tile>
                <v-list-tile-action>
                  <v-checkbox v-model="externalFilters.missingData"></v-checkbox>
                </v-list-tile-action>

                <v-list-tile-content>
                  <v-list-tile-title>Missing Data</v-list-tile-title>
                </v-list-tile-content>
              </v-list-tile>

              <v-list-tile>
                <v-list-tile-action>
                  <v-checkbox
                    v-model="externalFilters.missingPrimary"
                    @change="updateMissingExternalFilters(MissingFilterType.PRIMARY)"
                  ></v-checkbox>
                </v-list-tile-action>

                <v-list-tile-content>
                  <v-list-tile-title>Missing Primary</v-list-tile-title>
                </v-list-tile-content>
              </v-list-tile>

              <v-list-tile>
                <v-list-tile-action>
                  <v-checkbox
                    v-model="externalFilters.missingPosition"
                    @change="updateMissingExternalFilters(MissingFilterType.POSITION)"
                  ></v-checkbox>
                </v-list-tile-action>

                <v-list-tile-content>
                  <v-list-tile-title>Missing Position</v-list-tile-title>
                </v-list-tile-content>
              </v-list-tile>
            </v-list>
          </v-card>
        </v-menu>

        <v-btn
          class="app-button"
          @click="hideExternalFilters = !hideExternalFilters"
        >Hide Filters</v-btn>
      </v-flex>
    </v-layout>
    <v-divider></v-divider>
    <v-layout row wrap v-if="!hideExternalFilters">
      <v-flex xs4>
        <v-flex d-flex xs12>
          <v-text-field
            append-icon="search"
            label="Search..."
            v-model="externalFilters.searchQuery"
            @input="debounceFetchUsers"
          ></v-text-field>
        </v-flex>
        <v-flex d-flex xs12>
          <v-select
            v-model="selectedStatuses"
            :items="statuses"
            item-text="userStatusType"
            item-value="id"
            multiple
            return-object
            outline
            label="Status"
            @input="updateSelectStatuses"
          >
            <v-list-tile
              slot="prepend-item"
              ripple
              @click="toggleSelectAllStatuses"
            >
              <v-list-tile-action>
                <v-icon :color="selectedStatuses.length > 0 ? 'primary' : ''">{{ icon }}</v-icon>
              </v-list-tile-action>
              <v-list-tile-title>Select All</v-list-tile-title>
            </v-list-tile>
            <v-divider
              slot="prepend-item"
              class="mt-2"
            ></v-divider>
          </v-select>
        </v-flex>
      </v-flex>
      <v-flex xs4 offset-xs1>
        <v-layout wrap>
          <v-flex xs12>Positions</v-flex>
          <v-flex xs12 sm6>
            <v-radio-group
              v-model="positions.slot"
              @change="updatePositionFilters"
            >
              <v-radio
                :value="SlotValues.PRIMARY"
                :label="`Primary Only`"
              ></v-radio>
              <v-radio
                :value="SlotValues.SECONDARY"
                :label="`Secondary Only`"
              ></v-radio>
              <v-radio
                :value="SlotValues.BOTH"
                :label="`Both`"
              ></v-radio>
            </v-radio-group>
          </v-flex>
          <v-flex xs12 sm6>
            <v-radio-group
              v-model="positions.status"
              @change="updatePositionFilters"
            >
              <v-radio
                :value="StatusValues.ACTIVE"
                :label="`Active Only`"
              ></v-radio>
              <v-radio
                :value="StatusValues.INACTIVE"
                :label="`Inactive Only`"
              ></v-radio>
              <v-radio
                :value="StatusValues.BOTH"
                :label="`Both`"
              ></v-radio>
            </v-radio-group>
          </v-flex>
        </v-layout>
      </v-flex>
      <v-flex xs3 class="text-xs-right">
        <v-btn
          class="app-button"
          @click="resetFilters"
        >Reset Search</v-btn>
      </v-flex>
    </v-layout>
    <v-layout column align-start justify-start mt-5>
      <v-flex xs12>
        Users: {{ this.users.length }} Selected Users: {{ this.selected.length }}
      </v-flex>
      <v-flex xs12 mt-2>
        <v-data-table
          :headers="headers"
          :items="filteredUsers"
          :pagination.sync="pagination"
          item-key="id"
          class="elevation-1"
          v-model="selected"
          select-all
        >
          <template slot="headers" slot-scope="props">
            <tr>
              <th>
                <v-checkbox
                  :input-value="props.all"
                  :indeterminate="props.indeterminate"
                  primary
                  hide-details
                  @click.stop="toggleSelectAllUsers"
                ></v-checkbox>
              </th>
              <th
                v-for="header in props.headers"
                :key="header.text"
                :class="['column sortable', pagination.descending ? 'desc' : 'asc', header.value === pagination.sortBy ? 'active' : '']"
                @click="changeSort(header.value)"
              >
                <span>{{ header.text }}</span>
                <v-icon small>arrow_upward</v-icon>
              </th>
            </tr>
            <tr>
              <th></th>
              <th
                v-for="header in props.headers"
                :key="header.text"
              >

                <div v-if="inlineFilters.hasOwnProperty(header.value)">
                  <v-text-field
                    v-if="inlineFilters[header.value].type === FilterType.TEXT"
                    :label="header.text"
                    v-model="inlineFilters[header.value].value"
                  />
                  <v-select
                    v-else-if="inlineFilters[header.value].type === FilterType.SELECT"
                    :items="searchFilters[inlineFilters[header.value].searchFilter]"
                    item-value="id"
                    item-text="name"
                    multiple
                    return-object
                    v-model="inlineFilters[header.value].value"
                    @change="updateSearchFilters(inlineFilters[header.value].searchFilter)"
                  >
                    <v-list-tile
                      slot="prepend-item"
                      ripple
                      @click="toggleSelectAllFilter()"
                    >
                      <v-list-tile-action>
                        <v-icon :color="inlineFilters[header.value].value.length > 0 ? 'primary' : ''">{{ icon }}</v-icon>
                      </v-list-tile-action>
                      <v-list-tile-title>Select All</v-list-tile-title>
                    </v-list-tile>
                  </v-select>
                </div>
              </th>
            </tr>
          </template>
          <template slot="items" slot-scope="props">
            <tr :active="props.selected" @click="editUser(props.item.id)">
              <td @click.stop>
                <v-checkbox
                  :input-value="props.selected"
                  primary
                  hide-details
                ></v-checkbox>
              </td>
              <td>{{ props.item.firstName }}</td>
              <td>{{ props.item.lastName }}</td>
              <td>{{ props.item.email }}</td>
              <td>{{ props.item.phoneNumber }}</td>
              <td>{{ props.item.organization }}</td>
              <td>{{ props.item.department }}</td>
              <td>{{ props.item.region }}</td>
              <td>{{ props.item.office }}</td>
              <td>{{ props.item.positionName }}</td>
              <td>{{ props.item.userStatusType }}</td>
            </tr>
          </template>
        </v-data-table>
      </v-flex>
    </v-layout>
  </v-flex>
</v-layout>
</template>
<script>
import axios from 'axios'
import cloneDeep from 'lodash.clonedeep'
// import debounce from 'lodash.debounce'
import moment from 'moment'

const { VUE_APP_BASE_API } = process.env

const FilterType = {
  TEXT: 'text',
  SELECT: 'select'
}

const MissingFilterType = {
  PRIMARY: 'primary',
  POSITION: 'position'
}

const SlotValues = {
  PRIMARY: 'primary',
  SECONDARY: 'secondary',
  BOTH: 'both'
}

const StatusValues = {
  ACTIVE: 'active',
  INACTIVE: 'inactive',
  BOTH: 'both'
}

const InitExternalFilters = {
  searchQuery: '',
  statusIds: [1],
  areaIds: [],
  dateBefore: null,
  dateAfter: null,
  roleIds: [],
  primaryOnly: true,
  secondaryOnly: false,
  activeOnly: false,
  inactiveOnly: false,
  missingPrimary: false,
  missingPosition: false,
  missingData: false,
  userId: null
}

const InitInlineFilters = {
  firstName: {value: [], type: FilterType.TEXT},
  lastName: {value: [], type: FilterType.TEXT},
  email: {value: [], type: FilterType.TEXT},
  phoneNumber: {value: [], type: FilterType.TEXT},
  userStatusType: {value: [], type: FilterType.TEXT},
  organization: {value: [], type: FilterType.SELECT, searchFilter: 'organizations'},
  department: {value: [], type: FilterType.SELECT, searchFilter: 'departments'},
  region: {value: [], type: FilterType.SELECT, searchFilter: 'regions'},
  office: {value: [], type: FilterType.SELECT, searchFilter: 'offices'},
  positionName: {value: [], type: FilterType.SELECT, searchFilter: 'positions'}
}

// const InitSearchFilters = {
//   startingPoint: null,
// 	positions: [],
// 	organizations: [],
// 	departments: [],
// 	regions: [],
// 	offices: []
// }

const InitPositions = {
  slot: 'primary',
  status: 'both'
}

export default {
  name: 'users',
  data () {
    return {
      FilterType,
      MissingFilterType,
      SlotValues,
      StatusValues,
      hideExternalFilters: false,
      pagination: {},
      // I would like to rename this to something like `selectedUsers`. It's not documented, but testing shows Vuetify needs this to be called `selected`
      selected: [],
      selectedStatuses: [],
      positions: {},
      statuses: [],
      salesAreas: [],
      roles: [],
      users: [],
      headers: [
        { text: 'First Name', value: 'firstName'},
        { text: 'Last Name', value: 'lastName'},
        { text: 'Email', value: 'email'},
        { text: 'Phone', value: 'phoneNumber'},
        { text: 'Organization', value: 'organization'},
        { text: 'Department', value: 'department'},
        { text: 'Region', value: 'region'},
        { text: 'Office', value: 'office'},
        { text: 'Position', value: 'positionName'},
        { text: 'Status', value: 'userStatusType'}
      ],
      inlineFilters: {},
      searchFilters: {},
      searchFiltersDefault: {},
      externalFilters: {}
    }
  },
  computed: {
    filteredUsers () {
      return this.users && this.users.filter(user => {

        if (this.externalFilters.missingData && user.valid === true) {
          return false
        }

        return Object.keys(this.inlineFilters).every(f => {

          if (this.inlineFilters[f].value.length < 1) {
            return true
          }

          let selectedNames;

          switch (this.inlineFilters[f].type) {
            case FilterType.TEXT:
              return user[f].toLowerCase().includes(this.inlineFilters[f].value.toLowerCase())
            case FilterType.SELECT:
              selectedNames = this.inlineFilters[f].value.map(filter => filter.name)
              return selectedNames.includes(user[f])
          }
        })
      })
    },
    isAllStatusesSelected () {
      return this.statuses && this.selectedStatuses.length === this.statuses.length
    },
    isSomeStatusesSelected () {
      return this.selectedStatuses.length > 0 && !this.isAllStatusesSelected
    },
    icon () {
      let icon

      if (this.isAllStatusesSelected) {
        icon = 'check_box'
      } else if (this.isSomeStatusesSelected) {
        icon = 'indeterminate_check_box'
      } else {
        icon = 'check_box_outline_blank'
      }

      return icon
    },
    dateAfterFormatted () {
      const date = moment(this.externalFilters.dateAfter)
      return date.isValid() ? date.format('M/DD/YYYY') : ''
    },
    dateBeforeFormatted () {
      const date = moment(this.externalFilters.dateBefore)
      return date.isValid() ? date.format('M/DD/YYYY') : ''
    }
  },
  methods: {
    async fetchUsers () {

      const dateAfter = moment(this.externalFilters.dateAfter)
      const dateBefore = moment(this.externalFilters.dateBefore)

      const {data} = await axios.post(`${VUE_APP_BASE_API}/users/search`, {...this.externalFilters, ...{
        dateAfter: (dateAfter.isValid()) ? dateAfter.toISOString() : null,
        dateBefore: (dateBefore.isValid()) ? dateBefore.toISOString() : null
      }})
      this.users = data
    },
    async fetchStatuses () {
      return await axios.get(`${VUE_APP_BASE_API}/users/statuses`)
        .then(({data}) => {
          this.statuses = data
        })
    },
    async fetchSearchFilters (startingPoint = null) {
      let selectedFilterOptions = {
        startingPoint: startingPoint,
        positionIds: this.inlineFilters.positionName.value.map(f => f.id),
        organizationIds: this.inlineFilters.organization.value.map(f => f.id),
        departmentIds: this.inlineFilters.department.value.map(f => f.id),
        regionIds: this.inlineFilters.region.value.map(f => f.id),
        officeIds: this.inlineFilters.office.value.map(f => f.id),
        userStatusTypeIds: this.externalFilters.statusIds,
        primaryOnly: this.externalFilters.primaryOnly,
        secondaryOnly: this.externalFilters.secondaryOnly,
        activeOnly: this.externalFilters.activeOnly,
        inactiveOnly: this.externalFilters.inactiveOnly
      }

      return await axios.post(`${VUE_APP_BASE_API}/users/searchFilters`, selectedFilterOptions)
        .then(({data}) => {
          this.searchFilters = data
          return data
        })
    },
    async fetchSalesAreas () {
      const {data} = await axios.get(`${VUE_APP_BASE_API}/salesAreas`)
      this.salesAreas = data
    },
    async fetchRoles () {
      const {data} = await axios.get(`${VUE_APP_BASE_API}/roles`)
      this.roles = data
    },
    debounceFetchUsers () {
      // @TODO: get debounce working
      // debounce(this.fetchUsers, 500)
      this.fetchUsers()
    },
    updatePositionFilters () {

      switch (this.positions.slot) {
        case SlotValues.PRIMARY:
          this.externalFilters.primaryOnly = true
          this.externalFilters.secondaryOnly = false
          break
        case SlotValues.SECONDARY:
          this.externalFilters.primaryOnly = false
          this.externalFilters.secondaryOnly = true
          break
        case SlotValues.BOTH:
          this.externalFilters.primaryOnly = false
          this.externalFilters.secondaryOnly = false
      }

      switch (this.positions.status) {
        case StatusValues.ACTIVE:
          this.externalFilters.activeOnly = true
          this.externalFilters.inactiveOnly = false
          break
        case StatusValues.INACTIVE:
          this.externalFilters.activeOnly = false
          this.externalFilters.inactiveOnly = true
          break
        case StatusValues.BOTH:
          this.externalFilters.activeOnly = false
          this.externalFilters.inactiveOnly = false
      }

      this.fetchUsers();
    },
    updateSelectStatuses () {
      this.externalFilters.statusIds = this.selectedStatuses.map(s => s.id)
      this.fetchUsers()
    },
    updateSearchFilters (startingPoint) {
      this.fetchSearchFilters(startingPoint)
    },
    updateMissingExternalFilters (updatedFilter) {
      if (updatedFilter === MissingFilterType.PRIMARY && this.externalFilters.missingPrimary === true) {
        this.externalFilters.missingPosition = false
      }

      if (updatedFilter === MissingFilterType.POSITION && this.externalFilters.missingPosition === true) {
        this.externalFilters.missingPrimary = false
      }
      this.fetchUsers()
    },
    changeSort (column) {
      if (this.pagination.sortBy === column) {
        this.pagination.descending = !this.pagination.descending
      } else {
        this.pagination.sortBy = column
        this.pagination.descending = false
      }
    },
    toggleSelectAllUsers () {
      this.selected = (this.selected.length) ? [] : this.filteredUsers.slice()
    },
    toggleSelectAllStatuses () {
      this.$nextTick(() => {
        this.selectedStatuses = (this.isAllStatusesSelected) ? [] : this.statuses.slice()
        this.externalFilters.statusIds = this.selectedStatuses.map(s => s.id)
        this.fetchUsers()
      })
    },
    initFilters () {
      this.selected = []
      this.inlineFilters = cloneDeep(InitInlineFilters)
      this.externalFilters = cloneDeep(InitExternalFilters)
      this.searchFilters = cloneDeep(this.searchFiltersDefault)
      this.positions = cloneDeep(InitPositions)
    },
    resetFilters () {
      this.initFilters()
      this.selectedStatuses = this.statuses.filter(s => s.id === 1)
      this.fetchUsers()
    },
    editUser (id) {
      this.$router.push({name: 'user', params: {id}})
    }
  },
  created () {
    this.initFilters()
    this.fetchSalesAreas()
    this.fetchRoles()
    this.fetchSearchFilters()
      .then((filterDefaults) => {
        this.searchFiltersDefault = filterDefaults
      })
    this.fetchStatuses()
      .then(() => {
        this.selectedStatuses = this.statuses.filter(s => s.id === 1)
        this.fetchUsers()
      })
  }
}
</script>
<style lang="scss" scoped>

</style>
