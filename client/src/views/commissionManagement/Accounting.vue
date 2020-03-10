<template>
  <v-container>
    <v-row>
      <v-col>
        ACCOUNTING
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Accounting',
    components: {
      Snackbar
    },
    data() {
      return {
        snackbar: {},
      }
    },
    methods: {}
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

