<template>
<fragment>
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

        People with Access

        <v-list>
          <template v-for="(accessLevel) in currentAccess">
            <v-list-item>
              <v-row>
                <v-col cols="7">
                  {{ (accessLevel.isUser) ? `${accessLevel.name} - ${accessLevel.position}` : accessLevel.name }}
                </v-col>

                <v-col cols="5">
                  <v-select
                    v-model="accessLevel.accessControlId"
                    :items="accessLevels"
                    :item-text="(i) => `${i.accessLevel.substring(0,1).toUpperCase()}${i.accessLevel.substring(1)} Access`"
                    item-value="accessControlId"
                    @input="accessLevel.updated = true"
                  >
                    <template
                      #append-item
                      v-if="accessLevel.isUser"
                    >
                      <v-divider/>
                      <v-list-item @click="confirmOwnershipChange(accessLevel)">
                        Transfer Ownership
                      </v-list-item>
                    </template>
                  </v-select>
                </v-col>
              </v-row>
            </v-list-item>
          </template>
        </v-list>

      </v-card-text>

      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn
          @click.native="emit('dialog-closed')"
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

  <v-dialog
    v-model="openOwnershipDialog"
    :width="500"
    persistent
  >
    <v-card>
      <v-card-title>Transfer Ownership</v-card-title>

      <v-card-text>
        You will lose ownership and the following user will become the new Owner:
        <br />
        <br />
        <div class="new-owner-name">{{ `${newOwner.name} - ${newOwner.position}` }}</div>
      </v-card-text>

      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn
          @click.native="openOwnershipDialog = false"
          text
          color="primary"
          class="text-capitalize mr-2 mb-2"
        >
          Cancel
        </v-btn>
        <v-btn
          color="primary"
          class="white--text elevation-2 text-capitalize mr-2 mb-2"
          @click="updateOwner"
        >
          Transfer
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</fragment>
</template>

<script setup>

import { getRequest, getSnackbar, handleHidingGlobalLoader, logError, postRequest, putRequest } from '@/helpers/helpers'
import { getCurrentInstance, ref } from 'vue'
import { AppMutations } from '@/stores/AppStore'
import { Fragment } from 'vue-frag'

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

const emit = defineEmits([
  'dialog-closed',
  'updated-public',
  'updated-owner'
])

//a list of user positions and orgs the smartlist can be shared with
let sharables = ref([])

let accessLevels = ref([])

//a list of user positions and orgs the smartlist is CURRENTLY shared with
let currentAccess = ref([])

let newAccess = ref({accessControlId: 1})
let isPublic = ref(props.smartlist.public)
let openOwnershipDialog = ref(false)
let newOwner = ref({})

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

const getSmartlistAccess = async () => {
  const {data} = await getRequest(`/smartlist/${props.smartlist.id}/access`)
  currentAccess.value = data
}

const updateAccess = async () => {

  let payload = {
    updatedAccess: []
  }

  if (newAccess.value.updated) {
    payload.newAccess = newAccess.value
  }

  if (props.smartlist.public !== isPublic.value) {
    payload.updatePublic = true
    payload.public = isPublic.value
  }

  //add modified access levels to payload
  currentAccess.value.forEach((i) => {
    if (i.updated) {
      payload.updatedAccess.push({
        id: i.id,
        accessControlId: i.accessControlId
      })
    }
  })

  let snackbar

  if (Object.keys(payload).length > 0) {
    try {
      store.commit(AppMutations.SET_LOADING, true)
      await postRequest(`/smartlist/${props.smartlist.id}/access`, {...payload, smartlistId: props.smartlist.id})
      snackbar = getSnackbar('SUCCESS', `Smartlist Successfully Shared`)
      emit('dialog-closed')
      if (props.smartlist.public !== isPublic.value) {
        emit('updated-public', isPublic.value)
      }
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
    emit('dialog-closed')
  }
}

const confirmOwnershipChange = async (accessLevel) => {
  openOwnershipDialog.value = true
  newOwner.value = accessLevel
}

const updateOwner = async () => {

  let snackbar

  try {
    store.commit(AppMutations.SET_LOADING, true)
    await putRequest(`/smartlist/${props.smartlist.id}/owner`, newOwner.value)
    snackbar = getSnackbar('SUCCESS', `Ownership successfully transferred`)
    emit('dialog-closed')
    emit('updated-owner')
  } catch (err) {
    logError(err)
    snackbar = getSnackbar('ERROR', 'Error while transferring ownership')
  } finally {
    handleHidingGlobalLoader(vueInstance, true)
    store.commit(AppMutations.SHOW_SNACK, snackbar)
  }
}

getSharables()
getAccessLevels()
getSmartlistAccess()
</script>

<style scoped lang="scss">
.new-owner-name {
  border-bottom: 1px solid black;
}
</style>