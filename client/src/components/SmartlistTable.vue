<template>
<div>
    <v-toolbar class="elevation-1" width="100%">
        <v-text-field
          v-model="search"
          prepend-inner-icon="search"
          label="Search"
          single-line
          hide-details
        ></v-text-field>
        <v-spacer />
        <v-btn
            text
            :disabled="isLoading"
            @click="showConfirmDialog = true"
        >
          <v-icon>mdi-cloud-download</v-icon>
          <span>Export</span>
        </v-btn>
    </v-toolbar>

    <v-divider />

    <v-data-table
        :items="reportData"
        :headers="headers"
        :loading="isLoading"
        :footer-props="footerProps"
        fixed-header
        :options.sync="options"
        :search="search"
        multi-sort
    >
        <template #no-data>
            No available report data
        </template>

        <template #no-results>
            No available report data
        </template>

        <template #item="{item: row}">
            <tr
              class="clickable"
              @click="selectRow(row)"
            >
              <template
                v-for="(field, key) in row"
              >
                <td
                  v-if="key !== 'project_id' && key !== 'contact_id'"
                  :key="key"
                  class="text-left"
                >
                  <router-link class="router-link-td elevation-0 square-card"
                               color="transparent" :to="type === 'PROJECT' ? `/project/${row.project_id}/details` :
                                                        type === 'CONTACT' ? `/contact/${row.contact_id}` : ''">
                    {{field}}
                  </router-link>
                </td>
              </template>
            </tr>
        </template>
    </v-data-table>

    <ExportDialog
        :show="showConfirmDialog"
        :totalItems="reportData.length"
        @cancel="showConfirmDialog = false"
        @confirm="[showConfirmDialog = false, generateReport()]"
    />
</div>
</template>

<script>

import {logError, getRequestWithParams, getRequest, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ExportDialog from '@/components/ExportDialog'
import saveAs from 'file-saver'
import {AppMutations} from '@/stores/AppStore'

export default {
    name: 'SmartlistTable',
    components: {
        ExportDialog
    },
    props: {
        smartlistId: Number,
        type: String
    },
    data () {
        return {
            reportData: [],
            isLoading: false,
            headers: [],
            options: {
                itemsPerPage: 100
            },
            footerProps: {
                'items-per-page-options': [25, 50, 100],
                'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
            },
            showConfirmDialog: false,
            search: ''
        }
    },
    watch: {
        smartlistId: {
            immediate: true,
            handler() {
                this.getSmartlistData()
            }
        }
    },
    methods: {
        async getSmartlistData() {
            try {
                this.isLoading = true
                const {data} = await getRequestWithParams(`/smartlist/${this.smartlistId}/data`)
                this.reportData = data.data
                this.headers = data.headers.map(h => ({text: h.name, value: h.name, id: h.id}))
            } catch (e) {
                logError(e)
            } finally {
                this.isLoading = false
            }
        },
        async generateReport () {
          try {
            this.$store.commit(AppMutations.SET_LOADING, true)
            const {data} = await getRequest(`/smartlist/${this.smartlistId}/csv`)
            let blob = new Blob([data], {
              type: 'text/csv;charset=utf-8'
            });
            saveAs(blob, "smartlist.csv");
          } catch (e) {
            this.snackbar = getSnackbar('ERROR', e.message)
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            logError(e)
          } finally {
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        },
        selectRow (row) {
          this.$emit('row-selected', row)
        }
    }
}
</script>

<style scoped lang="scss">

@import "@/styles/main.scss";

tr:nth-of-type(even) {
    @extend .shaded-row;
}
</style>
