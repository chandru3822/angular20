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
          <a @click="alterEnabledFlagForColumns(header)">{{header.text}}</a>
        </template>

        <template v-slot:header.data-table-select="{ on, props }">
          <v-simple-checkbox v-bind="props" v-on="on" v-if="userCanEdit"></v-simple-checkbox>
        </template>

        <template #item="{ item, index, isSelected, select }">
          <tr :class="{ 'shaded-row': index % 2 }">
            <td class="text-center">
              <v-simple-checkbox v-if="userCanEdit" :value="isSelected" @input="select($event)"></v-simple-checkbox>
            </td>
            <td class="text-left">
              {{ item.featureName }}
            </td>
            <td v-for="acl in item.accessControl">
              <input type="checkbox" :readonly="!userCanEdit"
                     :disabled="!userCanEdit" v-model="acl.enabled" @input="callback(companyFeatureList)">
              
              <v-icon class="ml-2 mb-1" small color="activeBlue"
                      v-if="secondaryFeatureAccess.length > 0 && secondaryHasAccess(item, acl)">
                mdi-alpha-p-box-outline
              </v-icon>
            </td>
          </tr>
        </template>

      </v-data-table>
  </div>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'

  import cloneDeep from 'lodash.clonedeep'
  import {getRequest, getRequestWithParams, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'AccessControl',

    props: {
      companyFeatures: {type: Array},
      callback: Function,
      userCanEdit: Boolean,
      showSecondary: Boolean
    },
    watch: {
      'selectedRows': function (newVal, oldVal, blah) {
        this.alterEnabledFlagForRows(newVal, oldVal, blah)
      }
    },
    data() {
      return {
        snackbar: {},
        selectedRows: [],
        userId: this.$route.params.id,
        companyFeatureList: cloneDeep(this.companyFeatures),
        features: [],
        secondaryFeatureAccess: [],
        accessControlList: [],
        parentId: this.$store.state.user.details.parentCompanyId,
        headers: [
          { text: 'Feature', value: 'featureName', show: true },

        ],
      }
    },
    created () {
      this.getFeatures()
      if(this.showSecondary) {
        this.loadSecondary()
      }
    },
    methods: {
      async loadSecondary() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequestWithParams(`/feature/access/allUserPositions`, { params: {
            userId: this.userId
          }})
          this.secondaryFeatureAccess = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Features')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      secondaryHasAccess (item, acl) {
        let matchingAccessLevel = this.secondaryFeatureAccess.find(ac => { return ac.featureId === item.featureId && ac.accessCode === acl.accessCode })
        if(matchingAccessLevel?.id) {
          console.log('randaLogger', matchingAccessLevel)
        }
        return matchingAccessLevel?.enabled ?? false
      },
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
      populateSelectedRows () {
        // this determines if the checkbox for selecting the row should be checked or not on page load
        if(this.companyFeatureList?.length > 0) {
          let countAccessControlLevels = this.companyFeatureList[0]?.accessControl?.length
          this.companyFeatureList.forEach(cfl => {
            let countEnabled = 0
            cfl.accessControl?.forEach(acl => {
              if(acl.enabled) {
                countEnabled++
              }
            })
            if(countEnabled === countAccessControlLevels) {
              this.selectedRows.push(cfl)
            }
          })
        }
      },
      alterEnabledFlagForColumns (header) {
        if(this.userCanEdit) {
          header.selectAll = !header.selectAll
          this.companyFeatureList.forEach(cf => {
            cf.accessControl.forEach(acl => {
              if(header.accessControlId === acl.accessControlId) {
                acl.enabled = header.selectAll
              }
            })
          })
          this.callback(this.companyFeatureList)
        }
      },
      alterEnabledFlagForRows (newList, oldList) {
        // filter the new list and remove everything that was in old list.  this is the row that was clicked
        if(this.companyFeatureList.length === newList?.length) {
          // select all
          this.companyFeatureList.forEach(cfl => {
            cfl.accessControl.forEach(ac => {
              ac.enabled = true
            })
          })
        } else if (newList?.length === 0 && this.companyFeatureList.length === oldList?.length) {
          // deselect all
          this.companyFeatureList.forEach(cfl => {
            cfl.accessControl.forEach(ac => {
              ac.enabled = false
            })
          })
        } else {
          let selectedRow, enable
          if(newList?.length > oldList?.length) {
            selectedRow = newList?.filter(e => !oldList?.includes(e))[0]
            enable = true
          } else {
            selectedRow = oldList?.filter(e => !newList?.includes(e))[0]
            enable = false
          }
          let selectedCfl = this.companyFeatureList.find(cfl => { return cfl?.featureId === selectedRow?.featureId})
          selectedCfl?.accessControl?.forEach(acl => {
            acl.enabled = enable
          })
        }

        this.callback(this.companyFeatureList)
      },
      async getFeatures() {
        if(this.companyFeatureList?.length === 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {data} = await getRequest(`/feature/withAccess`)
            this.companyFeatureList = data
            this.populateHeaders()
            this.populateSelectedRows()
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Features')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } else {
          this.populateHeaders()
          this.populateSelectedRows()
        }
      },

    }
  }
</script>

<style lang="scss">

</style>

<style lang="scss" scoped>

</style>

