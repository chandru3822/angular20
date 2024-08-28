<template>
  <v-container id="release-admin-container" class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Releases</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                :text="showPreviousReleases ? 'HIDE PREVIOUS RELEASES' : 'SHOW PREVIOUS RELEASES'"
                @click="showPreviousReleases = !showPreviousReleases">
            </a-btn>

            <a-btn
                variant="text"
                color="primary"
                v-if="userCanAdd"
                text="ADD NEW"
                @click="prepNewRelease()">
            </a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card class="square-card">
            <v-data-table id="releases-table"
                :headers="headers"
                :items="filteredReleases"
                :fixed-header="true"
                :items-per-page="100"
                :loading="dataLoading"
                class="elevation-1 round-robin-table table-striped"
            >
              <template #item.stageLockDate="{item}">
                {{item.stageLockDate | formatDate('date', 'MM/DD/YYYY')}}
              </template>
              <template #item.uatLockDate="{item}">
                {{item.uatLockDate | formatDate('date', 'MM/DD/YYYY')}}
              </template>
              <template #item.releaseDate="{item}">
                {{item.releaseDate | formatDate('date', 'MM/DD/YYYY')}}
              </template>
              <template #item.icons="{item}" class="text-right">
                <a-btn
                    :size="$vuetify.breakpoint.smAndDown ? 'large' : 'small'"
                    icon
                    color="primary"
                    prepend-icon="edit"
                    @click="selectedRelease = item; releaseModalOpen = true;">
                </a-btn>

                <a-btn
                    v-if="userCanDelete"
                    size="small"
                    variant="text"
                    color="primary"
                    prepend-icon="delete"
                    @click="releaseToDelete=item">
                </a-btn>
              </template>

            </v-data-table>
          </v-card>
          <ConfirmationDialog :open-dialog="!!releaseToDelete" @confirm="[releaseToDelete.archived = true, deleteRelease()]" @close-dialog="releaseToDelete=null">
            Are you sure you want to delete this release: <strong>{{releaseToDeleteName}}</strong>?
          </ConfirmationDialog>
          <ConfirmationDialog v-if="selectedRelease" :open-dialog="releaseModalOpen"  @cancel="[releaseModalOpen = false, selectedRelease = null]" @confirm="saveRelease(), releaseModalOpen = false">
            <template v-slot:title>Release</template>
            <a-text-field
              v-model="selectedRelease.releaseName"

              label="Release Name"
            />
            <DatetimePickerInput
              v-model="selectedRelease.stageLockDate"
              :timezone="timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="Stage Lock Date"
            />
            <DatetimePickerInput
              v-model="selectedRelease.uatLockDate"
              :timezone="timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="UAT Lock Date"
            />
            <DatetimePickerInput
              v-model="selectedRelease.releaseDate"
              :timezone="timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="Production Release Date"
            />
            <template v-slot:no>Cancel</template>
            <template v-slot:yes>Save</template>
          </ConfirmationDialog>
        </v-container>
      </v-col>

    </v-row>
  </v-container>
</template>

<script setup>

  import moment from 'moment'

  import orderBy from 'lodash.orderby'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import { handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import ConfirmationDialog from '@/components/ConfirmationDialog'
  import {computed, getCurrentInstance, onMounted, ref} from 'vue'
  import {useRouter} from 'vue-router/composables'
  import { useUserStore } from '@/stores/UserStore.js'
  import { useAppStore } from '@/stores/AppStore.js'
  const appStore = useAppStore()

  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store
  const userStore = useUserStore()

  const router = useRouter()

  const releaseModalOpen = ref(false)
  const selectedRelease = ref(null)
  const addNew= ref(false),
        showPreviousReleases= ref(false),
        search= ref(null),
        dataLoading= ref(true),
        userId=ref(userStore.details.id),
        releases=ref([]),
        currentYear=ref(moment().year()),
        ownerTypes=ref([]),
        formulas=ref([]),
        headers= ref([
          {text: 'Release', value: 'releaseName', show: true},
          {text: 'Stage Lock', value: 'stageLockDate', show: true},
          {text: 'UAT Lock', value: 'uatLockDate', show: true},
          {text: 'Release Date', value: 'releaseDate', show: true},
          {text: '', value: 'icons', show: true},
        ]),
        releaseToDelete=ref(null)

    const releaseToDeleteName = computed(() => {
        return releaseToDelete.value ? releaseToDelete.value.releaseName : ''
      })

  const userCanAdd = computed(() => {
    return userStore.userHasFeatureAccessLevel('RELEASES', 'ADD')
  })

  const userCanEdit = computed(() => {
    return userStore.userHasFeatureAccessLevel('RELEASES', 'EDIT')
  })

  const userCanDelete = computed(() => {
    return userStore.userHasFeatureAccessLevel('RELEASES', 'DELETE')
  })

  const timezone = computed(() => {
    return userStore.timezone.value
  })

  const companyId = computed(() => {
    return userStore.details.companyId
  })

  const filteredReleases = computed(() => {
    if(!showPreviousReleases.value) {
      return releases.value.filter(r => moment(r.releaseDate) >= moment())
    }
    else{
      return releases.value
    }
  }),
  prepNewRelease = () =>{
    selectedRelease.value = {
    }
    releaseModalOpen.value = true
  },
  getReleases = async() => {
    dataLoading.value = true
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/release`)
      releases.value = data
      dataLoading.value = false
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      dataLoading.value = false
      appStore.showSnack('ERROR', 'Error Retrieving Data')
      appStore.loading = false
    }
  },
  saveRelease = async() =>{
    appStore.loading = true
    try {
      const {data, status} = await postRequest(`/release`, selectedRelease.value)
      if(selectedRelease.value.id != null) {
        appStore.showSnack('SUCCESS', 'Release Updated')
      }
      else {
        appStore.showSnack('SUCCESS', 'Release Added')
      }
      releases.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Adding Release')
      appStore.loading = false
    }
  },
  deleteRelease = async() => {
    const id = releaseToDelete.value.id
    appStore.loading = true
    try {
      const {data, status} = await deleteRequest(`/release/${id}`)
      appStore.showSnack('SUCCESS', 'Release Deleted')
      releases.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Deleting Release')
      appStore.loading = false
    }
    releaseToDelete.value=null
  }

  onMounted(async () => {
    await getReleases()
  })

</script>

<style lang="scss">
  #release-admin-container .v-data-table__wrapper {
    max-height: calc(100vh - 250px);
    min-height: 300px;
  }

  @media (max-width: 770px) {
    #releases-table {
      padding-bottom: 12px;
      div.v-data-footer {
        display: inline-block;
        width: 100%;
        height: auto;

        div.v-data-footer__select {
          justify-content: center;
        }

        div.v-data-footer__pagination {

        }

        div.v-data-footer__icons-before {
          display: inline;
          margin-left: calc(50% - 36px);
        }

        div.v-data-footer__icons-after {
          display: inline;
        }

      }
    }
  }

</style>
