<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Org Levels</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addNew = !addNew, newOrgLevel = {}]">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat >
          <h3>Add Org Level</h3>
          <div class="mb-3">
            <v-text-field text v-model="newOrgLevel.levelName"
                          label="Level Name" />
            <v-text-field text v-model="newOrgLevel.level" type="number"
                          label="Level" />
          </div>
          <v-btn text color="primary" @click="[addNew = !addNew, newOrgLevel = {}]">Cancel</v-btn>
          <v-btn :disabled="!newOrgLevel.levelName || !newOrgLevel.level"
                 color="primary" class="mr-2"
                 @click="saveOrgLevel(newOrgLevel, true)">
            Save
          </v-btn>
        </v-card>
        <v-data-table
            :headers="headers"
            :items="orgLevels"
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
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': orgLevels.indexOf(item) % 2}">
              <h3>Edit Org Level</h3>
              <div class="mb-3">
                <v-text-field text v-model="item.levelName"
                              label="Rank" />
                <v-text-field text v-model="item.level" type="number"
                              label="Rank" />
              </div>
              <v-btn :disabled="!item.levelName || !item.level"
                     color="primary" class="white--text mr-2"
                     @click="saveOrgLevel(item, false)">
                Save
              </v-btn>
            </td>
          </template>

          <template #item="{ item }">
            <tr  class="text-left" :class="{'shaded-row': orgLevels.indexOf(item) % 2}">
              <td class="text-left">{{ item.levelName }}</td>
              <td class="text-left">{{ item.level }}</td>
              <td>
                <v-btn small text color="primary" v-if="!expanded.includes(item)" @click="expanded = [item]">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text color="primary" v-if="expanded.includes(item)" @click="expanded = []">cancel</v-btn>
                <v-btn small text color="primary" @click="levelToDelete=item"><v-icon>delete</v-icon></v-btn>
              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!levelToDelete" @confirm="deleteOrgLevel" @close-dialog="levelToDelete=null">
      <div>
        <span class="error-text">WARNING:</span> This action can cause issues with many other screens.
      </div>
      Are you sure you want to delete this org level: <b>{{ levelToDeleteName }}</b>?
    </ConfirmationDialog>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {getOrgLevels} from '@/services/orgService'
  import {handleHidingGlobalLoader, deleteRequest, putRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import ConfirmationDialog from "@/components/ConfirmationDialog";

  export default {
    name: 'OrgLevels',
    components: {ConfirmationDialog},
    data() {
      return {
        snackbar: {},
        constants,
        addNew: false,
        levels: [],
        orgLevels: [],
        newOrgLevel: {},
        selectedOrgLevelId: null,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        headers: [
          { text: 'Org Level', value: 'levelName', show: true },
          { text: 'Level', value: 'level', width: 80, show: true },
          { text: null, value: 'icons', show: true, sortable: false }
        ],
        expanded: [],
        levelToDelete: null
      }
    },
    computed:{
      levelToDeleteName(){
        return this.levelToDelete ? this.levelToDelete.levelName : ''
      }
    },
    async created () {
      this.getOrgLevels()
    },
    methods: {
      async saveOrgLevel(ol, isNew) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await putRequest(`/orgType/level`, ol)
          if(isNew){
            this.orgLevels.push(data)
            this.addNew = false
            this.newOrgLevel = {}
            this.snackbar = getSnackbar('SUCCESS', 'Org Level Added')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          } else {
            this.expanded = []
            this.snackbar = getSnackbar('SUCCESS', 'Org Level Updated')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', isNew ? 'Error Adding Org Level' : 'Error Updating Org Level')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getOrgLevels() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getOrgLevels()
          this.orgLevels = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Org Levels')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteOrgLevel() {
        const level = this.levelToDelete
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/orgType/level/${level.id}`)
          this.orgLevels = this.orgLevels.filter(ol => {
            return ol.id !== level.id
          })
          this.snackbar = getSnackbar('SUCCESS', 'Org Level Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Org Level')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>
