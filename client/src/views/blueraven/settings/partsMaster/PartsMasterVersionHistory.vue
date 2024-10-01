<template>
  <v-dialog
    v-model="show"
    scrollable
    max-width="80vw"
    @keydown.esc="close"
    @click:outside="close"
  >
    <v-card v-if="!loading && detail">
      <v-card-title>
        Change Log #{{ detail.version }}
        <v-chip class="ma-2" label color="grey lighten-2" v-if="detail.status">
          {{ capitalize(detail.status) }}
        </v-chip>
        <v-chip
          class="ma-2 default-text-color"
          label
          color="primary lighten-9"
          v-if="detail.primaryVersion"
        >
          Current
        </v-chip>
      </v-card-title>
      <v-card-text>
        <table class="history-summary-table">
          <colgroup>
            <col style="width: 15%" />
          </colgroup>
          <tbody>
          <tr>
            <th>Last modified by</th>
            <td>{{ detail.modifiedBy }}</td>
          </tr>
          <tr>
            <th>Last modified</th>
            <td>{{ timestamp(detail.dateModified) }}</td>
          </tr>
          <tr v-if="detail.notes">
            <th>Notes</th>
            <td>
              {{ detail.notes }}
            </td>
          </tr>
          </tbody>
        </table>

        <v-data-table
          class="table-striped"
          v-if="detail.history.length > 0"
          :headers="headers"
          :items="detail.history"
        >
          <template #item.section="{ item }">{{ item.objectType }}</template>
          <template #item.action="{ item }">
            {{ capitalize(item.action) }}
          </template>
          <template #item.modifiedBy="{ item }">
            <span :title="`${timestamp(item.modifiedDate)}`">
              {{ item.modifiedBy }}
            </span>
          </template>
          <template #item.changes="{ item }">
            <table class="history-table" :class="item.action">
              <colgroup>
                <col style="width: 35%" />
              </colgroup>
              <tbody>
              <tr
                :title="`${change.modifiedBy} on ${timestamp(
                    change.modifiedDate
                  )} in #${change.versionId}`"
                :class="{
                    current:
                      item.action === 'modified' && change.versionId == version
                  }"
                v-for="change in item.changes"
              >
                <td>{{ change.fieldName }}</td>
                <td>
                    <span
                      class="changed"
                      v-if="
                        item.action === 'modified' &&
                        change.versionId == version &&
                        change.previousValue
                      "
                    >
                      {{ customValueFormatter(change.previousValue) }}
                    </span>
                  {{ customValueFormatter(change.currentValue) }}
                </td>
              </tr>
              </tbody>
            </table>
          </template>
        </v-data-table>
        <v-alert v-else dense tile transition="scale-transition">
          No changes were recorded.
        </v-alert>
      </v-card-text>

      <v-card-actions>
        <v-spacer />
        <a-btn
          variant="text"
          color="primary"
          @click="close()"
          text="Close"
        ></a-btn>
      </v-card-actions>
    </v-card>
    <v-card v-if="!loading && error">
      <v-card-title>Error</v-card-title>
      <v-card-text>
        <p>{{ error }}</p>
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <a-btn
          variant="text"
          color="primary"
          @click="close()"
          text="Close"
        ></a-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
<script setup>
import { getRequest } from '@/helpers/helpers'
import { toRefs, ref, watch } from 'vue'
import { customValueFormatter, timestamp, capitalize } from './formatters.js'

const props = defineProps(['visible', 'version'])
const emit = defineEmits(['update:visible'])
const { visible } = toRefs(props)

const error = ref(undefined)
const loading = ref(false)
const show = ref(false)
const detail = ref(undefined)
const headers = ref([
  { text: 'Section', value: 'section', sortable: false },
  { text: 'Action', value: 'action', sortable: false },
  { text: 'Last Modified', value: 'modifiedBy', sortable: false },
  { text: 'Changes', value: 'changes', sortable: false }
])

watch(visible, (val) => {
  show.value = val
})
watch(show, (val) => {
  if (val) {
    getPartsMasterHistory(props.version)
  }
})

const getPartsMasterHistory = async (versionId) => {
  try {
    loading.value = true
    const { data } = await getRequest(
      `/partsMaster/versions/${versionId}/history`,
      'blueraven'
    )
    data.history = data?.history?.map((h) => {
      if (h.archived) {
        h.action = 'deleted'
      } else {
        const modified =
          h?.changes?.some((v) => v.previousValue !== undefined) ?? false
        h.action = modified ? 'modified' : 'added'
      }

      h.changes.sort((a, b) => {
        if (a.fieldName < b.fieldName) {
          return -1
        }
        if (a.fieldName > b.fieldName) {
          return 1
        }
        return 0
      })

      return h
    })
    detail.value = { ...data }
  } catch (e) {
    error.value = e?.response?.data ?? 'Unknown error loading version history'
    console.error(e)
  } finally {
    loading.value = false
  }
}
const close = () => {
  show.value = !show.value
  error.value = undefined
  detail.value = undefined
  emit('update:visible', show.value)
}
</script>
<style scoped lang="scss">
.history-summary-table {
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

  tr:nth-of-type(even) {
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
  opacity: 0.5;
}
</style>
