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
          :item-text="getSharableText"
          return-object
          @input="addSharable"
        ></v-autocomplete>

        <v-checkbox
          v-model="smartlist.isPublic"
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
          @click="addSharable"
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

//a list of user positions and orgs the smartlist is CURRENTLY shared with
let shares = ref([])

const getSharables = async () => {
  const {data} = await getRequest(`/smartlist/sharables`)
  sharables.value = data
}

//append position to name if the sharable item is a user
const getSharableText = (sharable) => (sharable.isUser) ? `${sharable.name} - ${sharable.position}` : sharable.name

const addSharable = async (sharable) => {

  let snackbar

  try {
    store.commit(AppMutations.SET_LOADING, true)
    const {data} = await postRequest(`/smartlist/${props.smartlist.id}/share`, {...sharable, smartlistId: props.smartlist.id})
    snackbar = getSnackbar('SUCCESS', `Smartlist Successfully Shared`)
  } catch (err) {
    logError(err)
    snackbar = getSnackbar('ERROR', 'Error while Sharing Smartlist')
  } finally {
    handleHidingGlobalLoader(vueInstance, true)
    store.commit(AppMutations.SHOW_SNACK, snackbar)
  }
}

getSharables()
</script>

<style scoped lang="scss">

</style>