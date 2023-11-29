<template>
  <v-container>
    <v-toolbar flat class="app-toolbar">
      <v-toolbar-title class="title-large">Proposal Versions</v-toolbar-title>
      <v-spacer />
      <v-toolbar-items>
        <v-btn class="toolbar-btn-text" text color="primary" :to="{'name' : 'proposalDesigner'}">
          <span>Designer</span>
        </v-btn>
        <v-btn class="toolbar-btn-icon" icon large color="primary" :to="{'name' : 'proposalDesigner'}">
          <v-icon>edit</v-icon>
        </v-btn>
      </v-toolbar-items>
      <v-toolbar-items v-if="canCreateVersion">
        <v-btn class="toolbar-btn-text" text color="primary" @click="create">Create New Version</v-btn>
        <v-btn class="toolbar-btn-icon" icon large color="primary" @click="create"><v-icon>mdi-plus</v-icon></v-btn>
      </v-toolbar-items>
    </v-toolbar>
    <v-divider />
    <v-container>
      <div v-if="!loading && !versions.length">
        No proposals available.
      </div>
      <v-card v-if="versions.length" class="square-card">
        <v-data-table id="proposal-version-table"
            :headers="headers"
                      :items="versions"
                      :options.sync="options"
                      :server-items-length="totalVersions"
                      :footer-props="footerProps"
                      class="elevation-1"
                      @click:row="handleClick">
          <template #item.version="{item}">Version {{ item.version }}</template>
          <template #item.status="{ item }">
            <v-chip class="ma-2"
                    label
                    color="grey lighten-2"
                    v-if="item.status">
              {{ item.status | capitalize }}
            </v-chip>
            <v-chip class="ma-2 default-text-color"
                    label
                    color="primary lighten-9"
                    v-if="item.primaryVersion">
              Current
            </v-chip>

          </template>
          <template #item.dateModified="{ item }">
            <span> {{ item.dateModified | timestamp }}</span>
          </template>
          <template #item.actions="{item}">
            <v-btn
                class="ma-2"
                text
                icon
                color="blue lighten-2"
                @click.stop="showHistory(item.version)"
            >
              <v-icon>mdi-history</v-icon>
            </v-btn>
          </template>
        </v-data-table>

        <proposal-version-history :visible.sync="history.show" :version="history.version"/>

      </v-card>
    </v-container>
  </v-container>

</template>
<script>
import { getRequestWithParams, postRequest } from '@/helpers/helpers'
import store from '@/store'
import ProposalVersionHistory from "@/views/blueraven/settings/proposals/ProposalVersionHistory.vue";
import {ProposalSettingsMixins} from "@/views/blueraven/settings/proposals/mixins";

export default {
  name: 'ProposalSettings',
  components: {ProposalVersionHistory},
  mixins: [ProposalSettingsMixins],
  data() {
    return {
      loading: true,
      history: {
        show: false,
        version: undefined
      },
      options: {
        sortBy: ['version'],
        sortDesc: [true]
      },
      headers: [
        { text: '', value: 'status', sortable: false },
        { text: 'Version', value: 'version', sortable: false },
        { text: 'Modified on', value: 'dateModified', sortable: false },
        { text: 'Modified by', value: 'modifiedBy', sortable: false },
        { text: 'Description', value: 'notes', sortable: false },
        { text: '', value: 'actions', sortable: false }
      ],
      footerProps: {
        'items-per-page-options': [5, 10, 20, 50, 100],
      },
      totalVersions: -1,
      versions: []
    }
  },
  created() {
    this.getProposalFields()
  },
  computed: {
    canCreateVersion() {
      if (!store.getters.userHasFeatureAccessLevel('PROPOSALS', 'ADMIN')) {
        return false
      }
      return !this.loading && !this.versions.some(v => v.status === 'DRAFT')
    }
  },
  watch: {
    options: {
      handler() {
        this.getProposalFields()
      },
      deep: true
    }
  },
  methods: {
    async create() {
      const { data } = await postRequest('/proposal/versions', {}, 'blueraven')
      this.versions.push({ ...data })
      await this.$router.push({ name: 'proposalDetail', params: { id: data.id } })
    },
    handleClick(item) {
      this.$router.push({ name: 'proposalDetail', params: { id: item.id } })
    },
    async getProposalFields() {
      const { itemsPerPage, page } = this.options
      this.loading = true
      const { data } = await getRequestWithParams(`/proposal/versions?size=${itemsPerPage}&page=${page - 1}`, {}, 'blueraven')
      this.totalVersions = data.totalElements ?? -1
      this.versions = [...data.content]
      this.loading = false
    },
    showHistory(versionId){
      this.history.version = versionId
      this.history.show = true
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
    overflow: auto;
  }
}

tr:nth-of-type(even) {
  @extend .shaded-row;
}

.toolbar-btn-text {
  @media (max-width: 960px) {
    display: none;
  }
}.toolbar-btn-icon {
  @media (min-width: 961px) {
    display: none;
  }
}
</style>
<style lang="scss">
@media (max-width: 770px) {
  #proposal-version-table {
    padding-bottom: 12px;
    div.v-data-footer {
      display: inline-block;
      width: 100%;
      padding-bottom: 12px;

      div.v-data-footer__select {
        justify-content: center;
      }

      div.v-data-footer__icons-before {
        display: inline;
        margin-left: calc(50% - 36px);
      }

      div.v-data-footer__icons-after {
        display: inline;
      }
    }
  }
}
</style>
