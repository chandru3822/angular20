<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Functions</v-toolbar-title>
        </v-toolbar>
        <v-container>
          <v-list v-for="(f, index) in filterBy(functions, false, 'archived')"
                  :key="index"  class="pa-0">
            <v-list-item :class="{'shaded-row': index % 2}">
              <v-list-item-content>
                {{f.companyFunctionName}}
              </v-list-item-content>
              <v-list-item-action class="clickable">
                <v-btn :to="{ path: `/settings/function/${f.id}`}" text>
                  <v-icon>edit</v-icon>
                </v-btn>
              </v-list-item-action>
            </v-list-item>
          </v-list>
        </v-container>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import { handleHidingGlobalLoader, getRequest, getSnackbar } from '@/helpers/helpers'

  export default {
    name: 'ProcessSteps',
    mixins: [Vue2Filters.mixin],

    data () {
      return {
        snackbar: {},
        companyId: this.$store.state.user.details.companyId,
        userId: this.$store.state.user.details.id,
        functions: []
      }
    },
    computed: {
    },
    methods: {
      async getFunctions () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/function`)
          this.functions = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteFunction (functionId) {
        // await deleteRequest(`/processStep/${processStepId}`)
      }
    },
    async created () {
      this.getFunctions()
    }
  }
</script>

<style scoped lang="scss">


</style>
