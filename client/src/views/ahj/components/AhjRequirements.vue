<!-- suppress CssInvalidPseudoSelector -->
<template id="ahj-requirements">
  <div>
    <div id="transparent-header" v-if="transparent">
      <div class="requirement-header-bar px-4 pb-2 font-weight-bold">
        <span>{{title}}</span>
        <v-btn class="add-hide-btn" icon>
          <v-icon v-show="!addMode && !editMode"
                  @click="addRequirement">add</v-icon>
          <v-icon v-show="addMode || editMode"
                  @click="hideCtrls">remove</v-icon>
        </v-btn>
      </div>

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
          <v-btn @click="saveRequirement(null, false)" color="primaryButton" class="white--text py-1 px-2"
                 :disabled="(!requirement.description || requirement.description === '') || (!requirement.position || parseInt(requirement.position) <= 0)" small>
            {{ addMode ? 'Add' : 'Update' }}
          </v-btn>
        </div>
      </form>

      <v-list class="mt-0"
              v-for="requirement in requirementsCopy"
              :key="requirement.id">
        <v-list-item v-show="requirementsCopy.length > 0">
          <v-list-item-action :title="requirement.complete ? 'Mark requirement as incomplete' : 'Mark requirement as complete'"
                              @click="saveRequirement(requirement, true)">
            <v-checkbox v-model="requirement.complete"></v-checkbox>
          </v-list-item-action>
          <v-list-item-content class="ml-3">
            <v-list-item-title :style="{'text-decoration': requirement.complete ? 'line-through' : ''}"
                               :title="requirement.description">
              <span>{{ requirement.description }}</span>
            </v-list-item-title>
            <v-list-item-subtitle v-if="!requirement.formattedDateModified && requirement.formattedDateCreated"
                                  v-text="'Created ' + requirement.formattedDateCreated + ' by ' + requirement.createdBy">
            </v-list-item-subtitle>
            <v-list-item-subtitle v-if="requirement.formattedDateModified"
                                  v-text="'Updated ' + requirement.formattedDateModified + ' by ' + requirement.modifiedBy">
            </v-list-item-subtitle>
          </v-list-item-content>
          <v-list-item-content class="ml-4 flex-display requirement-history-tags mr-3">
            <span v-if="requirement.hasOpenChallenge">
              Active Challenge
            </span>
            <AhjRequirementHistory :class="[{'history-link-max-width': requirement.hasOpenChallenge}]"
                                   :itemType="itemType"
                                   :ahjId="ahjId"
                                   :requirement="requirement"
            ></AhjRequirementHistory>
          </v-list-item-content>
          <v-list-item-action v-if="!requirement.hasOpenChallenge">
            <v-icon small @click="editRequirement(requirement)" title="Edit requirement">edit</v-icon>
          </v-list-item-action>
          <v-list-item-action>
            <AhjDocumentsButton title="Notes and requirements"
                                :documentTypeId="12"
                                :sourceId="requirement.id"
                                :ahjId="ahjId"
                                :small="true"
            ></AhjDocumentsButton>
          </v-list-item-action>
          <v-list-item-action>
            <v-icon small @click="archiveRequirement(requirement.originalRequirementId)" title="Archive requirement">delete</v-icon>
          </v-list-item-action>
        </v-list-item>
      </v-list>
      <div class="empty-list mx-3 mt-2" v-show="requirementsCopy.length < 1">
        No requirements found
      </div>

      <Snackbar :snackbar="snackbar"></Snackbar>
    </div>

    <v-card v-if="!transparent">
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
          <v-btn @click="saveRequirement(null, false)" color="primaryButton" class="white--text py-1 px-2"
                 :disabled="(!requirement.description || requirement.description === '') || (!requirement.position || parseInt(requirement.position) <= 0)" small>
            {{ addMode ? 'Add' : 'Update' }}
          </v-btn>
        </div>
      </form>
      <v-list v-for="requirement in requirementsCopy"
              :key="requirement.id">
        <v-list-item v-show="requirementsCopy.length > 0">
          <v-list-item-action :title="requirement.complete ? 'Mark requirement as incomplete' : 'Mark requirement as complete'"
                              @click="saveRequirement(requirement, true)">
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
            <v-icon small @click="archiveRequirement(requirement.originalRequirementId)" title="Archive requirement">delete</v-icon>
          </v-list-item-action>
        </v-list-item>
      </v-list>
      <div class="empty-list" v-show="requirementsCopy.length < 1">
        No requirements found
      </div>

      <Snackbar :snackbar="snackbar"></Snackbar>
    </v-card>
  </div>
</template>

<script>
  import moment from 'moment'
  import cloneDeep from 'lodash.clonedeep'
  import orderBy from 'lodash.orderby'
  import AhjDocumentsButton from './AhjDocumentsButton'
  import AhjRequirementHistory from './AhjRequirementHistory'
  import Snackbar from '@/components/Snackbar'
  import { AppMutations } from '@/stores/AppStore'
  import { getRequest, putRequest, postRequest, getSnackbar } from '@/helpers/helpers'

  export default {
    name: "AhjRequirements",
    components: {
      AhjDocumentsButton,
      AhjRequirementHistory,
      Snackbar
    },
    props: {
      title: {
        type: String
      },
      transparent: {
        type: Boolean
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
      async saveRequirement(requirement, checkboxWasClicked) {
        if (!requirement) {
          this.requirement.requirementTypeId = this.requirementTypeId
          this.requirement.complete = this.requirement.complete ? this.requirement.complete : false
          this.requirement.position = parseInt(this.requirement.position)
        } else {
          this.requirement = Object.assign({}, requirement)
        }

        // runs when user clicks a checkbox next to a requirement
        if (checkboxWasClicked) {
          this.requirement.complete = this.requirement.complete ? this.requirement.complete : false

          try {
            this.$store.commit(AppMutations.SET_LOADING, true)
            const {data} = await putRequest(`/ahj/${this.ahjId}/${this.itemType}/requirement/${this.requirement.id}`, this.requirement, 'blueraven')
            let updatedRequirementIndex = this.requirementsCopy.findIndex(i => i.id === data.originalRequirementId)
            this.requirementsCopy[updatedRequirementIndex].formattedDateModified = moment(data.dateModifed).format('MM/DD/YY h:mm A')

            this.snackbar = getSnackbar('SUCCESS', 'Requirement completion status updated')
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error updating requirement completion status')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }

        // runs when user clicks Add button
        } else if (this.addMode) {
          try {
            this.$store.commit(AppMutations.SET_LOADING, true)
            const {data} = await postRequest(`/ahj/${this.ahjId}/${this.itemType}/requirement`, this.requirement, 'blueraven')
            this.requirementsCopy.push(cloneDeep(data))
            let addedRequirementIndex = this.requirementsCopy.findIndex(i => i.id === data.id)
            this.requirementsCopy[addedRequirementIndex].formattedDateCreated = moment(data.dateCreated).format('MM/DD/YY h:mm A')

            this.addMode = false
            this.snackbar = getSnackbar('SUCCESS', 'Requirement added')
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error adding requirement')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }

        // runs when user clicks Update button
        } else {
          try {
            this.$store.commit(AppMutations.SET_LOADING, true)
            const {data} = await putRequest(`/ahj/${this.ahjId}/${this.itemType}/requirement/${this.requirement.id}`, this.requirement, 'blueraven')
            let updatedRequirementIndex = this.requirementsCopy.findIndex(i => i.originalRequirementId === data.originalRequirementId)
            this.requirementsCopy[updatedRequirementIndex].description = data.description

            if (data.dateModified) {
              this.requirementsCopy[updatedRequirementIndex].formattedDateModified = moment(data.dateModified).format('MM/DD/YY h:mm A')
            } else {
              this.requirementsCopy[updatedRequirementIndex].formattedDateCreated = moment(data.dateCreated).format('MM/DD/YY h:mm A')
            }

            this.editMode = false
            this.snackbar = getSnackbar('SUCCESS', 'Requirement updated')
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error updating requirement')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }

        this.requirementsCopy = orderBy(this.requirementsCopy, requirement => requirement.position)
      },
      async archiveRequirement(originalRequirementId) {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          await putRequest(`/ahj/${this.itemType}/requirement/${originalRequirementId}/archive`, null, 'blueraven')
          let archivedRequirementIndex = this.requirementsCopy.findIndex(i => i.originalRequirementId === originalRequirementId)
          this.requirementsCopy.splice([archivedRequirementIndex], 1)

          this.editMode = false
          this.snackbar = getSnackbar('SUCCESS', 'Requirement archived')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error archiving requirement')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    created() {
      if (this.requirementsCopy.length > 0) {
        this.requirementsCopy.forEach(requirement => {
          if (requirement.dateCreated && requirement.createdBy) {
            requirement.formattedDateCreated = moment(requirement.dateCreated).format('MM/DD/YY h:mm A')
          }

          if (requirement.dateModified && requirement.modifiedBy) {
            requirement.formattedDateModified = moment(requirement.dateModified).format('MM/DD/YY h:mm A')
          }
        })
      }
    }
  }
</script>

<style scoped lang="scss">
  .requirement,
  .cancel-link {
    font-size: 0.85em !important;
    text-decoration: none;
  }
  .history-link {
    text-decoration: none;
    color: var(--v-primaryText-base) !important;
  }
  .cancel-link:hover,
  .history-link:hover {
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
  .v-input--checkbox {
    display: flex;
    align-items: center;
  }
  .v-list-item__action {
    margin: 0 !important;
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

  .requirement-history-tags {
    text-align: right;
    max-width: 40%;
    span {
      color: #d00;
      margin-bottom: 0;
      max-width: 67%;
    }
    .history-link-max-width {
      max-width: 28%;
    }
  }
  @media (min-width: 1400px) {
    .requirement-history-tags {
      max-width: 30%;
    }
  }
  @media (min-width: 1575px) {
    .requirement-history-tags {
      max-width: 25%;
    }
  }

  .close-modal-x {
    font-size: 20px;
    &:hover {
      font-weight: bolder;
    }
  }
  #requirement-status-table {
    tr:hover {
      background-color: initial;
    }
  }
  #requirement-status-btns {
    margin-top: -20px;
  }

  .v-data-table__wrapper {
    th {
      font-size: 1em;
    }
    td {
      color: rgba(0, 0, 0, 0.54);

      a:hover {
        text-decoration: underline;
      }
    }
  }

  #transparent-header {
    .requirement-header-bar {
      display: flex;
      flex-flow: row nowrap;
      justify-content: space-between;
      align-items: center;
      font-size: 1em;
      color: var(--v-primaryText-base);
      border-bottom: 1px solid var(--v-primaryText-base);
    }

    .add-hide-btn,
    .empty-list {
      background-color: var(--v-secondary-base);
      border-radius: 3px;
    }
  }
</style>
