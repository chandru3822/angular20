<template>
  <v-layout row wrap class="custom-field-group-container">
    <v-flex xs-12>
      <v-toolbar class="testing elevation-1">
        <v-toolbar-title class="app-title">{{ details.companyFunctionName }}</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-btn @click="saveParams">
          Save Changes
        </v-btn>
      </v-toolbar>
      <v-container>
        <v-list v-for="(cfp, index) in details.companyFunctionParams"
                :key="index">
          <v-list-item class="grab" :class="{ 'shaded-row': index % 2 }">
            <v-list-item-content>
              {{cfp.parameterName}}
              <v-container v-if="cfp.isDefaultValue">
                <v-text-field v-model="cfp.defaultValue"
                              placeholder="Enter a value"
                              label="Value">
                </v-text-field>
              </v-container>
              <v-container v-else-if="cfp.isSystemValue">
                {{ cfp.systemValueId }} hello
                <v-select v-model="cfp.systemValueId"
                          :items="systemValues"
                          label="System Value"
                          item-text="systemValue"
                          item-value="id"></v-select>
              </v-container>
              <v-container v-else>
                we are for custom field values
              </v-container>

            </v-list-item-content>
<!--            <v-list-item-action class="clickable">-->
<!--              <v-icon @click="selectedParamId = cfp.dbFunctionParamId">edit</v-icon>-->
<!--            </v-list-item-action>-->
          </v-list-item>

        </v-list>
      </v-container>
      <Snackbar :snackbar="snackbar"></Snackbar>
    </v-flex>
  </v-layout>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import { getRequest, deleteRequest, putRequest, postRequest } from '@/helpers/helpers'
  import Snackbar from '@/components/Snackbar.vue'
  import { SNACKBAR_SUCCESS, SNACKBAR_ERROR } from '@/helpers/helpers'

  export default {
    name: 'ProcessSteps',
    mixins: [Vue2Filters.mixin],
    components: {
      Snackbar
    },
    data () {
      return {
        companyId: this.$store.state.user.details.companyId,
        functionId: this.$route.params.id,
        userId: this.$store.state.user.details.id,
        systemValues: [],
        details: {},
        snackbar: {},
      }
    },
    computed: {
    },
    methods: {
      async getFunctionDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/function/${this.functionId}`)
        this.details = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      async getSystemValues () {
        const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/function/systemValues`)
        this.systemValues = data
      },
      async saveParams () {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          await postRequest(`/api/v1/flow/companies/${this.companyId}/function/${this.functionId}/params`, this.details.companyFunctionParams)
          this.$store.commit(AppMutations.SET_LOADING, false)
          this.snackbar = SNACKBAR_SUCCESS
          this.snackbar.text = 'Successfully Updated Parameters'
          this.snackbar.enabled = true
        } catch (e) {
          this.$store.commit(AppMutations.SET_LOADING, false)
          this.snackbar = SNACKBAR_ERROR
          this.snackbar.text = 'Error Saving Updates'
          this.snackbar.enabled = true
        }

      }
    },
    async created () {
      this.getFunctionDetails()
      this.getSystemValues()
    }
  }
</script>

<style scoped lang="scss">


</style>
