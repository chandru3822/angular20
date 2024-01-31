<template>
  <v-card>
    <v-card-title class="mb-1">
      <span v-if="startDate === endDate" class="drilldown-title">{{ milestone.name }} on {{ startDate | formatDate('date', 'MM/DD/YYYY') }}</span>
      <span v-else class="drilldown-title">{{ milestone.name }} {{ startDate | formatDate('date', 'MM/DD/YYYY') }} - {{ endDate | formatDate('date', 'MM/DD/YYYY') }}</span>
      <v-spacer></v-spacer>
      <v-btn color="primary" class="mr-4 mb-2"
             @click="exportCsv()">
        Export
      </v-btn>
      <a class="close-modal-x pb-3" title="Close" @click="closeCallback">×</a>
    </v-card-title>
    <v-divider></v-divider>
    <v-card-title v-if="drilldownData.length > 0" id="funnel-drilldown-search" class="pt-2">
      <v-text-field v-model="drilldownSearch"
                    placeholder="Type to filter..."
                    class="drilldown-filter"
                    single-line
                    hide-details
                    outlined
                    dense
      ></v-text-field>
      <span id="funnel-drilldown-row-count">
            Records: {{ drilldownRowCount + '/' + drilldownData.length }}
          </span>
    </v-card-title>

    <v-card-text class="drilldown-card">
      <v-data-table
        id="drilldown-table"
        :headers="filteredHeaders()"
        :items="drilldownData"
        :footer-props="footerProps"
        :items-per-page="500"
        :mobile-breakpoint="0"
        :search="drilldownSearch"
        @current-items="filteredDrilldownItems"
        fixed-header
        dense
        class="elevation-1"
      >

        <template #header.additional_field_value="{}">
          <span v-if="drilldownData && drilldownData[0]">{{ drilldownData[0].additional_field_label }}</span>
        </template>


        <template #header.date_value="{}">
          <span v-if="drilldownData && drilldownData[0]">{{ drilldownData[0].date_label }}</span>
        </template>

        <template v-if="drilldownData.length > 0" #item="{ item, index }">
          <tr :class="['text-sm-left', 'row-hover', {'shaded-row': !(index % 2)}]">
            <td class="text-left">{{ index + 1 }}</td>
            <router-link class="text-left" :to="`/project/${item.project_id}/details`">
              {{ item.project_id }}
            </router-link>
<!--            <td class="text-left">{{ item.project_id }}</td>-->
            <td class="text-left customer-name">{{ item.customer_name }}</td>
            <td class="text-left">{{ item.state }}</td>
            <td class="text-left">{{ item.source_name }}</td>
<!--            <td class="text-left">-->
<!--              <span v-if="item.date_type === 'date'">{{ item.date_value | formatDate('date', 'MM/DD/YYYY') }}</span>-->
<!--              <span v-else-if="item.date_type === 'timestamp'">{{ item.date_value | formatDate('timestamp', 'MM/DD/YYYY') }}</span>-->
<!--              <span v-else>{{ item.date_value }}</span>-->
<!--            </td>-->
<!--            <td class="text-left" v-if="milestone.has_additional_column">-->
<!--              <span v-if="item.additional_field_type === 'date'">{{ item.additional_field_value | formatDate('date', 'MM/DD/YYYY') }}</span>-->
<!--              <span v-else-if="item.additional_field_type === 'timestamp'">{{ item.additional_field_value | formatDate('timestamp', 'MM/DD/YYYY') }}</span>-->
<!--              <span v-else>{{ item.additional_field_value }}</span>-->
<!--            </td>-->
            <td class="text-left" v-for="additionalColumn in item.additional_columns">
              <span v-if="additionalColumn.data_type === 'date'">{{ additionalColumn.value | formatDate('date', 'MM/DD/YYYY') }}</span>
              <span v-else-if="additionalColumn.data_type === 'timestamp'">{{ additionalColumn.value | formatDate('timestamp', 'MM/DD/YYYY') }}</span>
              <span v-else>{{ additionalColumn.value }}</span>
            </td>
          </tr>
        </template>

        <template #no-data>
          <div class="my-3 default-text-color">
            No data was found for the specified date range.
          </div>
        </template>
      </v-data-table>
    </v-card-text>

    <v-card-actions>
      <v-spacer></v-spacer>
      <v-btn id="drilldown-close-btn" class="white--text text-capitalize mr-4 mb-2"
             color="primary" @click="closeCallback">
        Close
      </v-btn>
    </v-card-actions>
  </v-card>
</template>

<script>
  import constants from '@/helpers/constants'
  import DatetimePickerInput from "@/components/DatetimePickerInput"
  import Snackbar from '@/components/Snackbar.vue'
  import { saveAs } from 'file-saver'

  export default {
    name: 'companyDashboardDrilldown',
    components: {
      DatetimePickerInput,
      Snackbar
    },
    props: {
      milestone: Object,
      drilldownData: Array,
      loadPartners: Boolean,
      closeCallback: Function,
      startDate: String,
      endDate: String,
      additionalHeaders: Array
    },
    created() {
      if (this.$store?.state?.user?.details?.timezone?.value) {
        this.timezone = this.$store.state.user.details.timezone.value
      }
      this.addHeaders();
    },
    data() {
      return {
        snackbar: {},
        constants,
        headers: [],
        timezone: 'US/Mountain',
        isLoading: true,
        dashValues: [],
        drilldownHeaders: [
          {text: '', value: '', show: true, sortable: false}, // 0
          {text: 'Project ID', value: 'project_id', show: true}, // 1
          {text: 'Customer Name', value: 'customer_name', show: true}, // 2
          {text: 'State', value: 'state', show: true}, // 3
          {text: 'Source', value: 'source_name', show: true}, // 4
          // {text: '', value: 'date_value', show: true}, // 5
          // {text: '', value: 'additional_field_value', show: this.milestone.has_additional_column}, // 6
        ],
        // drilldownData: [],
        footerProps: {
          showFirstLastPage: !constants.IS_MOBILE,
          firstIcon: constants.IS_MOBILE ? '' : 'mdi-page-first',
          lastIcon: constants.IS_MOBILE ? '' : 'mdi-page-last',
          itemsPerPageText: constants.IS_MOBILE ? '' : 'Rows per page:',
          itemsPerPageOptions: [100, 500, 1000, 2000]
        },
        drilldownSearch: '',
        drilldownRowCount: 0,
        filteredDrilldownData: [],
      }
    },
    methods: {
      filteredDrilldownItems(filteredItems) {
        this.filteredDrilldownData = filteredItems
        this.drilldownRowCount = filteredItems.length
      },
      filteredHeaders () {
        return this.drilldownHeaders.filter(header => header.show === true)
      },
      addHeaders(){
        if(this.drilldownData.length > 0) {
          this.drilldownData[0].additional_columns.forEach((header, index) => {
            this.drilldownHeaders.push({
              text: header.label,
              value: 'additional_columns['+index+'].value',
              show: true,
              additional: true,
              index: index,
              sort: (a, b) => {
                //dataTypeId = 6 is an int
                let dataTypeId = parseInt(header.data_type_id);
                if ([4,6].includes(dataTypeId)) {
                  return (a === null) - (b === null) || a - b
                }

                  //if it is a date, format the string as a date and sort by that value
                  //without the .toString() this fails for numeric values
                //this does a lot of extra checking we probably dont need now that we know the data type id of the column, but i am keeping it cuz i am not sure what it all does
                else if ( [1,2].includes(dataTypeId)) {
                  //todo: keep an eye on if Date.parse returns false for regular numbers and such
                  //note: firefox doesn't support date formats with hyphens. only with /
                  return (new Date(a) - new Date(b))
                } else {
                  //otherwise sort normally
                  //nulls were sorting super weird when the normal options had special characters in them, like '#BQ-1234', setting nulls to '' before sorting seems to fix that, plus saves some null checks for localeCompare
                  let newA = null == a ? '' : a.trim().toLowerCase()
                  let newB = null == b ? '' : b.trim().toLowerCase()
                  return newA.localeCompare(newB)
                }
              },
            })
          })
        }
      },
      exportCsv() {
        let csv = ''

        this.filteredHeaders().forEach(h => {
          if(h.text !== '') {
            return csv += `${h.text},`
          }
        })

        this.drilldownData.forEach((o, idx) => {
          csv += `\n`

          this.filteredHeaders().forEach((h, i) => {

            if(i != 0) {
              if (h.value === 'date_value') {
                csv += '"' + `${o.date_value === null || o.date_value === undefined ? '' : this.$filters.formatDate(o.date_value, o.date_type, 'MM/DD/YYYY')}` + '",'
              } else if (h.value === 'additional_field_value') {
                csv += '"' + `${o.additional_field_value === null || o.additional_field_value === undefined ? '' : this.$filters.formatDate(o.additional_field_value, o.additional_field_type, 'MM/DD/YYYY')}` + '",'
              } else if(h.additional){
                if(o.additional_columns[h.index].data_type === 'timestamp') {
                  csv += '"' + `${this.$filters.formatDate(o.additional_columns[h.index].value, 'MM/DD/YYYY')}` + '",'
                }
                else if(o.additional_columns[h.index].data_type === 'timestamp') {
                  csv += '"' + `${this.$filters.formatDate(o.additional_columns[h.index].value, 'MM/DD/YYYY')}` + '",'
                }
                else{
                  csv += o.additional_columns[h.index].value + ',';
                }
              } else if (h.text !== '') {
                csv += '"' + `${o[h.value] === null || o[h.value] === undefined ? '' : o[h.value]}` + '",'
              }
            }
          })

          csv += `\n`
        })

        const blob = new Blob([csv], {type: 'text/csv;charset=utf-8'})
        saveAs(blob, `${this.milestone.name}.csv`)
      }
    }

  }
</script>

<style lang="scss">
  .drilldown-card{
    padding-bottom: 8px!important;
  }
  .drilldown-filter{
    max-width: 1000px;
  }

  #drilldown-table .v-data-table__wrapper {
    height: calc(100vh - 330px);
    min-height: 300px;
  }

  .drilldown-dialog {
    //this is changed if media width > 450
    min-width: 100% !important;
  }

</style>

<style lang="scss" scoped>
  .close-modal-x {
    font-size: 20px;

    &:hover {
      font-weight: bolder;
    }
  }

  .v-card__title {
    display: flex;
    flex-flow: row nowrap;
    justify-content: space-between;
    align-items: center;
  }

  .drilldown-title {
    font-family: "Roboto Condensed", sans-serif;
    font-size: 14px;
  }

  #drilldown-close-btn {
    font-size: 10px;
    height: 25px;
    margin-bottom: 16px;
  }

  @media (min-width: 450px) {
    .drilldown-dialog {
      min-width: 379px;
    }
  }

  @media (min-width: 769px) {
    .drilldown-title {
      font-size: 18px;
    }

    #drilldown-table {
      th, td {
        font-size: 12px;
      }

      ::v-deep {
        .v-data-footer {
          padding: initial;
        }
      }
    }

    #drilldown-close-btn {
      font-size: 14px;
      height: 35px;
      margin-bottom: 16px;
    }
  }
</style>
