<!-- suppress CssInvalidPseudoSelector -->
<template id="ahj-requirements">
  <div>
    <div id="transparent-header" v-if="transparent">
      <div class="requirement-header-bar px-4 pb-2 font-weight-bold">
        <span>{{title}}</span>
        <v-btn class="add-hide-btn" icon v-if="userCanEdit">
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
          <v-btn color="primary" text @click="hideCtrls"
             class="cancel-link">Cancel</v-btn>
          <v-btn v-if="userCanEdit" @click="saveRequirement(null, false)" color="primary" class="white--text py-1 px-2"
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
                              :class="{'disabled-checkbox': requirement.hasOpenChallenge}"
                              v-if="userCanEdit"
                              @click="saveRequirement(requirement, true)">
            <v-checkbox v-model="requirement.complete" :disabled="requirement.hasOpenChallenge || !userCanEdit"></v-checkbox>
          </v-list-item-action>
          <v-list-item-content class="ml-3">
            <v-list-item-title :style="{'text-decoration': requirement.complete ? 'line-through' : ''}"
                               :title="requirement.description">
              <span>{{ requirement.description }}</span>
            </v-list-item-title>
            <v-list-item-subtitle v-if="!requirement.formattedDateModified && requirement.formattedDateCreated"
                                  :title="'Created ' + requirement.formattedDateCreated + ' by ' + requirement.createdBy"
                                  v-text="'Created ' + requirement.formattedDateCreated + ' by ' + requirement.createdBy">
            </v-list-item-subtitle>
            <v-list-item-subtitle v-if="requirement.formattedDateModified"
                                  :title="'Updated ' + requirement.formattedDateModified + ' by ' + requirement.modifiedBy"
                                  v-text="'Updated ' + requirement.formattedDateModified + ' by ' + requirement.modifiedBy">
            </v-list-item-subtitle>
          </v-list-item-content>
          <v-list-item-content class="ml-4 flex-display flex-wrap text-right mr-3">
            <span v-if="requirement.hasOpenChallenge" style="color: #d00">
              Active Challenge
            </span>
            <AhjRequirementHistory :itemType="itemType"
                                   :itemId="itemId"
                                   :originalRequirement="requirement"
            ></AhjRequirementHistory>
          </v-list-item-content>
          <v-list-item-action>
            <v-icon v-if="!requirement.hasOpenChallenge"
                    @click="editRequirement(requirement)"
                    title="Edit requirement" small>
              edit
            </v-icon>
            <div v-if="requirement.hasOpenChallenge" class="icon-placeholder" style="width: 20px; height: 20px"></div>
          </v-list-item-action>
          <v-list-item-action>
            <AhjDocumentsButton title="Notes and requirements"
                                :documentTypeId="12"
                                :sourceId="requirement.id"
                                :itemId="itemId"
                                :small="true"
            ></AhjDocumentsButton>
          </v-list-item-action>
          <v-list-item-action>
            <v-dialog v-model="requirement.deleteConfirm" max-width="500px">
              <template #activator="{ on }">
                <v-icon v-on="on" small title="Archive requirement">delete</v-icon>
              </template>
              <v-card>
                <v-card-title>
                  <span class="text-h5">Confirm</span>
                </v-card-title>
                <v-card-text>
                  Are you sure you want to archive this requirement?<br>
                  <strong>{{ requirement.description }}</strong>
                </v-card-text>
                <v-card-actions>
                  <v-spacer></v-spacer>
                  <v-btn color="secondaryButton" text @click="requirement.deleteConfirm = false">No</v-btn>
                  <v-btn color="brRed" class="white--text"
                         @click="[archiveRequirement(requirement.originalRequirementId), requirement.deleteConfirm = false]">Yes</v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-list-item-action>
        </v-list-item>
      </v-list>
      <div class="empty-list mx-3 mt-3" v-show="requirementsCopy.length < 1">
        No requirements found
      </div>
    </div>

    <v-card v-if="!transparent">
      <v-toolbar class="primary">
        <v-toolbar-title class="white--text font-weight-bold" :title="title">
          {{title}}
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-btn icon color="primary" style="border-radius: 3px">
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
          <v-btn @click="saveRequirement(null, false)" color="primary" class="white--text py-1 px-2"
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
            <v-list-item-title :style="[{'text-decoration': requirement.complete ? 'line-through' : ''},
                                        {'font-size': isNested ? '0.95em !important' : '0.85em !important'}]">
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
      <div class="empty-list" v-show="requirementsCopy.length < 1"
           :style="{'font-size': isNested ? '0.95em !important' : '0.85em !important'}">
        No requirements found
      </div>


    </v-card>
  </div>
</template>

<script>
  import moment from 'moment'
  import cloneDeep from 'lodash.clonedeep'
  import orderBy from 'lodash.orderby'
  import AhjDocumentsButton from './AhjDocumentsButton'
  import AhjRequirementHistory from './AhjRequirementHistory'

  import { AppMutations } from '@/stores/AppStore'
  import { putRequest, postRequest, getSnackbar } from '@/helpers/helpers'

  export default {
    name: "AhjRequirements",
    components: {
      AhjDocumentsButton,
      AhjRequirementHistory,
    },
    props: {
      title: {
        type: String
      },
      userCanEdit: {
        type: Boolean
      },
      requirementTypeId: {
        type: Number
      },
      itemType: {
        type: String
      },
      itemId: {
        type: Number
      },
      requirements: {
        type: Array,
        default: () => []
      },
      transparent: {
        type: Boolean,
        default: false
      },
      isNested: {
        type: Boolean,
        default: false
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
          complete: null,
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
        // prevents user from marking a requirement with the "Open Challenge" status as complete
        if (checkboxWasClicked) {
          if ((requirement && requirement.hasOpenChallenge) || this.requirement.hasOpenChallenge) {
            return
          }
        }

        this.$store.commit(AppMutations.SET_LOADING, true)

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
          this.requirement.archived = false

          try {
            const {data} = await putRequest(`/ahj/${this.itemId}/${this.itemType}/requirement/${this.requirement.id}`, this.requirement, 'blueraven')
            let updatedRequirementIndex = this.requirementsCopy.findIndex(i => i.originalRequirementId === data.originalRequirementId)

            if (updatedRequirementIndex !== -1) {
              this.requirementsCopy[updatedRequirementIndex].formattedDateModified = moment(data.dateModifed).format('MM/DD/YY h:mm A')
            }

            this.snackbar = getSnackbar('SUCCESS', 'Requirement completion status updated')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error updating requirement completion status')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }

        // runs when user clicks Add button
        } else if (this.addMode) {
          try {
            const {data} = await postRequest(`/ahj/${this.itemId}/${this.itemType}/requirement`, this.requirement, 'blueraven')
            this.requirementsCopy.push(cloneDeep(data))
            let addedRequirementIndex = this.requirementsCopy.findIndex(i => i.id === data.id)
            this.requirementsCopy[addedRequirementIndex].formattedDateCreated = moment(data.dateCreated).format('MM/DD/YY h:mm A')

            this.snackbar = getSnackbar('SUCCESS', 'Requirement added')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error adding requirement')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
          this.addMode = false

        // runs when user clicks Update button
        } else {
          try {
            this.requirement.archived = false

            // resets the requirement status ID so that updates still work after a challenge is denied
            if (this.requirement.statusId === 4) {
              this.requirement.statusId = 1
            }

            const {data} = await putRequest(`/ahj/${this.itemId}/${this.itemType}/requirement/${this.requirement.id}`, this.requirement, 'blueraven')
            let updatedRequirementIndex = this.requirementsCopy.findIndex(i => i.originalRequirementId === data?.originalRequirementId)
            this.requirementsCopy[updatedRequirementIndex].id = data?.id
            this.requirementsCopy[updatedRequirementIndex].description = data?.description
            this.requirementsCopy[updatedRequirementIndex].position = this.requirement.position

            if (data?.dateModified) {
              this.requirementsCopy[updatedRequirementIndex].formattedDateModified = moment(data.dateModified).format('MM/DD/YY h:mm A')
            } else {
              this.requirementsCopy[updatedRequirementIndex].formattedDateCreated = moment(data?.dateCreated).format('MM/DD/YY h:mm A')
            }

            this.snackbar = getSnackbar('SUCCESS', 'Requirement updated')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error updating requirement')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
          this.editMode = false
        }

        this.requirementsCopy = orderBy(this.requirementsCopy, requirement => requirement.position)
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      async archiveRequirement(originalRequirementId) {
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          await putRequest(`/ahj/${this.itemType}/requirement/${originalRequirementId}/archive`, null, 'blueraven')
          let archivedRequirementIndex = this.requirementsCopy.findIndex(i => i.originalRequirementId === originalRequirementId)
          this.requirementsCopy.splice(archivedRequirementIndex, 1)

          this.snackbar = getSnackbar('SUCCESS', 'Requirement archived')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error archiving requirement')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }

        this.editMode = false
        this.$store.commit(AppMutations.SET_LOADING, false)
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
  .disabled-checkbox {
    cursor: not-allowed;
  }
  .v-list-item__action {
    margin: 0 !important;
  }
  .v-list-item__title {
    font-size: 0.95em !important;
    text-align: left;
    max-width: 525px;
  }
  .v-list-item__subtitle {
    text-align: left;
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
    text-align: left;
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
      text-align: left;
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
