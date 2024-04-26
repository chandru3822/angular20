<template>
  <v-container class="pa-0" id="residuals-container">
      <v-toolbar flat class="app-toolbar">
        <v-toolbar-title class="app-title">
          {{userFullName}} - {{title}}
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <div class="pt-3">
            <a-btn color="primary" class="ml-3" @click="exportData()">Export</a-btn>
            <a-btn variant="text" color="primary" @click="$emit('closerClawbackModalClosed')">
              Close
            </a-btn>
          </div>
        </v-toolbar-items>
      </v-toolbar>
      <v-data-table
        :headers="clawbackHeaders"
        :items="data"
        :fixed-header="true"
        :items-per-page="-1"
        single-expand
        :mobile-breakpoint="0"
        hide-default-footer
        class="elevation-0"
      >
        <template #no-data>
          <span class="default-text-color">NO RESULTS</span>
        </template>

        <template #item="{ item, index }">
          <tr class="text-left" :class="{'shaded-row': index % 2}">
            <td class="text-left">
              <a-btn variant="outlined" :to="`/project/${item.project_id}/status`">
                {{item.project_id}}
              </a-btn>
            </td>
            <td class="text-left">{{item.plan_name}}</td>
            <td class="text-left">{{item.residual_id}}</td>
            <td class="text-left">{{item.paid_date | formatDate('date', 'MM/DD/YYYY') }}</td>
            <td class="text-left">{{item.amount}}</td>
          </tr>
        </template>
      </v-data-table>
  </v-container>
</template>

<script setup>
  import { saveAs } from 'file-saver'
  import {toRefs, ref} from 'vue'

  const props = defineProps({
    userFullName: String,
    data: Array,
    title: String,
  })

  const { userFullName, data, title } = toRefs(props)

  const clawbackHeaders = ref([
    {text: 'Project ID', value: 'project_id', show: true},
    {text: 'Plan Name', value: 'plan_name', show: true},
    {text: 'Residual ID', value: 'residual_id', show: true},
    {text: 'Paid Date', value: 'paid_date', show: true},
    {text: 'Amount', value: 'amount', show: true},
  ])

  const exportData = async () => {
    appStore.loading = true
    try {
      let filename = `${userFullName.value} - ${title.value}.csv`;

      let csvData = ''

        csvData = 'Project ID, Plan Name, Residual ID, Paid Date, Amount';
        csvData += '\n';

        data.value.forEach(p => {
          csvData +=
            p.project_id + ',' +
            '"' + p.plan_name + '",' +
            '"' + p.residual_id + '",' +
            (p.paid_date || '') + ',' +
            '"' + p.amount + '"'
          csvData += '\n';
        })

      let blob = new Blob([csvData], {
        type: 'text/csv;charset=utf-8'
      });

      saveAs(blob, filename);
      appStore.loading = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Exporting Data')
      appStore.loading = false
    }
  }
</script>

<style lang="scss">
  #residuals-container .v-data-table__wrapper {
    height: calc(100vh - 350px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  .v-data-table {
    border-radius: 0;
  }
</style>

