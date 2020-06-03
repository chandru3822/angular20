<template>
<!--    @TODO humes: add export toolbar -->
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
        <tr>
            <td v-for="field in headers" :key="field.id">{{row[field.text]}}</td>
        </tr>
    </template>
</v-data-table>
</template>

<script>

import {logError, getRequestWithParams} from '@/helpers/helpers'
import constants from '@/helpers/constants'

export default {
    name: 'SmartlistTable',
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
            }
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
    }
}
</script>

<style scoped lang="scss">

@import "@/styles/main.scss";

tr:nth-of-type(even) {
    @extend .shaded-row;
}
</style>