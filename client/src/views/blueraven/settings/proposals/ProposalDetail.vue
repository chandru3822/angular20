<template>
  <div>
    <a-btn
        variant="text"
        color="primary"
        class="pl-1 pr-2"
        @click="router.back()"
        prepend-icon="arrow_left"
        text="Back"
    ></a-btn>
    <v-toolbar flat class="app-toolbar">
      <v-toolbar-title v-if="detail">
        <span class="app-title">Version {{ detail.version }}</span>
        <v-chip class="ma-2" color="grey lighten-2" label>{{ detail.status | capitalize }}</v-chip>
        <v-chip class="ma-2 default-text-color" color="primary lighten-9" label v-if="detail.primaryVersion">
          Current
        </v-chip>

        <a-btn
            class="ma-2"
            variant="text"
            icon
            color="primary"
            @click="showHistory = true"
            prepend-icon="mdi-history"
        ></a-btn>
        <proposal-version-history :visible.sync="showHistory" :version="detail.version"/>
      </v-toolbar-title>
      <v-spacer/>
      <v-toolbar-items v-if="isDraft">
        <a-btn
            variant="text"
            color="primary"
            @click="confirmation=true"
            text="Publish"
        ></a-btn>
        <ConfirmationDialog
          :open-dialog="confirmation"
          :disable-confirm="!publishNote"
          @confirm="publish(detail.id, publishNote)"
          @close-dialog="confirmation=false">
          <template v-slot:title>Confirm</template>
          <div>Please provide a description of changes made:</div>
          <v-form>
            <v-textarea
              v-model="publishNote"
              class="mt-3"
              solo
              autofocus
              clearable
              no-resize
              placeholder="Description"
            />
          </v-form>
          <template v-slot:yes>Publish</template>
        </ConfirmationDialog>
      </v-toolbar-items>
    </v-toolbar>
    <div v-if="detail">
      <div class="top-actions">
        <v-autocomplete
          outlined
          dense
          autofocus
          clearable
          single-line
          return-object
          hide-details
          full-width
          class="pr-2"
          v-model="propType"
          :items="types"
          item-text="name"
          item-value="id"
          @change="changer"
          placeholder="Please select a type"
          autocomplete="off"
        />
        <fragment v-if="isDraft">
          <a-btn
              v-if="hasChanges"
              variant="text"
              color="primary"
              @click="undoDraftChanges=true"
              text="Undo All Changes"
          ></a-btn>
          <ConfirmationDialog :open-dialog="undoDraftChanges"
                              @confirm="undoAllChanges"
                              @close-dialog="undoDraftChanges=false">
            <template v-slot:title>Confirm</template>
            <p>Are you sure you want to undo all changes to this draft?
              <span class="error--text">WARNING:</span>This action is <b>irreversible</b>!
            </p>
            <template v-slot:yes>Undo all</template>
          </ConfirmationDialog>
          <a-btn
              color="primary"
              @click.prevent="visible = true"
              text="Add New"
          ></a-btn>
          <NewProposalValueDialog
            v-if="propType"
            :visible="visible"
            :editing="editedItem"
            :object-code="propType.code"
            @input="doInput"
            @save="doSaveValues"/>
        </fragment>
      </div>
      <ConfirmationDialog :open-dialog="!!selectedDeleteItem"
                          @confirm="archiveItem(selectedDeleteItem)"
                          @close-dialog="selectedDeleteItem=undefined">
        Are you sure you want to delete this record?
        <p>
          <span class="error--text">WARNING:</span>
          It <b>will not</b> be available in future versions.
        </p>
      </ConfirmationDialog>
      <div>
        <v-data-table
          v-if="propType"
          :headers="headers"
          :items="rows"
          :options.sync="options"
          :search="search"
          :custom-filter="filterItems"
          :footer-props="footerProps"
          :items-per-page="50"
          @update:sort-by="sortValues"
          @update:sort-desc="sortValues"
          class="elevation-1"
        >
          <template #top>
            <v-container fluid>
              <v-row no-gutters>
                <v-col cols="8">
                  <a-text-field
                    v-model="search"
                    prepend-inner-icon="search"
                    label="Search"
                    class="mx-2 my-2"
                    single-line
                    clearable
                    hide-details
                  />
                </v-col>
                <v-col cols="4" v-if="isDraft">
                  <v-switch
                    v-model="modifiedOnlyFilter"
                    hide-details
                    inset
                    :label="`${!modifiedOnlyFilter ? 'Show Modified Only' : 'Show All'}`"
                  ></v-switch>
                </v-col>
              </v-row>
            </v-container>
          </template>

          <template #item="{item, headers}">
            <tr :class="getRowClass(item)" :title="item.archived ? 'This row has been archived' : ''"
                @click.prevent="editItem(item)" :aria-disabled="item.archived">
              <td v-for="header in headers">
                    <span class="row-actions" v-if="header.value === 'actions'">
                      <a-btn
                          size="small"
                          variant="text"
                          color="primary"
                          @click.native.stop="deleteItem(item)"
                          v-if="item.versionId === detail.id"
                          prepend-icon="mdi-undo"
                      ></a-btn>
                      <a-btn
                          size="small"
                          variant="text"
                          color="primary"
                          v-if="!item.archived"
                          @click.native.stop="selectedDeleteItem = item"
                          prepend-icon="mdi-delete"
                      ></a-btn>
                      <a-btn
                          size="small"
                          variant="text"
                          color="primary"
                          disabled
                          v-else
                      ></a-btn>
                    </span>

                <span v-if="item[header.value]">
                  {{ item[header.value] | customValueFormatter }}
                </span>
              </td>
            </tr>
          </template>
        </v-data-table>
        <p v-else>
          No type selected
        </p>
      </div>
    </div>
    <div v-else>
      <p>This isn't the proposal version you are looking for...</p>
    </div>
  </div>
</template>
<script setup>
import {Fragment} from 'vue-frag'
import {deleteRequestWithPayload, getRequestWithParams, getSnackbar, postRequest} from '@/helpers/helpers'
import NewProposalValueDialog from './NewProposalValueDialog.vue'
import {AppMutations} from '@/stores/AppStore'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import ProposalVersionHistory from "@/views/blueraven/settings/proposals/ProposalVersionHistory.vue";
import {ProposalSettingsMixins} from "@/views/blueraven/settings/proposals/mixins";

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const defaultActionColumn = {txt: 'Actions', value: 'actions', sortable: false}

const sorterFn = (fieldCode, sortDesc = false) => {
  return (a, b) => {
    if (a[fieldCode]?.value < b[fieldCode]?.value) {
      return sortDesc ? -1 : 1
    }

    if (a[fieldCode]?.value > b[fieldCode]?.value) {
      return sortDesc ? 1 : -1
    }
    return 0
  }
}

let headerSort = (a, b) => {
  if (a?.value < b?.value) {
    return -1
  }

  if (a?.value > b?.value) {
    return 1
  }

  return 0
}
// @kaleb mixin
// mixins: [ProposalSettingsMixins],
const props = defineProps(['id'])

onMounted(() => {
  Promise.allSettled([
    getProposalDetail(props.id),
    getProposalObjectTypes()
  ])
})

const search = ref('')
const options = ref({})
const detail = ref({})
const propType = ref(undefined)
const headers = ref([])
const values = ref([])
const types = ref([])
const confirmation = ref(false)
const visible = ref(false)
const editedItem = ref(undefined)
const modifiedOnlyFilter = ref(false)
const undoDraftChanges = ref(false)
const footerProps = ref({
  'items-per-page-options': [10, 20, 50, -1],})
const selectedDeleteItem = ref(undefined)
const publishNote = ref(undefined)
const showHistory = ref(false)

    const rows = computed(() => {
      //intentional '=='
      return !modifiedOnlyFilter.value ? values.value : values.value?.filter(v => v.versionId === props.id)
    })
    const hasChanges = computed(() => {
      //intentional '=='
      return values.value?.filter(v => v.versionId === props.id).length > 0
    })
    const isDraft = computed(() => {
      return detail.value && detail.value.status === 'DRAFT'
    })

    const changer = async() => {
      const requests = []
      const {code} = propType.value ?? {}

      if (code) {
        requests.push(getProposalObjectTypeFields(code))
        requests.push(getProposalObjectTypeFieldValues(props.id, code))
        await Promise.all(requests)
      } else {
        headers.value = []
        values.value = []
      }
    }
    const filterItems = (value, search, item) => {
      return Object.values(item)
        .filter(v => v.value !== undefined)
        .some(v => {
          if (Array.isArray(v.value)) {
            const needle = search?.toLowerCase()
            return v.value?.some(f => f.toLowerCase().indexOf(needle) > -1)
          }
          if (v.type === 'text' || v.type === 'system' || v.type === 'System List') {
            const needle = search?.toLowerCase()
            return v?.value?.toLowerCase().indexOf(needle) > -1
          }

          if (v.type === 'numeric') {
            return v?.value == search
          }

          return false
        })
    }
    const getRowClass = (item) => {
      if (isDraft.value) {
        return item.archived ? 'archived' : 'clickable'
      }
      return ''
    }
    const editItem = (item) => {
      if (item.archived) {
        return
      }
      visible.value = true
      editedItem.value = {...item}
    }
    const archiveItem = async(item) => {
      if (item.archived) {
        return
      }
      try {

        const pk = item.pk
        const values = values.value.map(v => {
          if (v.pk === pk) {
            v.archived = true
            v.originalVersionId = v.versionId
            v.versionId = props.id
          }
          return v
        })

        await postRequest(`/proposal/versions/${props.id}/values/${propType.value.code}/${item.pk}/archive`, undefined, 'blueraven')

        const sortHeader = headers.value.find(h => h.fieldOrder === 1)
        values.sort(sorterFn(sortHeader?.value))

        values.value = values
        selectedDeleteItem.value = undefined

        snackbar('SUCCESS', `Row was successfully archived. It will not be available in future versions.`)
      } catch (e) {
        snackbar('ERROR', `Row was not archived successfully.`)

        //rollback changes if there was an error
        const pk = item.pk
        values.value = values.value.map(v => {
          if (v.pk === pk) {
            v.archived = false
            v.versionId = v.originalVersionId
          }
          return v
        })
      }
    }
    const deleteItem = async(item) => {
      const {data} = await deleteRequestWithPayload(`/proposal/versions/${props.id}/values/${propType.value.code}/${item.pk}`, 'blueraven')
      const pk = data?.pk || item.pk
      const filteredValues = values.value?.filter(v => v.pk !== pk) ?? []

      if (data) {
        const {versionId, row} = data
        filteredValues.push({pk, versionId, ...row})
      }

      const sortHeader = headers.value.find(h => h.fieldOrder === 1)
      filteredValues.sort(sorterFn(sortHeader?.value))

      values.value = filteredValues

      snackbar('SUCCESS', `Row was reverted to previous version!`)
    }
    const undoAllChanges = async() => {
      const {data} = await postRequest(`/proposal/versions/${props.id}/values/${propType.value.code}/reset`, {}, 'blueraven')

      let filteredValues = data.map(({pk, versionId, row}) => ({pk, versionId, ...row}))
      const sortHeader = headers.value.find(h => h.fieldOrder === 1)
      filteredValues.sort(sorterFn(sortHeader?.value))
      values.value = filteredValues
      undoDraftChanges.value = false

      snackbar('SUCCESS', `All changes to "${propType.value.name}" successfully reverted!`)
    }
    const getProposalDetail = async(proposalVersionId) => {
      try {
        const {data} = await getRequestWithParams(`/proposal/versions/${proposalVersionId}`, {}, 'blueraven')
        detail.value = data ? {...data} : null
      } catch (e) {
        detail.value = null
      }
    }
    const getProposalObjectTypes = async() => {
      const {data} = await getRequestWithParams('/proposal/versions/types', {}, 'blueraven')
      types.value = [...data]
    }
    const getProposalObjectTypeFields = async(objectType) => {
      const {data} = await getRequestWithParams(`/proposal/versions/fields/${objectType}`, {}, 'blueraven')

      let headers = data?.length > 0
        ? data.map(r => ({
          text: r.fieldName,
          sortable: true,
          fieldOrder: r.fieldOrder,
          sort: headerSort,
          value: r.id
        }))
        : []

      headers.sort((a, b) => a.fieldOrder - b.fieldOrder)

      if (detail.value.status === 'DRAFT') {
        headers.push(defaultActionColumn)
      }
      headers.value = headers
    }
    const getProposalObjectTypeFieldValues = async(proposalVersionId, objectType) => {
      const {data} = await getRequestWithParams(`/proposal/versions/${proposalVersionId}/values/${objectType}`, {}, 'blueraven')
      const filteredValues = data.map(({pk, versionId, archived, row}) => ({pk, versionId, archived, ...row}))
      const sortHeader = headers.value?.find(h => h.fieldOrder === 1)
      filteredValues.sort(sorterFn(sortHeader.value))
      values.value = filteredValues
    }
    const publish = async(proposalVersionId, message) => {
      try {
        const {data} = await postRequest(`/proposal/versions/${proposalVersionId}/publish`, {message}, 'blueraven')
        detail.value = {...data}
        //hide the action column
        headers.value = headers.value?.slice(0, headers.value.length - 1)

        snackbar('SUCCESS', `Proposal Version #${proposalVersionId} Successfully Published`)
      } catch (e) {
        const message = e?.data?.message ?? 'Unable to publish proposal version'
        snackbar('ERROR', message)
      }
    }
    const doInput = async(val) => {
      visible.value = val
      if (!val) {
        editedItem.value = undefined
      }
    }
    const doSaveValues = async(group) => {
      try {
        const {data = {}} = await postRequest(`/proposal/versions/${detail.value.id}/values/${propType.value.code}`, group, 'blueraven')
        const {pk, versionId, row} = data
        const sortHeader = headers.value.find(h => h.fieldOrder === 1)
        const filteredValues = values.value?.filter(v => v.pk !== pk) ?? []
        filteredValues.push({pk, versionId, ...row})
        filteredValues.sort(sorterFn(sortHeader?.value))
        values.value = filteredValues
        snackbar('SUCCESS', 'Row updated successfully!')
      } catch (e) {
        snackbar('ERROR', 'Error Updating Proposal Version Fields')
      }
    }
    const sortValues = (sortHeader) => {
      const {sortBy, sortDesc} = options.value
      values.value.sort(sorterFn(sortBy[0], sortDesc[0]))
    }
</script>
<style scoped lang="scss">
@import "@/styles/main.scss";

.top-actions {
  padding: 10px 0;
  display: flex;
  justify-content: center;
  align-items: center;
}

.row-actions {
  display: flex;
  justify-content: flex-end;
}

::v-deep {
  .v-data-table {
    .v-data-table__wrapper {
      height: calc(100vh - 380px);
      min-height: 300px;
      overflow: auto;

      table {
        tbody {
          tr[aria-disabled=true] {
            cursor: not-allowed;
          }

          tr.archived {
            background-color: #afafaf !important;

            td > span:not(.row-actions) {
              opacity: .3;
              text-decoration: line-through;
            }

            &:hover {
              background-color: #afafaf !important;
            }
          }
        }
      }
    }
  }
}

tr:nth-of-type(even) {
  @extend .shaded-row;
}
</style>
