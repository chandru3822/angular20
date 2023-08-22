<template>
  <v-container id="types-settings">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Message Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" v-if="userCanAdd" @click="[addNew = !addNew, newType = {}]">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat >
          <h3>Add Message Type</h3>
          <div class="mb-3">
            <v-text-field text v-model="newType.title"
                          label="Title" />
            <v-text-field text v-model="newType.description"
                          label="Description" />
            <v-textarea text v-model="newType.content" auto-grow outlined hide-details
                          label="Content" />
            <div class="helper-buttons">
              <a v-for="hb in helperButtons" class="mr-3"
                 @click="appendText(newType, hb.textValue)">
                {{hb.label}}
              </a>
            </div>
          </div>
          <v-btn :disabled="!newType.title || !newType.content"
                 color="primary" class="white--text mr-2"
                 @click="saveMessageType(newType, true)">
            Save
          </v-btn>
          <v-btn text color="primary" @click="[addNew = !addNew, newType = {}]">Cancel</v-btn>
        </v-card>
        <v-data-table
            id="types-settings-table"
            :headers="headers"
            :items="filterTypes"
            :fixed-header="true"
            :items-per-page="-1"
            single-expand
            :expanded.sync="expanded"
            hide-default-footer
            class="elevation-1 org-type-table table-striped"
        >
          <template #no-data>
            <span class="default-text-color">NO DATA HERE!</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No parameters exist for this function</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': filterTypes.indexOf(item) % 2}">
              <h3>Edit Message Type</h3>
              <div class="mb-3">
                <v-text-field text v-model="item.title"
                              label="Title" />
                <v-text-field text v-model="item.description"
                              label="Description" />
                <v-textarea text v-model="item.content" auto-grow outlined hide-details
                              label="Content" />

                <div class="helper-buttons">
                  <a v-for="hb in helperButtons" class="mr-3"
                     @click="appendText(item, hb.textValue)">
                    {{hb.label}}
                  </a>
                </div>

                <label>Include Manager:</label>
                <input class="ml-3" type="checkbox" v-model="item.includeManager">
              </div>
              <v-btn :disabled="!item.title || !item.description || !item.content"
                     color="primary" class="white--text mr-2"
                     @click="saveMessageType(item, false)">
                Save
              </v-btn>
            </td>
          </template>
          <template #item.icons="{ item}">
            <td class="text-right">
              <v-btn small icon :large="$vuetify.breakpoint.smAndDown" color="primary" v-if="userCanEdit && !expanded.includes(item)" @click="expanded = [item]">
                <v-icon>edit</v-icon>
              </v-btn>
              <v-btn small icon :large="$vuetify.breakpoint.smAndDown" color="primary" v-if="userCanEdit && expanded.includes(item)" @click="expanded = []">cancel</v-btn>
              <v-btn small icon :large="$vuetify.breakpoint.smAndDown" color="primary" v-if="userCanDelete" @click="typeToDelete=item"><v-icon>delete</v-icon></v-btn>
            </td>
          </template>

        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!typeToDelete" @confirm="deleteMessageType" @close-dialog="typeToDelete=null">
      Are you sure you want to delete this type: <strong>{{typeToDeleteName}}</strong>
    </ConfirmationDialog>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'

  import {handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import ConfirmationDialog from "@/components/ConfirmationDialog";

  export default {
    name: 'MessageTypes',
    components: {ConfirmationDialog},
    data() {
      return {
        snackbar: {},
        constants,
        addNew: false,
        levels: [],
        messageTypes: [],
        newType: {},
        types: [],
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
        userCanDelete: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE'),
        headers: [
          { text: 'ID', value: 'id', show: true },
          { text: 'Title', value: 'title', show: true },
          { text: 'Content', value: 'content', show: true },
          { text: 'Description', value: 'description', show: true },
          { text: null, value: 'icons', show: true, sortable: false }
        ],
        helperButtons: [
          { textValue: 'v_closer_first_name', label: 'Closer First Name'},
          { textValue: 'v_contact_name', label: 'Contact Name'},
          { textValue: 'v_contact_street', label: 'Contact Street'},
          { textValue: 'v_contact_city', label: 'Contact City'},
          { textValue: 'v_contact_state', label: 'Contact State'},
          { textValue: 'v_appt_start_time', label: 'Closer Appt Start Time'},
          { textValue: 'v_appt_end_time', label: 'Closer Appt End Time'},
          { textValue: 'v_site_survey_start_time', label: 'Site Survey Start Time'},
          { textValue: 'v_system_size', label: 'System Size'},
          { textValue: 'v_installation_start_time', label: 'Installation Start Time'},
          { textValue: 'v_project_name', label: 'Project Name'},
          { textValue: 'v_project_id', label: 'Project ID'},
          { textValue: 'v_project_phone', label: 'Project Phone'},
        ],
        expanded: [],
        typeToDelete: null
      }
    },
    computed:{
      typeToDeleteName() {
        return this.typeToDelete ? this.typeToDelete.type : ''
      },
      filterTypes () {
        return this.messageTypes.filter(cs => { return !cs.archived})
      },
    },
    async created () {
      this.getMessageTypes()
    },
    methods: {
      appendText(item, value) {
        this.$set(item, 'content', ((item.content || '') + value))
      },
      async saveMessageType(ol, isNew) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            ...ol
          }
          params.id = isNew ? null : params.id
          const {data, status} = await postRequest(`/messageType`, params, 'blueraven', {})
          if(isNew){
            this.messageTypes.push(data)
            this.addNew = false
            this.newType = {}
            this.snackbar = getSnackbar('SUCCESS', 'Message Type Added')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          } else {
            this.expanded = []
            this.snackbar = getSnackbar('SUCCESS', 'Message Type Updated')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', isNew ? 'Error Adding Message Type' : 'Error Updating Message Type')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getMessageTypes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/messageType`, 'blueraven', [])
          this.messageTypes = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Company Types')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteMessageType() {
        const messageType = this.typeToDelete
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/messageType/${messageType.id}`, 'blueraven')
          messageType.archived = true
          this.snackbar = getSnackbar('SUCCESS', 'Message Type Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Message Type')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
        this.typeToDelete = null
      },

    }
  }
</script>
<style scoped lang="scss">
.helper-buttons {
  display: flex;
  flex-wrap: wrap;
  margin-bottom: 10px;
}

@media (max-width: 960px) {
  //increase the size of checkbox on mobile
  input[type='checkbox'] {
    width: 25px;
    height: 25px;
  }

}
</style>
<style lang="scss">
//keeps the arrow icon on the sort chip (mobile dropdown) from having a light blue background
#types-settings-table > div > table > thead > tr > th > div > div > div > div > div.v-select__slot > div.v-select__selections > span > span > div {
  background-color: inherit !important;
}


@media (max-width: 960px) {
  @import "@/styles/main.scss"; //yes this import has to be inside the media query b/c you can't @extend across media-queries ¯\_(ツ)_/¯
  //increase type name size on mobile so it looks better
  #types-settings-table > div > table > tbody > tr > td:nth-child(1) > div.v-data-table__mobile-row__cell {
    @extend .body-large;
  }

  #types-settings {
    margin-bottom: 24px;
  }
}
</style>
