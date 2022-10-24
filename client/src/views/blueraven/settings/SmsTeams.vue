<template>
  <v-container id="hierarchy-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar flat>
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Message Templates</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addTemplate = !addTemplate, newType = {}]" v-if="$store.getters.userHasFeatureAccessLevel('SMS_INBOX', 'EDIT')">
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
                          item-text="fullName"
                          item-value="positionId"
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
                <span>{{ item.fullName }}</span>
              </v-chip>
              <span
                v-if="index === 1 && newTemplate.teamIds && newTemplate.teamIds.length >= 2"
                class="primary--text caption"
              >{{ newTemplate.teamIds.length }} selected</span>
            </template>
          </v-autocomplete>

          <v-btn :disabled="!newTemplate.title || !newTemplate.message || newTemplate.teamIds.length < 1"
                 color="primary" class="white--text mr-2"
                 @click="saveTemplate(newTemplate, true)">
            Save
          </v-btn>
          <v-btn @click="[addTemplate = !addTemplate, newTemplate = {}]">Cancel</v-btn>
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
          <template #no-data>
            <span class="default-text-color">NO DATA HERE!</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No parameters exist for this function</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': filterTemplates.indexOf(item) % 2}">
              <h3>Edit Template</h3>
              <v-text-field text v-model="item.title" label="Title" />
              <v-textarea v-model="item.message"
                          label="Message"
                          auto-grow
              ></v-textarea>

              <v-autocomplete v-model="item.teamIds"
                              :items="selectableTeams"
                              item-text="fullName"
                              item-value="positionId"
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
                  <v-chip small v-if="index === 0 && expandedItem.teamIds && expandedItem.teamIds.length < 2">
                    <span>{{ item.fullName }}</span>
                  </v-chip>
                  <span
                    v-if="index === 1 && expandedItem.teamIds && expandedItem.teamIds.length >= 2"
                    class="primary--text caption"
                  >{{ expandedItem.teamIds.length }} selected</span>
                </template>
              </v-autocomplete>

              <v-btn color="primary" class="white--text mr-2" :disabled="!item.title || !item.message || item.teamIds.length < 1" @click="saveTemplate(item, false)">Save</v-btn>
            </td>
          </template>

          <template #item="{ item }">
            <tr  class="text-left" :class="{'shaded-row': filterTemplates.indexOf(item) % 2}">
              <td class="text-left">{{ item.title }}</td>
              <td>
                <v-btn small text v-if="!expanded.includes(item) && $store.getters.userHasFeatureAccessLevel('SMS_INBOX', 'EDIT')" @click="expanded = [item]; expandedItem = item">
                  <v-icon>edit</v-icon>
                </v-btn>
                <confirm-delete-dialog
                    v-if="!expanded.includes(item) && $store.getters.userHasFeatureAccessLevel('SMS_INBOX', 'EDIT')"
                    label="this template?"
                    @confirm="deleteTemplate(item)"
                ></confirm-delete-dialog>
                <v-btn small text v-if="expanded.includes(item)" @click="expanded = []">cancel</v-btn>
              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, putRequest, getSnackbar, getRequest} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmDeleteDialog from "@/ConfirmDeleteDialog";

export default {
  name: 'MessageTemplates',
  components: {ConfirmDeleteDialog},
  data () {
    return {
      snackbar: {},
      constants,
      templates: [],
      newTemplate: {},
      addTemplate: false,
      levels: [],
      parentId: this.$store.state.user.details.parentCompanyId,
      headers: [
        { text: 'Title', value: 'title', show: true },
        { text: null, value: 'icons', show: true, sortable: false }
      ],
      expanded: [],
      expandedItem: [],
      showDeleteDialog: false,
      teams: [],
      selectableTeams: [],
    }
  },
  computed: {
    filterTemplates () {
      return this.templates.filter(tmp => !tmp.archived)
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
    async deleteTemplate(template) {
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
  },
  async created () {
    this.getTemplates()
    this.getTeams()
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
.team-select {
  width: 450px;
}
</style>
