<template>
<div>
    <v-toolbar class="elevation-1" width="100%">
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
                <td
                    v-for="field in headers"
                    :key="field.id"
                    class="text-left"
                >
                    {{row[field.text]}}
                </td>
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

import {logError, getRequestWithParams, jsonToCsv} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ExportDialog from '@/components/ExportDialog'
import saveAs from 'file-saver'

export default {
    name: 'SmartlistTable',
    components: {
        ExportDialog
    },
    props: {
        smartlistId: Number
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
            showConfirmDialog: false
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
        generateReport () {
            saveAs(new Blob([jsonToCsv(this.reportData)], {type: constants.CSV_BLOB_TYPE}), 'export.csv')
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
