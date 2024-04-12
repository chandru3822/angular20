<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Org Levels</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn :hide-text-on-mobile="true" :prepend-icon="addNew ? 'close' : 'add'"
                             variant="text"
                             :text="addNew ? 'Cancel' : 'Add New'"
                             @click="[addNew = !addNew, newOrgLevel = {}]">
            </a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat >
          <h3>Add Org Level</h3>
          <div class="mb-3">
            <a-text-field  v-model="newOrgLevel.levelName"
                          label="Level Name" />
            <a-text-field  v-model="newOrgLevel.level" type="number"
                          label="Level" />
          </div>
          <a-btn variant="text" text="Cancel" @click="[addNew = !addNew, newOrgLevel = {}]"></a-btn>
          <a-btn :disabled="!newOrgLevel.levelName || !newOrgLevel.level"
                 text="Save" class="mr-2"
                 @click="saveOrgLevel(newOrgLevel, true)">
          </a-btn>
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
                <a-text-field  v-model="item.levelName"
                              label="Rank" />
                <a-text-field  v-model="item.level" type="number"
                              label="Rank" />
              </div>
              <a-btn :disabled="!item.levelName || !item.level"
                     text="Save" class="mr-2"
                     @click="saveOrgLevel(item, false)">
              </a-btn>
            </td>
          </template>

          <template #item="{ item }">
            <tr  class="text-left" :class="{'shaded-row': orgLevels.indexOf(item) % 2}">
              <td class="text-left">{{ item.levelName }}</td>
              <td class="text-left">{{ item.level }}</td>
              <td class="text-right">
                <a-btn variant="text" size="small" prepend-icon="edit" v-if="!expanded.includes(item)" @click="expanded = [item]">
                </a-btn>
                <a-btn size="small" text="cancel" v-if="expanded.includes(item)" @click="expanded = []"></a-btn>
                <a-btn variant="text" size="small" prepend-icon="delete" @click="levelToDelete=item" />
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

<script setup>
import {getOrgLevels} from '@/services/orgService'
import {handleHidingGlobalLoader, deleteRequest, putRequest} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from '@/components/ConfirmationDialog'
import {getCurrentInstance, onMounted, computed, ref} from 'vue'
import { useUserStore } from '@/stores/UserStore.js'
import {useRouter} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()
const router = useRouter()
const snackbar = vueInstance.$snackbar

const addNew = ref(false)
const levels = ref([])
const orgLevels = ref([])
const newOrgLevel = ref({})
const selectedOrgLevelId = ref(null)
const userId = ref(userStore.details.id)
const companyId = ref(userStore.details.companyId)
const expanded = ref([])
const levelToDelete = ref(null)
const headers = ref([
{ text: 'Org Level', value: 'levelName', show: true },
{ text: 'Level', value: 'level', width: 80, show: true },
{ text: null, value: 'icons', show: true, sortable: false }
])
  const levelToDeleteName = computed(() => {
    return levelToDelete.value ? levelToDelete.value.levelName : ''
  })
  onMounted(() => {
    getOrganizationLevels()
  })

      const saveOrgLevel = async(ol, isNew) => {
        appStore.loading = true
        try {
          const {data, status} = await putRequest(`/orgType/level`, ol)
          if(isNew){
            orgLevels.value.push(data)
            addNew.value = false
            newOrgLevel.value = {}
            snackbar('SUCCESS', 'Org Level Added')
          } else {
            expanded.value = []
            snackbar('SUCCESS', 'Org Level Updated')
          }
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', isNew ? 'Error Adding Org Level' : 'Error Updating Org Level')
          appStore.loading = false
        }
      }
      const getOrganizationLevels = async() => {
        appStore.loading = true
        try {
          const {data, status} = await getOrgLevels()
          orgLevels.value = data
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Loading Org Levels')
          appStore.loading = false
        }
      }
      const deleteOrgLevel = async() => {
        const level = levelToDelete.value
        appStore.loading = true
        try {
          const {status} = await deleteRequest(`/orgType/level/${level.id}`)
          orgLevels.value = orgLevels.value.filter(ol => {
            return ol.id !== level.id
          })
          snackbar('SUCCESS', 'Org Level Deleted')
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Deleting Org Level')
          appStore.loading = false
        }
      }
</script>
