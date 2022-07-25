<template>
  <v-container id="hierarchy-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar flat>
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Message Templates</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addTemplate = !addTemplate, newType = {}]" v-if="userCanEdit">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addTemplate ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addTemplate" class="text-left pa-5 mb-3 mt-2" flat >
          <h3>Add Template</h3>
          <v-text-field text v-model="newTemplate.title"
                        label="Title" />
          <v-textarea v-model="newTemplate.message"
                      label="Message" />
          <v-autocomplete v-model="newTemplate.teamIds"
                          :items="selectableTeams"
                          item-text="teamName"
                          item-value="id"
                          multiple
                          placeholder="Select Team(s)"
                          height="35px"
                          outlined
                          class="team-select"
          >
            <template
              slot="selection"
              slot-scope="{ item, index }"
            >
              <v-chip small v-if="index === 0 && newTemplate.teamIds && newTemplate.teamIds.length < 2">
                <span>{{ item.teamName }}</span>
              </v-chip>
              <span
                v-if="index === 1 && newTemplate.teamIds && newTemplate.teamIds.length >= 2"
                class="primary--text caption"
              >{{ newTemplate.teamIds.length }} selected</span>
            </template>
          </v-autocomplete>
          <v-btn text color="primary" @click="[addTemplate = !addTemplate, newTemplate = {}]">Cancel</v-btn>
          <v-btn :disabled="!newTemplate.title || !newTemplate.message"
                 color="primary" class="white--text mr-2"
                 @click="saveTemplate(newTemplate, true)">
            Save
          </v-btn>
        </v-card>
        <v-data-table
          :headers="headers"
          :items="filterTemplates"
          :fixed-header="true"
          :items-per-page="-1"
          single-expand
          :mobile-breakpoint="0"
          :expanded.sync="expanded"
          hide-default-footer
          class="elevation-1 org-type-table"
        >
          <template v-slot:header.teamIds="{ header }">
            <div class="d-flex align-baseline filter-dropdown"> <div>{{ header.text }}<v-icon small @click="showFilter = !showFilter">mdi-filter</v-icon></div>
            <v-autocomplete v-if="showFilter"
                            v-model="teamFilter"
                            :items="selectableTeams"
                            item-text="teamName"
                            item-value="id"
                            clearable
                            autofocus
                            placeholder="Enter Team Name"
                            class="pl-3 font-weight-regular albatross-body-2"
            ></v-autocomplete>
           </div>
          </template>
          <template #no-data>
            No templates available
          </template>
          <template #no-results>
            No templates match your selection
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-6" :class="{'shaded-row': filterTemplates.indexOf(item) % 2}">
              <v-text-field text v-model="item.title" label="Template Name" class="pb-4"/>
              <v-textarea v-model="item.message"
                          label="Template Message"
                          auto-grow
                          outlined
              ></v-textarea>


              <v-autocomplete v-model="item.teamIds"
                              :items="selectableTeams"
                              item-text="teamName"
                              item-value="id"
                              multiple
                              label="Teams"
                              class="team-select mt-0 pb-3"
              >

              </v-autocomplete>

              <v-btn color="primary" class="white--text mr-2" :disabled="!item.title || !item.message" @click="saveTemplate(item, false)">Save</v-btn>
            </td>
          </template>

          <template #item="{ item }">
            <tr  class="text-left" :class="{'shaded-row': filterTemplates.indexOf(item) % 2}">
              <td class="text-left">{{ item.title }}</td>
              <td class="">{{getTeamsForTemplate(item)}}</td>
              <td class="text-right flex-display align-center">
                <v-btn small text color="primary" v-if="!expanded.includes(item) && userCanEdit" @click="expanded = [item]; expandedItem = item; getAttachments()">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text color="primary" v-if="!expanded.includes(item) && userCanEdit" @click="templateToDelete=item">
                  <v-icon>delete</v-icon>
                </v-btn>
                <v-btn small text color="primary" v-if="expanded.includes(item)" @click="expanded = []">cancel</v-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!templateToDelete" @confirm="deleteTemplate" @close-dialog="templateToDelete=null">
      Are you sure you want to delete this template?
    </ConfirmationDialog>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {
  handleHidingGlobalLoader,
  putRequest,
  getSnackbar,
  getRequest,
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmDeleteDialog from "@/ConfirmDeleteDialog";
import ConfirmationDialog from "@/ConfirmationDialog";

export default {
  name: 'MessageTemplate',
  components: {ConfirmationDialog, ConfirmDeleteDialog},
  data () {
    return {
      snackbar: {},
      constants,
      templates: [],
      newTemplate: {},
      addTemplate: false,
      addTeam: false,
      teamFilter: null,
      showFilter:false,
      levels: [],
      parentId: this.$store.state.user.details.parentCompanyId,
      headers: [
        { text: 'Template Title', value: 'title', show: true },
        {text: 'Teams', value: 'teamIds', show: true, sortable: false, filter: value => {
          if(!value || !this.teamFilter) {
            return true
          }
            return value.includes(this.teamFilter)
          }},
        { text: null, value: 'icons', show: true, sortable: false }
      ],
      expanded: [],
      expandedItem: [],
      showDeleteDialog: false,
      teams: [],
      selectableTeams: [],
      templateToDelete: null
    }
  },
  computed: {
    filterTemplates () {
      return this.templates.filter(tmp => !tmp.archived)
    },
    userCanEdit() {
      return this.$store.getters.userHasFeatureAccessLevel('SMS_INBOX', 'MANAGE')
    },
  },
  methods: {
    async getTemplates () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/messaging/templates`)
        this.templates = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Templates')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveTemplate(template, isNew) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await putRequest(`/messaging/template`, template)
        if(isNew){
          this.templates.push(data)
          this.addTemplate = false
          this.newTemplate = {}
          this.snackbar = getSnackbar('SUCCESS', 'Template Added')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } else {
          this.expanded = []
          this.snackbar = getSnackbar('SUCCESS', 'Template Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', isNew ? 'Error Adding Template' : 'Error Updating Template')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteTemplate() {
      const template = this.templateToDelete
      try {
        const {status} = await putRequest(`/messaging/template/delete/${template.id}`)
        this.showDeleteDialog = false
        template.archived = true
        this.snackbar = getSnackbar('SUCCESS', 'Template Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Template')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getTeams() {
      try {
        const {data} = await getRequest(`/smsTeam/`)
        this.selectableTeams = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving teams')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },

    getTeamsForTemplate(template) {
        const teamNames = this.selectableTeams.filter(team => template.teamIds.includes(team.id)).map(team => {
          return team.teamName
      })
      return teamNames.join(", ")
    }
  },
  async created () {
    await this.getTemplates()
    await this.getTeams()
  }
}
</script>

<style lang="scss">
#hierarchy-container .v-data-table__wrapper {
  height: calc(100vh - 200px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>

.filter-dropdown {
  width: 50%;
}

.team-select {
  width: 450px;
}

.wqt-header-bar {
  border-bottom: 1px solid #E6E6E6;
  border-top: 1px solid #E6E6E6;
}
</style>
