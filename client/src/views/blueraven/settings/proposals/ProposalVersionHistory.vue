<template>
  <v-dialog v-model="show" scrollable max-width="80vw" @keydown.esc="close" @click:outside="close">
    <v-card v-if="!loading && detail">
      <v-card-title>
        Change Log #{{ detail.version }}
        <v-chip class="ma-2"
                label
                color="grey lighten-2"
                v-if="detail.status">
          {{ detail.status | capitalize }}
        </v-chip>
        <v-chip class="ma-2 default-text-color"
                label
                color="primary lighten-9"
                v-if="detail.primaryVersion">
          Current
        </v-chip>

      </v-card-title>
      <v-card-text>
        <table class="history-summary-table">
          <colgroup>
            <col style="width: 15%">
          </colgroup>
          <tbody>
          <tr>
            <th>Last modified by</th>
            <td>{{ detail.modifiedBy }}</td>
          </tr>
          <tr>
            <th>Last modified</th>
            <td>{{ detail.dateModified | timestamp }}</td>
          </tr>
          <tr v-if="detail.notes">
            <th>Notes</th>
            <td>
              {{ detail.notes }}
            </td>
          </tr>
          </tbody>
        </table>

        <v-data-table class="table-striped" v-if="detail.history.length > 0" :headers="headers" :items="detail.history">
          <template #item.section="{item}">{{ item.objectType }}</template>
          <template #item.action="{item}">{{ item.action | capitalize }}</template>
          <template #item.modifiedBy="{item}">
                <span :title="`${$options.filters.timestamp(item.modifiedDate)}`">
                  {{ item.modifiedBy }}
                </span>
          </template>
          <template #item.changes="{item}">
            <table class="history-table" :class="item.action">
              <colgroup>
                <col style="width: 35%">
              </colgroup>
              <tbody>
              <tr
                :title="`${change.modifiedBy} on ${ $options.filters.timestamp(change.modifiedDate)} in #${change.versionId}`"
                :class="{ 'current' : item.action === 'modified' && change.versionId == version }"
                v-for="change in item.changes">
                <td>{{ change.fieldName }}</td>
                <td>
                  <span class="changed"
                        v-if="item.action === 'modified' && change.versionId == version && change.previousValue">
                    {{ change.previousValue | customValueFormatter }}
                  </span>
                  {{ change.currentValue | customValueFormatter }}
                </td>
              </tr>
              </tbody>
            </table>
          </template>
        </v-data-table>
        <v-alert
          v-else
          dense
          tile
          transition="scale-transition"
        >
          No changes were recorded.
        </v-alert>
      </v-card-text>

      <v-card-actions>
        <v-spacer/>
        <v-btn text color="primary" @click="close()">Close</v-btn>
      </v-card-actions>
    </v-card>
    <v-card v-if="!loading && error">
      <v-card-title>Error</v-card-title>
      <v-card-text>
        <p>{{ error }}</p>
      </v-card-text>
      <v-card-actions>
        <v-spacer/>
        <v-btn text color="primary" @click="close()">Close</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
<script>
import {getRequest} from "@/helpers/helpers";
import {ProposalSettingsMixins} from "@/views/blueraven/settings/proposals/mixins";

export default {
  name: 'ProposalVersionHistory',
  props: ['visible', 'version'],
  mixins: [ProposalSettingsMixins],
  data() {
    return {
      error: undefined,
      loading: false,
      show: false,
      detail: undefined,
      headers: [
        {text: 'Section', value: 'section', sortable: false},
        {text: 'Action', value: 'action', sortable: false},
        {text: 'Last Modified', value: 'modifiedBy', sortable: false},
        {text: 'Changes', value: 'changes', sortable: false},
      ]
    }
  },
  watch: {
    visible(val) {
      this.show = val

    },
    show(val) {
      if (val) {
        this.getProposalHistory(this.version)
      }
    }
  },
  methods: {
    async getProposalHistory(versionId) {
      try {
        this.loading = true
        const {data} = await getRequest(`/proposal/versions/${versionId}/history`, 'blueraven')
        data.history = data?.history?.map(h => {
          if (h.archived) {
            h.action = 'deleted'
          } else {
            const modified = h?.changes?.some(v => v.previousValue !== undefined) ?? false
            h.action = modified ? 'modified' : 'added'
          }

          h.changes.sort((a, b) => {
            if (a.fieldName < b.fieldName) {
              return -1;
            }
            if (a.fieldName > b.fieldName) {
              return 1;
            }
            return 0;
          })

          return h
        })
        this.detail = {...data}
      } catch (e) {
        this.error = e?.response?.data ?? 'Unknown error loading version history'
        console.error(e)
      } finally {
        this.loading = false
      }
    },
    close() {
      this.show = !this.show
      this.error = undefined
      this.detail = undefined
      this.$emit('update:visible', this.show)
    }
  }
}
</script>
<style scoped lang="scss">
.history-summary-table{
  border-spacing: 0;
  width: 100%;
  th {
    text-align: left;
    vertical-align: top;
  }
}

.history-table {
  width: 100%;
  border-spacing: 0;

  td {
    vertical-align: top;
  }

  tr:nth-of-type(even){
    background-color: unset !important;
  }

  &.modified {
    tr:not(.current) {
      color: #6c6a6a;
    }

    tr.current {
      font-weight: bold;
    }
  }
}

.changed {
  text-decoration: line-through;
  opacity: .5;
}
</style>
