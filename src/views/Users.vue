<template>
	<v-content>
		<v-container fluid fill-height>
			<v-data-table
        :headers="headers"
        :items="users"
        class="elevation-1 table-header-with-title"
        expand
      >
        <template slot="headers" slot-scope="props">
          <tr>
            <th
              v-for="header in props.headers"
              :key="header.text"
              class="column"
            >
              <span>{{ header.text }}</span>
            </th>
          </tr>
        </template>
        <template slot="items" slot-scope="props">
          <tr>
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

export default {
  name: 'users',
  data () {
    return {
      headers: [
        { text: 'First Name', value: 'firstName', sortable: false },
        { text: 'Last Name', value: 'lastName', sortable: false },
        { text: 'Email', value: 'email', sortable: false },
        { text: 'Phone', value: 'phoneNumber', sortable: false },
        { text: 'Organization', value: 'organization', sortable: false },
        { text: 'Department', value: 'department', sortable: false },
        { text: 'Region', value: 'region', sortable: false },
        { text: 'Office', value: 'office', sortable: false },
        { text: 'Position', value: 'position', sortable: false },
        { text: 'Status', value: 'status', sortable: false }
      ],
      users: []
    }
  },
  methods: {
    async fetchUsers () {
      await axios.get(`${VUE_APP_BASE_API}/users`)
        .then(({data}) => {
          this.users = data.users
        })
    }
  },
  created () {
    this.fetchUsers()
  }
}
</script>
<style lang="scss" scoped>

</style>
