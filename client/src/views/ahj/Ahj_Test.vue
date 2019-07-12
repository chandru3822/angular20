<template>
  <v-layout column fill-height>
    <v-flex xs12 shrink>
      <v-data-table
          :headers="headers"
          :items="filteredAhjs"
          :items-per-page="-1"
          hide-default-footer
          :sort-by.sync="pagination.sortBy"
          :sort-desc.sync="pagination.descending"
          class="elevation-1"
      >
        <template #header="{ props: { headers } }">
          <thead class="v-data-table-header">
            <tr>
              <th v-for="header in headers" :key="header.text"
                    :class="['text-xs-start column sortable', pagination.descending ? 'desc' : 'asc', header.value === pagination.sortBy ? 'active' : '']">
                <v-icon class="fix-opacity" small v-if="pagination.descending.includes(true) && pagination.sortBy.includes(header.value)">arrow_upward</v-icon>
                <v-icon class="fix-opacity" small v-if="pagination.descending.includes(false) && pagination.sortBy.includes(header.value)">arrow_downward</v-icon>
                <!--<v-icon small>arrow_upward</v-icon>-->

                <v-text-field v-if="header.filterType === 'text'" v-model="search"></v-text-field>
                <v-select v-if="header.filterType === 'select'"
                          v-model="filters[header.value]"
                          :items="header.filterValues"
                          item-text="name"
                          return-object></v-select>
                {{header.name}}
              </th>
            </tr>
          </thead>
        </template>
        <template #body="{ items }">
          <tr v-for="ahj in items" :key="ahj.name" class="text-sm-left">
            <td v-if="ahj.name">{{ ahj.name }}</td>
            <td v-if="ahj.metroArea">{{ ahj.metroArea }}</td>
            <td v-if="ahj.state">{{ ahj.state }}</td>
            <td>
              <v-btn text v-if="ahj.id" :to="`ahj/${ahj.id}/permit`" class="mr-3 rmv-underline blue-txt">Permit</v-btn>
              <v-btn text v-if="ahj.id" :to="`ahj/${ahj.id}/inspection`" class="mr-3 rmv-underline blue-txt">Inspection</v-btn>
              <v-btn text v-if="ahj.id" :to="`ahj/${ahj.id}/design`" class="mr-3 rmv-underline blue-txt">Design</v-btn>
              <v-icon small class="mr-3 blue-txt" @click="editAhj(ahj)">edit</v-icon>
              <v-icon small class="blue-txt" @click="deleteAhj(ahj)">delete</v-icon>
            </td>
          </tr>
        </template>
      </v-data-table>
    </v-flex>
  </v-layout>
</template>

<script>
  const FILTER_TYPE = {
    TEXT: 'text',
    SELECT: 'select'
  }

  const ahjItems = [
    {
        id: 1,
        name: 'Conejos County',
        metroArea: 'Colorado Springs',
        metroAreaId: 4,
        state: 'Colorado',
        stateAbrv: 'CO'
    },
    {
        id: 2,
        name: 'Fremont County',
        metroArea: 'Colorado Springs',
        metroAreaId: 4,
        state: 'Colorado',
        stateAbrv: 'CO'
    },
    {
        id: 3,
        name: 'Town of Limon',
        metroArea: 'Colorado Springs',
        metroAreaId: 4,
        state: 'Colorado',
        stateAbrv: 'CO'
    },
    {
        id: 4,
        name: 'Town of Romeo',
        metroArea: 'Colorado Springs',
        metroAreaId: 4,
        state: 'Colorado',
        stateAbrv: 'CO'
    },
    {
        id: 5,
        name: 'Adams County',
        metroArea: 'Denver',
        metroAreaId: 8,
        state: 'Colorado',
        stateAbrv: 'CO'
    },
    {
        id: 6,
        name: 'Arapahoe County',
        metroArea: 'Denver',
        metroAreaId: 8,
        state: 'Colorado',
        stateAbrv: 'CO'
    },
    {
        id: 7,
        name: 'Boulder County',
        metroArea: 'Denver',
        metroAreaId: 8,
        state: 'Colorado',
        stateAbrv: 'CO'
    }
  ]

  const metroAreas = [
    { id: 8, name: 'Denver', metroArea: 'Denver'},
    { id: 4, name: 'Colorado Springs', metroArea: 'Colorado Springs'}
  ]

  const states = [
    { id: 8, name: 'Colorado', state: 'Colorado'},
    { id: 4, name: 'Oregon', state: 'Oregon'}
  ]

  export default {
    name: 'ahjs',
    data: () => ({
      tabs: null,
      search: '',
      pagination: {
        sortBy: ['name'],
        descending: [false]
      },
      ahjs: ahjItems,
      filters: {
        metroArea: [],
        state: [],
      },
      masterAhjs: ahjItems,
      selectedFilter: {},
      headers: [
        { text: 'Name', filterType: FILTER_TYPE.TEXT, value: 'name', show: true },
        { text: 'Metro Area', filterType: FILTER_TYPE.SELECT, value: 'metroArea', show: true, filterValues: metroAreas},
        { text: 'State', filterType: FILTER_TYPE.SELECT, value: 'state', show: true, filterValues: states },
        { text: null, filterType: null, value: null, sortable: false, show: true }
      ]
    }),
    computed: {
      // filteredAhjs () {
      //   return this.ahjs && this.ahjs.filter(a => { return a.name.toLowerCase().includes(this.search.toLowerCase())})
      // },
      filteredAhjs() {
        return this.ahjs.filter(a => {
          return Object.keys(this.filters).every(f => {
            // console.log('includes', f)
            // console.log('full', this.filters[f].name)
            // console.log('ahj', a[f])
            return (this.search.length < 1 || a.name.toLowerCase().includes(this.search.toLowerCase())) && (this.filters[f].length < 1 || (this.filters[f] && this.filters[f].name === a[f]))
          })
        })
      }
    },
    watch: {

    },
    methods: {
      fetchAhjs () {
        return this.ahjs
      },
    },
    created () {
      this.fetchAhjs()
    }
  }
</script>

<style lang="scss" scoped>

</style>
