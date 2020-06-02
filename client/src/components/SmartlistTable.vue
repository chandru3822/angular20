<template>
<v-data-table
    :items="reportData"
    :loading="isLoading"
>
    <template #no-data>
        No available report data
    </template>

    <template #no-results>
        No available report data
    </template>
</v-data-table>
</template>

<script>

import {logError, getRequestWithParams} from '@/helpers/helpers'

export default {
    name: 'SmartlistTable',
    props: {
        smartlistId: Number
    },
    data () {
        return {
            reportData: [],
            isLoading: false
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
                const {data} = getRequestWithParams(`/smartlist/${this.smartlistId}/data`)
                this.reportData = data
            } catch (e) {
                logError(e)
            } finally {
                this.isLoading = false
            }
        },
    }
}
</script>

<style scoped>

</style>