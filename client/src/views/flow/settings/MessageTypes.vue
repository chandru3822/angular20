<template>
  <v-container id="types-settings">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Message Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
              variant="text"
              color="primary"
              v-if="userCanAdd"
              @click="[addNew = !addNew, newType = {}]"
              :hide-text-on-mobile="constants.IS_MOBILE"
              :prepend-icon="constants.IS_MOBILE ? 'add' : ''"
              :text="addNew ? 'CANCEL' : 'ADD NEW'"
            />
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
          <a-btn
            :disabled="!newType.title || !newType.content"
            color="primary"
            class="white--text mr-2"
            @click="saveMessageType(newType, true)"
            text="SAVE"
          />
          <a-btn
            variant="text"
            color="primary"
            @click="[addNew = !addNew, newType = {}]"
            text="CANCEL"
          />
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
              <a-btn
                :disabled="!item.title || !item.description || !item.content"
                color="primary"
                class="white--text mr-2"
                @click="saveMessageType(item, false)"
                text="SAVE"
              />
            </td>
          </template>
          <template #item.icons="{ item}">
            <td class="text-right">
              <a-btn
                size="small"
                variant="text"
                :large="vuetify.breakpoint.smAndDown"
                color="primary"
                v-if="userCanEdit && !expanded.includes(item)"
                @click="expandItem(item)"
                prepend-icon="edit"
              />
              <a-btn
                size="small"
                variant="text"
                :large="vuetify.breakpoint.smAndDown"
                color="primary"
                v-if="userCanEdit && expanded.includes(item)"
                @click="expanded = []; item.content = tempItemContent; tempItemContent = ''"
                text="CANCEL"
              />
              <a-btn
                size="small"
                variant="text"
                :large="vuetify.breakpoint.smAndDown"
                color="primary"
                v-if="userCanDelete"
                @click="typeToDelete=item"
                prepend-icon="delete"
              />
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

<script setup>
  import {handleHidingGlobalLoader, getRequest, deleteRequest, postRequest} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import ConfirmationDialog from "@/components/ConfirmationDialog";

  import {computed, getCurrentInstance, onMounted, ref} from "vue";
  import { useUserStore } from '@/stores/UserStorePinia.js'
  import { useAppStore } from '@/stores/AppStorePinia.js'
  const vueInstance = getCurrentInstance().proxy
  const snackbar = vueInstance.$snackbar
  const vuetify = vueInstance.$vuetify
  const store = vueInstance.$store
  const userStore = useUserStore()
  const appStore = useAppStore()

  const addNew = ref(false)
  const levels = ref([])
  const messageTypes = ref([])
  const newType = ref({})
  const types = ref([])

  // stores the content when editing a message type. This way we can discard changes if the user presses 'cancel'
  const tempItemContent = ref('')
  const headers = ref([
    { text: 'ID', value: 'id', show: true },
    { text: 'Title', value: 'title', show: true },
    { text: 'Content', value: 'content', show: true },
    { text: 'Description', value: 'description', show: true },
    { text: null, value: 'icons', show: true, sortable: false }
  ])
  const helperButtons = ref([
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
  ])
  const expanded = ref([])
  const typeToDelete = ref(null)

  const typeToDeleteName = computed(() => {
    return typeToDelete.value ? typeToDelete.value.type : ''
  })
  const filterTypes = computed (() => {
    return messageTypes.value.filter(cs => { return !cs.archived})
  })

  const userCanAdd = computed(() => {
    return userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')
  })
  const userCanEdit = computed(() => {
    return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
  })
  const userCanDelete = computed(() => {
    return userStore.userHasFeatureAccessLevel('SETTINGS', 'DELETE')
  })

  onMounted (() => {
    getMessageTypes()
  })

  const appendText = (item, value) => {
    vueInstance.$set(item, 'content', ((item.content || '') + value))
  }
  const saveMessageType = async (ol, isNew) => {
    appStore.loading = true
    try {
      let params = {
        ...ol
      }
      params.id = isNew ? null : params.id
      const {data, status} = await postRequest(`/messageType`, params, 'blueraven', {})
      if(isNew){
        messageTypes.value.push(data)
        addNew.value = false
        newType.value = {}
        snackbar('SUCCESS', 'Message Type Added')
      } else {
        expanded.value = []
        snackbar('SUCCESS', 'Message Type Updated')
      }

      tempItemContent.value = ''

      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', isNew ? 'Error Adding Message Type' : 'Error Updating Message Type')
      appStore.loading = false
    }
  }
  const getMessageTypes = async () => {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/messageType`, 'blueraven', [])
      messageTypes.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Loading Company Types')
      appStore.loading = false
    }
  }
  const deleteMessageType = async () => {
    const messageType = typeToDelete.value
    appStore.loading = true
    try {
      const {status} = await deleteRequest(`/messageType/${messageType.id}`, 'blueraven')
      messageType.archived = true
      snackbar('SUCCESS', 'Message Type Deleted')
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Deleting Message Type')
      appStore.loading = false
    }
    typeToDelete.value = null
  }

  const expandItem = (item) => {
    expanded.value = [item]
    tempItemContent.value = item?.content

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
