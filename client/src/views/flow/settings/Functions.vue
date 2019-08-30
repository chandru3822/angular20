<template>
  <v-layout row wrap class="custom-field-group-container">
    <v-flex xs-12>
      <v-toolbar class="testing elevation-1">
        <v-toolbar-title class="app-title">Functions</v-toolbar-title>
      </v-toolbar>
      <v-container>
        <v-list v-for="(f, index) in filterBy(functions, false, 'archived')"
                :key="index">
          <v-list-item :class="{'shaded-row': index % 2}">
            <v-list-item-content>
              {{f.companyFunctionName}}
            </v-list-item-content>
            <v-list-item-action class="clickable">
              <v-btn :to="{ path: `/settings/function/${f.id}`}" text>
                <v-icon>edit</v-icon>
              </v-btn>
            </v-list-item-action>
            <v-dialog
                v-model="f.deleteConfirm"
                width="500">
              <template v-slot:activator="{ on }">
                <v-list-item-action class="clickable" v-on="on">
                  <v-icon>delete</v-icon>
                </v-list-item-action>
              </template>
              <v-card>
                <v-card-title
                    class="headline grey lighten-2"
                    primary-title
                >
                  Confirm
                </v-card-title>

                <v-card-text>
                  Are you sure you want to delete this function: <strong>{{ f.companyFunctionName }}</strong>?
                </v-card-text>

                <v-divider></v-divider>

                <v-card-actions>
                  <v-spacer></v-spacer>
                  <v-btn
                      @click="f.deleteConfirm = false">
                    No
                  </v-btn>
                  <v-btn
                      color="primary"
                      text
                      @click="f.archived = true; deleteFunction(f.id)">
                    Yes
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-list-item>
        </v-list>
      </v-container>
    </v-flex>
  </v-layout>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import { getRequest, deleteRequest, putRequest, postRequest } from '@/helpers/helpers'

  export default {
    name: 'ProcessSteps',
    mixins: [Vue2Filters.mixin],
    data () {
      return {
        companyId: this.$store.state.user.details.companyId,
        userId: this.$store.state.user.details.id,
        functions: []
      }
    },
    computed: {
    },
    methods: {
      async getFunctions () {
        const {data} = await getRequest(`/api/v1/flow/${this.companyId}/function`)
        this.functions = data
      },
      async deleteFunction (functionId) {
        console.log('will delete here')
        // await deleteRequest(`/api/v1/flow/${this.companyId}/processStep/${processStepId}`)
      }
    },
    async created () {
      this.getFunctions()
    }
  }
</script>

<style scoped lang="scss">


</style>
