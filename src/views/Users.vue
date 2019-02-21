<template>
	<v-content>
		Users: {{ this.filteredUsers.length }}
		Selected Users: {{ this.selected.length }}
		<v-container fluid fill-height>
			
			<v-data-table
        :headers="headers"
        :items="filteredUsers"
				:pagination.sync="pagination"
				item-key="userId"
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
								@click.stop="toggleAll"
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

export default {
  name: 'users',
  data () {
    return {
			FilterType,
			pagination: {},
			selected: [],
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
			users: [],
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
		}
	},
  methods: {
    async fetchUsers () {
      await axios.get(`${VUE_APP_BASE_API}/users`)
        .then(({data}) => {
          this.users = data.users
        })
		},
		selectFilterList (propertyName) {
			return this.users.filter(user => user[propertyName] != null).map(user => user[propertyName])
		},
		changeSort (column) {
      if (this.pagination.sortBy === column) {
        this.pagination.descending = !this.pagination.descending
      } else {
        this.pagination.sortBy = column
        this.pagination.descending = false
      }
		},
		toggleAll () {
			this.selected = (this.selected.length) ? [] : this.users.slice()
		}
	},
  created () {
    this.fetchUsers()
  }
}
</script>
<style lang="scss" scoped>

</style>
