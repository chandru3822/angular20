<template>
  <v-content>
    <v-flex>
      <v-text-field
        append-icon="search"
        label="Search..."
        v-model="externalFilters.searchQuery"
        @input="debounceFetchUsers"
      ></v-text-field>
    </v-flex>
    <div>
      <v-select
        v-model="selectedStatuses"
        :items="statuses"
        item-text="userStatusType"
        item-value="id"
        multiple
        return-object
        outline
        label="Status"
        @change="updateSelectStatuses"
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
    </div>
    <div>
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
    </div>
    Users: {{ this.filteredUsers.length }}
    Selected Users: {{ this.selected.length }}
    <v-container fluid fill-height>
      
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
              <div v-if="filters.hasOwnProperty(header.value)">
                  <v-text-field
                    v-if="filters[header.value].type == FilterType.TEXT"
                    :label="header.text"
                    v-model="filters[header.value].value"
                  />
                  <v-select
                    v-else-if="filters[header.value].type == FilterType.SELECT"
                    :items="selectFilterList(header.value)"
                    v-model="filters[header.value].value"
                  ></v-select>
              </div>
            </th>
          </tr>
        </template>
        <template slot="items" slot-scope="props">
          <tr :active="props.selected" @click="props.selected = !props.selected">
            <td>
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
    </v-container>
  </v-content>
</template>
<script>
import axios from 'axios'

const { VUE_APP_BASE_API } = process.env

const FilterType = {
  TEXT: 'text',
  SELECT: 'select'
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

export default {
  name: 'users',
  data () {
    return {
      FilterType,
      SlotValues,
      StatusValues,
      pagination: {},
      selected: [],
      selectedStatuses: [1],
      positions: {
        slot: 'primary',
        status: 'both'
      },
      statuses: [],
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
      filters: {
        firstName: {value: [], type: FilterType.TEXT},
        lastName: {value: [], type: FilterType.TEXT},
        email: {value: [], type: FilterType.TEXT},
        phoneNumber: {value: [], type: FilterType.TEXT},
        organization: {value: [], type: FilterType.SELECT},
        department: {value: [], type: FilterType.SELECT},
        region: {value: [], type: FilterType.SELECT},
        office: {value: [], type: FilterType.SELECT},
        positionName: {value: [], type: FilterType.SELECT},
        userStatusType: {value: [], type: FilterType.TEXT}
      },
      externalFilters: {
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
        userId: null
      }
    }
  },
  computed: {
    filteredUsers () {
      return this.users.filter(user => {
        return Object.keys(this.filters).every(f => {

          if (this.filters[f].value.length < 1) {
            return true;
          }

          switch (this.filters[f].type) {
            case FilterType.TEXT:
              return user[f].toLowerCase().includes(this.filters[f].value.toLowerCase())
            case FilterType.SELECT:
              return this.filters[f].value == user[f]
          }
        })
      })
    },
    isAllStatusesSelected () {
      return this.selectedStatuses.length === this.statuses.length
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
    }
  },
  methods: {
    async fetchUsers () {
      await axios.post(`${VUE_APP_BASE_API}/users/search`, this.externalFilters)
        .then(({data}) => {
          this.users = data.users
        })
    },
    async fetchStatuses () {
      await axios.get(`${VUE_APP_BASE_API}/users/statuses`)
        .then(({data}) => {
          this.statuses = data.statuses
        })
    },
    debounceFetchUsers () {

      // @TODO: get debounce working
      // debounce(this.fetchUsers, 2000)

      this.fetchUsers();
    },
    selectFilterList (propertyName) {
      return this.users.filter(user => user[propertyName] != null).map(user => user[propertyName])
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
    }
  },
  created () {
    this.fetchStatuses()
    this.fetchUsers()
  }
}
</script>
<style lang="scss" scoped>

</style>
