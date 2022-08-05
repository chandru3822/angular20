<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-breadcrumbs :items="breadcrumbs"></v-breadcrumbs>
        <v-toolbar class="elevation-1 testing">
          <v-toolbar-title class="app-title">{{ details.companyFunctionName }}</v-toolbar-title>
        </v-toolbar>
        <v-card class="square-card pa-4 elevation-1" v-if="details.description">
          <strong>Description:</strong> <br/>
          {{details.description}}
        </v-card>

        <v-data-table
            :headers="headers"
            :items="details.companyFunctionParams"
            :items-per-page="-1"
            single-expand
            :mobile-breakpoint="0"
            item-key="dbFunctionParamId"
            :expanded.sync="expanded"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            NO DATA HERE!
          </template>

          <template #no-results>
            No parameters exist for this function
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': details.companyFunctionParams.indexOf(item) % 2}">
<!--              they should not be able to edit system value types-->
<!--              <v-select attach v-if="item.parameterTypeId === 1"-->
<!--                          v-model="item.systemValueId"-->
<!--                          :items="systemValues"-->
<!--                          label="System Value"-->
<!--                          item-text="systemValue"-->
<!--                          item-value="id"></v-select>-->
              <div v-if="item.parameterTypeId === 3">
                <v-select attach v-model="item.processStepId"
                          :items="parentObjects"
                          label="Parent Object"
                          item-text="processStepName"
                          item-value="id"
                          @input="loadFieldsByParent(item.processStepId, item.dataTypeId)"
                ></v-select>
                <v-select attach v-if="item.processStepId"
                          v-model="item.customFieldGroupAssignmentId"
                          :items="availableCustomFields"
                          label="Custom Field"
                          item-text="fieldName"
                          item-value="customFieldGroupAssignmentId"
                ></v-select>
              </div>
              <v-btn @click="saveParam(item)">
                <v-icon>save</v-icon>
                Save
              </v-btn>
            </td>
          </template>


          <template #item="{ item }">
            <tr  class="text-left" :class="{'shaded-row': details.companyFunctionParams.indexOf(item) % 2}">
              <td class="text-left">{{ item.parameterName }}</td>
              <!-- customTypeColumn -->
              <td class="text-left" v-if="item.parameterTypeId === 3">
                {{ item.processStepName || 'Custom Field'}}
              </td>
              <td class="text-left" v-else-if="item.parameterTypeId === 1">
                System
              </td>
              <td class="text-left" v-else-if="item.parameterTypeId === 2">
                Dynamic
              </td>
              <!-- customValueColumn -->
              <td class="text-left" v-if="item.customFieldGroupAssignmentId !== null">
                {{item.fieldName}}
              </td>
              <td class="text-left" v-else-if="item.systemValueId !== null">
                {{item.systemValue}}
              </td>
              <td class="text-left" v-else-if="item.dynamicValue !== null">
                {{item.dynamicValue}}
              </td>
              <td class="text-left" v-else-if="item.customFieldGroupAssignmentId === null && item.systemValueId === null && item.dynamicValue === null">
                n/a
              </td>
              <!-- icon column -->
              <td>
                <v-btn text color="primary" v-if="userCanEdit && item.parameterTypeId === 3 && !expanded.includes(item)" @click="handleExpand(item, true)">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn text v-if="item.parameterTypeId === 3 && expanded.includes(item)" @click="handleExpand(item, false)">cancel</v-btn>
              </td>
            </tr>
          </template>

          <template #item.customTypeColumn="{ item }">

          </template>
          <template #item.customValueColumn="{ item }">
            <span v-if="item.customFieldGroupAssignmentId !== null">{{item.fieldName}}</span>
            <span v-else-if="item.systemValueId !== null">{{item.systemValue}}</span>
            <span v-else-if="item.dynamicValue !== null">{{item.dynamicValue}}</span>
            <span v-else-if="item.customFieldGroupAssignmentId === null && item.systemValueId === null && item.dynamicValue === null">n/a</span>
          </template>
        </v-data-table>


      </v-col>
    </v-row>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import { handleHidingGlobalLoader, getRequest, postRequest, getSnackbar } from '@/helpers/helpers'


  export default {
    name: 'ProcessSteps',
    mixins: [Vue2Filters.mixin],

    data () {
      return {
        headers: [
          { text: 'Parameter Name', value: 'parameterName', show: true },
          { text: 'Type', value: 'customTypeColumn', show: true },
          { text: 'Value', value: 'customValueColumn', show: true},
          { text: null, value: 'icons', show: true }
        ],
        breadcrumbs: [
          {
            text: 'Back',
            disabled: false,
            exact: true,
            to: `/settings/functions`
          },
        ],
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
        companyId: this.$store.state.user.details.companyId,
        functionId: this.$route.params.id,
        userId: this.$store.state.user.details.id,
        systemValues: [],
        details: {},
        snackbar: {},
        parentObjects: [],
        availableCustomFields: [],
        selectedField: {},
        expanded: [],
      }
    },
    computed: {
    },
    methods: {
      async getFunctionDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/function/${this.functionId}`)
          this.details = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },

      async loadParentObjects () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/processStep/getParentObjects`)
          this.parentObjects = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async loadFieldsByParent(id, dataTypeId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/customField/getByParentProcessStep/${id}`)
          this.availableCustomFields = data.filter(d => {
            return d.dataTypeId === dataTypeId
          })
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async handleExpand (item, expand) {
        if(expand) {
          this.expanded = [item]
          if(item.processStepId) {
            this.loadFieldsByParent(item.processStepId)
          }
        } else {
          this.expanded = []
        }
      },
      async saveParam (item) {

        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {data, status} = await postRequest(`/function/${this.functionId}/param`, item)
          if(item.parameterTypeId === 3) {
            item.fieldName = data.fieldName
            item.processStepName = data.processStepName
          }
          this.expanded = []
          handleHidingGlobalLoader(this, status)
          this.snackbar = getSnackbar('SUCCESS', 'Parameter Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } catch (e) {
          this.$store.commit(AppMutations.SET_LOADING, false)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Parameter')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }

      }
    },
    async created () {
      this.getFunctionDetails()
      this.loadParentObjects()
    }
  }
</script>

<style scoped lang="scss">
.testing {
  margin-bottom: 2px;
}
</style>
