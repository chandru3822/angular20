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
            <v-btn text color="primary" @click="$emit('residualDetailModalClosed')">
              Close
            </v-btn>
          </div>
        </v-toolbar-items>
      </v-toolbar>
      <v-data-table
        :headers="headers"
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
              <v-btn outlined :to="`/project/${item.projectId}/details`">
                {{item.projectId}}
              </v-btn>
            </td>
            <td class="text-left" v-if="typeId !== 4">{{item.state}}</td>
            <td class="text-left" v-if="typeId !== 4">{{item.finalDesignSignedDate | formatDate('date')}}</td>
            <td class="text-left" v-if="typeId !== 4">{{item.finalDesignCompleteDate | formatDate('date')}}</td>
            <td class="text-left" v-if="typeId !== 4">{{item.utilityBillVerifiedDate | formatDate('date')}}</td>
            <td class="text-left" v-if="typeId !== 4">{{item.financialAgreementSignedDate | formatDate('date')}}</td>
            <td class="text-left" v-if="typeId !== 4">{{item.proofOfHomeownersInsuranceObtainedDate | formatDate('date')}}</td>
            <td class="text-left" v-if="typeId !== 4">{{item.substantialCompletionDate | formatDate('date')}}</td>
            <td class="text-left" v-if="typeId === 4">{{item.projectName }}</td>
            <td class="text-left">{{item.cancelledDate | formatDate('date')}}</td>
            <td class="text-left" v-if="typeId !== 4">{{item.onHoldDate | formatDate('date')}}</td>
            <td class="text-left" v-if="typeId !== 4">{{item.totalCashDownPayment | currency('$', 0)}}</td>
            <td class="text-left" v-if="typeId !== 4">{{item.firstCashPaymentAmount | currency('$', 0)}}</td>
            <td class="text-left" v-if="typeId === 4">{{item.clawbackAmount | currency('$', 0)}}</td>
            <td class="text-left" v-if="typeId === 4">{{item.clawbackDate | formatDate('date')}}</td>
          </tr>
        </template>
      </v-data-table>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'ResidualDetailModal',
    props: {
      userFullName: String,
      data: Array,
      title: String,
      typeId: Number
    },
    computed: {
      headers(){
        return this.typeId === 4 ? this.clawbackHeaders : this.residualHeaders
      }
    },
    created() {
    },
    data() {
      return {
        snackbar: {},
        residualHeaders: [
          {text: 'Project ID', value: 'projectId', show: true},
          {text: 'State', value: 'state', show: true},
          {text: 'FDA', value: 'finalDesignSignedDate', show: true},
          {text: 'FDC', value: 'finalDesignCompleteDate', show: true},
          {text: 'Utility Bill Verified', value: 'utilityBillVerifiedDate', show: true},
          {text: 'FAS', value: 'financialAgreementSignedDate', show: true},
          {text: 'Proof Of Homeowners Insurance', value: 'proofOfHomeownersInsuranceObtainedDate', show: true},
          {text: 'SC', value: 'substantialCompletionDate', show: true},
          {text: 'Cancelled', value: 'cancelledDate', show: true},
          {text: 'On Hold', value: 'onHoldDate', show: true},
          {text: 'Total Cash Down Payment', value: 'totalCashDownPayment', show: true},
          {text: 'First Cash Payment Amount', value: 'firstCashPaymentAmount', show: true},
        ],
        clawbackHeaders: [
          {text: 'Project ID', value: 'projectId', show: true},
          {text: 'Project Name', value: 'projectName', show: true},
          {text: 'Cancelled Date', value: 'cancelledDate', show: true},
          {text: 'Clawback Amount', value: 'clawbackAmount', show: true},
          {text: 'Period Paid', value: 'clawbackDate', show: true},
        ]
      }
    },
    methods: {
      async exportData () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let filename = `${this.userFullName} - ${this.title}.csv`;

          let csvData = ''

          if(this.typeId === 4) {
            csvData = 'Project ID, Project Name, Cancelled Date, Clawback Amount, Period Paid';
            csvData += '\n';

            this.data.forEach(p => {
              csvData +=
                p.projectId + ',' +
                '"' + p.projectName + '",' +
                (p.cancelledDate || '') + ',' +
                (p.clawbackAmount || '') + ',' +
                (p.clawbackDate || '')
              csvData += '\n';
            })
          } else {
            csvData = 'Project ID, State, FDA, FDC, Utility Bill Verified, FAS, Proof Of Homeowners Insurance, SC, Cancelled, On Hold, Total Cash Down Payment, First Cash Payment Amount';
            csvData += '\n';

            this.data.forEach(p => {
              csvData +=
                p.projectId + ',"' +
                p.state + '",' +
                (p.finalDesignSignedDate || '') + ',"' +
                (p.finalDesignCompleteDate || '') + '",' +
                (p.utilityBillVerifiedDate || '') + ',' +
                (p.financialAgreementSignedDate || '') + ',"' +
                (p.proofOfHomeownersInsuranceObtainedDate || '') + '",' +
                (p.substantialCompletionDate || '') + ',' +
                (p.cancelledDate || '') + ',' +
                (p.onHoldDate || '') + ',' +
                (p.totalCashDownPayment || '') + ',' +
                (p.firstCashPaymentAmount || '')
              csvData += '\n';
            })
          }

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

