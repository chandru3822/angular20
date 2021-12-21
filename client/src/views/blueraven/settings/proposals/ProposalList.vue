<template>
  <v-container>
    <v-toolbar flat class="app-toolbar">
      <v-toolbar-title class="app-title">Proposal Versions</v-toolbar-title>
      <v-spacer/>
      <v-toolbar-items v-if="canCreateVersion">
        <v-btn text color="primaryButton" @click="create">Create New Version</v-btn>
      </v-toolbar-items>

    </v-toolbar>
    <v-divider/>
    <v-container>
      <div v-if="!loading && !versions.length">
        No proposals available.
      </div>
      <v-card v-if="versions.length" class="square-card">
        <v-data-table :headers="headers"
                      :items="versions"
                      :sort-by="['id']"
                      :sort-desc="true"
                      class="elevation-1"
                      @click:row="handleClick">
          <template #item.version="{item}">Version {{ item.version }}</template>
          <template #item.status="{ item }">
            <v-chip class="ma-2"
                    label
                    v-if="item.status">
              {{ item.status | capitalize }}
            </v-chip>
            <v-chip class="ma-2"
                    label
                    color="blue"
                    v-if="item.primaryVersion">
              Current
            </v-chip>

          </template>
          <template #item.dateModified="{ item }">
            <span> {{ item.dateModified | dateFormatter }}</span>
          </template>
        </v-data-table>
      </v-card>
    </v-container>
  </v-container>

</template>
<script>
// TODO: show status / primary version needs to be part of that
import {getRequestWithParams, postRequest} from "@/helpers/helpers"

export default {
  name: 'ProposalSettings',
  data() {
    return {
      loading: true,
      headers: [
        {text: '', value: 'status', sortable: false},
        {text: 'version', value: 'version', sortable: false},
        {text: 'modified', value: 'dateModified', sortable: false},
        {text: 'modified by', value: 'modifiedBy', sortable: false}
      ],
      versions: []
    }
  },
  created() {
    this.getProposalFields()
  },
  filters: {
    capitalize: (value) => {
      if (!value) return
      return value[0].toUpperCase() + value?.slice(1).toLowerCase()
    },
    dateFormatter: (value) => {
      if (!value) {
        return 'NA'
      }
      return new Intl.DateTimeFormat('default', {
        dateStyle: 'short',
        timeStyle: 'short'
      }).format(new Date(value))
    }
  },
  computed: {
    canCreateVersion() {
      return !this.loading && !this.versions.some(v => v.status === 'DRAFT')
    }
  },
  methods: {
    async create() {
      const {data} = await postRequest('/proposal/versions', {}, 'blueraven')
      this.versions.push({...data})
      await this.$router.push({name: 'proposalDetail', params: {id: data.id}})
    },
    handleClick(item) {
      this.$router.push({name: 'proposalDetail', params: {id: item.id}})
    },
    async getProposalFields() {
      this.loading = true
      const {data} = await getRequestWithParams('/proposal/versions', {}, 'blueraven')
      this.versions = [...data.content]
      this.loading = false
    }
  }
}
</script>
<style scoped lang="scss">
@import "@/styles/main.scss";

::v-deep {
  .v-data-table__wrapper {
    height: calc(100vh - 290px);
    min-height: 300px;
  }
}

tr:nth-of-type(even) {
  @extend .shaded-row;
}
</style>
