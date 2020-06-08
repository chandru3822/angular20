<template>
<v-dialog
    v-model="show"
    width="500"
>
    <v-card>
        <v-card-title>
            Export
        </v-card-title>

        <v-card-text>
            You are attempting to export {{ totalItems | currency('', 0)}} results.
            This can take a few minutes.
        </v-card-text>

        <v-divider></v-divider>

        <v-card-actions>
            <div class="flex-grow-1"></div>
            <v-btn
                color="grey"
                text
                @click="$emit('cancel')"
            >
                Cancel
            </v-btn>
            <v-btn
                color="primary"
                text
                @click="$emit('confirm')"
            >
                Continue
            </v-btn>
        </v-card-actions>
    </v-card>
</v-dialog>
</template>

<script>
export default {
    name: 'ExportDialog',
    props: {
        show: {
            type: Boolean,
            default: false
        },
        totalItems: Number
    }
}
</script>

<style scoped>

</style>