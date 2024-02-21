<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">Links</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AlbatrossButton text color="primary" @click="[addNew = !addNew, newLink = { url: ''}]" v-if="store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
              <v-icon v-if="isMobile">{{addNew ? 'close' : 'add'}}</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </AlbatrossButton>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card v-if="addNew" flat color="transparent">
            <v-text-field v-model="newLink.link"
                          placeholder="Enter a link name"
                          label="Link">
            </v-text-field>
            <v-text-field v-model="newLink.url"
                          clearable
                          placeholder="Enter a URL"
                          label="URL">
            </v-text-field>
            <div>
              <p>These parameters can be used to add some system values to a url. </p>
              <p>Validation is not yet in place so be careful which screens you assign a url to.</p>
              <p>If you want to use the value from a cfga, prefix the id with CFGA_ID_. </p>
              <p>For example, you should not add a url using "Project Process Step Event ID" to a Process Step. </p>
              <AlbatrossButton text outlined color="primary" v-for="p in linkParams" @click="updateUrl(newLink, p.code)" class="ma-2">
                {{p.name}}
              </AlbatrossButton>
            </div>
            <AlbatrossButton color="primary" class="mt-4" :disabled="!newLink.link || !newLink.url" @click="addNewLink">Save</AlbatrossButton>
          </v-card>
          <div v-else>
            <v-list v-for="(a, index) in filterBy(links, false, 'archived')"
                    :key="index"  class="pa-0">
              <v-list-item :class="{'shaded-row': index % 2, 'flex-column': vuetify.breakpoint.smAndDown && selectedLinkId === a.id}">
                <v-list-item-content class="text-left">
                  <div v-if="selectedLinkId === a.id">
                    <v-text-field class="one-hunned"
                                  :class="{'px-4': vuetify.breakpoint.smAndDown}"
                                  label="Link"
                                  v-model="a.link">
                    </v-text-field>
                    <v-text-field class="one-hunned"
                                  :class="{'px-4': vuetify.breakpoint.smAndDown}"
                                  label="URL"
                                  clearable
                                  v-model="a.url">
                    </v-text-field>
                    <div>
                      <p :class="{'px-4': vuetify.breakpoint.smAndDown}">These parameters can be used to add some system values to a url. </p>
                      <p :class="{'px-4': vuetify.breakpoint.smAndDown}">Validation is not yet in place so be careful which screens you assign a url to. </p>
                      <p :class="{'px-4': vuetify.breakpoint.smAndDown}"> If you want to use the value from a cfga, prefix the id with CFGA_ID_ </p>
                      <p :class="{'px-4': vuetify.breakpoint.smAndDown}">For example, you should not add a url using "Project Process Step Event ID" to a Process Step. </p>
                      <AlbatrossButton text outlined color="primary" v-for="p in linkParams" @click="updateUrl(a, p.code)" class="ma-2">
                        <span>{{p.name}}</span>
                      </AlbatrossButton>
                    </div>
                  </div>
                  <div v-else>{{a.link}}</div>
                </v-list-item-content>
                <div :class="{'d-flex flex-row align-center justify-end': vuetify.breakpoint.smAndDown, 'align-self-end': selectedLinkId === a.id && vuetify.breakpoint.smAndDown}">
                  <AlbatrossButton text color="primary" :disabled="!a.url || !a.link" v-if="selectedLinkId === a.id && store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT')" @click="saveLink(a)">
                    <v-icon>save</v-icon>
                  </AlbatrossButton>
                  <v-icon v-else-if="store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT')" color="primary" @click="selectedLinkId = a.id">edit</v-icon>
                  <AlbatrossButton small text color="primary" v-if="selectedLinkId === a.id" @click="selectedLinkId = null">
                    <v-icon>close</v-icon>
                  </AlbatrossButton>
                <AlbatrossButton small text color="primary"
                       v-if="store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                       @click="linkToDelete=a">
                  <v-icon>delete</v-icon>
                </AlbatrossButton>
                </div>
              </v-list-item>
            </v-list>
          </div>
          <ConfirmationDialog :open-dialog="!!linkToDelete" @confirm="deleteLink" @close-dialog="linkToDelete=null">
            Are you sure you want to delete this link: <strong>{{linkToDeleteValue}}</strong>?
          </ConfirmationDialog>
        </v-container>
      </v-col>

    </v-row>
  </v-container>
</template>


<script setup>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import orderBy from 'lodash.orderby'

  import {handleHidingGlobalLoader, getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import ConfirmationDialog from "@/components/ConfirmationDialog";
  import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
  import {computed, getCurrentInstance, onMounted, ref} from "vue";

  const vueInstance = getCurrentInstance().proxy
  const snackbar = vueInstance.$snackbar
  const vuetify = vueInstance.$vuetify
  const store = vueInstance.$store
  const router = vueInstance.$route

  const links = ref([])
  const addNew = ref(false)
  const newLink = ref({ url: '' })
  //hard coding these for now till we figure out what we want to do
  const linkParams = ref([
    { name: 'Albatross Base URL', code: 'ALB_HOST'},
    { name: 'Contact ID', code: 'ALB_CONTACT_ID'},
    { name: 'Project ID', code: 'ALB_PROJECT_ID'},
    { name: 'Project Process Step ID', code: 'ALB_PPS_ID'},
    { name: 'Project Process Step Event ID', code: 'ALB_PPSE_ID'},
  ])
  const selectedLinkId = ref(null)
  const userId = ref(store.state.user.details.id)
  const companyId = ref(store.state.user.details.companyId)
  const linkToDelete = ref(null)

  const linkToDeleteValue = computed(() => {
    return linkToDelete.value ? linkToDelete.value.link : ''
  })

  const isMobile = computed(() => {
    return vuetify.breakpoint.smAndDown
  })

  const updateUrl = (item, code) => {
    item.url == null ? item.url = code : item.url += code
  }
  const getLinks = async () => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data, status} = await getRequest(`/links`)
      links.value = orderBy(data, [a => a.link.toLowerCase()])
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const deleteLink = async () => {
    const link = linkToDelete.value
    const typeId= linkToDelete.value.id
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {status} = await deleteRequest(`/links/${typeId}`)
      snackbar('SUCCESS', 'Link Deleted')

      link.archived = true
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Deleting Link')

      store.commit(AppMutations.SET_LOADING, false)
    }
    linkToDelete.value = null
  }
  const addNewLink = async () => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      newLink.value.companyId = companyId.value
      // this.newProcess.createdById = this.userId
      const {data, status} = await postRequest(`/links`, newLink.value)

      // add it to the records already on the screen
      links.value.push(data)
      links.value = orderBy(links.value, [a => a.link.toLowerCase()])

      // reset the new process fields
      addNew.value = false
      newLink.value = { url: ''}
      snackbar('SUCCESS', 'Link Added')

      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Adding Link')

      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const saveLink = async (a)  => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      selectedLinkId.value = null
      a.modifiedById = userId.value
      const {status} = await putRequest(`/links`, a)
      snackbar('SUCCESS', 'Link Updated')

      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Updating Link')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }

  onMounted(() => {
    getLinks()
  })
</script>

