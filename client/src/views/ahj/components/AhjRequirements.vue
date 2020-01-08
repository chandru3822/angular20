<!-- suppress CssInvalidPseudoSelector -->
<template id="ahj-requirements">
  <v-card>
    <v-toolbar class="primaryCustom">
      <v-toolbar-title class="white--text font-weight-bold" :title="title">
        {{title}}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-btn icon color="#ddd" style="border-radius: 3px">
        <v-icon v-show="!addMode && !editMode"
                @click="addRequirement" class="white--text">add</v-icon>
        <v-icon v-show="addMode || editMode"
                @click="hideCtrls" class="white--text">remove</v-icon>
      </v-btn>
    </v-toolbar>
    <form class="requirement-edit-ctrls px-3"
          ref="requirementForm" v-show="addMode || editMode">
      <v-textarea required label="Requirement Details" auto-grow filled
                  style="margin: 15px 0 -15px 0"
                  v-model="requirement.description">
      </v-textarea>
      <v-text-field required label="Display Order" filled
                    type="number"
                    v-model="requirement.position">
      </v-text-field>
      <div class="requirement-btns">
        <a @click="hideCtrls"
           class="cancel-link">Cancel</a>
        <v-btn @click="saveRequirement(null)" color="primaryButton" class="white--text py-1 px-2"
               :disabled="(!requirement.description || requirement.description === '') || (!requirement.position || parseInt(requirement.position) <= 0)" small>
          {{ addMode ? 'Add' : 'Update' }}
        </v-btn>
      </div>
    </form>
    <v-list v-for="requirement in requirementsCopy"
            :key="requirement.id">
      <v-list-item v-show="requirementsCopy.length > 0">
        <v-list-item-action :title="requirement.complete ? 'Mark requirement as incomplete' : 'Mark requirement as complete'"
                            @click="saveRequirement(requirement)">
          <v-checkbox v-model="requirement.complete"></v-checkbox>
        </v-list-item-action>
        <v-list-item-content class="ml-3">
          <v-list-item-title :style="{'text-decoration': requirement.complete ? 'line-through' : ''}">
            <span>{{ requirement.description }}</span>
          </v-list-item-title>
          <v-list-item-subtitle v-if="!requirement.formattedDateModified && requirement.formattedDateCreated"
                                v-text="'Created ' + requirement.formattedDateCreated + ' by ' + requirement.createdBy">
          </v-list-item-subtitle>
          <v-list-item-subtitle v-if="requirement.formattedDateModified"
                                v-text="'Updated ' + requirement.formattedDateModified + ' by ' + requirement.modifiedBy">
          </v-list-item-subtitle>
        </v-list-item-content>
        <v-list-item-action>
          <v-icon small class="mr-3" @click="editRequirement(requirement)" title="Edit requirement">edit</v-icon>
        </v-list-item-action>
        <v-list-item-action>
          <v-icon small @click="archiveRequirement(requirement.id)" title="Archive requirement">delete</v-icon>
        </v-list-item-action>
      </v-list-item>
    </v-list>
    <div class="empty-list"
         v-show="requirementsCopy.length < 1">
      No AHJ-specific installation requirements found
    </div>

    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-card>
</template>

<script>
  import moment from 'moment'
  import cloneDeep from 'lodash.clonedeep'
  import orderBy from 'lodash.orderby'
  import { putRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import Snackbar from '@/components/Snackbar'
  import { AppMutations } from '@/stores/AppStore'

  export default {
    name: "AhjRequirements",
    components: {
      Snackbar
    },
    props: {
      title: {
        type: String
      },
      requirementTypeId: {
        type: Number
      },
      itemType: {
        type: String
      },
      ahjId: {
        type: Number
      },
      requirements: {
        type: Array,
        default: () => []
      }
    },
    data () {
      return {
        requirement: {
          id: null,
          requirementTypeId: this.requirementTypeId,
          description: null,
          position: null,
          archived: null,
          complete: null
        },
        addMode: false,
        editMode: false,
        snackbar: {},
        requirementsCopy: orderBy(this.requirements, requirement => requirement.position)
      }
    },
    methods: {
      hideCtrls() {
        this.addMode = false
        this.editMode = false
      },
      addRequirement() {
        this.editMode = false
        this.addMode = true
        this.requirement.description = ''
        this.requirement.position = null
      },
      editRequirement(requirement) {
        this.addMode = false
        this.editMode = true
        this.requirement = Object.assign({}, requirement)
      },
      async saveRequirement(requirement) {
        if (!requirement) {
          this.requirement.requirementTypeId = this.requirementTypeId
          this.requirement.archived = this.requirement.archived ? this.requirement.archived : false
          this.requirement.complete = this.requirement.complete ? this.requirement.complete : false
          this.requirement.position = parseInt(this.requirement.position)
        } else {
          this.requirement = Object.assign({}, requirement)
        }

        // runs when user clicks a checkbox next to a requirement
        if (!this.addMode && !this.editMode) {
          this.requirement.complete = this.requirement.complete ? this.requirement.complete : false

          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {data} = await putRequest(`/ahj/${this.ahjId}/${this.itemType}/requirement/${this.requirement.id}`, this.requirement, 'blueraven')
            let updatedRequirementIndex = this.requirementsCopy.findIndex(i => i.id === data.originalRequirementId)
            this.requirementsCopy[updatedRequirementIndex].formattedDateModified = moment(data.dateModifed).format('MM/DD/YY h:mm A')
            this.snackbar = getSnackbar('SUCCESS', 'AHJ Specific Installation Requirement completion status updated')
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Saving AHJ Specific Installation Requirement')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        // runs when user clicks Add button
        } else if (this.addMode) {
          const {data} = await postRequest(`/ahj/${this.ahjId}/${this.itemType}/requirement`, this.requirement, 'blueraven')
          this.requirementsCopy.push(cloneDeep(data))
          let addedRequirementIndex = this.requirementsCopy.findIndex(i => i.id === data.id)
          this.requirementsCopy[addedRequirementIndex].formattedDateCreated = moment(data.dateCreated).format('MM/DD/YY h:mm A')
          this.addMode = false
        // runs when user clicks Update button
        } else {
          const {data} = await putRequest(`/ahj/${this.ahjId}/${this.itemType}/requirement/${this.requirement.id}`, this.requirement, 'blueraven')
          let updatedRequirementIndex = this.requirementsCopy.findIndex(i => i.id === data.originalRequirementId)
          this.requirementsCopy[updatedRequirementIndex].description = data.description
          this.editMode = false
        }
        this.requirementsCopy = orderBy(this.requirementsCopy, requirement => requirement.position)
      },
      async archiveRequirement(requirementId) {
        await putRequest(`/ahj/${this.itemType}/requirement/${requirementId}/archive`, null, 'blueraven')
        let archivedRequirementIndex = this.requirementsCopy.findIndex(i => i.id === requirementId)
        this.requirementsCopy.splice([archivedRequirementIndex], 1)
        this.editMode = false
      }
    }
  }
</script>

<style scoped lang="scss">
  .cancel-link,
  .requirement {
    font-size: 0.85em !important;
    text-decoration: none;
  }
  .cancel-link:hover {
    text-decoration: underline;
  }
  .v-card__title,
  .v-toolbar__title {
    font-size: 1em !important;
  }
  .v-text-field,
  .v-input ::v-deep label {
    font-size: 0.95em !important;
  }
  .v-list-item__action {
    margin: 0 !important;
    max-width: 24px;
  }
  .v-list-item__title {
    font-size: 0.95em !important;
    max-width: 525px;
  }
  .requirement-btns {
    display: flex;
    flex-flow: row nowrap;
    justify-content: flex-end;
    align-items: center;
    button {
      margin: 0 0 0 7px;
    }
  }
  .empty-list {
    padding: 20px;
    font-size: 0.85em;
  }
</style>
