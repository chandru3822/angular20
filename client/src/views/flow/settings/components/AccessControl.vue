<template>
  <div>
      <v-data-table
          :headers="headers"
          :items="companyFeatureList"
          :fixed-header="true"
          :items-per-page="-1"
          v-model="selectedRows"
          hide-default-footer
          disable-sort
          show-select

          class="elevation-1 mt-1"
      >
        <template #no-data>
          No available fields
        </template>

        <template #no-results>
          No available fields
        </template>

        <template v-slot:header.MODIFY-ME="{ header, on, props }">
          <a @click="header.selectAll = !header.selectAll; alterEnabledFlagForColumns(header)">{{header.text}}</a>
        </template>

        <template v-slot:header.data-table-select="{ on, props }">
          <v-simple-checkbox v-bind="props" v-on="on"></v-simple-checkbox>
        </template>

        <template #item="{ item, index, isSelected, select }">
          <tr :class="{ 'shaded-row': index % 2 }">
            <td class="text-center">
              <v-simple-checkbox :value="isSelected" @input="select($event)"></v-simple-checkbox>
            </td>
            <td class="text-left">
              {{ item.featureName }}
            </td>
            <td v-for="acl in item.accessControl">
              <input type="checkbox" v-model="acl.enabled" @input="callback(companyFeatureList)">
            </td>
          </tr>
        </template>

      </v-data-table>
  </div>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import cloneDeep from 'lodash.clonedeep'
  import {getRequest, getRequestWithParams, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'AccessControl',
    components: {
      Snackbar
    },
    props: {
      companyFeatures: {type: Array},
      callback: Function,
    },
    watch: {
      'selectedRows': function () {
        this.alterEnabledFlagForRows()
      }
    },
    data() {
      return {
        snackbar: {},
        selectedRows: [],
        companyFeatureList: cloneDeep(this.companyFeatures),
        features: [],
        accessControlList: [],
        parentId: this.$store.state.user.details.parentCompanyId,
        headers: [
          { text: 'Feature', value: 'featureName', show: true },

        ],
      }
    },
    created () {
      this.getFeatures()
    },
    methods: {
      populateHeaders () {
        //todo. not my favorite
        if(this.companyFeatureList?.length > 0) {
          this.companyFeatureList[0]?.accessControl?.forEach(acl => {
            this.headers.push({
              text: acl.accessLevel,
              value: 'MODIFY-ME',
              custom: acl.accessCode,
              accessControlId: acl.accessControlId,
              show: true
            })
          })
        }
      },
      alterEnabledFlagForColumns (header) {
        this.companyFeatureList.forEach(cf => {
          cf.accessControl.forEach(acl => {
            if(header.accessControlId === acl.accessControlId) {
              acl.enabled = header.selectAll
            }
          })
        })
        this.callback(this.companyFeatureList)
      },
      alterEnabledFlagForRows () {
        this.companyFeatureList.forEach(cf => {
          let matchingRow = this.selectedRows.find(row => row.featureId === cf.featureId)
          let enabled = matchingRow !== null && matchingRow !== undefined
          cf.accessControl.forEach(acl => {
            acl.enabled = enabled
          })
        })
        this.callback(this.companyFeatureList)
      },
      async getFeatures() {
        if(this.companyFeatureList?.length === 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {data} = await getRequest(`/feature/withAccess`)
            this.companyFeatureList = data
            this.populateHeaders()
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Features')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } else {
          this.populateHeaders()
        }
      },

    }
  }
</script>

<style lang="scss">

</style>

<style lang="scss" scoped>

</style>

