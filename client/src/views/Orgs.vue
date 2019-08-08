<template>
  <v-row class="fill-height" align="center" justify="start">
    <v-col class="shrink" cols="12" v-if="$route.name === 'orgs'">
      <v-row class="fill-height" align="center">
        <v-col
          cols="6"
          class="display-1 text-left"
        >Organizations</v-col>
        <v-col class="text-right" cols="6">
          <v-row class="fill-height" justify="end" align="center">
            <v-col class="shrink">
              <v-btn
                class="app-button"
                @click="initFilters"
              > Reset Search</v-btn>
            </v-col>
            <v-col class="shrink">
              <v-menu
                offset-y
                left
              >
                <template #activator="{on}">
                  <v-btn
                    class="app-button"
                    v-on="on"
                  >Fields</v-btn>
                </template>
                <v-list>
                  <v-list-item
                    v-for="header in headers"
                    :key="header.value"
                    @click="header.show = !header.show"
                  >
                    <v-icon class="mr-3" v-if="!header.show">add</v-icon>
                    <v-icon class="mr-3" v-if="header.show">remove</v-icon>
                    <v-list-item-title>{{ header.text }}</v-list-item-title>
                  </v-list-item>
                </v-list>
              </v-menu>
            </v-col>
            <v-col class="shrink">
              <download-excel
                :fields="exportableFields"
                :fetch="calculateExportableData"
                type="csv"
                name="orgs.csv"
              >
                <v-btn
                  class="app-button"
                >Export</v-btn>
              </download-excel>
            </v-col>
            <v-col class="shrink">
              <v-btn
                dark
                color="primaryButton"
                class="app-button"
                @click="$router.push({name: 'org'})"
              >Add Org</v-btn>
            </v-col>
          </v-row>
        </v-col>
      </v-row>
      <v-divider></v-divider>
      <v-row class="mt-5" align="start" justify="center">
        <v-col cols="12">
          <v-data-table
            :items="filteredOrgs"
            :headers="visibleHeaders"
            :options="pagination"
            item-key="id"
            class="elevation-1"
            v-model="selected"
            show-select
          >
            <template #headers="{all, indeterminate, headers}">
              <tr>
                <th>
                  <v-checkbox
                    :input-value="all"
                    :indeterminate="indeterminate"
                    primary
                    hide-details
                    @click.stop="toggleSelectAllOrgs"
                  >
                  </v-checkbox>
                </th>
                <th
                  v-for="header in headers"
                  :key="header.text"
                  :class="['column sortable', pagination.descending ? 'desc' : 'asc', header.value === pagination.sortBy ? 'active' : '']"
                  @click="changeSort(header.value)"
                >
                  <span>{{ header.text }}</span>
                  <v-icon>arrow_upward</v-icon>
                </th>
              </tr>
              <tr>
                <th></th>
                <th
                  v-for="header in headers"
                  :key="header.text"
                >
                  <v-text-field
                    v-if="filters[header.value].type === FILTER_TYPE.TEXT"
                    :label="header.text"
                    v-model="filters[header.value].value"
                  />
                  <v-select
                    v-else-if="filters[header.value].type === FILTER_TYPE.SELECT"
                    :items="searchFilters[header.value]"
                    item-value="id"
                    :item-text="`${com.albatross.api.v1.company.blueraven.models}`"
                    multiple
                    return-object
                    v-model="filters[header.value].value"
                  >
                    <template #prepend-item>
                      <v-list-item ripple>
                        <v-list-item-action>
                          <v-icon
                            :color="filters[header.value].value.length > 0 ? 'primary' : ''"
                            @click="toggleSelectAllFilter(header.value)"
                          >{{ filterIcon(header.value) }}</v-icon>
                        </v-list-item-action>
                        <v-list-item-title>Select All</v-list-item-title>
                      </v-list-item>
                      <v-divider class="mt-2"></v-divider>
                    </template>
                    <template #selection="{item, index}">
                      <v-chip v-if="index === 0 && filters[header.value].value.length < 2">
                        <span>{{ item[`${com.albatross.api.v1.company.blueraven.models}`] }}</span>
                      </v-chip>
                      <span
                        v-if="index === 1 && filters[header.value].value.length >= 2"
                        class="primary--text caption"
                      >{{ filters[header.value].value.length }} selected</span>
                    </template>
                  </v-select>
                </th>
              </tr>
            </template>
            <!-- Vuetify data tables as of 1.5.7 are (undocumentedly) unable to handle destructured slot props. aka #item="{selected, item}" -->
            <template #items="props">
              <tr :active="props.selected" @click="$router.push({name: 'org', params: {orgId: props.item.id}})">
                <td @click.stop>
                  <v-checkbox
                    v-model="props.selected"
                    primary
                    hide-details
                  ></v-checkbox>
                </td>
    <!--     @TODO: The calendar name is not displaying properly. Needs to show the summary property       -->
                <td
                  v-for="header in visibleHeaders"
                  :key="header.value"
                >
                  {{ props.item[header.value] }}
                </td>
              </tr>
            </template>
          </v-data-table>
        </v-col>
      </v-row>
    </v-col>
    <router-view/>
  </v-row>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'

  const FILTER_TYPE = {
    TEXT: 'text',
    SELECT: 'select'
  }

  // @TODO: I don't necessarily like how I've tied this to the models
  const FILTER_DEFAULTS = {
    orgName: {value: [], type: FILTER_TYPE.TEXT, model: 'orgName'},
    calendarOid: {value: [], type: FILTER_TYPE.SELECT, model: 'name'},
    orgType: {value: [], type: FILTER_TYPE.SELECT, model: 'orgType'},
    parent: {value: [], type: FILTER_TYPE.SELECT, model: 'orgName'},
    salesArea: {value: [], type: FILTER_TYPE.SELECT, model: 'area'},
    salesMetroArea: {value: [], type: FILTER_TYPE.SELECT, model: 'salesMetroArea'},
    metroArea: {value: [], type: FILTER_TYPE.SELECT, model: 'metroArea'},
    active: {value: [], type: FILTER_TYPE.SELECT, model: 'active'}
  }

  export default {
    name: 'orgs',
    data () {
      return {
        FILTER_TYPE,
        orgs: [],
        searchFilters: {
          orgName: [],
          calendarOid: [],
          orgType: [],
          parent: [],
          salesArea: [],
          salesMetroArea: [],
          metroArea: [],
          active: [{active: true}, {active: false}]
        },
        headers: [
          { text: 'Organization', value: 'orgName', show: true},
          { text: 'Calendar', value: 'calendarOid', show: true},
          { text: 'Type', value: 'orgType', show: true},
          { text: 'Parent', value: 'parent', show: true},
          { text: 'Sales Area', value: 'salesArea', show: true},
          { text: 'Sales Area Metro', value: 'salesMetroArea', show: true},
          { text: 'Metro Area', value: 'metroArea', show: true},
          { text: 'Active', value: 'active', show: true}
        ],
        filters: [],
        selected: [],
        pagination: {}
      }
    },
    computed: {
      filteredOrgs () {
        return this.orgs && this.orgs.filter(org => {

          return Object.keys(this.filters).every(filterName => {
            const filter = this.filters[filterName]

            if (filter.value.length < 1) {
              return true
            }

            let selectedItems

            switch (filter.type) {
              case FILTER_TYPE.TEXT:
                return org[filterName].toLowerCase().includes(filter.value.toLowerCase())
              case FILTER_TYPE.SELECT:
                selectedItems = filter.value.map(f => f[`${com.albatross.api.v1.company.blueraven.models}`])
                return selectedItems.includes(org[filterName])
            }
          })
        })
      },
      visibleHeaders () {
        return this.headers.filter(header => header.show === true)
      },
      isAllOrgsSelected () {
        return this.selected.length === this.filteredOrgs.length
      },
      isSomeOrgsSelected () {
        return this.selected.length > 0 && !this.isAllRolesSelected
      },
      orgsIcon () {
        let icon

        if (this.isAllOrgsSelected) {
          icon = 'check_box'
        } else if (this.isSomeOrgsSelected) {
          icon = 'indeterminate_check_box'
        } else {
          icon = 'check_box_outline_blank'
        }

        return icon
      },
      exportableFields () {
        let fields = {}

        this.visibleHeaders.forEach(header => {
          fields[header.text] = header.value
        })

        return fields
      }
    },
    methods: {
      async fetchOrgs () {
        // const {data} = await axios.get(`${VUE_APP_BASE_API}/orgs`)
        // return data
        // const { data } = await this.$apollo.query({
        //   query: ORGS,
        //   fetchPolicy: 'no-cache',
        //   variables: {},
        //   debounce: 500
        // })
        // const { orgs } = data
        // return orgs
      },
      async fetchOrgTypes () {
        // const {data} = await axios.get(`${VUE_APP_BASE_API}/orgs/types`)
        // return data
        // const { data } = await this.$apollo.query({
        //   query: ORG_TYPES,
        //   fetchPolicy: 'no-cache',
        //   variables: {},
        //   debounce: 500
        // })
        // const { orgTypes } = data
        // return orgTypes
      },
      async fetchOrgParents () {
        // const {data} = await axios.get(`${VUE_APP_BASE_API}/orgs/parents`)
        // return data
        // const { data } = await this.$apollo.query({
        //   query: ORG_PARENTS,
        //   fetchPolicy: 'no-cache',
        //   variables: {},
        //   debounce: 500
        // })
        // const { orgParents } = data
        // return orgParents
      },
      async fetchCalendars () {
        // const {data} = await axios.get(`${VUE_APP_BASE_API}/calendars`)
        // return data
        // const { data } = await this.$apollo.query({
        //   query: GOOGLE_CALENDARS,
        //   fetchPolicy: 'no-cache',
        //   variables: {},
        //   debounce: 500
        // })
        // const { googleCalendars } = data
        // return googleCalendars
      },
      async fetchSalesAreas () {
        // const {data} = await axios.get(`${VUE_APP_BASE_API}/salesAreas`)
        // return data
        // const { data } = await this.$apollo.query({
        //   query: SALES_AREAS,
        //   fetchPolicy: 'no-cache',
        //   variables: {},
        //   debounce: 500
        // })
        // const { salesAreas } = data
        // return salesAreas
      },
      async fetchMetroAreas() {
        // const {data} = await axios.get(`${VUE_APP_BASE_API}/metroAreas`)
        // return data
        // const { data } = await this.$apollo.query({
        //   query: METRO_AREAS,
        //   fetchPolicy: 'no-cache',
        //   variables: {},
        //   debounce: 500
        // })
        // const { metroAreas } = data
        // return metroAreas
      },
      async fetchSalesMetroAreas () {
        // const {data} = await axios.get(`${VUE_APP_BASE_API}/salesMetroAreas`)
        // return data
        // const { data } = await this.$apollo.query({
        //   query: SALES_METRO_AREAS,
        //   fetchPolicy: 'no-cache',
        //   variables: {},
        //   debounce: 500
        // })
        // const { salesMetroAreas } = data
        // return salesMetroAreas
      },
      toggleSelectAllOrgs () {
        this.selected = (this.selected.length) ? [] : this.filteredOrgs.slice()
      },
      toggleSelectAllFilter (filterName) {
        this.$nextTick(() => {
          let changedFilter = this.filters[filterName]
          const searchFilter = this.searchFilters[filterName]

          changedFilter.value = (changedFilter.value.length > 0 && changedFilter.value.length === searchFilter.length) ? [] : searchFilter.slice()
        })
      },
      filterIcon (filterName) {
        const filter = this.filters[filterName],
              searchFilter = this.searchFilters[filterName]

        let icon
        if (filter.value.length < 1) {
          icon = this.$vuetify.icons.checkboxOff
        } else if (filter.value.length === searchFilter.length) {
          icon = this.$vuetify.icons.checkboxOn
        } else {
          icon = this.$vuetify.icons.checkboxIndeterminate
        }
        return icon
      },
      changeSort (column) {
        if (this.pagination.sortBy === column) {
          this.pagination.descending = !this.pagination.descending
        } else {
          this.pagination.sortBy = column
          this.pagination.descending = false
        }
      },
      calculateExportableData () {
        const headers = this.visibleHeaders.map(header => header.value)

        // If user has selected rows, use them. Else use all orgs in the table
        const dataSet = (this.selected.length > 0) ? 'selected' : 'filteredOrgs'

        // Build an array of orgs based on dataSet where each object within the array has only the properties which match the visible headers
        return this[dataSet].map(org => headers.reduce((acc, column) => (acc[column] = org[column], acc), {}))
      },
      initFilters () {
        this.filters = cloneDeep(FILTER_DEFAULTS)
      },
      async fetchSearchFilters () {
        this.searchFilters.orgType = await this.fetchOrgTypes()
        this.searchFilters.parent = await this.fetchOrgParents()
        this.searchFilters.calendarOid = await this.fetchCalendars()
        this.searchFilters.salesArea = await this.fetchSalesAreas()
        this.searchFilters.metroArea = await this.fetchMetroAreas()
        this.searchFilters.salesMetroArea = await this.fetchSalesMetroAreas()
      }
    },
    async created () {
      this.initFilters()
      this.fetchSearchFilters()
      this.orgs = await this.fetchOrgs()
    }
  }
</script>

<style lang="scss" scoped>

</style>