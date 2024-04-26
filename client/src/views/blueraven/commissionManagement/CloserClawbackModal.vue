<template>
  <v-container class="pa-0" id="residuals-container">
      <v-toolbar flat class="app-toolbar">
        <v-toolbar-title class="app-title">
          {{userFullName}} - {{title}}
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <div class="pt-3">
            <v-btn color="primary" class="ml-3" dark @click="exportData()">Export</v-btn>
            <v-btn text color="primary" @click="$emit('closerClawbackModalClosed')">
              Close
            </v-btn>
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
              <v-btn outlined :to="`/project/${item.project_id}/status`">
                {{item.project_id}}
              </v-btn>
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

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {getSnackbar} from '@/helpers/helpers'
  import { saveAs } from 'file-saver'

  export default {
    name: 'ResidualDetailModal',
    props: {
      userFullName: String,
      data: Array,
      title: String,
    },
    computed: {
    },
    created() {
    },
    data() {
      return {
        snackbar: {},
        clawbackHeaders: [
          {text: 'Project ID', value: 'project_id', show: true},
          {text: 'Plan Name', value: 'plan_name', show: true},
          {text: 'Residual ID', value: 'residual_id', show: true},
          {text: 'Paid Date', value: 'paid_date', show: true},
          {text: 'Amount', value: 'amount', show: true},
        ]
      }
    },
    methods: {
      async exportData () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let filename = `${this.userFullName} - ${this.title}.csv`;

          let csvData = ''

            csvData = 'Project ID, Plan Name, Residual ID, Paid Date, Amount';
            csvData += '\n';

            this.data.forEach(p => {
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
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Exporting Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
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

