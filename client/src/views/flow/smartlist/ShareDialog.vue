<template>
<span>
  <v-dialog
    v-model="openDialog"
    :width="450"
    @click:outside="closeDialog"
  >
    <v-card>
      <v-card-title
        class="title font-weight-bold pt-6">
        Share Smartlist
      </v-card-title>

      <v-card-text>
        <v-row>
          <v-col
            cols="8"
            class="py-0"
          >
            <v-autocomplete
              :items="filteredSharables"
              label="Add Users and Organizations"
              :item-text="(i) => (i.isUser) ? `${i.name} - ${i.position}` : i.name"
              return-object
              @input="updateNewAccess"
            />
          </v-col>

          <v-col
            cols="4"
            class="py-0"
          >
            <v-autocomplete
              v-model="newAccess.accessControlId"
              :items="accessLevels"
              :item-text="(i) => `${i.accessLevel.substring(0,1).toUpperCase()}${i.accessLevel.substring(1)} Access`"
              item-value="accessControlId"
            />
          </v-col>
        </v-row>

        <v-row>
          <v-col
            cols="12"
            class="px-2 pt-0"
          >
            <v-checkbox
              v-if="canMakePublic"
              v-model="isPublic"
              label="Make Public"
              :hide-details="true"
              :ripple="false"
            />
          </v-col>
        </v-row>

        <v-row>
          <v-col cols="12">
            <span class="font-weight-bold default-text-color">People with Access</span>
          </v-col>
        </v-row>

        <v-list class="bordered rounded-lg">
          <v-list-item>
            <v-row>
              <v-col
                cols="6"
                align-self="center"
                class="py-0"
              >
                <span class="default-text-color">{{ smartlist.owner }}</span>
                <div class="position">
                  {{ smartlist.ownerPosition }}
                </div>
              </v-col>

              <v-col
                cols="6"
                align-self="center"
                class="py-0"
              >
                Owner
              </v-col>
            </v-row>
          </v-list-item>

          <v-list-item v-for="(accessLevel) in currentAccess.filter(i => i.deleted !== true)" :key="UUID()">
            <v-row>
              <v-col
                cols="6"
                align-self="center"
                class="py-0"
              >
                <span class="default-text-color">{{ accessLevel.name }}</span>
                <div
                  v-if="accessLevel.isUser"
                  class="position"
                >{{ accessLevel.position }}
                </div>
              </v-col>

              <v-col
                cols="5"
                align-self="center"
                class="py-0"
              >
                <v-select
                  v-model="accessLevel.accessControlId"
                  :items="accessLevels"
                  :item-text="(i) => `${i.accessLevel.substring(0,1).toUpperCase()}${i.accessLevel.substring(1)} Access`"
                  item-value="accessControlId"
                  @input="[accessLevel.updated = true, accessLevel.deleted = false]"
                >
                  <template #append-item>
                    <v-divider/>
                    <v-list-item
                      v-if="accessLevel.isUser && isOwner"
                      @click="confirmOwnershipChange(accessLevel)"
                    >
                      Transfer Ownership
                    </v-list-item>
                  </template>
                </v-select>
              </v-col>

              <v-col
                cols="1"
                align-self="center"
                class="pl-0"
              >
                <v-icon color="primary" @click="markDeleted(accessLevel)">mdi-delete</v-icon>
              </v-col>
            </v-row>
          </v-list-item>
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
          Save
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
        <br/>
        <br/>
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
</span>
</template>

<script setup>

import { getRequest, handleHidingGlobalLoader, logError, postRequest, putRequest, UUID } from '@/helpers/helpers'
import { getCurrentInstance, ref, computed } from 'vue'
import { AppMutations } from '@/stores/AppStore'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

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

const hasManageAccess = store.getters.userHasFeatureAccessLevel('SMARTLIST', 'MANAGE')
const isSmartlistAdmin = store.getters.userHasFeatureAccessLevel('SMARTLIST', 'ADMIN')
const isSystemAdmin = store.getters.isFullAdmin

//a list of user positions and orgs the smartlist can be shared with
const sharables = ref([])

const accessLevels = ref([])

//a list of user positions and orgs the smartlist is CURRENTLY shared with
const currentAccess = ref([])

const newAccess = ref({accessControlId: 1})
const isPublic = ref(props.smartlist.public)
const openOwnershipDialog = ref(false)
const newOwner = ref({})

const isOwner = computed(() => {
  return props.smartlist?.ownerId === store.state.user.details.id
})

const canMakePublic = computed(() => {
  return (hasManageAccess && isOwner) || isSmartlistAdmin || isSystemAdmin
})

const filteredSharables = computed(() => {
  if (sharables.value.length === 0) {
    return []
  }

  if (currentAccess.value.length === 0) {
    return sharables.value
  }

  let filtered = []

  sharables.value.forEach(s => {
    if (s.isUser && s.userId !== props.smartlist.ownerId && !currentAccess.value.find(a => a.userPositionId === s.userPositionId)) {
      filtered.push(s)
    } else if (s.isOrg && !currentAccess.value.find(a => a.orgId === s.orgId)) {
      filtered.push(s)
    }
  })

  return filtered
})

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
    updatedAccess: [],
    deletedAccess: []
  }

  if (newAccess.value.updated) {
    //check new share doesn't already have it shared
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

    if (i.deleted) {
      payload.deletedAccess.push({id: i.id})
    }
  })

  if (Object.keys(payload).length > 0) {
    try {
      store.commit(AppMutations.SET_LOADING, true)
      await postRequest(`/smartlist/${props.smartlist.id}/access`, {...payload, smartlistId: props.smartlist.id})

      if (payload.updatePublic && payload.public) {
        snackbar('SUCCESS', `Smartlist made public`)
      }
      else {
        snackbar('SUCCESS', `Access updated`)
      }

      emit('dialog-closed')
      if (props.smartlist.public !== isPublic.value) {
        emit('updated-public', isPublic.value)
      }
    } catch (err) {
      logError(err)
      snackbar('ERROR', 'Error while sharing Smartlist')
    } finally {
      handleHidingGlobalLoader(vueInstance, true)
    }
  } else {
    snackbar('SUCCESS', `Access updated`)
    emit('dialog-closed')
  }
}

const confirmOwnershipChange = async (accessLevel) => {
  openOwnershipDialog.value = true
  newOwner.value = accessLevel
}

const updateOwner = async () => {
  try {
    store.commit(AppMutations.SET_LOADING, true)
    await putRequest(`/smartlist/${props.smartlist.id}/owner`, newOwner.value)
    snackbar('SUCCESS', `Ownership successfully transferred`)
    emit('dialog-closed')
    emit('updated-owner', {
      name: newOwner.value.name,
      position: newOwner.value.position,
      userId: newOwner.value.userId,
      userPositionId: newOwner.value.userPositionId,
      smartlistId: props.smartlist.id
    })
  } catch (err) {
    logError(err)
    snackbar('ERROR', 'Error while transferring ownership')
  } finally {
    handleHidingGlobalLoader(vueInstance, true)
  }
}

const markDeleted = (accessLevel) => {
  //find index in the non-filtered array
  const index = currentAccess.value.findIndex(i => i.id === accessLevel.id)

  currentAccess.value.splice(index, 1, {
    ...currentAccess.value[index],
    updated: false,
    deleted: true
  })
}

const closeDialog = () => {
  emit('dialog-closed')
};

getSharables()
getAccessLevels()
getSmartlistAccess()
</script>

<style scoped lang="scss">

.title {
  color: var(--v-primary-base);
}

.new-owner-name {
  border-bottom: 1px solid black;
}

.position {
  font-size: 12px;
  color: rgba(0, 0, 0, 0.54);
}
</style>
