<template>
  <div>
    <v-btn text color="primary" class="pl-1 pr-2" @click="$router.back()">
      <v-icon>arrow_left</v-icon>
      <span>Back</span>
    </v-btn>
    <v-toolbar flat class="app-toolbar">
      <v-toolbar-title v-if="detail">
        <span class="app-title">Version {{ detail.version }}</span>
        <v-chip class="ma-2" color="grey lighten-2" label>{{ detail.status | capitalize }}</v-chip>
        <v-chip class="ma-2 default-text-color" color="primary lighten-9" label v-if="detail.primaryVersion">
          Current
        </v-chip>

        <v-btn
          class="ma-2"
          text
          icon
          color="blue lighten-2"
          @click="showHistory = true"
        >
          <v-icon>mdi-history</v-icon>
        </v-btn>
        <proposal-version-history :visible.sync="showHistory" :version="detail.version"/>
      </v-toolbar-title>
      <v-spacer/>
      <v-toolbar-items v-if="isDraft">
        <v-btn text color="primary" @click="confirmation=true">Publish</v-btn>
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
          <v-btn v-if="hasChanges" text
                 color="primary"
                 @click="undoDraftChanges=true">
            Undo All Changes
          </v-btn>
          <ConfirmationDialog :open-dialog="undoDraftChanges"
                              @confirm="undoAllChanges"
                              @close-dialog="undoDraftChanges=false">
            <template v-slot:title>Confirm</template>
            <p>Are you sure you want to undo all changes to this draft?
              <span class="error--text">WARNING:</span>This action is <b>irreversible</b>!
            </p>
            <template v-slot:yes>Undo all</template>
          </ConfirmationDialog>
          <v-btn color="primary" dark @click.prevent="visible = true">
            Add New
          </v-btn>
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
                  <v-text-field
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
                      <v-btn small text color="primary" @click.stop="deleteItem(item)"
                             v-if="item.versionId === detail.id">
                           <v-icon>mdi-undo</v-icon>
                      </v-btn>
                      <v-btn small text color="primary" v-if="!item.archived" @click.stop="selectedDeleteItem = item">
                        <v-icon>mdi-delete</v-icon>
                      </v-btn>
                      <v-btn small text color="primary" disabled v-else></v-btn>
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
<script>
import {Fragment} from 'vue-frag'
import {deleteRequestWithPayload, getRequestWithParams, getSnackbar, postRequest} from '@/helpers/helpers'
import NewProposalValueDialog from './NewProposalValueDialog.vue'
import {AppMutations} from '@/stores/AppStore'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import ProposalVersionHistory from "@/views/blueraven/settings/proposals/ProposalVersionHistory.vue";
import {ProposalSettingsMixins} from "@/views/blueraven/settings/proposals/mixins";

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

export default {
  name: 'ProposalDetail',
  components: {ProposalVersionHistory, ConfirmationDialog, NewProposalValueDialog, Fragment},
  props: ['id'],
  mixins: [ProposalSettingsMixins],
  created() {
    Promise.allSettled([
      this.getProposalDetail(this.id),
      this.getProposalObjectTypes()
    ])
  },
  data() {
    return {
      search: '',
      options: {},
      detail: {},
      propType: undefined,
      headers: [],
      values: [],
      types: [],
      confirmation: false,
      visible: false,
      editedItem: undefined,
      modifiedOnlyFilter: false,
      undoDraftChanges: false,
      footerProps: {
        'items-per-page-options': [10, 20, 50, -1],
      },
      selectedDeleteItem: undefined,
      publishNote: undefined,
      showHistory: false
    }
  },
  computed: {
    rows() {
      //intentional '=='
      return !this.modifiedOnlyFilter ? this.values : this.values?.filter(v => v.versionId == this.id)
    },
    hasChanges() {
      //intentional '=='
      return this.values?.filter(v => v.versionId == this.id).length > 0
    },
    isDraft() {
      return this.detail && this.detail.status === 'DRAFT'
    }
  },
  methods: {
    async changer() {
      const requests = []
      const {code} = this.propType ?? {}

      if (code) {
        requests.push(this.getProposalObjectTypeFields(code))
        requests.push(this.getProposalObjectTypeFieldValues(this.id, code))
        await Promise.all(requests)
      } else {
        this.headers = []
        this.values = []
      }
    },

    filterItems(value, search, item) {
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
    },

    getRowClass(item) {
      if (this.isDraft) {
        return item.archived ? 'archived' : 'clickable'
      }
      return ''
    },

    editItem(item) {
      if (item.archived) {
        return
      }
      this.visible = true
      this.editedItem = {...item}
    },

    async archiveItem(item) {
      if (item.archived) {
        return
      }
      try {

        const pk = item.pk
        const values = this.values.map(v => {
          if (v.pk === pk) {
            v.archived = true
            v.originalVersionId = v.versionId
            v.versionId = this.id
          }
          return v
        })

        await postRequest(`/proposal/versions/${this.id}/values/${this.propType.code}/${item.pk}/archive`, undefined, 'blueraven')

        const sortHeader = this.headers.find(h => h.fieldOrder === 1)
        values.sort(sorterFn(sortHeader?.value))

        this.values = values
        this.selectedDeleteItem = undefined

        const snackbar = getSnackbar('SUCCESS', `Row was successfully archived. It will not be available in future versions.`)
        this.$store.commit(AppMutations.SHOW_SNACK, snackbar)
      } catch (e) {
        const snackbar = getSnackbar('ERROR', `Row was not archived successfully.`)
        this.$store.commit(AppMutations.SHOW_SNACK, snackbar)

        //rollback changes if there was an error
        const pk = item.pk
        this.values = this.values.map(v => {
          if (v.pk === pk) {
            v.archived = false
            v.versionId = v.originalVersionId
          }
          return v
        })
      }
    },

    async deleteItem(item) {
      const {data} = await deleteRequestWithPayload(`/proposal/versions/${this.id}/values/${this.propType.code}/${item.pk}`, 'blueraven')
      const pk = data?.pk || item.pk
      const values = this.values?.filter(v => v.pk !== pk) ?? []

      if (data) {
        const {versionId, row} = data
        values.push({pk, versionId, ...row})
      }

      const sortHeader = this.headers.find(h => h.fieldOrder === 1)
      values.sort(sorterFn(sortHeader?.value))

      this.values = values

      const snackbar = getSnackbar('SUCCESS', `Row was reverted to previous version!`)
      this.$store.commit(AppMutations.SHOW_SNACK, snackbar)
    },

    async undoAllChanges() {
      const {data} = await postRequest(`/proposal/versions/${this.id}/values/${this.propType.code}/reset`, {}, 'blueraven')

      let values = data.map(({pk, versionId, row}) => ({pk, versionId, ...row}))
      const sortHeader = this.headers.find(h => h.fieldOrder === 1)
      values.sort(sorterFn(sortHeader?.value))
      this.values = values
      this.undoDraftChanges = false

      const snackbar = getSnackbar('SUCCESS', `All changes to "${this.propType.name}" successfully reverted!`)
      this.$store.commit(AppMutations.SHOW_SNACK, snackbar)
    },

    async getProposalDetail(proposalVersionId) {
      try {
        const {data} = await getRequestWithParams(`/proposal/versions/${proposalVersionId}`, {}, 'blueraven')
        this.detail = data ? {...data} : null
      } catch (e) {
        this.detail = null
      }
    },

    async getProposalObjectTypes() {
      const {data} = await getRequestWithParams('/proposal/versions/types', {}, 'blueraven')
      this.types = [...data]
    },

    async getProposalObjectTypeFields(objectType) {
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

      if (this.detail.status === 'DRAFT') {
        headers.push(defaultActionColumn)
      }
      this.headers = headers
    },

    async getProposalObjectTypeFieldValues(proposalVersionId, objectType) {
      const {data} = await getRequestWithParams(`/proposal/versions/${proposalVersionId}/values/${objectType}`, {}, 'blueraven')
      const values = data.map(({pk, versionId, archived, row}) => ({pk, versionId, archived, ...row}))
      const sortHeader = this.headers.find(h => h.fieldOrder === 1)
      values.sort(sorterFn(sortHeader?.value))
      this.values = values
    },

    async publish(proposalVersionId, message) {
      try {
        const {data} = await postRequest(`/proposal/versions/${proposalVersionId}/publish`, {message}, 'blueraven')
        this.detail = {...data}
        //hide the action column
        this.headers = this.headers.slice(0, this.headers.length - 1)

        const snackbar = getSnackbar('SUCCESS', `Proposal Version #${proposalVersionId} Successfully Published`)
        this.$store.commit(AppMutations.SHOW_SNACK, snackbar)
      } catch (e) {
        const message = e?.data?.message ?? 'Unable to publish proposal version'
        const snackbar = getSnackbar('ERROR', message)
        this.$store.commit(AppMutations.SHOW_SNACK, snackbar)
      }
    },

    async doInput(val) {
      this.visible = val
      if (!val) {
        this.editedItem = undefined
      }
    },

    async doSaveValues(group) {
      try {
        const {data = {}} = await postRequest(`/proposal/versions/${this.detail.id}/values/${this.propType.code}`, group, 'blueraven')
        const {pk, versionId, row} = data
        const sortHeader = this.headers.find(h => h.fieldOrder === 1)
        const values = this.values?.filter(v => v.pk !== pk) ?? []
        values.push({pk, versionId, ...row})
        values.sort(sorterFn(sortHeader?.value))
        this.values = values
        const snackbar = getSnackbar('SUCCESS', 'Row updated successfully!')
        this.$store.commit(AppMutations.SHOW_SNACK, snackbar)
      } catch (e) {
        const snackbar = getSnackbar('ERROR', 'Error Updating Proposal Version Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, snackbar)
      }
    },

    sortValues(sortHeader) {
      const {sortBy, sortDesc} = this.options
      this.values.sort(sorterFn(sortBy[0], sortDesc[0]))
    }
  }
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
