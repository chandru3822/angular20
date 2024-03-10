<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">Links</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AlbatrossButton
              variant="text"
              color="primary"
              @click="[addNew = !addNew, newLink = { url: ''}]"
              v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')"
              :hide-text-on-mobile="isMobile"
              :prepend-icon="addNew ? 'close' : 'add'"
              :text="addNew ? '': 'Add New'"
            />

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
              <AlbatrossButton
                variant="text"
                outlined
                color="primary"
                v-for="p in linkParams"
                @click="updateUrl(newLink, p.code)"
                class="ma-2"
                :text="p.name"
              />
            </div>
            <AlbatrossButton
              color="primary"
              class="mt-4"
              :disabled="!newLink.link || !newLink.url"
              @click="addNewLink"
              text="Save"
            />
          </v-card>
          <div v-else>
            <v-list v-for="(a, index) in filteredLinks"
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
                      <AlbatrossButton
                        variant="text"
                        outlined
                        color="primary"
                        v-for="p in linkParams"
                        @click="updateUrl(a, p.code)"
                        class="ma-2"
                        :text="p.name"
                      />
                    </div>
                  </div>
                  <div v-else>{{a.link}}</div>
                </v-list-item-content>
                <div :class="{'d-flex flex-row align-center justify-end': vuetify.breakpoint.smAndDown, 'align-self-end': selectedLinkId === a.id && vuetify.breakpoint.smAndDown}"
                      class="px-0">
                  <AlbatrossButton
                    variant="text"
                    color="primary"
                    :disabled="!a.url || !a.link" v-if="selectedLinkId === a.id && userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')"
                    @click="saveLink(a)"
                    prepend-icon="save"
                  />
                  <v-icon
                    v-else-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')"
                    color="primary"
                    @click="selectedLinkId = a.id">edit</v-icon>
                  <AlbatrossButton
                    size="small"
                    variant="text"
                    color="primary"
                    v-if="selectedLinkId === a.id"
                    @click="selectedLinkId = null"
                    prepend-icon="close"
                  />
                  <AlbatrossButton
                    size="small"
                    variant="text"
                    color="primary"
                    v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                    @click="linkToDelete=a"
                    prepend-icon="delete"
                  />
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
  import orderBy from 'lodash.orderby'
  import {handleHidingGlobalLoader, getRequest, deleteRequest, putRequest, postRequest} from '@/helpers/helpers'
  import ConfirmationDialog from '@/components/ConfirmationDialog'
  import AlbatrossButton from '@/components/customVuetify/AlbatrossButton.vue'
  import {computed, getCurrentInstance, onMounted, ref} from 'vue'
  import { useUserStore } from '@/stores/UserStorePinia.js'
  import { useAppStore } from '@/stores/AppStorePinia.js'
  const vueInstance = getCurrentInstance().proxy
  const snackbar = vueInstance.$snackbar
  const vuetify = vueInstance.$vuetify
  const store = vueInstance.$store
  const userStore = useUserStore()
  const appStore = useAppStore()

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
  const userId = ref(userStore.details.id)
  const companyId = ref(userStore.details.companyId)
  const linkToDelete = ref(null)

  const linkToDeleteValue = computed(() => {
    return linkToDelete.value ? linkToDelete.value.link : ''
  })

  const isMobile = computed(() => {
    return vuetify.breakpoint.smAndDown
  })

  const filteredLinks = computed(() => {
    return links.value.filter((l) => l.archived === false)
  })
  const updateUrl = (item, code) => {
    item.url == null ? item.url = code : item.url += code
  }
  const getLinks = async () => {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/links`)
      links.value = orderBy(data, [a => a.link.toLowerCase()])
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')
      appStore.loading = false
    }
  }
  const deleteLink = async () => {
    const link = linkToDelete.value
    const typeId= linkToDelete.value.id
    appStore.loading = true
    try {
      const {status} = await deleteRequest(`/links/${typeId}`)
      snackbar('SUCCESS', 'Link Deleted')

      link.archived = true
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Deleting Link')

      appStore.loading = false
    }
    linkToDelete.value = null
  }
  const addNewLink = async () => {
    appStore.loading = true
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

      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Adding Link')

      appStore.loading = false
    }
  }
  const saveLink = async (a)  => {
    appStore.loading = true
    try {
      selectedLinkId.value = null
      a.modifiedById = userId.value
      const {status} = await putRequest(`/links`, a)
      snackbar('SUCCESS', 'Link Updated')

      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Updating Link')
      appStore.loading = false
    }
  }

  onMounted(() => {
    getLinks()
  })
</script>

<style lang="scss">
