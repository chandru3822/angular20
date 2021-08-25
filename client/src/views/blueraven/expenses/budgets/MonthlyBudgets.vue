<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        Monthly here
      </v-col>
    </v-row>

  </v-container>
</template>

<script>

import {AppMutations} from '@/stores/AppStore'
import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

export default {
  name: 'MonthlyBudgets',

  computed: {},
  data() {
    return {
      snackbar: {}
    }
  },
  methods: {}
}
</script>
