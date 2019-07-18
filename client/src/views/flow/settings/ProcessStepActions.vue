<template>
  <v-layout row wrap>
    <v-flex xs-12>
      <h3>Requirements</h3>
      <v-btn @click="addNewRequirement = !addNewRequirement">
        <v-icon v-if="!addNewRequirement">add</v-icon>
        {{ addNewRequirement ? 'Cancel' : 'Add Requirement'}}
      </v-btn>
      <v-select v-if="addNewRequirement"
                v-model="newRequirement.id"
                :items="availableRequirements"
                label="Select Requirement"
                item-text="requirement"
                item-value="id"
                @input="assignNewRequirement"
      ></v-select>
      <v-container>
        <v-list v-for="(r, index) in filterBy(requirements, false, 'archived')"
                :key="index">
          <v-list-item>
            <v-list-item-content>
              {{r.requirement}}
            </v-list-item-content>
            <v-dialog
                v-model="r.deleteConfirm"
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
                  Are you sure you want to delete this requirement: <strong>{{ r.requirement }}</strong>?
                </v-card-text>

                <v-divider></v-divider>

                <v-card-actions>
                  <v-spacer></v-spacer>
                  <v-btn
                      @click="r.deleteConfirm = false">
                    No
                  </v-btn>
                  <v-btn
                      color="primary"
                      text
                      @click="r.archived = true; deleteRequirement(r.id)">
                    Yes
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-list-item>
        </v-list>
      </v-container>
    </v-flex>
    <v-divider></v-divider>
    <v-flex xs-12>
      <h3>Actions</h3>
      <v-btn @click="addNewAction = !addNewAction">
        <v-icon v-if="!addNewAction">add</v-icon>
        {{ addNewAction ? 'Cancel' : 'Add Action'}}
      </v-btn>
      <v-select v-if="addNewAction"
                v-model="newAction.id"
                :items="availableActions"
                label="Select Action"
                item-text="action"
                item-value="id"
                @input="assignNewAction"
      ></v-select>
      <v-container>
        <v-list v-for="(a, index) in filterBy(actions, false, 'archived')"
                :key="index">
          <v-list-item>
            <v-list-item-content>
              {{a.action}}
            </v-list-item-content>
            <v-dialog
                v-model="a.deleteConfirm"
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
                  Are you sure you want to delete this action: <strong>{{ a.action }}</strong>?
                </v-card-text>

                <v-divider></v-divider>

                <v-card-actions>
                  <v-spacer></v-spacer>
                  <v-btn
                      @click="a.deleteConfirm = false">
                    No
                  </v-btn>
                  <v-btn
                      color="primary"
                      text
                      @click="a.archived = true; deleteAction(a.id)">
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
  import Vue2Filters from 'vue2-filters'

  export default {
    name: 'ProcessStepActions',
    mixins: [Vue2Filters.mixin],
    components: {},
    data () {
      return {
        addNewRequirement: false,
        newRequirement: {},
        availableRequirements: [],
        requirements: [],
        addNewAction: false,
        newAction: {},
        availableActions: [],
        actions: [],
      }
    },
    computed: {
    },
    async created () {
      this.getRequirements()
      this.getActions()
    },
    methods: {
      async getRequirements () {
        console.log('LOAD REQUIREMENTS HERE')
        // const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/processStep/${this.processStepId}`)
        // this.requirements = data
      },
      async getActions () {
        console.log('LOAD ACTIONS HERE')
        // const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/processStep/${this.processStepId}`)
        // this.actions = data
      },
      async assignNewRequirement() {
        console.log('ASSIGN REQUIREMENT HERE')
      },
      async deleteRequirement(id) {
        console.log('DELETE REQUIREMENT HERE', id)
      },
      async assignNewAction() {
        console.log('ASSIGN ACTION HERE')
      },
      async deleteAction(id) {
        console.log('DELETE ACTION HERE', id)
      }
    }

  }
</script>

<style scoped lang="scss">
</style>
