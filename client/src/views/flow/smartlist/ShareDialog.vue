<template>
  <v-dialog
    v-model="openDialog"
    :width="500"
    persistent
  >
    <v-card>
      <v-card-title>
        Share Smartlist
      </v-card-title>

      <v-card-text>

        <v-autocomplete
          class="body-large"
          :items="sharables"
          label="Add Users and Organizations"
          :item-text="(i) => (i.isUser) ? `${i.name} - ${i.position}` : i.name"
          return-object
          @input="updateNewAccess"
        />

        <v-autocomplete
          v-model="newAccess.accessControlId"
          class="body-large"
          :items="accessLevels"
          :item-text="(i) => `${i.accessLevel.substring(0,1).toUpperCase()}${i.accessLevel.substring(1)} Access`"
          item-value="accessControlId"
        />

        <v-checkbox
          v-model="isPublic"
          label="Make Public"
          :hide-details="true"
          :ripple="false"
        />
      </v-card-text>

      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn
          @click.native="emit('closed-dialog')"
          text
          color="primary"
          class="text-capitalize mr-2 mb-2"
        >
           Cancel
        </v-btn>
        <v-btn
          color="primary"
          class="white--text elevation-2 text-capitalize mr-2 mb-2"
          @click="updateAccess"
        >
          Share
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>

import { getRequest, getSnackbar, handleHidingGlobalLoader, logError, postRequest } from '@/helpers/helpers'
import { getCurrentInstance, ref } from 'vue'
import { AppMutations } from '@/stores/AppStore'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const props = defineProps({
  openDialog: {
    type: Boolean,
    required: true
  },
  smartlist: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['closed-dialog'])

//a list of user positions and orgs the smartlist can be shared with
let sharables = ref([])

let accessLevels = ref([])

//a list of user positions and orgs the smartlist is CURRENTLY shared with
let currentAccess = ref([])

let newAccess = ref({accessControlId: 1})
let isPublic = ref(props.smartlist.public)

const updateNewAccess = (access) => {
  newAccess.value = {
    ...access,
    smartlistId: props.smartlist.id,
    accessControlId: newAccess.value.accessControlId,
    updated: true
  }
}

const getSharables = async () => {
  const {data} = await getRequest(`/smartlist/sharables`)
  sharables.value = data
}

const getAccessLevels = async () => {
  const {data} = await getRequest(`/smartlist/access`)
  accessLevels.value = data
}

const updateAccess = async () => {

  let payload = {}

  if (newAccess.value.updated) {
    payload.newAccess = newAccess.value
  }

  if (props.smartlist.public !== isPublic.value) {
    payload.updatePublic = true
    payload.isPublic = isPublic.value
  }

  //add modified access levels to payload

  let snackbar

  if (Object.keys(payload).length > 0) {
    try {
      store.commit(AppMutations.SET_LOADING, true)
      await postRequest(`/smartlist/${props.smartlist.id}/access`, {...payload, smartlistId: props.smartlist.id})
      snackbar = getSnackbar('SUCCESS', `Smartlist Successfully Shared`)
      emit('closed-dialog')
    } catch (err) {
      logError(err)
      snackbar = getSnackbar('ERROR', 'Error while Sharing Smartlist')
    } finally {
      handleHidingGlobalLoader(vueInstance, true)
      store.commit(AppMutations.SHOW_SNACK, snackbar)
    }
  } else {
    snackbar = getSnackbar('SUCCESS', `Smartlist Successfully Shared`)
    store.commit(AppMutations.SHOW_SNACK, snackbar)
    emit('closed-dialog')
  }
}

getSharables()
getAccessLevels()
</script>

<style scoped lang="scss">

</style>