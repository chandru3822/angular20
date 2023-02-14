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
<!--        <v-btn-->
<!--          v-if="!hideConfirm"-->
<!--          color="primary"-->
<!--          class="white&#45;&#45;text elevation-2 text-capitalize mr-2 mb-2"-->
<!--          :disabled="disableConfirm"-->
<!--          :class="confirmClass"-->
<!--          @click="yes">-->
<!--          Share-->
<!--        </v-btn>-->
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>

import { getRequest } from '@/helpers/helpers'
import { ref } from 'vue'

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
  const {data} = await getRequest(`/smartlist/sharableEntities`)
  sharables.value = data
}

//append position to name if the sharable item is a user
const getSharableText = (sharable) => (sharable.isUser) ? `${sharable.name} - ${sharable.position}` : sharable.name

const addSharable = (sharable) => {
  console.log(sharable)
  //append to items this smartlist is shared with
}

getSharables()
</script>

<style scoped lang="scss">

</style>